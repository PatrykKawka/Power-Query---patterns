// ============================================================
// NAZWA: Postępowanie z brakującymi kolumnami przy Table.SelectColumns
// KATEGORIA: Jakość danych i błędy
// FOLDING: TAK zwykle — sam SelectColumns folduje się, o ile wcześniejsze kroki też
// ZŁOŻONOŚĆ: O(1)
// WYMAGANIA WEJŚCIOWE: brak — dotyczy sytuacji, gdy źródło czasem nie ma
//                       którejś z oczekiwanych kolumn (np. rozjechany eksport)
// ============================================================

Wybrane_kolumny =
    Table.SelectColumns(
        Źródło,
        {"Produkt", "Cena"},
        MissingField.UseNull
        // opcje trzeciego argumentu:
        // MissingField.UseNull  — zostaw jawnie wskazane kolumny, brakującą wypełnij wartością null
        //                         (bezpieczne dla dashboardów, które muszą się zawsze odświeżyć)
        // MissingField.Ignore   — po prostu pomiń brakującą, jawnie wskazaną kolumnę
        //                         (uwaga: kolejne kroki referencujące tę kolumnę po nazwie wysypią błąd)
        // MissingField.Error    — WARTOŚĆ DOMYŚLNA jeśli argument pominięty — zwraca błąd
        //                         i zatrzymuje odświeżanie; dobre gdy brak kolumny MA być alarmem
    )
