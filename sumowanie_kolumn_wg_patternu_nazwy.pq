// FOLDING: NIE — Record.SelectFields/Record.ToList w 'each' są operacjami lokalnymi
// ZŁOŻONOŚĆ: O(k) na wiersz — k = liczba kolumn pasujących do wzorca
// WYMAGANIA WEJŚCIOWE: konwencja nazewnicza kolumn (przykład: "partner" w nazwie)
// ============================================================

= Table.AddColumn(
    Source,
    "partner_suma",
    each
        List.Sum(
            Record.ToList(
                Record.SelectFields(
                    _,
                    List.Select(
                        Table.ColumnNames(Source),
                        each Text.Contains(Text.Lower(_), "partner")
                    )
                )
            )
        ),
    type number
)

