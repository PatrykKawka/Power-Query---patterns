// ============================================================
// NAZWA: Ręczne dodawanie rekordów do tabeli
// KATEGORIA: Kolumny i transformacje
// FOLDING: NIE — Table.InsertRows jest operacją czysto lokalną
// ZŁOŻONOŚĆ: O(n) — n = liczba dodawanych wierszy
// WYMAGANIA WEJŚCIOWE: brak (działa na dowolnej tabeli)
// ============================================================

let
    // PARAMETRY
    SourceTable = #"Poprzedni krok",

    NewRows = {
        [Aranzacja = "S-G"],
        [Aranzacja = "X-Y"]
    },

    InsertedRows =
        Table.InsertRows(
            SourceTable,
            Table.RowCount(SourceTable),
            NewRows
        )
in
    InsertedRows

// WARIANTY listy NewRows:

// a) 1 kolumna, 1 rekord
// NewRows = {
//     [Aranzacja = "S-G"]
// }

// b) 1 kolumna, 2 rekordy
// NewRows = {
//     [Aranzacja = "S-G"],
//     [Aranzacja = "A-B"]
// }

// c) Wiele kolumn, 1 rekord
// NewRows = {
//     [
//         Aranzacja = "S-G",
//         Kategoria = "Premium",
//         Aktywna   = true
//     ]
// }

// d) Wiele kolumn, 2 rekordy
// NewRows = {
//     [
//         Aranzacja = "S-G",
//         Kategoria = "Premium",
//         Aktywna   = true
//     ],
//     [
//         Aranzacja = "X-Y",
//         Kategoria = "Standard",
//         Aktywna   = false
//     ]
// }

// UWAGA: każdy rekord w NewRows musi mieć te same nazwy pól co kolumny
// w SourceTable — brakujące pole zostanie wypełnione null, ale nadmiarowe
// pole (którego nie ma w tabeli źródłowej) spowoduje błąd.
