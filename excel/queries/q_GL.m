// q_GL – Sổ cái doanh thu (GL – General Ledger) của phòng Tài chính: mỗi dòng là 1 bút toán (khóa journal_id).
// Bút toán tự động gộp nhiều giao dịch: cửa hàng × ngày ghi sổ (POS_DAILY), ngày giao × loại tiền (WEB_DELIVERY, WEB_RETURN).
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepGL = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Finance_GL_Revenue") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachGL = Excel.Workbook(TepGL, null, true),
    #"Lấy sheet đầu tiên" = Table.SelectRows(SachGL, each [Kind] = "Sheet"){0}[Data],
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet đầu tiên", [PromoteAllScalars = true]),
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"journal_id", type text}, {"posting_date", type date}, {"period", type text}, {"account", type text},
        {"journal_type", type text}, {"store_code", type text}, {"channel", type text}, {"currency", type text},
        {"amount_local", type number}, {"fx_rate_month_end", type number}, {"amount_usd", type number},
        {"description", type text}, {"source_ref", type text}}, "en-US"),
    // BẪY 3 – sổ cái ghi doanh thu là số âm (ghi Có), hàng bán bị trả lại là số dương (ghi Nợ).
    // Đổi dấu để doanh thu là số dương, cùng chiều với Flash; giữ nguyên cột gốc để đối chiếu.
    #"Đổi dấu doanh thu (USD)" = Table.AddColumn(#"Đổi kiểu dữ liệu", "revenue_usd", each - [amount_usd], type number),
    #"Đổi dấu doanh thu (nội tệ)" = Table.AddColumn(#"Đổi dấu doanh thu (USD)", "revenue_local", each - [amount_local], type number)
in
    #"Đổi dấu doanh thu (nội tệ)"
