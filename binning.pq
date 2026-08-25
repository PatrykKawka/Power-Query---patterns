// ============================================================
// NAZWA: Kolumna z przedziałami (binning)
// KATEGORIA: Kolumny i transformacje
// FOLDING: NIE — logika each z wieloma krokami wewnątrz zwykle przerywa folding;
//          sam Number.IntegerDivide bywa foldowalny, ale konkatenacja tekstu już nie
// ZŁOŻONOŚĆ: O(1) na wiersz (warianty a, b); O(log k) / O(k) na wiersz dla wariantu
//            z granicami niestandardowymi (k = liczba granic)
// WYMAGANIA WEJŚCIOWE: kolumna liczbowa (przykład używa [Wiek] / [Wartość])
// ============================================================

// 1. Koszyki o STAŁEJ szerokości przedziałów — Number.IntegerDivide

= Table.AddColumn(
    Source,
    "Koszyk wieku",
    each
        let
            Start = Number.IntegerDivide([Wiek], 10) * 10,
            End = Start + 9
        in
            Text.From(Start) & "-" & Text.From(End),
    type text
)

// Wzór uniwersalny — szerokość koszyka w zmiennej Width, łatwa do zmiany w 1 miejscu:
// let
//     Width = 10,
//     Start = Number.IntegerDivide([Wartość], Width) * Width,
//     End = Start + Width - 1
// in
//     Text.From(Start) & "-" & Text.From(End)


// 2a. Koszyki o RÓŻNEJ szerokości — kilka przedziałów, ręczny if-else
// POPRAWKA: ostatnia gałąź opisywała ">30", a logicznie (po przejściu warunków
// >=65, >=45, >=30) obejmuje wartości PONIŻEJ 30 — etykieta była odwrócona.

let
    zmienna = [kolumna]
in
    if zmienna >= 65 then "65+"
    else if zmienna >= 45 then "45-64"
    else if zmienna >= 30 then "30-44"
    else "<30"


// 2b. Koszyki o różnej szerokości — wersja dynamiczna dla większej liczby
// przedziałów, sterowana listą granic (bez łańcucha if-else)

= Table.AddColumn(
    Source,
    "Koszyk wieku",
    each
        let
            Age = [Wiek],
            Boundaries = {0, 19, 28, 31, 41, 51, 66, 101},
            ValidBoundaries =
                List.Select(
                    Boundaries,
                    each _ <= Age
                ),
            Start =
                List.Last(ValidBoundaries),
            Position =
                List.PositionOf(
                    Boundaries,
                    Start
                ),
            End =
                Boundaries{Position + 1} - 1
        in
            Text.From(Start) & "-" & Text.From(End),
    type text
)

// UWAGA do wariantu 2b: jeśli Age jest mniejszy niż pierwsza granica (0) lub
// większy/równy ostatniej granicy (101), ValidBoundaries może być pustą listą
// albo Position+1 wyjdzie poza zakres — warto dodać na wejściu walidację
// (np. Table.SelectRows odfiltrowujące wartości spoza [0, 100]) albo opakować
// całość w `try ... otherwise "poza zakresem"`.
