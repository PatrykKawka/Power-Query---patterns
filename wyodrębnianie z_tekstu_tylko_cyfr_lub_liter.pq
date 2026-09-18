1. Wyodrębnienie tekstu lub cyfr z kolumny można wykonać na dwa sposoby
a) jako Table.TransformColumns

  #"Wyodrębnienie cyfr z kolumny" = Table.TransformColumns(
    #"Source", 
    {{"id_zamówienia", each Text.Select(_, {"0" .. "9"}), type text}}
  ), 

b) tworząc nową kolumnę Table.AddColumn

  #"Dodanie nowej kolumny z wyodrębnionymi cyframi" = Table.AddColumn(
    #"Source", 
    "tylko_cyfry", 
    each Text.Select([id_zamówienia], {"0".."9"}), type text
  )


  //Text.Select - pobiera wszystkie znaki z zakresu podanego jako argument - cyfry od 0 do 9, {"a".."z"} - wszystkie znaki od a do z, funkcja jest case sensitive
  //Text.Remove - działa odwrotnie - usuwa znaki podane jako lista. Text.Remove([KodProdukt], {"a".."z"} & {"A".."Z"} & {"-"}) - usuwa wszystkie znaki podane w listach

  

   //można uzywać też w innych przypadkach
    a) Czyszczenie numerów telefonów (Usuwanie spacji i znaków)
    Text.Remove([Telefon], {" ", "-", "(", ")", "+"})

    b)Baza słów: Usuwanie znaków interpunkcyjnych
    Text.Remove([Opinia], {".", ",", "!", "?", ";", ":", "-", """"})

