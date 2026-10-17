// q_Calendar – Lịch từng ngày, thêm cột ngày ghi sổ posting_date.
// Quy tắc của sổ cái (kênh cửa hàng): bán vào ngày nghỉ (cuối tuần, ngày lễ) thì ghi sổ vào ngày làm việc kế tiếp.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm file danh mục theo phần đầu tên, không ghi cứng năm
    #"Các file danh mục tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"),
    // Phải có đúng 1 file, nếu không thì báo lỗi rõ ràng
    #"Nội dung file danh mục" = if Table.RowCount(#"Các file danh mục tìm thấy") = 1 then #"Các file danh mục tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng Nexa_Home_Master_Data (.xlsx), đang có "
            & Text.From(Table.RowCount(#"Các file danh mục tìm thấy"))),
    // Mở file Excel danh mục
    #"Các sheet của file danh mục" = Excel.Workbook(#"Nội dung file danh mục", null, true),
    // Lấy sheet calendar
    #"Lấy sheet calendar" = #"Các sheet của file danh mục"{[Item = "calendar", Kind = "Sheet"]}[Data],
    // Dòng đầu của sheet là tên cột
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet calendar", [PromoteAllScalars = true]),
    // Đổi kiểu theo vùng en-US; working_day = 1 là ngày làm việc, 0 là ngày nghỉ
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"date", type date}, {"year", Int64.Type}, {"month", Int64.Type}, {"period", type text},
        {"day_of_week", type text}, {"working_day", Int64.Type}}, "en-US"),
    // Danh sách các ngày làm việc, sắp tăng dần và giữ sẵn trong bộ nhớ (List.Buffer) để tra nhanh
    #"Danh sách ngày làm việc" = List.Buffer(List.Sort(Table.SelectRows(#"Đổi kiểu dữ liệu", each [working_day] = 1)[date])),
    // Ngày ghi sổ = ngày làm việc đầu tiên kể từ ngày đó (ngày làm việc thì ghi sổ ngay hôm đó).
    // Ngày nghỉ ở cuối lịch, sau đó không còn ngày làm việc nào trong lịch, sẽ để trống: muốn tính thì thêm ngày vào sheet calendar
    #"Thêm ngày ghi sổ" = Table.AddColumn(#"Đổi kiểu dữ liệu", "posting_date",
        (dong) => List.First(List.Select(#"Danh sách ngày làm việc", each _ >= dong[date])), type date)
in
    #"Thêm ngày ghi sổ"
