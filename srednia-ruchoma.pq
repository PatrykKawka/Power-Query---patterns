// ============================================================
// NAZWA: Średnia ruchoma z N ostatnich rekordów wewnątrz grupy
// KATEGORIA: Grupowanie i funkcje okienkowe
// FOLDING: NIE — Table.Group z 'each' na liście przerywa folding
// ZŁOŻONOŚĆ: O(n) w obrębie grupy — okno ma STAŁY rozmiar (max 3 elementy),
//            więc List.Range per wiersz jest tanie i NIE tworzy problemu O(n²)
//            takiego jak w naiwnej wersji Running Total (patrz running-total.pq).
//            To jest kluczowa różnica: okno o stałej długości vs okno narastające.
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [Oddział], [Data], [Sprzedaż]
// ============================================================

let
    Grupowanie =
        Table.Group(
            Source,
            {"Oddział"},
            {
                {
                    "Dane",
                    each
                        let
                            Sort =
                                Table.Sort(_, {{"Data", Order.Ascending}}),

                            Index =
                                Table.AddIndexColumn(Sort, "ID", 0, 1, Int64.Type),

                            Sales =
                                Index[Sprzedaż],

                            MovingAverage =
                                Table.AddColumn(
                                    Index,
                                    "Moving Average",
                                    each
                                        let
                                            Start = Number.Max(0, [ID] - 2),
                                            Window = List.Range(Sales, Start, [ID] - Start + 1)
                                        in
                                            List.Average(Window),
                                    type number
                                ),

                            UsuńIndex =
                                Table.RemoveColumns(MovingAverage, {"ID"})
                        in
                            UsuńIndex
                }
            }
        ),

    Wynik =
        Table.ExpandTableColumn(Grupowanie, "Dane", {"Data", "Sprzedaż", "Moving Average"})
in
    Wynik

// Aby zmienić szerokość okna (np. 5 zamiast 3 ostatnich rekordów),
// zamień "2" w `Number.Max(0, [ID] - 2)` na (N - 1), gdzie N to rozmiar okna.
