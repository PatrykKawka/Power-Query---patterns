// ============================================================
// NAZWA: Usuwanie kolumn, które są całe puste
// KATEGORIA: Jakość danych i błędy
// FOLDING: NIE — List.NonNullCount wywoływane per kolumna jest operacją lokalną
// ZŁOŻONOŚĆ: O(k * n) — k = liczba kolumn, n = liczba wierszy (pełny skan tabeli)
// WYMAGANIA WEJŚCIOWE: brak
// ============================================================

let
    Source = ...,
    RemovedEmpty =
        Table.SelectColumns(
            Source,
            List.Select(
                Table.ColumnNames(Source),
                each List.NonNullCount(Table.Column(Source, _)) > 0
            )
        )
in
    RemovedEmpty

// UWAGA WYDAJNOŚCIOWA: dla bardzo szerokich/długich tabel ten wzorzec czyta
// każdą kolumnę w całości, żeby policzyć NonNullCount — przy dużych źródłach
// (miliony wierszy) rozważ ograniczenie sprawdzenia do próbki wierszy
// (np. Table.FirstN(Source, 10000)) zamiast całej tabeli, jeśli akceptowalne
// jest ryzyko false-positive przy rzadko wypełnianych kolumnach.
