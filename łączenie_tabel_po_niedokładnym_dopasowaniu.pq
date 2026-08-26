// FOLDING: NIE, NIGDY — fuzzy matching to algorytm czysto lokalny
// ZŁOŻONOŚĆ: znacząco większa niż zwykły join (porównania przybliżone między
//            wieloma parami wierszy) — kosztowne obliczeniowo
// WYMAGANIA WEJŚCIOWE: dwie tabele z kolumną tekstową do dopasowania
// CASE USE: łączysz dane sprzedażowe z listą klientów z innego systemu, gdzie nazwy firm są wpisane niespójnie ("ABC Sp. z o.o." vs "ABC sp zoo").
// ============================================================

let
    Source = SprzedażTabela,
    Klienci = KlienciTabela,
    FuzzyMerge =
        Table.FuzzyNestedJoin(
            Source, {"NazwaKlienta"},
            Klienci, {"NazwaKlienta"},
            "DopasowanieKlienta",
            JoinKind.LeftOuter,
            [
                IgnoreCase = true,
                IgnoreSpace = true,
                Threshold = 0.8  // 0-1, im niżej tym bardziej "luźne" dopasowanie
            ]
        ),
    Rozwinięcie =
        Table.ExpandTableColumn(FuzzyMerge, "DopasowanieKlienta", {"IDKlienta"})
in
    Rozwinięcie

// ZASTRZEŻENIE WYDAJNOŚCIOWE: fuzzy merge nie folduje się nigdy i jest kosztowny obliczeniowo — sensowny na dziesiątkach tysięcy wierszy, nie milionach. Dla dużych wolumenów zawęź zbiór PRZED fuzzy matchem (np. po pierwszej literze nazwy albo mieście), żeby ograniczyć liczbę porównywanych par.
