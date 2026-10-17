// q_Calendar – Lịch từng ngày, thêm cột ngày ghi sổ posting_date.
// Quy tắc của sổ cái (kênh cửa hàng): bán vào ngày nghỉ (cuối tuần, ngày lễ) thì ghi sổ vào ngày làm việc kế tiếp.
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepDanhMuc = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachDanhMuc = Excel.Workbook(TepDanhMuc, null, true),
    #"Lấy sheet calendar" = SachDanhMuc{[Item = "calendar", Kind = "Sheet"]}[Data],
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet calendar", [PromoteAllScalars = true]),
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"date", type date}, {"year", Int64.Type}, {"month", Int64.Type}, {"period", type text},
        {"day_of_week", type text}, {"working_day", Int64.Type}}, "en-US"),
    // Danh sách các ngày làm việc, giữ sẵn trong bộ nhớ (List.Buffer) để tra nhanh
    #"Danh sách ngày làm việc" = List.Buffer(List.Sort(Table.SelectRows(#"Đổi kiểu dữ liệu", each [working_day] = 1)[date])),
    // Ngày ghi sổ = ngày làm việc đầu tiên kể từ ngày đó (ngày làm việc thì ghi sổ ngay hôm đó)
    #"Thêm ngày ghi sổ" = Table.AddColumn(#"Đổi kiểu dữ liệu", "posting_date",
        (dong) => List.First(List.Select(#"Danh sách ngày làm việc", each _ >= dong[date])), type date)
in
    #"Thêm ngày ghi sổ"
