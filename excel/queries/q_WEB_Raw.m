// q_WEB_Raw – Đọc thẳng file đơn online (WEB), mọi cột vẫn là chữ, chưa xử lý gì.
// Dùng làm số "trước khi xử lý" ở sheet Bay_du_lieu; q_WEB đọc tiếp từ đây nên file chỉ phải đọc 1 lần.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm file đơn online theo phần đầu tên, không ghi cứng năm
    #"Các file WEB tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "WEB_Orders_Export") and Text.Lower([Extension]) = ".csv"),
    // Phải có đúng 1 file, nếu không thì báo lỗi rõ ràng
    #"Nội dung file WEB" = if Table.RowCount(#"Các file WEB tìm thấy") = 1 then #"Các file WEB tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng WEB_Orders_Export (.csv), đang có "
            & Text.From(Table.RowCount(#"Các file WEB tìm thấy"))),
    // Đọc file CSV (dấu phẩy ngăn cột, mã UTF-8)
    #"Đọc file CSV" = Csv.Document(#"Nội dung file WEB", [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    // Dòng đầu của file là tên cột
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Đọc file CSV", [PromoteAllScalars = true])
in
    #"Dòng đầu là tên cột"
