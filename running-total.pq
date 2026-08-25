// ============================================================
// NAZWA: Running Total (suma narastająca) wewnątrz grupy
// KATEGORIA: Grupowanie i funkcje okienkowe
// FOLDING: NIE — Table.Group z 'each' na liście przerywa folding
// ZŁOŻONOŚĆ: WERSJA A (List.FirstN/List.Sum per wiersz) = O(n²) w obrębie grupy
//            WERSJA B (List.Accumulate)                  = O(n) w obrębie grupy
//            Dla grup > ~5-10 tys. wierszy różnica jest odczuwalna przy odświeżaniu —
//            używaj WERSJI B.
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [Oddział], [Data], [Sprzedaż]
// ============================================================

// ---------------------------------------------------------------
// WERSJA A (oryginalna) — czytelna, ale O(n²): każdy wiersz przelicza
// sumę od zera zamiast korzystać z wyniku poprzedniego wiersza.
// Zostaw jako wariant referencyjny / do małych grup (<kilka tysięcy wierszy).
// ---------------------------------------------------------------
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
                            Sort = Table.Sort(_, {{"Data", Order.Ascending}}),
                            Index = Table.AddIndexColumn(Sort, "ID", 0, 1, Int64.Type),
                            Sales = Index[Sprzedaż],
                            RunningTotal =
                                Table.AddColumn(
                                    Index,
                                    "Running Total",
                                    each List.Sum(List.FirstN(Sales, [ID] + 1)),
                                    type number
                                ),
                            UsuńIndex = Table.RemoveColumns(RunningTotal, {"ID"})
                        in
                            UsuńIndex
                }
            }
        ),
    Wynik = Table.ExpandTableColumn(Grupowanie, "Dane", {"Data", "Sprzedaż", "Running Total"})
in
    Wynik


// ---------------------------------------------------------------
// WERSJA B (zalecana) — O(n): List.Accumulate liczy sumę narastającą
// jednym przebiegiem po liście i zwraca gotową listę wyników.
// ---------------------------------------------------------------
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
