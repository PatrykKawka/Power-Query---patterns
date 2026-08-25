// ============================================================
// NAZWA: Tabela kalendarza generowana z zakresu dat w tabeli faktów
// KATEGORIA: Daty i kalendarz
// FOLDING: NIE — List.Dates i kolejne kolumny liczone są operacją lokalną
//          (typowe dla tabeli kalendarza — generowana raz, nie trzeba foldować)
// ZŁOŻONOŚĆ: O(d) — d = liczba dni w zakresie (zwykle tania operacja jednorazowa)
// WYMAGANIA WEJŚCIOWE: tabela źródłowa tbl_fact z kolumną [Data]
// ============================================================

let
    Źródło = Table.SelectColumns(tbl_fact, {"Data"}),

    MinData = Date.StartOfMonth(List.Min(Źródło[Data])),
    MaxData = Date.EndOfMonth(List.Max(Źródło[Data])),

    ListaDat = List.Dates(MinData, Duration.Days(MaxData - MinData) + 1, #duration(1, 0, 0, 0)),

    Kalendarz =
        Table.AddColumns(
            Table.FromList(ListaDat, Splitter.SplitByNothing(), {"Data"}),
            {
                {"Rok", each Date.Year([Data]), Int64.Type},
                {"Miesiac", each Date.Month([Data]), Int64.Type},
                {"Dzien", each Date.Day([Data]), Int64.Type},
                {"Kwartał", each Date.QuarterOfYear([Data]), Int64.Type},
                {"DzienTygodnia", each Date.DayOfWeek([Data], Day.Monday) + 1, Int64.Type},
                {"NazwaMiesiaca", each Date.ToText([Data], "MMMM"), type text},
                {"NazwaMiesiacaSkrot", each Date.ToText([Data], "MMM"), type text},
                {"DzienTygodniaNazwa", each Date.ToText([Data], "dddd"), type text},
                {"DzienTygodniaSkrot", each Date.ToText([Data], "ddd"), type text},
                {"RokMiesiac", each Date.Year([Data]) * 100 + Date.Month([Data]), Int64.Type},
                {"RokKwartal", each Date.Year([Data]) * 10 + Date.QuarterOfYear([Data]), Int64.Type},
                {"CzyWeekend", each Date.DayOfWeek([Data], Day.Monday) >= 5, type logical},
                {"CzyDzis", each [Data] = Date.From(DateTime.LocalNow()), type logical},
                {"CzyWPrzyszlosci", each [Data] > Date.From(DateTime.LocalNow()), type logical},
                {"Rok-Kwartał", each Text.From(Date.Year([Data])) & "-Q" & Text.From(Date.QuarterOfYear([Data])), type text},
                {"Rok-MiesiacTekst", each Date.ToText([Data], "yyyy-MM"), type text},
                {"Rok-MiesiacNazwa", each Date.ToText([Data], "yyyy MMM"), type text},
                {"SortMiesiac", each Date.Month([Data]), Int64.Type},
                {"SortDzienTygodnia", each Date.DayOfWeek([Data], Day.Monday) + 1, Int64.Type}
            }
        )
in
    Kalendarz

// UWAGA WYDAJNOŚCIOWA: kolumny "CzyDzis" i "CzyWPrzyszlosci" wywołują
// DateTime.LocalNow() dla KAŻDEGO wiersza osobno — funkcyjnie poprawne
// (bo wynik jest stały w obrębie odświeżenia), ale czytelniej i nieco szybciej
// jest policzyć DzisiajZmienna = Date.From(DateTime.LocalNow()) RAZ jako osobny
// krok let, a potem odwoływać się do tej zmiennej w obu kolumnach.
