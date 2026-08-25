// ============================================================
// NAZWA: Dodanie kilku kolumn niestandardowych w jednym kroku
// KATEGORIA: Kolumny i transformacje
// FOLDING: CZĘŚCIOWO — zależy od operacji wewnątrz rekordu; proste działania
//          arytmetyczne na kolumnach źródłowych zwykle foldują się do SQL/BigQuery
// ZŁOŻONOŚĆ: O(1) na wiersz
// WYMAGANIA WEJŚCIOWE: kolumny [kolumna_x], [kolumna_y], [kolumna_z]
// ============================================================

// CEL: dodać 3 kolumny liczone na raz, zamiast trzech osobnych kroków
// "Dodaj kolumnę niestandardową" (co tworzy 3 osobne, kaskadowe kroki M).
//
// KROKI W INTERFEJSIE:
// 1. Kolumna niestandardowa → w edytorze wpisz rekord z wieloma polami:
//    [
//        kolumna1 = [kolumna_x] * [kolumna_y],
//        kolumna2 = [kolumna_y] - [kolumna_x],
//        kolumna3 = [kolumna_x] * [kolumna_z]
//    ]
// 2. OK — powstaje jedna kolumna typu Record.
// 3. Rozwiń kolumnę (strzałka w prawym górnym rogu nagłówka) — Power Query
//    rozpakuje rekord do 3 osobnych kolumn w jednym kroku Table.ExpandRecordColumn.

// Kod wynikowy (po rozwinięciu):
= Table.ExpandRecordColumn(
    Table.AddColumn(
        Source,
        "TymczasowyRekord",
        each
            [
                kolumna1 = [kolumna_x] * [kolumna_y],
                kolumna2 = [kolumna_y] - [kolumna_x],
                kolumna3 = [kolumna_x] * [kolumna_z]
            ]
    ),
    "TymczasowyRekord",
    {"kolumna1", "kolumna2", "kolumna3"}
)

// ZALETA vs 3 osobne kroki "Dodaj kolumnę niestandardową":
// - jeden krok w liście Applied Steps zamiast trzech — czytelniejszy log zmian
// - łatwiej o spójną logikę, gdy kolumny są od siebie zależne
