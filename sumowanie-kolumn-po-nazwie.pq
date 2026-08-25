// ============================================================
// NAZWA: Sumowanie wartości z kilku kolumn zawierających określony fragment nazwy
// KATEGORIA: Kolumny dynamiczne
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

// Rozbicie logiki krok po kroku:
// Table.ColumnNames(Source)                    → lista wszystkich kolumn
// List.Select(..., Text.Contains(...))          → zostaw tylko te zawierające "partner"
//                                                  (Text.Lower ujednolica wielkość liter)
// Record.SelectFields(_, ...)                   → z bieżącego wiersza wybierz tylko te pola
// Record.ToList(...)                            → zamień wartości pól na listę
// List.Sum(...)                                 → zsumuj
//
// Działa dynamicznie: gdy w źródle pojawi się nowa kolumna "Partner Q3",
// zostanie automatycznie uwzględniona w sumie bez zmiany kodu.
