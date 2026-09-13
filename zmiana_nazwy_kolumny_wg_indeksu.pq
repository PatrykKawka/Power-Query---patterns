// FOLDING: TAK zwykle — Table.RenameColumns jest lekką operacją metadanych
// ZŁOŻONOŚĆ: O(k) — k = liczba zmienianych nazw
// WYMAGANIA WEJŚCIOWE: brak; Power Query indeksuje kolumny od 0
// ============================================================

= Table.RenameColumns(
    Source,
    {
        {Table.ColumnNames(Source){1}, "Nowa nazwa kolumny z indeksem 1"},
        {Table.ColumnNames(Source){15}, "Nowa nazwa kolumny z indeksem 15"}
    }
)

