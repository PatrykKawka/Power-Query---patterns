
// FOLDING: NIE — Text.Split/List.Distinct na poziomie komórki są operacjami lokalnymi
// ZŁOŻONOŚĆ: O(m log m) na wiersz — m = liczba elementów w komórce
// WYMAGANIA WEJŚCIOWE: kolumna tekstowa z wartościami rozdzielonymi przecinkiem, np. [Kategorie sprzedaży] = "B2B, B2B, Retail, retail "
// ============================================================
let
    Źródło = ...,  // wczytaj dane źródłowe
    Rozdzielone = Table.TransformColumns(Źródło, {"Kategorie sprzedaży", each Text.Split(_, ","), type list}),
    UsunięcieSpacji = Table.TransformColumns(Rozdzielone, {"Kategorie sprzedaży", each List.Transform(_, Text.Trim)}),
    NormalizacjaWielkosciLiter = Table.TransformColumns(UsunięcieSpacji, {"Kategorie sprzedaży", each List.Transform(_, Text.Proper)}),
    UsunięcieDuplikatów = Table.TransformColumns(NormalizacjaWielkosciLiter, {"Kategorie sprzedaży", each List.Distinct(_)}),
    Posortowanie = Table.TransformColumns(UsunięcieDuplikatów, {"Kategorie sprzedaży", each List.Sort(_, Order.Ascending)}),
    Połączone = Table.TransformColumns(Posortowanie, {"Kategorie sprzedaży", each Text.Combine(_, ", "), type text})
in
    Połączone

