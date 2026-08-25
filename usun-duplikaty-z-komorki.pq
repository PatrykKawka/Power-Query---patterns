// ============================================================
// NAZWA: Usuwanie duplikatów wewnątrz komórki (lista rozdzielona przecinkami) i sortowanie
// KATEGORIA: Jakość danych i błędy
// FOLDING: NIE — Text.Split/List.Distinct na poziomie komórki są operacjami lokalnymi
// ZŁOŻONOŚĆ: O(m log m) na wiersz — m = liczba elementów w komórce
// WYMAGANIA WEJŚCIOWE: kolumna tekstowa z wartościami rozdzielonymi przecinkiem,
//                       np. [Kategorie sprzedaży] = "B2B, B2B, Retail, retail "
// ============================================================

let
    Źródło = ...,  // wczytaj dane źródłowe
    Rozdzielone =
        Table.TransformColumns(Źródło, {"Kategorie sprzedaży", each Text.Split(_, ","), type list}),
    UsunięcieDuplikatów =
        Table.TransformColumns(Rozdzielone, {"Kategorie sprzedaży", each List.Distinct(_)}),
    UsunięcieSpacji =
        Table.TransformColumns(UsunięcieDuplikatów, {"Kategorie sprzedaży", each List.Transform(_, Text.Trim)}),
    Posortowanie =
        Table.TransformColumns(UsunięcieSpacji, {"Kategorie sprzedaży", each List.Sort(_, Order.Ascending)}),
    Połączone =
        Table.TransformColumns(Posortowanie, {"Kategorie sprzedaży", each Text.Combine(_, ", "), type text})
in
    Połączone

// UWAGA: List.Distinct porównuje wartości PRZED trim — "Retail" i " Retail"
// (ze spacją) są traktowane jako różne wpisy i obie przejdą przez deduplikację.
// Jeśli źródło ma niespójne spacje, przenieś krok UsunięcieSpacji PRZED
// UsunięcieDuplikatów, żeby deduplikacja działała na już oczyszczonych wartościach:
//
// Rozdzielone → UsunięcieSpacji → UsunięcieDuplikatów → Posortowanie → Połączone
