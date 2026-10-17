// q_WEB_Raw – Đọc thẳng file đơn online (WEB), mọi cột vẫn là chữ, chưa xử lý gì.
// Dùng làm số "trước khi xử lý" ở sheet Bay_du_lieu; q_WEB đọc tiếp từ đây.
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepWEB = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "WEB_Orders_Export") and Text.Lower([Extension]) = ".csv"){0}[Content],
    #"Đọc file CSV" = Csv.Document(TepWEB, [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Đọc file CSV", [PromoteAllScalars = true])
in
    #"Dòng đầu là tên cột"
