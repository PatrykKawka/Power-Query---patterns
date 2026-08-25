// ============================================================
// NAZWA: Grupowanie z łączeniem wartości tekstowych po przecinku (string agg)
// KATEGORIA: Grupowanie i funkcje okienkowe
// FOLDING: NIE — Text.Combine/List.Distinct w 'each' są operacjami lokalnymi
// ZŁOŻONOŚĆ: O(n) na grupę
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [ID_autoryzacji], [ID_zdarzenia], [Zdarzenie]
// ============================================================
//
// POPRAWKA względem oryginału: List.Distinct nie przyjmuje separatora jako
// drugiego argumentu (to sygnatura Text.Combine) — oryginał mylił obie funkcje
// i miał niedomknięty nawias. Poprawnie: najpierw List.Distinct (bez argumentu
// separatora), dopiero wynik przekazać do Text.Combine.

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
