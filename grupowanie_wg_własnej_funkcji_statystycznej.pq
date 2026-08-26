FOLDING: NIE — funkcje List.StandardDeviation/List.Median wywołane w 'each'
//          nie mają odpowiednika w natywnym zapytaniu SQL/BigQuery generowanym
//          przez Power Query, więc ten krok zawsze przerywa folding
// ZŁOŻONOŚĆ: O(n) na grupę dla większości funkcji List.*
// WYMAGANIA WEJŚCIOWE: tabela z kolumnami [Oddział], [Sprzedaż]
// ============================================================

// Domyślny interfejs grupowania w Power Query oferuje tylko: Sum, Count, Min, Max, Median, All Rows. Więcej statystyk — trzeba dopisać w edytorze M.

// a) Odchylenie standardowe
Table.Group(
    Source,
    {"Oddział"},
    {
        {"STD", each List.StandardDeviation([Sprzedaż]), type number}
    }
)

// b) Rozstęp (max - min)
Table.Group(
    Source,
    {"Oddział"},
    {
        {"Rozstęp", each List.Max([Sprzedaż]) - List.Min([Sprzedaż]), type number}
    }
)

// c) Współczynnik zmienności (CV = odchylenie std / średnia)
Table.Group(
    Source,
    {"Oddział"},
    {
        {
            "CV",
            each List.StandardDeviation([Sprzedaż]) / List.Average([Sprzedaż]),
            Percentage.Type
        }
    }
)

// d) Kilka statystyk naraz jako jeden rekord (potem Table.ExpandRecordColumn)
Table.Group(
    Source,
    {"Oddział"},
    {
        {
            "Statystyki",
            each
                [
                    Min    = List.Min([Sprzedaż]),
                    Max    = List.Max([Sprzedaż]),
                    Avg    = List.Average([Sprzedaż]),
                    Median = List.Median([Sprzedaż]),
                    STD    = List.StandardDeviation([Sprzedaż]),
                    Count  = Table.RowCount(_)
                ]
        }
    }
)
