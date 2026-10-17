// q_FLASH_Raw – Đọc thẳng sheet đầu tiên của file Flash, chưa bỏ dòng tiêu đề hay dòng tổng. Các cột tên Column1…Column5.
// Dùng làm số "trước khi xử lý" ở sheet Bay_du_lieu; q_FLASH đọc tiếp từ đây nên file chỉ phải đọc 1 lần.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm file Flash theo phần đầu tên, không ghi cứng năm
    #"Các file Flash tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "Sales_Flash_Report") and Text.Lower([Extension]) = ".xlsx"),
    // Phải có đúng 1 file, nếu không thì báo lỗi rõ ràng
    #"Nội dung file Flash" = if Table.RowCount(#"Các file Flash tìm thấy") = 1 then #"Các file Flash tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng Sales_Flash_Report (.xlsx), đang có "
            & Text.From(Table.RowCount(#"Các file Flash tìm thấy"))),
    // Mở file Excel Flash
    #"Các sheet của file Flash" = Excel.Workbook(#"Nội dung file Flash", null, true),
    // Lấy sheet đầu tiên (không phụ thuộc tên sheet)
    #"Lấy sheet đầu tiên" = Table.SelectRows(#"Các sheet của file Flash", each [Kind] = "Sheet"){0}[Data]
in
    #"Lấy sheet đầu tiên"
