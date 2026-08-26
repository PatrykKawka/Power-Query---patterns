//FOLDING: NIE — Table.Group z 'each' na liście przerywa folding
// ZŁOŻONOŚĆ:  (List.Accumulate)    liczy sumę narastającą jednym przebiegiem po liście i zwraca gotową listę wyników   = O(n) w obrębie grupy
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
                            // Jeden przebieg: buduje listę sum narastających
                            RunningList =
                                List.Accumulate(
                                    Sales,
                                    {},
                                    (state, current) =>
                                        state & { (if List.IsEmpty(state) then 0 else List.Last(state)) + current }
                                ),
                            DodajRunningTotal =
                                Table.AddColumn(
                                    Index,
                                    "Running Total",
                                    each RunningList{[ID]},
                                    type number
                                ),
                            UsuńIndex =
                                Table.RemoveColumns(DodajRunningTotal, {"ID"})
                        in
                            UsuńIndex
                }
            }
        ),
    Wynik =
        Table.ExpandTableColumn(Grupowanie, "Dane", {"Data", "Sprzedaż", "Running Total"})
in
    Wynik
