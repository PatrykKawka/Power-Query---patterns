let
    // 1. Tabela źródłowa z przykładami umów/rezerwacji
    Source = Table.FromRecords({
        [ID_Umowy = 1, Klient = "Firma A", DataOd = #date(2026, 1, 1), DataDo = #date(2026, 1, 3)],
        [ID_Umowy = 2, Klient = "Firma B", DataOd = #date(2026, 1, 5), DataDo = #date(2026, 1, 6)]
    }),
    SetTypes = Table.TransformColumnTypes(Source, {
        {"ID_Umowy", Int64.Type}, 
        {"Klient", type text}, 
        {"DataOd", type date}, 
        {"DataDo", type date}
    }),

    // 2. KLUCZOWY KROK: Dodanie kolumny z listą wszystkich dat z danego zakresu
    // Number.From() przelicza daty na liczby całkowite, aby obliczyć czas trwania w dniach
    AddDateList = Table.AddColumn(
        SetTypes, 
        "DataPojedyncza", 
        each List.Dates(
            [DataOd], 
            Number.From([DataDo] - [DataOd]) + 1, 
            #duration(1, 0, 0, 0)
        ),
        type list
    ),

    // 3. Rozwinięcie listy na pojedyncze wiersze (Expand)
    ExpandedDates = Table.ExpandListColumn(AddDateList, "DataPojedyncza"),

    // 4. Ustawienie typu nowej kolumny na 'Date'
    FinalType = Table.TransformColumnTypes(ExpandedDates, {{"DataPojedyncza", type date}}),

    // 5. (Opcjonalnie) Usunięcie oryginalnych kolumn zakreślowych, jeśli nie są już potrzebne
    RemovedRangeColumns = Table.SelectColumns(FinalType, {"ID_Umowy", "Klient", "DataPojedyncza"})
in
    RemovedRangeColumns
