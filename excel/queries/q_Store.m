// q_Store – Danh mục cửa hàng: nối mã cửa hàng bên POS (pos_store_id) với mã bên kế toán (finance_store_code, dạng NX001).
// Một mã NX có thể có nhiều mã POS (ví dụ NX007 có 3 mã). Thêm cửa hàng mới chỉ cần thêm dòng vào sheet store_master.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat)
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    // Tìm file danh mục theo phần đầu tên, không ghi cứng đường dẫn hay năm
    TepDanhMuc = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachDanhMuc = Excel.Workbook(TepDanhMuc, null, true),
    #"Lấy sheet store_master" = SachDanhMuc{[Item = "store_master", Kind = "Sheet"]}[Data],
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet store_master", [PromoteAllScalars = true]),
    // Đổi kiểu theo vùng en-US để máy cài tiếng Việt vẫn đọc đúng
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"pos_store_id", Int64.Type}, {"finance_store_code", type text}, {"country", type text}, {"state", type text},
        {"currency", type text}, {"open_date", type date}, {"close_date", type date}, {"status", type text}}, "en-US")
in
    #"Đổi kiểu dữ liệu"
