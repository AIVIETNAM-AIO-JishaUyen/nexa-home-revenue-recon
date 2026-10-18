// q_Web_Timing – Lệch thời điểm online theo tháng. Nhãn nguồn: [RC-WEB].
// Flash ghi đơn theo NGÀY ĐẶT, sổ cái ghi theo NGÀY GIAO. Khoản này = đơn chưa hủy cộng theo tháng giao − cộng theo tháng đặt
// (USD theo tỷ giá ngày đặt, cùng cách tính với bảng cầu nối). Trong năm, tiền chuyển đi ở tháng này được nhận lại ở tháng sau;
// phần còn lại của cả năm chỉ là đơn vắt qua năm: đặt năm trước giao năm nay (cộng) và đặt năm nay giao năm sau (trừ).
let
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = List.Buffer(List.Sort(List.Distinct(q_FLASH[period]))),
    // Đơn chưa hủy, đánh dấu tháng đặt / tháng giao có thuộc kỳ đối soát không
    #"Đơn chưa hủy" = Table.Buffer(Table.AddColumn(Table.AddColumn(
        Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] <> "Cancelled"),
        "dat_trong_ky", each List.Contains(#"Tháng đối soát", [sale_period]), type logical),
        "giao_trong_ky", each List.Contains(#"Tháng đối soát", [recognition_period]), type logical)),
    // Đơn đặt và giao khác tháng
    #"Đơn khác tháng" = Table.SelectRows(#"Đơn chưa hủy", each [sale_period] <> [recognition_period]),
    // Tiền chuyển ĐI khỏi tháng đặt (ghi âm ở tháng đặt)
    #"Chuyển đi" = Table.Group(#"Đơn khác tháng", {"sale_period"},
        {{"moved_out_usd", each - List.Sum([net_usd_daily]), type number}, {"orders_out", each Table.RowCount(_), Int64.Type}}),
    // Tiền chuyển ĐẾN tháng giao (ghi dương ở tháng giao)
    #"Chuyển đến" = Table.Group(#"Đơn khác tháng", {"recognition_period"},
        {{"moved_in_usd", each List.Sum([net_usd_daily]), type number}, {"orders_in", each Table.RowCount(_), Int64.Type}}),
    // Bảng tháng đối soát
    #"Các tháng" = Table.FromList(#"Tháng đối soát", Splitter.SplitByNothing(), {"period"}),
    // Ghép số chuyển đi và chuyển đến theo tháng
    #"Ghép" = Table.Join(Table.Join(#"Các tháng", {"period"}, #"Chuyển đi", {"sale_period"}, JoinKind.LeftOuter),
        {"period"}, #"Chuyển đến", {"recognition_period"}, JoinKind.LeftOuter),
    // Tháng không có đơn chuyển thì là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Ghép", null, 0, Replacer.ReplaceValue, {"moved_out_usd", "orders_out", "moved_in_usd", "orders_in"}),
    // Khoản lệch thời điểm online của tháng = chuyển đến + chuyển đi
    #"Khoản lệch thời điểm" = Table.AddColumn(#"Ô trống thành 0", "online_timing_usd", each Number.Round([moved_in_usd] + [moved_out_usd], 2), type number),
    // Làm tròn hai cột tiền
    #"Làm tròn" = Table.TransformColumns(#"Khoản lệch thời điểm", {{"moved_out_usd", each Number.Round(_, 2), type number}, {"moved_in_usd", each Number.Round(_, 2), type number}}),
    // Chọn cột
    #"Chọn cột" = Table.SelectColumns(#"Làm tròn", {"period", "orders_out", "moved_out_usd", "orders_in", "moved_in_usd", "online_timing_usd"}),
    // Đơn đặt TRƯỚC kỳ, giao TRONG kỳ (đầu năm: sổ cái có, Flash không có)
    #"Vắt qua đầu kỳ" = Table.SelectRows(#"Đơn chưa hủy", each not [dat_trong_ky] and [giao_trong_ky]),
    // Đơn đặt TRONG kỳ, giao SAU kỳ (cuối năm: Flash có, sổ cái chưa có)
    #"Vắt qua cuối kỳ" = Table.SelectRows(#"Đơn chưa hủy", each [dat_trong_ky] and not [giao_trong_ky]),
    // Tổng cả năm của khoản lệch thời điểm
    #"Tổng cả năm" = Number.Round(List.Sum(#"Chọn cột"[online_timing_usd]), 2),
    // 3 dòng tổng: cả năm; tách thành phần đầu kỳ và cuối kỳ; dòng kiểm tra (cả năm − hai phần, phải bằng 0)
    #"Dòng tổng" = #table(type table [period = text, orders_out = Int64.Type, moved_out_usd = number, orders_in = Int64.Type, moved_in_usd = number, online_timing_usd = number],
        {{"Cả năm", List.Sum(#"Chọn cột"[orders_out]), Number.Round(List.Sum(#"Chọn cột"[moved_out_usd]), 2),
          List.Sum(#"Chọn cột"[orders_in]), Number.Round(List.Sum(#"Chọn cột"[moved_in_usd]), 2), #"Tổng cả năm"},
         {"Trong đó: đặt trước kỳ, giao trong kỳ", null, null, Table.RowCount(#"Vắt qua đầu kỳ"), null, Number.Round(List.Sum(#"Vắt qua đầu kỳ"[net_usd_daily]), 2)},
         {"Trong đó: đặt trong kỳ, giao sau kỳ", Table.RowCount(#"Vắt qua cuối kỳ"), null, null, null, Number.Round(- List.Sum(#"Vắt qua cuối kỳ"[net_usd_daily]), 2)},
         {"Kiểm tra: cả năm − hai phần trên (phải bằng 0)", null, null, null, null,
          Number.Round(#"Tổng cả năm" - List.Sum(#"Vắt qua đầu kỳ"[net_usd_daily]) + List.Sum(#"Vắt qua cuối kỳ"[net_usd_daily]), 2)}}),
    // Nối các dòng tổng vào cuối
    #"Thêm dòng tổng" = Table.Combine({#"Chọn cột", #"Dòng tổng"})
in
    #"Thêm dòng tổng"
