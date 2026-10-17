// q_FX_MonthEnd – Tỷ giá ngày cuối tháng, sổ cái dùng tỷ giá này để đổi nội tệ ra USD. Cũng CHIA cho tỷ giá.
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
    // Lấy sheet fx_month_end
    #"Lấy sheet fx_month_end" = #"Các sheet của file danh mục"{[Item = "fx_month_end", Kind = "Sheet"]}[Data],
    // Dòng đầu của sheet là tên cột
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet fx_month_end", [PromoteAllScalars = true]),
    // Đổi kiểu theo vùng en-US; period là tháng dạng YYYY-MM
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"period", type text}, {"rate_date", type date}, {"currency", type text}, {"usd_to_ccy", type number}}, "en-US")
in
    #"Đổi kiểu dữ liệu"
