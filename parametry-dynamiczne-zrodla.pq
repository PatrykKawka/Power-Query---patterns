// ============================================================
// NAZWA: Parametry zapytań i dynamiczne źródła (SQL Server / BigQuery / pliki)
// KATEGORIA: Źródła i wydajność
// FOLDING: TAK — zmienna wartość parametru w połączeniu nie wpływa na folding
//          samego zapytania, o ile reszta kroków foldowałaby się i tak
// ZŁOŻONOŚĆ: N/D
// WYMAGANIA WEJŚCIOWE: parametry zdefiniowane w "Zarządzaj parametrami" w Power Query
// NOWY WZORZEC — dodany w ramach audytu repo
// ============================================================
//
// CASE USE: migracja z SQL Server na BigQuery — zamiast wpisywać connection
// string na sztywno w każdym zapytaniu, trzymasz go w parametrze i podmieniasz
// w jednym miejscu (środowisko dev/prod, różne projekty GCP w okresie przejściowym,
// gdy część zapytań działa jeszcze na starym źródle).

// Parametr: ŚrodowiskoDB (typ: Text, wartości sugerowane: "dev", "prod")
// Parametr: ProjektGCP (typ: Text)

let
    Źródło =
        if ŚrodowiskoDB = "prod" then
            GoogleBigQuery.Database([BillingProject = ProjektGCP])
        else
            GoogleBigQuery.Database([BillingProject = ProjektGCP & "-dev"])
in
    Źródło


// Parametr dynamicznej ścieżki plików (np. folder z eksportami miesięcznymi)
// Parametr: ŚcieżkaFolderu (typ: Text)
// Parametr: MiesiącRaportu (typ: Date)

let
    NazwaPliku = "eksport_" & Date.ToText(MiesiącRaportu, "yyyy-MM") & ".xlsx",
    PełnaŚcieżka = ŚcieżkaFolderu & "\" & NazwaPliku,
    Source = Excel.Workbook(File.Contents(PełnaŚcieżka), null, true)
in
    Source

// DLACZEGO TO WAŻNE PRZY MIGRACJI: parametry to jedyny sensowny sposób, by ten
// sam zestaw zapytań działał zamiennie na SQL Server i BigQuery w okresie
// przejściowym — zamiast utrzymywać dwie równoległe wersje plików/zapytań.
