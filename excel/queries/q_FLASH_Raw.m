// q_FLASH_Raw – Đọc thẳng sheet đầu tiên của file Flash, chưa bỏ dòng tiêu đề hay dòng tổng.
// Dùng làm số "trước khi xử lý" ở sheet Bay_du_lieu; q_FLASH đọc tiếp từ đây.
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepFlash = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Sales_Flash_Report") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachFlash = Excel.Workbook(TepFlash, null, true),
    #"Lấy sheet đầu tiên" = Table.SelectRows(SachFlash, each [Kind] = "Sheet"){0}[Data]
in
    #"Lấy sheet đầu tiên"
