// ============================================================
// NAZWA: Zamiana wartości w kolumnie na zasadzie słownika (3 warianty)
// KATEGORIA: Jakość danych i błędy
// FOLDING: Szablon 1 i 2 — NIE (logika w 'each' na poziomie wartości)
//          Szablon 3 — CZĘŚCIOWO, jeśli TabelaMapowan jest osobnym query
//          wskazującym na tabelę SQL/BigQuery, Table.NestedJoin może się foldować
// ZŁOŻONOŚĆ: Szablon 1/2 — O(k) na wiersz (k = rozmiar słownika, dla Szablonu 2 O(1)
//            dzięki Record.HasFields); Szablon 3 — zależny od implementacji joina,
//            zwykle O(n log n) lub lepiej
// WYMAGANIA WEJŚCIOWE: kolumna tekstowa [NazwaKolumny] do zamiany
// ============================================================
//
// KIEDY KTÓREGO UŻYĆ:
// Szablon 1 (List.PositionOf) — codzienne użycie, do ~20 zamian. Dwie równoległe
// listy, jeden krok w zapytaniu, żadnej pętli ani zagnieżdżonych if-else.
//
// Szablon 2 (Record.Field) — gdy wolisz parę klucz=wartość zamiast dwóch list.
// Pułapka: klucze rekordu muszą być poprawnymi identyfikatorami M — spacje
// i znaki specjalne wymagają notacji #"wartość ze spacją".
//
// Szablon 3 (join z tabelą) — gdy słownik zamian jest duży, współdzielony między
// wieloma zapytaniami albo pochodzi z zewnętrznego źródła. TabelaMapowan jako
// osobne zapytanie Power Query = "single source of truth": edytujesz w jednym
// miejscu, zmiana propaguje się wszędzie, gdzie zapytanie jest referencjonowane.


// --- Szablon 1 ---
// POPRAWKA: w oryginale brakowało domykającego nawiasu Table.TransformColumns.
let
    StareWartosci = {"wartość_1", "wartość_2", "wartość_3"},
    NoweWartosci  = {"nowa_1",    "nowa_2",    "nowa_3"},

    Wynik =
        Table.TransformColumns(
            poprzedni_krok,
            {{
                "NazwaKolumny",
                each
                    let idx = List.PositionOf(StareWartosci, _)
                    in  if idx = -1
                        then _                    // wartość niezmieniona, gdy brak w słowniku
                        else NoweWartosci{idx},
                type text                          // zmień typ wyjściowy wg potrzeby
            }}
        )
in
    Wynik


// --- Szablon 2 ---
let
    Slownik = [
        wartość_1 = "nowa_1",
        wartość_2 = "nowa_2",
        wartość_3 = "nowa_3"
    ],

    Wynik =
        Table.TransformColumns(
            poprzedni_krok,
            {{
                "NazwaKolumny",
                each
                    if Record.HasFields(Slownik, _)
                    then Record.Field(Slownik, _)
                    else _,                         // wartość niezmieniona, gdy brak w słowniku
                type text
            }}
        )
in
    Wynik


// --- Szablon 3 ---
// POPRAWKA: oryginał mieszał kroki NestedJoin/ExpandTableColumn z ręczną próbą
// odtworzenia "coalesce" przez indeksowanie po wartości — niepotrzebnie
// skomplikowane i podatne na błąd przy duplikatach w kolumnie "Nowa". Poniżej
// uproszczona, poprawna wersja: left outer join + wypełnienie braków wartością
// oryginalną (klasyczny wzorzec "zachowaj, gdy brak dopasowania w słowniku").
let
    // Tabela mapowań: dwie kolumny — "Stara" i "Nowa".
    // Może pochodzić z Excela, CSV, bazy danych albo być osobnym zapytaniem
    // Power Query (zalecane — patrz uwaga o "single source of truth" wyżej).
    TabelaMapowan =
        Table.FromRows(
            {
                {"wartość_1", "nowa_1"},
                {"wartość_2", "nowa_2"},
                {"wartość_3", "nowa_3"}
            },
            {"Stara", "Nowa"}
        ),

    ZMerge =
        Table.NestedJoin(
            poprzedni_krok, {"NazwaKolumny"},
            TabelaMapowan,  {"Stara"},
            "_map",
            JoinKind.LeftOuter
        ),

    Rozwin =
        Table.ExpandTableColumn(ZMerge, "_map", {"Nowa"}),

    // Gdy brak dopasowania w słowniku, "Nowa" = null — wtedy zachowaj
    // oryginalną wartość z NazwaKolumny zamiast null.
    Wynik =
        Table.TransformColumns(
            Rozwin,
            {{
                "Nowa",
                each if _ = null then [NazwaKolumny] else _,
                type text
            }}
        )
in
    Wynik
// Po tym kroku: usuń starą kolumnę "NazwaKolumny" i przemianuj "Nowa" → "NazwaKolumny"
// (Table.RemoveColumns + Table.RenameColumns), jeśli chcesz zachować oryginalną nazwę.
