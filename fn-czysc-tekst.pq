// ============================================================
// NAZWA: Funkcja wielokrotnego użytku — czyszczenie tekstu
// KATEGORIA: Funkcje wielokrotnego użytku
// FOLDING: NIE — funkcje niestandardowe M nie foldują się do SQL/BigQuery
// ZŁOŻONOŚĆ: O(1) na wywołanie
// WYMAGANIA WEJŚCIOWE: brak — parametr wejściowy dowolny tekst lub null
// NOWY WZORZEC — dodany w ramach audytu repo
// ============================================================
//
// CASE USE: masz kilka zapytań, które robią to samo czyszczenie tekstu (trim,
// usuwanie niedrukowalnych znaków, ujednolicenie wielkości liter) — zamiast
// kopiować te same 3 kroki w każdym query, definiujesz funkcję RAZ jako osobne
// zapytanie i wywołujesz ją wszędzie. Zmiana logiki w jednym miejscu propaguje
// się do wszystkich zapytań, które z niej korzystają.
//
// JAK DODAĆ DO REPO: zapisz jako osobne zapytanie o nazwie "fn_CzyśćTekst"
// (Power Query automatycznie rozpozna je jako funkcję po sygnaturze `(x) =>`).

let
    fn_CzyśćTekst = (tekst as nullable text) as nullable text =>
        if tekst = null then
            null
        else
            Text.Trim(Text.Upper(Text.Clean(tekst)))
in
    fn_CzyśćTekst


// PRZYKŁAD UŻYCIA w innym zapytaniu (po dodaniu fn_CzyśćTekst jako query):
//
// let
//     Source = ...,
//     Wyczyszczone =
//         Table.TransformColumns(
//             Source,
//             {{"NazwaKlienta", fn_CzyśćTekst, type text}}
//         )
// in
//     Wyczyszczone
