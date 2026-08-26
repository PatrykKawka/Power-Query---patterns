// FOLDING: CZĘŚCIOWO — Table.SelectColumns zwykle folduje się (odpowiednik SELECT  z listą kolumn); logika budowania listy nazw jest lokalna, ale nie   wpływa na folding samego SelectColumns
// ZŁOŻONOŚĆ: O(k) — k = liczba wybieranych kolumn
// WYMAGANIA WEJŚCIOWE: brak — działa na dowolnej tabeli; Power Query indeksuje kolumny i listy od 0
// ============================================================

let
    Nazwy_kolumn = Table.ColumnNames(Source),
    WybraneKolumny =
        List.Combine(
            {
                List.Range(Nazwy_kolumn, 1, 13),
                {Nazwy_kolumn{15}},              // <- pojedyncza kolumna opakowana w listę
                {Nazwy_kolumn{20}},
                List.Range(Nazwy_kolumn, 23, 3)
            }
        ),
    Wynik = Table.SelectColumns(Source, WybraneKolumny)
in
    Wynik

// Można też wybierać pierwsze/ostatnie N lub pomijać wybrane kolumny:

// a) pierwsze 5 kolumn — FirstN
Table.SelectColumns(
    Source,
    List.FirstN(Table.ColumnNames(Source), 5)
)

// b) zakres kolumn — od pozycji 5, weź 8 kolejnych (indeksy 5-12)
Table.SelectColumns(
    Source,
    List.Range(Table.ColumnNames(Source), 5, 8)
)

// c) wszystkie poza 3 pierwszymi
Table.SelectColumns(
    Source,
    List.Skip(Table.ColumnNames(Source), 3)
)

// d) wszystkie poza dwiema ostatnimi
Table.SelectColumns(
    Source,
    List.RemoveLastN(Table.ColumnNames(Source), 2)
)
