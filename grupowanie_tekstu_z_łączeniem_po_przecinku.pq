// FOLDING: NIE — Text.Combine/List.Distinct w 'each' są operacjami lokalnymi
// ZŁOŻONOŚĆ: O(n) na grupę
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [ID_autoryzacji], [ID_zdarzenia], [Zdarzenie]
// ============================================================

let
    Źródło = TwojaTabela,

    Grupowanie =
        Table.Group(
            Źródło,
            {"ID_autoryzacji"},
            {
                {
                    "ID_zdarzenia",
                    each Text.Combine(List.Transform([ID_zdarzenia], Text.From), ", "),
                    type text
                },
                {
                    "Zdarzenie_Distinct",
                    each Text.Combine(List.Distinct([Zdarzenie]), ", "),  // <- unikalne wartości po przecinku
                    type text
                }
            }
        )
in
    Grupowanie
