// FOLDING: NIE — Table.Group z 'each' przerywa folding
// ZŁOŻONOŚĆ: O(n log n) na grupę (sortowanie) + O(n) na indeksowanie
// WYMAGANIA WEJŚCIOWE: nazwa kolumny do grupowania i kolumny do sortowania
// ============================================================

let
    Ranking_grupowanie =
        Table.Group(
            #"Poprzedni krok",
            {"KOLUMNA_DO_GRUPOWANIA"},
            {
                {
                    "Dane",
                    each
                        Table.AddIndexColumn(
                            Table.Sort(_, {{"KOLUMNA_DO_SORTOWANIA", Order.Descending}}),
                            "Ranking",
                            1,
                            1,
                            Int64.Type
                        )
                }
            }
        ),

    // Table.Group tworzy zagnieżdżoną strukturę (jedna tabela na grupę) — trzeba połączyć wszystkie podtabele z powrotem w jedną płaską tabelę.
    Wynik_grupowania =
        Table.Combine(Ranking_grupowanie[Dane])
in
    Wynik_grupowania

// UWAGA: Order.Descending oznacza, że ranking 1 = najwyższa wartość w grupie. Dla rankingu rosnącego (1 = najniższa wartość) zmień na Order.Ascending.
