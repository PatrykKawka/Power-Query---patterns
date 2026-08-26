// FOLDING: NIE — Text.PositionOf w pętli po liście ograniczników jest operacją lokalną
// ZŁOŻONOŚĆ: O(d) na wiersz — d = liczba możliwych ograniczników
// WYMAGANIA WEJŚCIOWE: kolumna tekstowa [kolumna] / [Dane]
// ============================================================

// 1. Podział kolumny — kilka możliwych ograniczników na raz. Gdy kolumna może zawierać różne separatory, przekaż je jako listę.

= Table.SplitColumn(
    Source,
    "kolumna",
    Splitter.SplitTextByAnyDelimiter({" - ", " / ", " | "}, QuoteStyle.Csv),
    {"kolumna1", "kolumna2"}
)

// 2. Tekst PRZED pierwszym występującym ogranicznikiem (spośród kilku możliwych)
// Text.BeforeDelimiter działa tylko dla jednego, znanego z góry ogranicznika — dla wielu możliwych trzeba najpierw znaleźć pozycję najbliższego.

= Table.AddColumn(
    Source,
    "Przed ogranicznikiem",
    each
        let
            TextValue = [Dane],
            Positions =
                List.Transform(
                    {" - ", " / ", " | "},
                    each Text.PositionOf(TextValue, _, Occurrence.First)
                ),
            ValidPositions = List.Select(Positions, each _ >= 0),
            Position =
                if List.IsEmpty(ValidPositions) then
                    -1
                else
                    List.Min(ValidPositions)
        in
            if Position = -1 then
                TextValue
            else
                Text.Start(TextValue, Position),
    type text
)

// 3. Tekst PO pierwszym występującym ograniczniku (spośród kilku możliwych)
// Analogicznie, ale trzeba dodatkowo ustalić, KTÓRY ogranicznik wystąpił jako pierwszy, żeby wiedzieć ile znaków pominąć.

= Table.AddColumn(
    Source,
    "Po ograniczniku",
    each
        let
            TextValue = [Dane],
            Delimiters = {" - ", " / ", " | "},
            Positions =
                List.Transform(
                    Delimiters,
                    each Text.PositionOf(TextValue, _, Occurrence.First)
                ),
            ValidPositions = List.Select(Positions, each _ >= 0),
            Position =
                if List.IsEmpty(ValidPositions) then
                    -1
                else
                    List.Min(ValidPositions),
            Delimiter =
                if Position = -1 then
                    null
                else
                    List.First(
                        List.Select(
                            List.Zip({Positions, Delimiters}),
                            each _{0} = Position
                        )
                    ){1}
        in
            if Position = -1 then
                null
            else
                Text.AfterDelimiter(TextValue, Delimiter),
    type text
)
