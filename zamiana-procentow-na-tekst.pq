// ============================================================
// NAZWA: Zamiana kolumn procentowych na tekst (dynamicznie po nazwie kolumny)
// KATEGORIA: Kolumny i transformacje
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

// Jak to czytać:
// - ProcentoweKolumny: filtruje nazwy kolumn zawierające "%" (np. "Marża %")
// - List.Transform buduje dynamicznie listę specyfikacji transformacji
//   {nazwa_kolumny, funkcja, typ_docelowy} — dokładnie w formacie, jakiego
//   oczekuje drugi argument Table.TransformColumns
// - działa niezależnie od tego, ile kolumn procentowych ma tabela i jak się nazywają
