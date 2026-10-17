// q_Store – Danh mục cửa hàng: nối mã cửa hàng bên POS (pos_store_id) với mã bên kế toán (finance_store_code, dạng NX001).
// Một mã NX có thể có nhiều mã POS (ví dụ NX007 có 3 mã). Thêm cửa hàng mới chỉ cần thêm dòng vào sheet store_master.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm trong thư mục (không tìm thư mục con) file danh mục theo phần đầu tên, không ghi cứng năm
    #"Các file danh mục tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"),
    // Phải có đúng 1 file; nếu không có hoặc có nhiều hơn 1 thì báo lỗi rõ ràng thay vì lấy bừa
    #"Nội dung file danh mục" = if Table.RowCount(#"Các file danh mục tìm thấy") = 1 then #"Các file danh mục tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng Nexa_Home_Master_Data (.xlsx), đang có "
            & Text.From(Table.RowCount(#"Các file danh mục tìm thấy"))),
    // Mở file Excel danh mục (mọi giá trị giữ nguyên, chưa đổi kiểu)
    #"Các sheet của file danh mục" = Excel.Workbook(#"Nội dung file danh mục", null, true),
    // Lấy sheet store_master
    #"Lấy sheet store_master" = #"Các sheet của file danh mục"{[Item = "store_master", Kind = "Sheet"]}[Data],
    // Dòng đầu của sheet là tên cột
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet store_master", [PromoteAllScalars = true]),
    // Đổi kiểu theo vùng en-US (English – United States) để máy cài tiếng Việt vẫn đọc đúng số và ngày
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"pos_store_id", Int64.Type}, {"finance_store_code", type text}, {"country", type text}, {"state", type text},
        {"currency", type text}, {"open_date", type date}, {"close_date", type date}, {"status", type text}}, "en-US")
in
    #"Đổi kiểu dữ liệu"
