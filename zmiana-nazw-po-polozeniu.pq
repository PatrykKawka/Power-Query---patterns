// ============================================================
// NAZWA: Zmiana nazw kolumn na podstawie ich położenia (indeksu)
// KATEGORIA: Kolumny dynamiczne
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

// Przydatne przy plikach źródłowych, gdzie nagłówki są niestabilne
// (puste, zduplikowane, wygenerowane automatycznie), ale pozycja kolumny
// jest stała między odświeżeniami.
