// FOLDING: NIE — funkcje niestandardowe M nie foldują się do SQL/BigQuery
// ZŁOŻONOŚĆ: O(1) na wywołanie
// WYMAGANIA WEJŚCIOWE: brak — parametr wejściowy dowolny tekst lub null

let
    fn_CzyśćTekst = (tekst as nullable text) as nullable text =>
        if tekst = null then
            null
        else
            Text.Trim(Text.Upper(Text.Clean(tekst)))
in
    fn_CzyśćTekst

PRZYKŁAD:

// let
//     Source = ...,
//     Wyczyszczone =
//         Table.TransformColumns(
//             Source,
//             {{"NazwaKlienta", fn_CzyśćTekst, type text}}
//         ),
        WyczyszczoneNagłówkiKolumn = Table.TransformColumnNames(Wyczyszczone, fn_CzyśćTekst)
// in
//     WyczyszczoneNagłówkiKolumn


