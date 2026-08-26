// FOLDING: NIE — Table.TransformColumns z funkcją (x)=>... jest lokalne
// ZŁOŻONOŚĆ: O(k * n) — k = liczba kolumn procentowych, n = liczba wierszy
// WYMAGANIA WEJŚCIOWE: kolumny procentowe muszą mieć "%" w nazwie
// ============================================================

let
    ProcentoweKolumny =
        List.Select(
            Table.ColumnNames(POPRZEDNI_KROK),
            each Text.Contains(_, "%")
        ),

    Wynik =
        Table.TransformColumns(
            POPRZEDNI_KROK,
            List.Transform(
                ProcentoweKolumny,
                each {
                    _,
                    (x) =>
                        if x = null then
                            null
                        else
                            Number.ToText(x * 100, "0.00") & "%",
                    type text
                }
            )
        )
in
    Wynik

