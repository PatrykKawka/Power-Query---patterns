# Checklist diagnostyki wydajności Power Query

NOWY DOKUMENT — dodany w ramach audytu repo. Wracaj do tej listy przy każdym
nowym, wolno odświeżającym się zapytaniu, zanim zaczniesz optymalizować "na wyczucie".

## 1. Sprawdź folding krok po kroku
PPM na ostatni krok w Applied Steps → **View Native Query**.
- Aktywne → krok wciąż folduje się do zapytania źródłowego (SQL/BigQuery robi robotę).
- Wyszarzone → folding przerwany na tym kroku lub wcześniej. Cofnij się krok po
  kroku, aż znajdziesz pierwsze miejsce, gdzie opcja jeszcze działa — to Twoja
  granica "praca po stronie serwera vs praca po stronie Power Query".

## 2. Włącz Query Diagnostics
`Narzędzia danych → Diagnostyka zapytania` → porównaj czas trwania poszczególnych
kroków. Szukaj kroku, który dominuje całkowity czas odświeżania — zwykle to jeden
konkretny krok, nie rozkład równomierny.

## 3. Table.Buffer / List.Buffer — używaj świadomie
- Buforuj TYLKO wtedy, gdy ta sama struktura jest odczytywana wielokrotnie
  w pętli (`each`) **i** folding już i tak jest przerwany w tym miejscu.
- Buforowanie PRZED miejscem, gdzie folding jeszcze działa, **wyłącza folding
  przedwcześnie** i zwykle pogarsza wydajność zamiast ją poprawić.

## 4. Kolejność kroków ma znaczenie dla foldingu
Filtruj i redukuj kolumny (`Table.SelectColumns`, `Table.SelectRows`) możliwie
najwcześniej, przed krokami nie-foldowalnymi (customowe kolumny, grupowania
z `each`, funkcje z listy `01-04` w tym repo, które są oznaczone `FOLDING: NIE`).

## 5. Referencje między zapytaniami
Gdy `Query B` odwołuje się do `Query A` (przez `= QueryA` zamiast osobnego
źródła), sprawdź czy `QueryA` nie jest przeliczane wielokrotnie przy każdym
użyciu. Jeśli tak: rozważ wyłączenie "Włącz ładowanie" dla `QueryA` i/lub
buforowanie wyniku pośredniego.

## Wzorce w tym repo oznaczone `FOLDING: NIE`
Świadomie zaakceptuj koszt braku foldingu przy: grupowaniu z funkcjami
okienkowymi (LAG/LEAD, Running Total, Moving Average, Ranking), własnych
funkcjach statystycznych w grupowaniu, fuzzy merge, unpivocie dynamicznym.
Dla dużych źródeł (SQL Server, BigQuery) rozważ przeniesienie części tej logiki
bliżej źródła (np. widok SQL z window functions) zamiast realizować ją w M.
