// q_Check – Sheet kiểm tra tổng: so 13 chỉ tiêu của bảng tổng kiểm soát QC_Summary (file danh mục) với số nhóm tính lại từ các truy vấn nạp.
// Cột chenh_lech phải bằng 0 và cột dat phải TRUE ở mọi dòng. Nhãn nguồn khi trích số: [QC].
// Các tổng line_amount, discount_amount, net_amount cộng thẳng nhiều loại tiền: chỉ để kiểm tra đã nạp đủ, không phải doanh thu.
let
    ThuMuc = Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1],
    TepDanhMuc = Table.SelectRows(Folder.Files(ThuMuc), each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"){0}[Content],
    SachDanhMuc = Excel.Workbook(TepDanhMuc, null, true),
    #"Lấy sheet QC_Summary" = SachDanhMuc{[Item = "QC_Summary", Kind = "Sheet"]}[Data],
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet QC_Summary", [PromoteAllScalars = true]),
    #"Đánh số thứ tự" = Table.AddIndexColumn(#"Dòng đầu là tên cột", "stt", 1, 1, Int64.Type),
    // Table.Buffer: giữ sẵn mỗi bảng trong bộ nhớ, để không phải đọc lại file nhiều lần
    POS = Table.Buffer(q_POS),
    WEB = Table.Buffer(q_WEB),
    GL = Table.Buffer(q_GL),
    FL = Table.Buffer(q_FLASH),
    DemDonTheoTrangThai = (trangThai as text) as number => Table.RowCount(Table.SelectRows(WEB, each [order_status] = trangThai)),
    NgayThanhChu = (ngay as date) as text => Date.ToText(ngay, "yyyy-MM-dd"),
    // Số nhóm tính lại, theo đúng thứ tự 13 dòng của QC_Summary
    #"Số nhóm tính lại" = Table.FromRows({
        {1, Table.RowCount(POS)},
        {2, List.Count(List.Distinct(POS[receipt_no]))},
        {3, NgayThanhChu(List.Min(POS[business_date])) & " → " & NgayThanhChu(List.Max(POS[business_date]))},
        {4, List.Sum(POS[qty])},
        {5, List.Sum(POS[line_amount])},
        {6, List.Sum(POS[discount_amount])},
        {7, Table.RowCount(WEB)},
        {8, Text.From(DemDonTheoTrangThai("Delivered")) & " / " & Text.From(DemDonTheoTrangThai("Cancelled")) & " / " & Text.From(DemDonTheoTrangThai("Returned"))},
        {9, List.Sum(WEB[net_amount])},
        {10, Table.RowCount(GL)},
        {11, List.Sum(GL[amount_usd])},
        {12, Table.RowCount(FL)},
        {13, List.Sum(FL[revenue_usd])}
    }, type table [stt = Int64.Type, gia_tri_nhom = any]),
    #"Ghép với QC_Summary" = Table.NestedJoin(#"Đánh số thứ tự", {"stt"}, #"Số nhóm tính lại", {"stt"}, "Nhom", JoinKind.LeftOuter),
    #"Mở cột số nhóm" = Table.ExpandTableColumn(#"Ghép với QC_Summary", "Nhom", {"gia_tri_nhom"}),
    #"Đổi tên cột" = Table.RenameColumns(#"Mở cột số nhóm", {
        {"File", "file"}, {"Chỉ tiêu kiểm soát", "chi_tieu"}, {"Giá trị", "gia_tri_de"}, {"Ghi chú", "ghi_chu_de"}}),
    // Chênh lệch = số nhóm − số của đề (làm tròn 2 chữ số). Hai dòng dạng chữ (khoảng ngày, số đơn theo trạng thái) so bằng chữ: giống nhau thì chênh lệch 0
    #"Tính chênh lệch" = Table.AddColumn(#"Đổi tên cột", "chenh_lech",
        each if Value.Is([gia_tri_de], type number) and Value.Is([gia_tri_nhom], type number)
             then Number.Round([gia_tri_nhom] - [gia_tri_de], 2)
             else if Text.From([gia_tri_de]) = Text.From([gia_tri_nhom]) then 0 else null, type nullable number),
    #"Đạt hay không" = Table.AddColumn(#"Tính chênh lệch", "dat", each [chenh_lech] <> null and [chenh_lech] = 0, type logical),
    #"Chọn cột" = Table.SelectColumns(#"Đạt hay không", {"stt", "file", "chi_tieu", "gia_tri_de", "gia_tri_nhom", "chenh_lech", "dat", "ghi_chu_de"})
in
    #"Chọn cột"
