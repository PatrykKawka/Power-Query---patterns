//FOLDING: TAK z definicji — cała logika wykonuje się po stronie serwera,  bo to Ty piszesz SQL, a nie liczysz na to, że GUI go wygeneruje
// ZŁOŻONOŚĆ: zależna wyłącznie od zapytania SQL i indeksów po stronie serwera
// WYMAGANIA WEJŚCIOWE: aktywne połączenie ODBC/natywne do źródła; uprawnienia do wykonania zapytania SQL wprost
// ============================================================


let
    Źródło =
        Sql.Database("nazwa_serwera", "nazwa_bazy"),

    Wynik =
        Value.NativeQuery(
            Źródło,
            "
            SELECT
                o.OddzialID,
                o.Nazwa,
                SUM(f.Sprzedaz) AS SumaSprzedazy,
                COUNT(*) AS LiczbaTransakcji
            FROM dbo.Fakty f
            JOIN dbo.Oddzialy o ON o.OddzialID = f.OddzialID
            WHERE f.Data >= @DataOd
              AND f.Data <  @DataDo
            GROUP BY o.OddzialID, o.Nazwa
            ",
            [DataOd = #date(2026, 1, 1), DataDo = #date(2026, 2, 1)],
            [EnableFolding = true]
        )
in
    Wynik

// UWAGA: parametry w SQL Server podajesz jako @NazwaParametru w treści zapytania,
// a wartości jako rekord w trzecim argumencie Value.NativeQuery — NIE konkatenuj
// wartości ręcznie do stringa SQL (ryzyko SQL injection przy dynamicznych filtrach
// pochodzących np. z parametru Power Query wpisywanego przez użytkownika).
//
// EnableFolding = true pozwala kolejnym krokom M (np. Table.SelectRows,
// Table.SelectColumns dodanym PO tym kroku) nadal foldować się na wierzchu
// tego zapytania — bez tego każdy kolejny krok M i tak wykona się lokalnie.


// --- BIGQUERY ---

let
    Źródło =
        GoogleBigQuery.Database([BillingProject = "nazwa-projektu-gcp"]),

    Wynik =
        Value.NativeQuery(
            Źródło,
            "
            SELECT
                oddzial_id,
                nazwa,
                SUM(sprzedaz) AS suma_sprzedazy,
                COUNT(*) AS liczba_transakcji
            FROM `nazwa-projektu-gcp.zbior_danych.fakty` AS f
            JOIN `nazwa-projektu-gcp.zbior_danych.oddzialy` AS o
                ON o.oddzial_id = f.oddzial_id
            WHERE f.data >= @data_od
              AND f.data <  @data_do
            GROUP BY oddzial_id, nazwa
            ",
            [data_od = #date(2026, 1, 1), data_do = #date(2026, 2, 1)],
            [EnableFolding = true]
        )
in
    Wynik

// RÓŻNICA WZGLĘDEM SQL SERVER: BigQuery standard SQL wymaga backtick ` `wokół pełnej ścieżki tabeli (projekt.zbior_danych.tabela) oraz konwencji
// snake_case dla nazw kolumn — dopasuj do tego, jak wygląda Twoje źródło po stronie BigQuery po migracji.


// --- WARIANT Z PARAMETREM POWER QUERY (dynamiczny zakres dat) ---
// Parametr: DataPoczatkowa (typ: Date)
// Parametr: DataKoncowa (typ: Date)

let
    Źródło = Sql.Database("nazwa_serwera", "nazwa_bazy"),
    Wynik =
        Value.NativeQuery(
            Źródło,
            "SELECT * FROM dbo.Fakty WHERE Data >= @DataOd AND Data < @DataDo",
            [DataOd = DataPoczatkowa, DataDo = DataKoncowa],
            [EnableFolding = true]
        )
in
    Wynik

