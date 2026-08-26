// FOLDING: CZĘŚCIOWO — Table.SelectColumns zwykle folduje się; logikę wyboru nazw można też łączyć z wyborem po pozycji (patrz plik obok),  bo Table.SelectColumns w drugim argumencie po prostu wymaga listy
// ZŁOŻONOŚĆ: O(k) — k = liczba wszystkich kolumn źródłowych
// WYMAGANIA WEJŚCIOWE: brak
// ============================================================

// a) kolumny zaczynające się od...
Table.SelectColumns(
    Source,
    List.Select(
        Table.ColumnNames(Source),
        each Text.StartsWith(_, "Sprzedaż")
    )
)

// b) kolumny zawierające dany tekst
Table.SelectColumns(
    Source,
    List.Select(
        Table.ColumnNames(Source),
        each Text.Contains(_, "Plan")
    )
)
