// FOLDING: TAK (dla prostych porównań na kolumnach źródłowych z SQL/BigQuery)
// ZŁOŻONOŚĆ: O(k) na wiersz, k = liczba warunków
// WYMAGANIA WEJŚCIOWE: kolumna liczbowa/tekstowa do testowania w [Kolumna]
// ============================================================

= Table.AddColumn(
    Source,
    "NowaKolumna",
    each
        let
            Warunki =
                {
                    [Kolumna] > 0 and [Kolumna] < 500,
                    [Kolumna] >= 500 and [Kolumna] < 1000
                    // ... kolejne warunki w tej samej kolejności co Wyniki
                },
            Wyniki = {0.1, 0.2 /* ... to co po 'then' w wersji if-else */}
        in
            Wyniki{List.PositionOf(Warunki, true)},
    type number
)

// UWAGA: jeśli żaden warunek nie jest spełniony, List.PositionOf zwraca -1
// i indeks {-1} zwróci błąd. Wersja bezpieczna z wartością domyślną:

= Table.AddColumn(
    Source,
    "NowaKolumna",
    each
        let
            Warunki = {[Kolumna] > 0 and [Kolumna] < 500, [Kolumna] >= 500 and [Kolumna] < 1000},
            Wyniki = {0.1, 0.2},
            Pozycja = List.PositionOf(Warunki, true)
        in
            if Pozycja = -1 then null else Wyniki{Pozycja},
    type number
)
