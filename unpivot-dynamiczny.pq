// ============================================================
// NAZWA: Dynamiczny Unpivot (bez ręcznego wskazywania kolumn do unpivotu)
// KATEGORIA: Kolumny dynamiczne
// FOLDING: NIE — unpivot generalnie nie folduje się do prostego SQL
// ZŁOŻONOŚĆ: O(k) kolumn x O(n) wierszy → O(k*n) wierszy wynikowych
// WYMAGANIA WEJŚCIOWE: znana i stabilna lista kolumn, które NIE mają być
//                       unpivotowane (KolumnyStałe)
// NOWY WZORZEC — dodany w ramach audytu repo
// ============================================================
//
// CASE USE: eksport z systemu finansowego, gdzie liczba kolumn-miesięcy
// rośnie w czasie (np. kolejne miesiące roku budżetowego). Zamiast ręcznie
// wskazywać kolumny do unpivotu (i edytować zapytanie co miesiąc),
// Table.UnpivotOtherColumns automatycznie obejmuje KAŻDĄ kolumnę, która NIE
// jest na liście KolumnyStałe — więc nowa kolumna w źródle jest uwzględniona
// bez żadnej zmiany w kodzie M.

let
    Source = ...,
    KolumnyStałe = {"Oddział", "Konto"},  // <- kolumny, które mają zostać jako są
    Unpivot =
        Table.UnpivotOtherColumns(
            Source,
            KolumnyStałe,
            "Miesiąc",
            "Wartość"
        )
in
    Unpivot

// PUŁAPKA: jeśli lista KolumnyStałe jest niekompletna (np. zapomnisz dodać
// nową kolumnę opisową, która NIE powinna być unpivotowana), trafi ona
// do unpivotu razem z danymi liczbowymi i zepsuje wynik. Warto raz na jakiś
// czas zweryfikować Table.ColumnNames(Source) względem KolumnyStałe.
