// q_FX_Daily – Tỷ giá theo ngày. Tỷ giá là số ngoại tệ đổi được 1 USD, nên muốn đổi nội tệ ra USD thì CHIA cho tỷ giá.
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepDanhMuc = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachDanhMuc = Excel.Workbook(TepDanhMuc, null, true),
    #"Lấy sheet fx_daily" = SachDanhMuc{[Item = "fx_daily", Kind = "Sheet"]}[Data],
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet fx_daily", [PromoteAllScalars = true]),
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"rate_date", type date}, {"currency", type text}, {"usd_to_ccy", type number}}, "en-US")
in
    #"Đổi kiểu dữ liệu"
