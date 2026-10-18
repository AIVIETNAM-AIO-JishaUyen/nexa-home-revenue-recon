// q_RC_Store_Timing – Lệch ngày ghi sổ của cửa hàng theo tháng. Nhãn nguồn: [RC-CH-NGAYGS].
// Bán ngày nghỉ (thứ Bảy, Chủ nhật, ngày lễ) thì sổ cái ghi vào ngày làm việc kế tiếp; nếu ngày đó sang tháng sau
// thì doanh thu "chuyển" sang tháng sau. Khoản này = POS theo tháng ghi sổ − POS theo tháng bán (đã bỏ dòng trùng,
// USD theo tỷ giá ngày bán – cùng cách tính với bảng cầu nối). Tháng trước âm bao nhiêu thì tháng sau dương bấy nhiêu.
let
    // POS đã bỏ dòng trùng
    #"POS đã bỏ trùng" = Table.Buffer(Table.SelectRows(q_Transactions, each [channel] = "STORE" and not [is_duplicate])),
    // Chỉ các dòng bán tháng này nhưng ghi sổ tháng khác
    #"Dòng sang tháng khác" = Table.SelectRows(#"POS đã bỏ trùng", each [sale_period] <> [recognition_period]),
    // Số tiền chuyển ĐI khỏi tháng bán (ghi âm ở tháng bán)
    #"Chuyển đi" = Table.Group(#"Dòng sang tháng khác", {"sale_period"},
        {{"moved_out_usd", each - List.Sum([net_usd_daily]), type number}, {"lines_out", each Table.RowCount(_), Int64.Type},
         {"to_period", each Text.Combine(List.Distinct([recognition_period]), ", "), type text}}),
    // Số tiền chuyển ĐẾN tháng ghi sổ (ghi dương ở tháng ghi sổ)
    #"Chuyển đến" = Table.Group(#"Dòng sang tháng khác", {"recognition_period"},
        {{"moved_in_usd", each List.Sum([net_usd_daily]), type number},
         {"from_period", each Text.Combine(List.Distinct([sale_period]), ", "), type text}}),
    // Danh sách mọi tháng có POS (để tháng không có dòng chuyển vẫn hiện số 0)
    #"Các tháng" = Table.FromList(List.Sort(List.Distinct(#"POS đã bỏ trùng"[sale_period] & #"POS đã bỏ trùng"[recognition_period])), Splitter.SplitByNothing(), {"period"}),
    // Ghép số chuyển đi theo tháng
    #"Ghép chuyển đi" = Table.Join(#"Các tháng", {"period"}, #"Chuyển đi", {"sale_period"}, JoinKind.LeftOuter),
    // Ghép số chuyển đến theo tháng
    #"Ghép chuyển đến" = Table.Join(#"Ghép chuyển đi", {"period"}, #"Chuyển đến", {"recognition_period"}, JoinKind.LeftOuter),
    // Tháng không có dòng chuyển thì là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Ghép chuyển đến", null, 0, Replacer.ReplaceValue, {"moved_out_usd", "moved_in_usd", "lines_out"}),
    // Khoản lệch ngày ghi sổ của tháng = chuyển đến + chuyển đi (làm tròn 2 chữ số)
    #"Khoản lệch ngày ghi sổ" = Table.AddColumn(#"Ô trống thành 0", "store_posting_usd", each Number.Round([moved_in_usd] + [moved_out_usd], 2), type number),
    // Làm tròn hai cột tiền để dễ đọc
    #"Làm tròn" = Table.TransformColumns(#"Khoản lệch ngày ghi sổ", {{"moved_out_usd", each Number.Round(_, 2), type number}, {"moved_in_usd", each Number.Round(_, 2), type number}}),
    // Chọn cột
    #"Chọn cột" = Table.SelectColumns(#"Làm tròn", {"period", "lines_out", "moved_out_usd", "to_period", "moved_in_usd", "from_period", "store_posting_usd"}),
    // Dòng cả năm: tổng khoản lệch phải bằng 0 (mọi doanh thu chuyển đi đều được ghi ở tháng sau)
    #"Dòng cả năm" = #table(type table [period = text, lines_out = Int64.Type, moved_out_usd = number, to_period = text, moved_in_usd = number, from_period = text, store_posting_usd = number],
        {{"Cả năm", List.Sum(#"Chọn cột"[lines_out]), Number.Round(List.Sum(#"Chọn cột"[moved_out_usd]), 2), null,
          Number.Round(List.Sum(#"Chọn cột"[moved_in_usd]), 2), null, Number.Round(List.Sum(#"Chọn cột"[store_posting_usd]), 2)}}),
    // Nối dòng cả năm vào cuối
    #"Thêm dòng cả năm" = Table.Combine({#"Chọn cột", #"Dòng cả năm"})
in
    #"Thêm dòng cả năm"
