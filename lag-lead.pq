// ============================================================
// NAZWA: LAG i LEAD (wartość poprzednia/następna) wewnątrz grupy
// KATEGORIA: Grupowanie i funkcje okienkowe
// FOLDING: NIE — Table.Group z 'each' operującym na indeksowanej liście
//          zawsze przerywa folding do SQL/BigQuery
// ZŁOŻONOŚĆ: O(n) na grupę (dostęp do listy po indeksie to O(1))
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [Oddział], [Data], [Sprzedaż];
//                       dane NIE muszą być posortowane wcześniej — sortowanie
//                       odbywa się wewnątrz każdej grupy
// ============================================================

// Schemat ogólny dla wszystkich wzorców okienkowych w tym folderze:
// Group --> Sort --> AddIndexColumn --> lista wartości --> odwołanie po indeksie
//        --> AddColumn z wynikiem --> ExpandTableColumn na końcu

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
                                Table.Sort(
                                    _,
                                    {{"Data", Order.Ascending}}
                                ),

                            Index =
                                Table.AddIndexColumn(
                                    Sort,
                                    "ID",
                                    0,
                                    1,
                                    Int64.Type
                                ),

                            Sales =
                                Index[Sprzedaż],

                            DodajLag =
                                Table.AddColumn(
                                    Index,
                                    "LAG",
                                    each
                                        if [ID] = 0 then
                                            null
                                        else
                                            Sales{[ID] - 1},
                                    type number
                                ),

                            DodajLead =
                                Table.AddColumn(
                                    DodajLag,
                                    "LEAD",
                                    each
                                        if [ID] = List.Count(Sales) - 1 then
                                            null
                                        else
                                            Sales{[ID] + 1},
                                    type number
                                ),

                            UsuńIndex =
                                Table.RemoveColumns(
                                    DodajLead,
                                    {"ID"}
                                )
                        in
                            UsuńIndex
                }
            }
        ),

    Wynik =
        Table.ExpandTableColumn(
            Grupowanie,
            "Dane",
            {"Data", "Sprzedaż", "LAG", "LEAD"}
        )
in
    Wynik
