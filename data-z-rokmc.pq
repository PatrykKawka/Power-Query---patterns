// ============================================================
// NAZWA: Tworzenie kolumny z datą na podstawie tekstu "rok/miesiąc"
// KATEGORIA: Daty i kalendarz
// FOLDING: NIE — parsowanie tekstu i budowa daty przez #date() w 'each' jest lokalne
// ZŁOŻONOŚĆ: O(1) na wiersz
// WYMAGANIA WEJŚCIOWE: kolumna tekstowa w formacie "RRRR/MM", np. [rok/mc] = "2026/03"
// ============================================================
//
// POPRAWKI względem oryginału:
// 1) Literówki w nazwach funkcji: Text.BeforeDelimeter/Text.AfterDelimeter
//    NIE ISTNIEJĄ w M — poprawne nazwy to Text.BeforeDelimiter/Text.AfterDelimiter.
// 2) Table.AddColumns (liczba mnoga, lista specyfikacji kolumn) użyte tam, gdzie
//    potrzebne jest Table.AddColumn (liczba pojedyncza, dodaje jedną kolumnę) —
//    sygnatury tych funkcji się nie zgadzały, kod się nie parsował.
// 3. Brakujący trzeci argument #date() — dzień musi być podany jako liczba,
//    nie jako nieopisana zmienna "wybrany_dzień" bez kontekstu.

= Table.AddColumn(
    #"Poprzedni_Krok",
    "Data",
    each
        #date(
            Number.FromText(Text.BeforeDelimiter([#"rok/mc"], "/")),
            Number.FromText(Text.AfterDelimiter([#"rok/mc"], "/")),
            1  // <- dzień miesiąca; zmień na własną logikę, jeśli inny niż "1"
        ),
    type date
)

// UWAGA: [#"rok/mc"] to notacja wymagana dla nazw kolumn zawierających znaki
// specjalne (tu: "/"), które nie są dozwolone w zwykłym identyfikatorze M.
