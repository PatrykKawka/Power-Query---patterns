// FOLDING: NIE — logika per-wiersz z Record.Field/List.Select jest lokalna
// ZŁOŻONOŚĆ: O(k² ) na wiersz, k = liczba porównywanych kolumn (tu: 5 dni tygodnia) — akceptowalne dla małego, stałego k; nie skalować bezmyślnie na dziesiątki kolumn
// WYMAGANIA WEJŚCIOWE: kolumny [PONIEDZIALEK]..[PIATEK] z wartościami do zliczenia  (np. godziny otwarcia per dzień tygodnia)
// ============================================================

let
    AddMostFrequentColumn =
        Table.AddColumn(
            #"Rozwinięty element Godziny otwarcia",
            "NajczesciejWystepujacaGodzina",
            each
                let
                    CurrentRow = _,

                    ColumnNames = {
                        "PONIEDZIALEK",
                        "WTOREK",
                        "SRODA",
                        "CZWARTEK",
                        "PIATEK"
                    },

                    ValuesList = {
                        [PONIEDZIALEK],
                        [WTOREK],
                        [SRODA],
                        [CZWARTEK],
                        [PIATEK]
                    },
                    NonNullValues = List.RemoveNulls(ValuesList),
                    DistinctValues = List.Distinct(NonNullValues),
                    ValueCounts =
                        List.Transform(
                            DistinctValues,
                            (Value) =>
                                {
                                    Value,
                                    List.Count(List.Select(NonNullValues, each _ = Value)),
                                    List.PositionOf(ValuesList, Value, Occurrence.First)
                                }
                        ),

                    // Sortowanie: 1. liczba wystąpień DESC, 2. pierwsza pozycja ASC
                    SortedValueCounts =
                        List.Sort(
                            ValueCounts,
                            (x, y) =>
                                if x{1} <> y{1} then
                                    y{1} - x{1}
                                else
                                    x{2} - y{2}
                        ),

                    TopValues = List.FirstN(SortedValueCounts, 3),

                    MostFrequentValue        = if List.Count(TopValues) >= 1 then TopValues{0}{0} else null,
                    MostFrequentCount        = if List.Count(TopValues) >= 1 then TopValues{0}{1} else 0,
                    SecondMostFrequentValue  = if List.Count(TopValues) >= 2 then TopValues{1}{0} else null,
                    SecondMostFrequentCount  = if List.Count(TopValues) >= 2 then TopValues{1}{1} else 0,
                    ThirdMostFrequentValue   = if List.Count(TopValues) >= 3 then TopValues{2}{0} else null,
                    ThirdMostFrequentCount   = if List.Count(TopValues) >= 3 then TopValues{2}{1} else 0,

                    GetColumnsForValue =
                        (Value) =>
                            if Value = null then
                                ""
                            else
                                Text.Combine(
                                    List.Select(
                                        ColumnNames,
                                        (ColumnName) => Record.Field(CurrentRow, ColumnName) = Value
                                    ),
                                    ", "
                                ),

                    MostFrequentColumns       = GetColumnsForValue(MostFrequentValue),
                    SecondMostFrequentColumns = GetColumnsForValue(SecondMostFrequentValue),
                    ThirdMostFrequentColumns  = GetColumnsForValue(ThirdMostFrequentValue)
                in
                    [
                        NajczesciejWystepujacaGodzina         = MostFrequentValue,
                        DrugaNajczesciejWystepujacaGodzina    = SecondMostFrequentValue,
                        TrzeciaNajczesciejWystepujacaGodzina  = ThirdMostFrequentValue,

                        LiczbaWystapienNajczesciej = MostFrequentCount,
                        LiczbaWystapienDrugiej     = SecondMostFrequentCount,
                        LiczbaWystapienTrzeciej    = ThirdMostFrequentCount,

                        KolumnaNajczesciej = MostFrequentColumns,
                        KolumnaDrugiej     = SecondMostFrequentColumns,
                        KolumnaTrzeciej    = ThirdMostFrequentColumns
                    ],
            type record
        ),

    ExpandedColumns =
        Table.ExpandRecordColumn(
            AddMostFrequentColumn,
            "NajczesciejWystepujacaGodzina",
            {
                "NajczesciejWystepujacaGodzina",
                "DrugaNajczesciejWystepujacaGodzina",
                "TrzeciaNajczesciejWystepujacaGodzina",
                "LiczbaWystapienNajczesciej",
                "LiczbaWystapienDrugiej",
                "LiczbaWystapienTrzeciej",
                "KolumnaNajczesciej",
                "KolumnaDrugiej",
                "KolumnaTrzeciej"
            }
        )
in
    ExpandedColumns
