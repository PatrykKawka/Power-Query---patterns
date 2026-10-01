let
    Source = File.Contents("C:\Dane\dane.csv.gz"),
    Decompressed = Binary.Decompress(
        Source,
        Compression.Gzip
    ),
    Csv = Csv.Document(
        Decompressed,
        [
            Delimiter = ";",
            Encoding = 65001,
            QuoteStyle = QuoteStyle.Csv
        ]
    )
in
    Csv
