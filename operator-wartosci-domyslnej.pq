// ============================================================
// NAZWA: Operator wartości domyślnej ?? (null-coalescing)
// KATEGORIA: Operator domyślny i inne idiomy
// FOLDING: TAK zwykle — proste wyrażenia z ?? na kolumnach źródłowych foldują
//          się do COALESCE()/ISNULL() w SQL Server/BigQuery
// ZŁOŻONOŚĆ: O(1) na wiersz
// WYMAGANIA WEJŚCIOWE: brak
// ============================================================
//
// Symbol ?? w Power Query (język M) to operator wartości domyślnej
// (null-coalescing operator).

// 1) Podstawa: jeśli wartość1 ≠ null → zwraca wartość1; jeśli null → zwraca wartość2
wartość1 ?? wartość2

// null ?? 5  →  5 (pierwsza wartość jest pusta, więc zwraca drugą)


// 2) Typowe użycie: kaskada "cena promocyjna, jak jest — a jak nie, podstawowa"
= Table.AddColumn(Tabela, "CenaKońcowa", each [CenaPromocyjna] ?? [CenaPodstawowa])


// 3) Łańcuch wielu kolumn — pierwsza niepusta wygrywa
[Kolumna 1] ?? [Kolumna 2] ?? [Kolumna 3]


// 4) Działania na kolumnach z wartościami null — zastąp 0 zamiast propagować null
[Kolumna] ?? 0


// 5) Filtrowanie z uwzględnieniem null-i — bez ?? filtr domyślnie ODFILTROWUJE
// wiersze z null (bo null > 50 zwraca null, nie false); z ?? 0 dostają wartość
// porównywalną i są jawnie potraktowane jako niespełniające warunku
each ([Kolumna] ?? 0) > 50
