// ============================================================
// NAZWA: Grupowanie i zwracanie pierwszych N rekordów z każdej grupy
// KATEGORIA: Grupowanie i funkcje okienkowe
// FOLDING: NIE — Table.FirstN wewnątrz 'each' po posortowaniu grupy jest lokalne
// ZŁOŻONOŚĆ: O(n log n) na grupę (sortowanie dominuje)
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [Oddział], [Sprzedaż]
// ============================================================

Table.Group(
    Source,
    {"Oddział"},
    {
        {
            "Top3",
            each
                Table.FirstN(
                    Table.Sort(_, {{"Sprzedaż", Order.Descending}}),
                    3
                )
        }
    }
)

// UWAGA: wynik to kolumna zagnieżdżonych tabel (jedna na Oddział).
// Aby dostać płaską listę Top3 wierszy ze wszystkich oddziałów naraz:
//
// Table.Combine(WynikPowyzej[Top3])
