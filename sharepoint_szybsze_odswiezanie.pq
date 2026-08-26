// FOLDING: N/D — to zmiana samego konektora, nie transformacja danych
// ZŁOŻONOŚĆ: N/D — poprawa dotyczy czasu połączenia, nie złożoności obliczeniowej
// WYMAGANIA WEJŚCIOWE: adres witryny SharePoint
// ============================================================
//
// PROBLEM: domyślny konektor SharePoint.Files() jest wolny, bo:
// - zależy od liczby WSZYSTKICH plików w witrynie (nie tylko w interesującym folderze)
// - zwraca też pliki z podfolderów wymieszane razem — trzeba potem filtrować
//   po kolumnie ze ścieżką, żeby wyłuskać właściwy folder

SharePoint.Files("https://firma.sharepoint.com/sites/nazwa_folderu/", [ApiVersion = 15])


// ROZWIĄZANIE: zmień konektor w pasku formuły na SharePoint.Contents() — pokazuje foldery zamiast płaskiej listy plików i jest znacznie szybszy
//przy odświeżaniu, bo nawiguje strukturę zamiast skanować wszystko naraz.

SharePoint.Contents("https://firma.sharepoint.com/sites/nazwa_folderu/", [ApiVersion = 15])

// Aby wypakować zawartość plików/skoroszytów po przejściu do właściwego folderu:

NowyKrok =
    Table.AddColumn(
        #"Poprzedni krok",
        "Nowa kolumna",
        each Excel.Workbook([Content], true, true)
    )
