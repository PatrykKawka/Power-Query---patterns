// FOLDING: NIE — parsowanie tekstu i budowa daty przez #date() w 'each' jest lokalne
// ZŁOŻONOŚĆ: O(1) na wiersz
// WYMAGANIA WEJŚCIOWE: kolumna tekstowa w formacie "RRRR/MM", np. [rok/mc] = "2026/03"
// ============================================================

= Table.AddColumn(
    #"Poprzedni_Krok",
    "Data",
    each
        #date(
            Number.FromText(Text.BeforeDelimiter([#"rok/mc"], "/")),
            Number.FromText(Text.AfterDelimiter([#"rok/mc"], "/")),
            1  // <- dzień miesiąca; zmień na własną logikę, jeśli inny niż "1"
        ),
    type date
)

