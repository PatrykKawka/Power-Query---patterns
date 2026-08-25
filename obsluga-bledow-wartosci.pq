// ============================================================
// NAZWA: Obsługa błędów wartości po konwersji typu (nie mylić z brakującymi kolumnami)
// KATEGORIA: Jakość danych i błędy
// FOLDING: NIE — Table.ReplaceErrorValues / try...otherwise są operacjami lokalnymi
// ZŁOŻONOŚĆ: O(n) na kolumnę
// WYMAGANIA WEJŚCIOWE: kolumna po Table.TransformColumnTypes, która może
//                       zawierać błędy konwersji (np. tekst w kolumnie liczbowej)
// NOWY WZORZEC — dodany w ramach audytu repo
// ============================================================
//
// CASE USE: jeden z najczęstszych powodów zatrzymania odświeżania w produkcji —
// zmiana formatu w źródle (np. "1 234,56" zamiast "1234.56", albo pojedynczy
// wiersz z wartością tekstową "brak danych" w kolumnie liczbowej) powoduje błąd
// konwersji typu, który bez obsługi przerywa całe odświeżanie raportu.

// a) Zamiana błędów na null — priorytet: ciągłość odświeżania
let
    Source = ...,
    BezpieczneTypy = Table.TransformColumnTypes(Source, {{"Ilość", Int64.Type}}),
    ZamianaBłędówNaNull = Table.ReplaceErrorValues(BezpieczneTypy, {{"Ilość", null}})
in
    ZamianaBłędówNaNull


// b) Wariant z raportowaniem — zachowaj informację, które wiersze miały błąd
// (przydatne do osobnego dashboardu monitorującego jakość danych źródłowych)
let
    Source = ...,
    BezpieczneTypy = Table.TransformColumnTypes(Source, {{"Ilość", Int64.Type}}),
    OznaczBłędy =
        Table.AddColumn(
            BezpieczneTypy,
            "WartośćBezBłędu",
            each try [Ilość] otherwise null,
            type any
        ),
    FlagaBłędu =
        Table.AddColumn(
            OznaczBłędy,
            "MiałBłąd",
            each try ([Ilość] <> null and true) otherwise true,
            type logical
        )
in
    FlagaBłędu


// c) Usunięcie tylko wierszy z błędem w konkretnej kolumnie
// — gdy błędne wiersze są nie do naprawienia i mają zniknąć z analizy
let
    Source = ...,
    BezpieczneTypy = Table.TransformColumnTypes(Source, {{"Ilość", Int64.Type}}),
    UsuńBłędneWiersze = Table.RemoveRowsWithErrors(BezpieczneTypy, {"Ilość"})
in
    UsuńBłędneWiersze

// KIEDY KTÓREGO WARIANTU UŻYĆ:
// (a) szybkie raporty, gdzie liczy się przede wszystkim ciągłość odświeżania
// (b) gdy chcesz osobno monitorować jakość feedu źródłowego (% błędnych wierszy)
// (c) gdy błędne wiersze i tak nie nadają się do analizy
