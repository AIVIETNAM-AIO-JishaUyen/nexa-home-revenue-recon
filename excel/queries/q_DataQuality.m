// q_DataQuality – Sheet chất lượng dữ liệu: mỗi dòng là 1 phép kiểm tra, tự đếm lại mỗi lần làm mới.
// Cột so_luong là số dòng (hoặc số ô) vi phạm; mong_doi là số "sạch"; trang_thai = "Đạt" nếu bằng mong đợi, ngược lại "Cần xem". Nhãn nguồn: [QC].
let
    // Giữ sẵn các bảng trong bộ nhớ (Table.Buffer) để không đọc lại file nhiều lần
    #"Giao dịch chung" = Table.Buffer(q_Transactions),
    // Bảng sổ cái
    #"Sổ cái" = Table.Buffer(q_GL),
    // Bảng đơn online
    #"Đơn online" = Table.Buffer(q_WEB),
    // Danh mục cửa hàng: mã POS và ngày đóng cửa
    #"Danh mục cửa hàng" = Table.Buffer(Table.RenameColumns(Table.SelectColumns(q_Store, {"pos_store_id", "close_date"}), {{"pos_store_id", "k_pos_store_id"}})),
    // Hàm phụ viết ngày dạng dd/MM/yyyy
    #"Ngày kiểu Việt Nam" = (d as nullable date) as text => if d = null then "" else Date.ToText(d, "dd/MM/yyyy", "vi-VN"),
    // Hàm phụ: gộp tối đa 5 mục chi tiết thành 1 dòng chữ
    #"Gộp chi tiết" = (ds as list) as text => Text.Combine(List.FirstN(ds, 5), "; ") & (if List.Count(ds) > 5 then "; …" else ""),

    // Kiểm tra 1: dòng POS trùng khóa receipt_no + line_no (bản xuất lần sau)
    #"Dòng POS trùng" = Table.SelectRows(#"Giao dịch chung", each [is_duplicate]),
    // Kiểm tra 2: ô cửa hàng × ngày ghi sổ có bán (POS đã bỏ trùng) mà sổ cái không có bút toán POS_* nào
    #"Ô có bán" = Table.Distinct(Table.SelectColumns(Table.SelectRows(#"Giao dịch chung", each [channel] = "STORE" and not [is_duplicate]), {"store_code", "recognition_date"})),
    // Các ô có bút toán doanh thu POS trên sổ cái
    #"Ô có bút toán" = Table.Distinct(Table.SelectColumns(Table.SelectRows(#"Sổ cái", each Text.StartsWith([journal_type], "POS_")), {"store_code", "posting_date"})),
    // Giữ các ô có bán mà không tìm thấy bút toán (ghép kiểu "chỉ có ở bên trái")
    #"Ô có bán mà thiếu bút toán" = Table.NestedJoin(#"Ô có bán", {"store_code", "recognition_date"}, #"Ô có bút toán", {"store_code", "posting_date"}, "gl", JoinKind.LeftAnti),
    // Kiểm tra 3: bút toán sổ cái không gắn cửa hàng nào
    #"Bút toán không gắn cửa hàng" = Table.SelectRows(#"Sổ cái", each [store_code] = null or [store_code] = ""),
    // Kiểm tra 4: đơn hủy mà vẫn có ngày giao
    #"Đơn hủy có ngày giao" = Table.SelectRows(#"Đơn online", each [order_status] = "Cancelled" and [delivery_date] <> null),
    // Kiểm tra 5: đơn giao trước ngày đặt
    #"Đơn giao trước ngày đặt" = Table.SelectRows(#"Đơn online", each [delivery_date] <> null and [delivery_date] < [order_date]),
    // Kiểm tra 6: hàng trả trước ngày giao
    #"Hàng trả trước ngày giao" = Table.SelectRows(#"Đơn online", each [return_date] <> null and ([delivery_date] = null or [return_date] < [delivery_date])),
    // Kiểm tra 7: dòng POS bán sau ngày cửa hàng đóng cửa
    #"POS ghép ngày đóng cửa" = Table.Join(Table.SelectRows(#"Giao dịch chung", each [channel] = "STORE"), {"pos_store_id"}, #"Danh mục cửa hàng", {"k_pos_store_id"}, JoinKind.LeftOuter),
    // Giữ dòng có ngày bán sau ngày đóng cửa
    #"Bán ở cửa hàng đã đóng" = Table.SelectRows(#"POS ghép ngày đóng cửa", each [close_date] <> null and [sale_date] > [close_date]),
    // Kiểm tra 8: dòng thiếu tỷ giá ngày (không đổi được ra USD)
    #"Dòng thiếu tỷ giá ngày" = Table.SelectRows(#"Giao dịch chung", each [fx_daily] = null),
    // Kiểm tra 9: dòng POS có mã cửa hàng không có trong danh mục
    #"Mã cửa hàng không ghép được" = Table.SelectRows(#"Giao dịch chung", each [channel] = "STORE" and [store_code] = null),
    // Kiểm tra 10: bút toán tay điều chỉnh không có giấy tờ (mã MJ-ADJ)
    #"Bút toán tay không có giấy tờ" = Table.SelectRows(#"Sổ cái", each [journal_type] = "MANUAL" and [source_ref] <> null and Text.StartsWith([source_ref], "MJ-ADJ")),
    // Kiểm tra 11: dòng có tháng ghi nhận (hoặc tháng nhận hàng trả) mà thiếu tỷ giá cuối tháng – xảy ra khi nạp tháng mới mà sheet fx_month_end chưa có tháng đó
    #"Dòng thiếu tỷ giá cuối tháng" = Table.SelectRows(#"Giao dịch chung", each ([recognition_date] <> null and [fx_month_end] = null) or ([return_date] <> null and [fx_month_end_return] = null)),
    // Kiểm tra 12: dòng POS không tìm được ngày ghi sổ – xảy ra khi ngày bán nằm ngoài sheet calendar
    #"Dòng POS thiếu ngày ghi sổ" = Table.SelectRows(#"Giao dịch chung", each [channel] = "STORE" and [recognition_date] = null),
    // Kiểm tra 13: số dòng bảng giao dịch chung phải đúng bằng số dòng POS + số đơn online (ghép bảng không được làm nhân đôi hay mất dòng)
    #"Số dòng lệch khi gộp" = Table.RowCount(#"Giao dịch chung") - (Table.RowCount(q_POS) + Table.RowCount(#"Đơn online")),
    // Hàm phụ: tên cửa hàng để ghi chi tiết (trống thì ghi rõ là không rõ cửa hàng)
    #"Tên cửa hàng" = (ma as nullable text) as text => if ma = null then "(không rõ cửa hàng)" else ma,

    // Gom kết quả thành bảng
    #"Bảng kiểm tra" = #table(
        type table [stt = Int64.Type, kiem_tra = text, bang_nguon = text, so_luong = Int64.Type, mong_doi = Int64.Type, chi_tiet = text],
        {
            {1, "Dòng POS trùng khóa receipt_no + line_no", "q_Transactions (cờ từ q_POS)", Table.RowCount(#"Dòng POS trùng"), 0,
                #"Gộp chi tiết"(List.Distinct(List.Transform(Table.ToRecords(#"Dòng POS trùng"), each #"Tên cửa hàng"([store_code]) & " ngày " & #"Ngày kiểu Việt Nam"([sale_date]))))},
            {2, "Ô cửa hàng × ngày ghi sổ có bán mà sổ cái thiếu bút toán", "q_Transactions, q_GL", Table.RowCount(#"Ô có bán mà thiếu bút toán"), 0,
                #"Gộp chi tiết"(List.Transform(Table.ToRecords(#"Ô có bán mà thiếu bút toán"), each #"Tên cửa hàng"([store_code]) & " ngày " & #"Ngày kiểu Việt Nam"([recognition_date])))},
            {3, "Bút toán sổ cái không gắn cửa hàng", "q_GL", Table.RowCount(#"Bút toán không gắn cửa hàng"), 0,
                #"Gộp chi tiết"(List.Transform(Table.ToRecords(#"Bút toán không gắn cửa hàng"), each [journal_id] & " (" & (if [source_ref] = null then "" else [source_ref]) & ")"))},
            {4, "Đơn hủy mà có ngày giao", "q_WEB", Table.RowCount(#"Đơn hủy có ngày giao"), 0, ""},
            {5, "Đơn giao trước ngày đặt", "q_WEB", Table.RowCount(#"Đơn giao trước ngày đặt"), 0, ""},
            {6, "Hàng trả trước ngày giao", "q_WEB", Table.RowCount(#"Hàng trả trước ngày giao"), 0, ""},
            {7, "Dòng POS bán sau ngày cửa hàng đóng cửa", "q_Transactions, q_Store", Table.RowCount(#"Bán ở cửa hàng đã đóng"), 0, ""},
            {8, "Dòng thiếu tỷ giá ngày (không đổi được ra USD)", "q_Transactions", Table.RowCount(#"Dòng thiếu tỷ giá ngày"), 0, ""},
            {9, "Dòng POS có mã cửa hàng không có trong danh mục", "q_Transactions, q_Store", Table.RowCount(#"Mã cửa hàng không ghép được"), 0, ""},
            {10, "Bút toán tay điều chỉnh không có giấy tờ (mã MJ-ADJ)", "q_GL", Table.RowCount(#"Bút toán tay không có giấy tờ"), 0,
                #"Gộp chi tiết"(List.Transform(Table.ToRecords(#"Bút toán tay không có giấy tờ"), each [journal_id] & " " & #"Ngày kiểu Việt Nam"([posting_date]) & " " & Number.ToText([revenue_usd], "#,##0.00", "vi-VN") & " USD"))},
            {11, "Dòng thiếu tỷ giá cuối tháng (tháng ghi nhận hoặc tháng nhận hàng trả)", "q_Transactions, q_FX_MonthEnd", Table.RowCount(#"Dòng thiếu tỷ giá cuối tháng"), 0, ""},
            {12, "Dòng POS không tìm được ngày ghi sổ (ngày bán ngoài lịch)", "q_Transactions, q_Calendar", Table.RowCount(#"Dòng POS thiếu ngày ghi sổ"), 0, ""},
            {13, "Số dòng bảng giao dịch chung − (dòng POS + đơn online)", "q_Transactions, q_POS, q_WEB", #"Số dòng lệch khi gộp", 0, ""}
        }),
    // Trạng thái: "Đạt" khi số lượng bằng mong đợi, ngược lại "Cần xem"
    #"Thêm trạng thái" = Table.AddColumn(#"Bảng kiểm tra", "trang_thai", each if [so_luong] = [mong_doi] then "Đạt" else "Cần xem", type text),
    // Xếp cột: trạng thái đứng trước chi tiết
    #"Xếp cột" = Table.ReorderColumns(#"Thêm trạng thái", {"stt", "kiem_tra", "bang_nguon", "so_luong", "mong_doi", "trang_thai", "chi_tiet"})
in
    #"Xếp cột"
