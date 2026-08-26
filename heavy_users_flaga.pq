//FOLDING: TAK dla kroków liczących (Table.Distinct, Table.Group z Count) — w odróżnieniu od wzorców z List.Distinct w 'each', ten wzorzec NIE przerywa foldingu, o ile źródło (fact_Wizyty) samo się folduje
// ZŁOŻONOŚĆ: O(n log n) po stronie silnika (dystynkcja + grupowanie) —  tania operacja na serwerze, znacznie tańsza niż liczenie  List.Distinct per klient w M
// WYMAGANIA WEJŚCIOWE: fact_Wizyty z kolumną klucza klienta [IDKlienta]  oraz albo gotową kolumną [rok/mc], albo [Data]; dim_Klienci z kolumną [IDKlienta] do dołączenia flagi
// PARAMETR: ProgHeavyUser (typ: liczba całkowita, domyślnie 3) — próg liczby różnych miesięcy wymaganych do statusu Heavy User
// ============================================================

// --- WARIANT A: masz już kolumnę [rok/mc] w fact_Wizyty ---

let
    Źródło = fact_Wizyty,

    // 1) Zredukuj do unikalnych par klient-miesiąc — SELECT DISTINCT po stronie serwera
    UnikalneKlientMiesiac =
        Table.Distinct(
            Table.SelectColumns(Źródło, {"IDKlienta", "rok/mc"})
        ),

    // 2) Policz liczbę różnych miesięcy na klienta — GROUP BY COUNT po stronie serwera
    LiczbaMiesiecy =
        Table.Group(
            UnikalneKlientMiesiac,
            {"IDKlienta"},
            {{"LiczbaMiesiecy", each Table.RowCount(_), Int64.Type}}
        ),

    // 3) Flaga Heavy User
    DodajFlage =
        Table.AddColumn(
            LiczbaMiesiecy,
            "CzyHeavyUser",
            each [LiczbaMiesiecy] >= ProgHeavyUser,
            type logical
        )
in
    DodajFlage


// --- WARIANT B: liczysz na podstawie [Data], bo nie masz kolumny [rok/mc] ---

let
    Źródło = fact_Wizyty,

    // Dodaj klucz miesiąca z daty — RRRRMM jako liczba
    DodajRokMiesiac =
        Table.AddColumn(
            Źródło,
            "RokMiesiac",
            each Date.Year([Data]) * 100 + Date.Month([Data]),
            Int64.Type
        ),

    UnikalneKlientMiesiac =
        Table.Distinct(
            Table.SelectColumns(DodajRokMiesiac, {"IDKlienta", "RokMiesiac"})
        ),

    LiczbaMiesiecy =
        Table.Group(
            UnikalneKlientMiesiac,
            {"IDKlienta"},
            {{"LiczbaMiesiecy", each Table.RowCount(_), Int64.Type}}
        ),

    DodajFlage =
        Table.AddColumn(
            LiczbaMiesiecy,
            "CzyHeavyUser",
            each [LiczbaMiesiecy] >= ProgHeavyUser,
            type logical
        )
in
    DodajFlage


// --- DOŁĄCZENIE FLAGI DO dim_Klienci (merge) ---

let
    HeavyUsers = DodajFlage,  // <- wynik z Wariantu A lub B

    Merge =
        Table.NestedJoin(
            dim_Klienci, {"IDKlienta"},
            HeavyUsers,   {"IDKlienta"},
            "_hu",
            JoinKind.LeftOuter
        ),

    Rozwin =
        Table.ExpandTableColumn(Merge, "_hu", {"LiczbaMiesiecy", "CzyHeavyUser"}),

    // Klienci bez żadnej wizyty w fact_Wizyty dostają null po lewym joinie —
    // zamień na 0 / false, żeby flaga była jednoznaczna w całej tabeli wymiaru
    UzupelnijBraki =
        Table.TransformColumns(
            Rozwin,
            {
                {"LiczbaMiesiecy", each _ ?? 0, Int64.Type},
                {"CzyHeavyUser", each _ ?? false, type logical}
            }
        )
in
    UzupelnijBraki


// ============================================================
// WARIANT C: Heavy User = TEN SAM ODDZIAŁ odwiedzony w N różnych miesiącach
// (odmienny od Wariantów A/B, gdzie liczyły się miesiące łącznie, niezależnie
// od tego, ile różnych oddziałów klient odwiedził)
// WYMAGANIA WEJŚCIOWE: fact_Wizyty z [IDKlienta], [OddzialID] oraz [rok/mc]/[Data]
// ============================================================

let
    Źródło = fact_Wizyty,

    // (opcjonalnie, jeśli liczysz z [Data] a nie z gotowej kolumny [rok/mc])
    DodajRokMiesiac =
        Table.AddColumn(
            Źródło,
            "RokMiesiac",
            each Date.Year([Data]) * 100 + Date.Month([Data]),
            Int64.Type
        ),

    // 1) Unikalne trójki klient-oddział-miesiąc — SELECT DISTINCT po stronie serwera
    UnikalneKlientOddzialMiesiac =
        Table.Distinct(
            Table.SelectColumns(DodajRokMiesiac, {"IDKlienta", "OddzialID", "RokMiesiac"})
        ),

    // 2) Policz liczbę różnych miesięcy NA PARĘ klient-oddział — GROUP BY COUNT
    LiczbaMiesiecyNaOddzial =
        Table.Group(
            UnikalneKlientOddzialMiesiac,
            {"IDKlienta", "OddzialID"},
            {{"LiczbaMiesiecy", each Table.RowCount(_), Int64.Type}}
        ),

    // 3) Flaga na poziomie pary klient-oddział
    DodajFlageOddzial =
        Table.AddColumn(
            LiczbaMiesiecyNaOddzial,
            "CzyHeavyUserOddzial",
            each [LiczbaMiesiecy] >= ProgHeavyUser,
            type logical
        ),

    // 4) Zwinięcie do poziomu klienta — klient może być HU w kilku oddziałach naraz, więc trzeba zdecydować, jak to zagregować do jednego wiersza na klienta.
    // UWAGA: ten krok gubi informację o TYM KONKRETNYM oddziale, w którym klient jest HU (poza przybliżeniem OddzialGlowny) — patrz WARIANT C-BRIDGE niżej, 
    //jeśli potrzebujesz filtrować/krzyżować HU z oddziałem w raportach.
    ZwinDoKlienta =
        Table.Group(
            DodajFlageOddzial,
            {"IDKlienta"},
            {
                // czy klient jest HU w JAKIMKOLWIEK oddziale
                {"CzyHeavyUser", each List.AnyTrue([CzyHeavyUserOddzial]), type logical},

                // w ilu różnych oddziałach osiągnął próg HU (zwykle 0 lub 1, ale może być więcej)
                {"LiczbaOddzialowHU", each List.Sum(List.Transform([CzyHeavyUserOddzial], each if _ then 1 else 0)), Int64.Type},

                // "główny" oddział — ten z największą liczbą odwiedzonych miesięcy
                {
                    "OddzialGlowny",
                    each
                        let
                            Posortowane = Table.Sort(_, {{"LiczbaMiesiecy", Order.Descending}})
                        in
                            Posortowane{0}[OddzialID],
                    type any
                },
                {
                    "LiczbaMiesiecyOddzialGlowny",
                    each
                        let
                            Posortowane = Table.Sort(_, {{"LiczbaMiesiecy", Order.Descending}})
                        in
                            Posortowane{0}[LiczbaMiesiecy],
                    Int64.Type
                }
            }
        )
in
    ZwinDoKlienta


// --- DOŁĄCZENIE WARIANTU C DO dim_Klienci (merge) ---
// Wynik ZwinDoKlienta ma jeden wiersz na IDKlienta — dokładnie tę samą
// granularność co dim_Klienci, więc merge jest analogiczny do Wariantów A/B.
// Stosuj TĘ ścieżkę, jeśli w raportach wystarczy Ci "czy klient JEST heavy
// userem gdziekolwiek" plus opcjonalnie jego oddział główny — bez potrzeby
// filtrowania/krzyżowania HU z konkretnym oddziałem w wizualizacjach.

let
    HeavyUsersOddzial = ZwinDoKlienta,

    Merge =
        Table.NestedJoin(
            dim_Klienci, {"IDKlienta"},
            HeavyUsersOddzial, {"IDKlienta"},
            "_hu_oddzial",
            JoinKind.LeftOuter
        ),

    Rozwin =
        Table.ExpandTableColumn(
            Merge, "_hu_oddzial",
            {"CzyHeavyUser", "LiczbaOddzialowHU", "OddzialGlowny", "LiczbaMiesiecyOddzialGlowny"}
        ),

    UzupelnijBraki =
        Table.TransformColumns(
            Rozwin,
            {
                {"CzyHeavyUser", each _ ?? false, type logical},
                {"LiczbaOddzialowHU", each _ ?? 0, Int64.Type}
                // OddzialGlowny / LiczbaMiesiecyOddzialGlowny zostają null dla
                // klientów bez wizyt — logicznie poprawne, bo nie mają "głównego oddziału"
            }
        )
in
    UzupelnijBraki


// --- WARIANT C-BRIDGE: gdy trzeba filtrować/krzyżować HU z konkretnym oddziałem ---
// Stosuj, gdy raport ma pokazywać np. macierz Oddział × Heavy User, albo "pokaż Heavy Userów oddziału X" — pojedyncza flaga na dim_Klienci (wariant 
//powyżej) nie wystarczy, bo zwija/gubi informację o TYM, w KTÓRYM oddziale
// klient jest HU (poza przybliżeniem OddzialGlowny).
//
// Zamiast zwijać do poziomu klienta (pomiń krok 4 ZwinDoKlienta), dołącz wynik kroku 3 (DodajFlageOddzial — poziom klient-oddział) jako OSOBNĄ
// tabelę pomostową w modelu danych:
//
//   dim_Klienci (1) ---- (*) bridge_KlientOddzialHU (*) ---- (1) dim_Oddzialy
//
// czyli bridge_KlientOddzialHU = DodajFlageOddzial, ładowana do modelu jako
// osobna tabela faktów/pomostowa, powiązana:
// - z dim_Klienci po kluczu IDKlienta
// - z dim_Oddzialy po kluczu OddzialID
//
// Ta tabela zostaje bliżej natywnej granularności faktów (klient-oddział-flaga) i pozwala DAX-owi/wizualizacjom filtrować po dowolnej kombinacji klient
// i/lub oddział bez utraty informacji przy wcześniejszym zwijaniu w Power Query.

BridgeKlientOddzialHU = DodajFlageOddzial  // <- do załadowania jako osobna tabela w modelu


