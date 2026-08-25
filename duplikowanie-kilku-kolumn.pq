// ============================================================
// NAZWA: Duplikowanie kilku kolumn w jednym kroku
// KATEGORIA: Kolumny i transformacje
// FOLDING: NIE — List.Accumulate na tabeli jako stanie jest operacją lokalną
// ZŁOŻONOŚĆ: O(k) — k = liczba duplikowanych kolumn
// WYMAGANIA WEJŚCIOWE: lista nazw kolumn do zduplikowania musi istnieć w tabeli
// ============================================================

// Zamiast k-krotnego klikania "Duplikuj kolumnę" (co tworzy k osobnych kroków
// w Applied Steps), List.Accumulate przechodzi po liście nazw kolumn i za każdym
// przebiegiem dokłada jedną duplikowaną kolumnę do tabeli-stanu.

#"Duplikowanie kilku kolumn" =
    List.Accumulate(
        {"Kolumna1", "Kolumna2", "Kolumna3"},  // <- lista kolumn do zduplikowania
        #"Poprzedni krok",                      // <- stan początkowy (tabela wejściowa)
        (state as table, current as text) =>
            Table.DuplicateColumn(state, current, current & " - Kopia")
    )

// Jak to czytać:
// - state    = tabela w kolejnej iteracji (na starcie: #"Poprzedni krok")
// - current  = nazwa kolumny aktualnie przetwarzanej z listy
// - każda iteracja zwraca nową tabelę z jedną dodatkową kolumną "<nazwa> - Kopia"
// - wynik ostatniej iteracji to finalna tabela ze wszystkimi duplikatami
