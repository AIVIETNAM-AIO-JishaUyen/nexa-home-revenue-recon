// q_GL – Sổ cái doanh thu (GL – General Ledger) của phòng Tài chính: mỗi dòng là 1 bút toán (khóa journal_id).
// Bút toán tự động gộp nhiều giao dịch: cửa hàng × ngày ghi sổ (POS_DAILY), ngày giao × loại tiền (WEB_DELIVERY, WEB_RETURN).
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm file sổ cái theo phần đầu tên, không ghi cứng năm
    #"Các file sổ cái tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "Finance_GL_Revenue") and Text.Lower([Extension]) = ".xlsx"),
    // Phải có đúng 1 file, nếu không thì báo lỗi rõ ràng
    #"Nội dung file sổ cái" = if Table.RowCount(#"Các file sổ cái tìm thấy") = 1 then #"Các file sổ cái tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng Finance_GL_Revenue (.xlsx), đang có "
            & Text.From(Table.RowCount(#"Các file sổ cái tìm thấy"))),
    // Mở file Excel sổ cái
    #"Các sheet của file sổ cái" = Excel.Workbook(#"Nội dung file sổ cái", null, true),
    // Lấy sheet đầu tiên (không phụ thuộc tên sheet)
    #"Lấy sheet đầu tiên" = Table.SelectRows(#"Các sheet của file sổ cái", each [Kind] = "Sheet"){0}[Data],
    // Dòng đầu của sheet là tên cột
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet đầu tiên", [PromoteAllScalars = true]),
    // Đổi kiểu theo vùng en-US; số tài khoản (5111 doanh thu, 5213 hàng bị trả lại) để dạng chữ
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"journal_id", type text}, {"posting_date", type date}, {"period", type text}, {"account", type text},
        {"journal_type", type text}, {"store_code", type text}, {"channel", type text}, {"currency", type text},
        {"amount_local", type number}, {"fx_rate_month_end", type number}, {"amount_usd", type number},
        {"description", type text}, {"source_ref", type text}}, "en-US"),
    // BẪY 3 – sổ cái ghi doanh thu là số âm (ghi Có), hàng bán bị trả lại là số dương (ghi Nợ).
    // Đổi dấu để doanh thu là số dương, cùng chiều với Flash; giữ nguyên cột gốc amount_usd để đối chiếu
    #"Đổi dấu doanh thu (USD)" = Table.AddColumn(#"Đổi kiểu dữ liệu", "revenue_usd", each - [amount_usd], type number),
    // Đổi dấu cả số nội tệ, dùng khi đối soát theo nội tệ
    #"Đổi dấu doanh thu (nội tệ)" = Table.AddColumn(#"Đổi dấu doanh thu (USD)", "revenue_local", each - [amount_local], type number)
in
    #"Đổi dấu doanh thu (nội tệ)"
