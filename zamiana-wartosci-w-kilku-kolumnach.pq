// ============================================================
// NAZWA: Zamiana wartości (0/1 → TAK/NIE) w kilku kolumnach jednocześnie
// KATEGORIA: Kolumny i transformacje
// FOLDING: TAK — proste CASE WHEN foldują się do SQL Server / BigQuery
// ZŁOŻONOŚĆ: O(k) kolumn, O(1) na wiersz na kolumnę
// WYMAGANIA WEJŚCIOWE: kolumny liczbowe/logiczne z wartościami 0/1
// ============================================================

= Table.TransformColumns(
    #"Poprzedni krok",
    {
        {"Kolumna1", each if _ = 0 then "NIE" else if _ = 1 then "TAK" else _, type text},
        {"Kolumna2", each if _ = 0 then "NIE" else if _ = 1 then "TAK" else _, type text},
        {"Kolumna3", each if _ = 0 then "NIE" else if _ = 1 then "TAK" else _, type text}
    }
)

// WARIANT skalowalny — gdy lista kolumn do zamiany jest dłuższa niż 3-4,
// wygodniej wygenerować specyfikację dynamicznie zamiast powtarzać ten sam
// wyraz `each if...` dla każdej kolumny z osobna:

= Table.TransformColumns(
    #"Poprzedni krok",
    List.Transform(
        {"Kolumna1", "Kolumna2", "Kolumna3"},  // <- lista kolumn do zamiany
        each {
            _,
            (x) => if x = 0 then "NIE" else if x = 1 then "TAK" else x,
            type text
        }
    )
)
