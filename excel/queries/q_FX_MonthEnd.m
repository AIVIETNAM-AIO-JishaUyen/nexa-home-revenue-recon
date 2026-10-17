// q_FX_MonthEnd – Tỷ giá ngày cuối tháng, sổ cái dùng tỷ giá này để đổi nội tệ ra USD. Cũng CHIA cho tỷ giá.
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepDanhMuc = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachDanhMuc = Excel.Workbook(TepDanhMuc, null, true),
    #"Lấy sheet fx_month_end" = SachDanhMuc{[Item = "fx_month_end", Kind = "Sheet"]}[Data],
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet fx_month_end", [PromoteAllScalars = true]),
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"period", type text}, {"rate_date", type date}, {"currency", type text}, {"usd_to_ccy", type number}}, "en-US")
in
    #"Đổi kiểu dữ liệu"
