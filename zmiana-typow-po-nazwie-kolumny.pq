// ============================================================
// NAZWA: Zmiana typów danych dynamicznie, na podstawie fragmentu nazwy kolumny
// KATEGORIA: Kolumny dynamiczne
// FOLDING: TAK zwykle — Table.TransformColumnTypes folduje się do CAST/CONVERT
//          w SQL Server/BigQuery, o ile poprzednie kroki też foldują
// ZŁOŻONOŚĆ: O(k) — k = liczba kolumn
// WYMAGANIA WEJŚCIOWE: konwencja nazewnicza kolumn (np. "%" w nazwie = procent,
//                       "Liczba" w nazwie = liczba całkowita)
// ============================================================

= Table.TransformColumnTypes(
    #"Poprzedni krok",
    List.Transform(
        Table.ColumnNames(#"Poprzedni krok"),
        each {
            _,
            if Text.Contains(_, "%") then
                Percentage.Type
            else if Text.Contains(_, "Liczba") then
                Int64.Type
            else
                type text
        }
    )
)

// Przydatne przy plikach źródłowych o zmiennej liczbie kolumn (np. eksporty
// z rosnącą liczbą miesięcy) — nie trzeba ręcznie wypisywać typu dla każdej
// kolumny osobno, wystarczy trzymać się konwencji nazewniczej.
