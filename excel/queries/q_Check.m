// q_Check – Sheet kiểm tra tổng: so 13 chỉ tiêu của bảng tổng kiểm soát QC_Summary (QC – Quality Control, kiểm soát chất lượng; nằm trong file danh mục)
// với số nhóm tính lại từ các truy vấn nạp. Cột chenh_lech phải bằng 0 và cột dat phải TRUE ở mọi dòng. Nhãn nguồn khi trích số: [QC].
// Các tổng line_amount, discount_amount, net_amount cộng thẳng nhiều loại tiền: chỉ để kiểm tra đã nạp đủ, không phải doanh thu.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm file danh mục theo phần đầu tên
    #"Các file danh mục tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "Nexa_Home_Master_Data") and Text.Lower([Extension]) = ".xlsx"),
    // Phải có đúng 1 file, nếu không thì báo lỗi rõ ràng
    #"Nội dung file danh mục" = if Table.RowCount(#"Các file danh mục tìm thấy") = 1 then #"Các file danh mục tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng Nexa_Home_Master_Data (.xlsx), đang có "
            & Text.From(Table.RowCount(#"Các file danh mục tìm thấy"))),
    // Mở file Excel danh mục và lấy sheet QC_Summary
    #"Lấy sheet QC_Summary" = Excel.Workbook(#"Nội dung file danh mục", null, true){[Item = "QC_Summary", Kind = "Sheet"]}[Data],
    // Dòng đầu của sheet là tên cột (File, Chỉ tiêu kiểm soát, Giá trị, Ghi chú)
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Lấy sheet QC_Summary", [PromoteAllScalars = true]),
    // Đánh số thứ tự 13 dòng của đề. Ghép theo số thứ tự chứ không theo tên chỉ tiêu, vì tên chỉ tiêu dài và dễ gõ sai 1 ký tự;
    // cột chi_tieu vẫn hiện tên của đề để người đọc thấy hai bên đang so cùng một chỉ tiêu
    #"Đánh số thứ tự" = Table.AddIndexColumn(#"Dòng đầu là tên cột", "stt", 1, 1, Int64.Type),
    // Giữ sẵn 4 bảng nạp trong bộ nhớ (Table.Buffer), để truy vấn này không phải đọc lại file nhiều lần
    #"Bảng POS" = Table.Buffer(q_POS),
    // Giữ sẵn bảng đơn online
    #"Bảng đơn online" = Table.Buffer(q_WEB),
    // Giữ sẵn bảng sổ cái
    #"Bảng sổ cái" = Table.Buffer(q_GL),
    // Giữ sẵn bảng Flash
    #"Bảng Flash" = Table.Buffer(q_FLASH),
    // Hàm phụ: đếm số đơn online theo trạng thái
    #"Đếm đơn theo trạng thái" = (trangThai as text) as number => Table.RowCount(Table.SelectRows(#"Bảng đơn online", each [order_status] = trangThai)),
    // Hàm phụ: viết ngày thành chữ dạng YYYY-MM-DD giống QC_Summary
    #"Ngày thành chữ" = (ngay as date) as text => Date.ToText(ngay, "yyyy-MM-dd", "en-US"),
    // Số nhóm tính lại, theo đúng thứ tự 13 dòng của QC_Summary
    #"Số nhóm tính lại" = Table.FromRows({
        {1, Table.RowCount(#"Bảng POS")},
        {2, List.Count(List.Distinct(#"Bảng POS"[receipt_no]))},
        {3, #"Ngày thành chữ"(List.Min(#"Bảng POS"[business_date])) & " → " & #"Ngày thành chữ"(List.Max(#"Bảng POS"[business_date]))},
        {4, List.Sum(#"Bảng POS"[qty])},
        {5, List.Sum(#"Bảng POS"[line_amount])},
        {6, List.Sum(#"Bảng POS"[discount_amount])},
        {7, Table.RowCount(#"Bảng đơn online")},
        {8, Text.From(#"Đếm đơn theo trạng thái"("Delivered")) & " / " & Text.From(#"Đếm đơn theo trạng thái"("Cancelled")) & " / " & Text.From(#"Đếm đơn theo trạng thái"("Returned"))},
        {9, List.Sum(#"Bảng đơn online"[net_amount])},
        {10, Table.RowCount(#"Bảng sổ cái")},
        {11, List.Sum(#"Bảng sổ cái"[amount_usd])},
        {12, Table.RowCount(#"Bảng Flash")},
        {13, List.Sum(#"Bảng Flash"[revenue_usd])}
    }, type table [stt = Int64.Type, gia_tri_nhom = any]),
    // Ghép số nhóm vào từng dòng của đề theo số thứ tự
    #"Ghép với QC_Summary" = Table.NestedJoin(#"Đánh số thứ tự", {"stt"}, #"Số nhóm tính lại", {"stt"}, "Nhom", JoinKind.LeftOuter),
    // Mở cột số nhóm ra từ bảng vừa ghép
    #"Mở cột số nhóm" = Table.ExpandTableColumn(#"Ghép với QC_Summary", "Nhom", {"gia_tri_nhom"}),
    // Đổi tên cột sang tên không dấu cho dễ dùng trong công thức
    #"Đổi tên cột" = Table.RenameColumns(#"Mở cột số nhóm", {
        {"File", "file"}, {"Chỉ tiêu kiểm soát", "chi_tieu"}, {"Giá trị", "gia_tri_de"}, {"Ghi chú", "ghi_chu_de"}}),
    // Chênh lệch = số nhóm − số của đề (làm tròn 2 chữ số).
    // Hai dòng dạng chữ (khoảng ngày, số đơn theo trạng thái) so bằng chữ: giống nhau thì chênh lệch 0, khác thì để trống
    #"Tính chênh lệch" = Table.AddColumn(#"Đổi tên cột", "chenh_lech",
        each if Value.Is([gia_tri_de], type number) and Value.Is([gia_tri_nhom], type number)
             then Number.Round([gia_tri_nhom] - [gia_tri_de], 2)
             else if Text.From([gia_tri_de]) = Text.From([gia_tri_nhom]) then 0 else null, type nullable number),
    // Đạt khi chênh lệch đúng bằng 0
    #"Đạt hay không" = Table.AddColumn(#"Tính chênh lệch", "dat", each [chenh_lech] <> null and [chenh_lech] = 0, type logical),
    // Chọn và sắp xếp cột để hiện trên sheet Kiem_tra
    #"Chọn cột" = Table.SelectColumns(#"Đạt hay không", {"stt", "file", "chi_tieu", "gia_tri_de", "gia_tri_nhom", "chenh_lech", "dat", "ghi_chu_de"})
in
    #"Chọn cột"
