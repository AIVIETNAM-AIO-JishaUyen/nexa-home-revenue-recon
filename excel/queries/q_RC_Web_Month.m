// q_RC_Web_Month – Kênh online theo tháng: chênh lệch Sổ cái − WEB TRƯỚC và SAU khi đưa về cùng cách tính, cờ ⚠ vượt ngưỡng. Nhãn nguồn: [RC-WEB].
// So bằng USD theo tỷ giá cuối tháng (cách sổ cái quy đổi), cùng cách với bảng cửa hàng × tháng.
//   Trước (chưa xử lý): đơn chưa hủy, cộng theo THÁNG ĐẶT, tỷ giá cuối tháng đặt – cách dashboard mẫu tính.
//   Sau (cùng cách tính): đơn chưa hủy theo THÁNG GIAO (tỷ giá cuối tháng giao) trừ hàng trả theo THÁNG TRẢ (tỷ giá cuối tháng trả).
//   Sổ cái: bút toán WEB_DELIVERY và WEB_RETURN (không lấy bút toán tay phí vận chuyển, chuyển kênh, ADJ).
let
    // Ngưỡng tiền và ngưỡng phần trăm, giống bảng cửa hàng
    #"Ngưỡng USD" = 200,
    // Ngưỡng phần trăm so với |sổ cái|
    #"Ngưỡng phần trăm" = 0.01,
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = Table.FromList(List.Sort(List.Distinct(q_FLASH[period])), Splitter.SplitByNothing(), {"period"}),
    // Đơn online chưa hủy
    #"Đơn chưa hủy" = Table.Buffer(Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] <> "Cancelled")),
    // Tỷ giá cuối tháng, đổi tên để ghép theo tháng đặt
    #"Tỷ giá cuối tháng" = Table.Buffer(Table.RenameColumns(Table.SelectColumns(q_FX_MonthEnd, {"period", "currency", "usd_to_ccy"}),
        {{"period", "me_period"}, {"currency", "me_currency"}, {"usd_to_ccy", "fx_month_end_order"}})),
    // Ghép tỷ giá cuối THÁNG ĐẶT vào từng đơn, đổi ra USD
    #"USD theo tỷ giá tháng đặt" = Table.AddColumn(Table.Join(#"Đơn chưa hủy", {"sale_period", "currency"}, #"Tỷ giá cuối tháng", {"me_period", "me_currency"}, JoinKind.LeftOuter),
        "net_usd_order_month_end", each [net_local] / [fx_month_end_order], type number),
    // Phần "trước": theo tháng đặt
    #"Trước xử lý" = Table.Group(#"USD theo tỷ giá tháng đặt", {"sale_period"}, {{"web_raw_usd", each List.Sum([net_usd_order_month_end]), type number}}),
    // Phần "sau", vế giao hàng: theo tháng giao, tỷ giá cuối tháng giao
    #"Sau xử lý: giao hàng" = Table.Group(#"Đơn chưa hủy", {"recognition_period"}, {{"deliv_usd", each List.Sum([net_usd_month_end]), type number}}),
    // Phần "sau", vế hàng trả: theo tháng trả, tỷ giá cuối tháng trả (ghi âm)
    #"Sau xử lý: hàng trả" = Table.Group(Table.SelectRows(#"Đơn chưa hủy", each [status] = "Returned"), {"return_period"},
        {{"ret_usd", each - List.Sum([net_usd_month_end_return]), type number}}),
    // Sổ cái: bút toán giao hàng và hàng trả theo tháng ghi sổ
    #"Sổ cái theo tháng" = Table.Group(Table.SelectRows(q_GL, each [journal_type] = "WEB_DELIVERY" or [journal_type] = "WEB_RETURN"), {"period"},
        {{"gl_usd", each List.Sum([revenue_usd]), type number}}),
    // Ghép lần lượt 4 bảng vào danh sách tháng đối soát
    #"Ghép trước" = Table.Join(#"Tháng đối soát", {"period"}, #"Trước xử lý", {"sale_period"}, JoinKind.LeftOuter),
    // Ghép vế giao hàng
    #"Ghép giao hàng" = Table.Join(#"Ghép trước", {"period"}, #"Sau xử lý: giao hàng", {"recognition_period"}, JoinKind.LeftOuter),
    // Ghép vế hàng trả
    #"Ghép hàng trả" = Table.Join(#"Ghép giao hàng", {"period"}, #"Sau xử lý: hàng trả", {"return_period"}, JoinKind.LeftOuter),
    // Đổi tên cột tháng của sổ cái rồi ghép
    #"Ghép sổ cái" = Table.Join(#"Ghép hàng trả", {"period"}, Table.RenameColumns(#"Sổ cái theo tháng", {{"period", "k_period"}}), {"k_period"}, JoinKind.LeftOuter),
    // Tháng thiếu số thì coi là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Ghép sổ cái", null, 0, Replacer.ReplaceValue, {"web_raw_usd", "deliv_usd", "ret_usd", "gl_usd"}),
    // WEB sau xử lý = giao hàng + hàng trả (hàng trả đã là số âm)
    #"WEB sau xử lý" = Table.AddColumn(#"Ô trống thành 0", "web_norm_usd", each [deliv_usd] + [ret_usd], type number),
    // Chênh lệch trước và sau (Sổ cái − WEB), làm tròn 2 chữ số
    #"Chênh lệch" = Table.AddColumn(Table.AddColumn(#"WEB sau xử lý",
        "diff_raw_usd", each Number.Round([gl_usd] - [web_raw_usd], 2), type number),
        "diff_norm_usd", each Number.Round([gl_usd] - [web_norm_usd], 2), type number),
    // % chênh lệch so với |sổ cái|
    #"Phần trăm" = Table.AddColumn(Table.AddColumn(#"Chênh lệch",
        "pct_raw", each if [gl_usd] = 0 then null else [diff_raw_usd] / Number.Abs([gl_usd]), type nullable number),
        "pct_norm", each if [gl_usd] = 0 then null else [diff_norm_usd] / Number.Abs([gl_usd]), type nullable number),
    // Hàm cờ ⚠: vượt cả ngưỡng tiền và ngưỡng phần trăm
    #"Vượt ngưỡng?" = (diff as number, pct as nullable number) as logical =>
        Number.Abs(diff) > #"Ngưỡng USD" and (pct = null or Number.Abs(pct) > #"Ngưỡng phần trăm"),
    // Cờ trước và sau
    #"Cờ vượt ngưỡng" = Table.AddColumn(Table.AddColumn(#"Phần trăm",
        "flag_raw", each #"Vượt ngưỡng?"([diff_raw_usd], [pct_raw]), type logical),
        "flag_norm", each #"Vượt ngưỡng?"([diff_norm_usd], [pct_norm]), type logical),
    // Chọn cột, sắp theo tháng
    #"Chọn cột" = Table.Sort(Table.SelectColumns(#"Cờ vượt ngưỡng", {"period", "gl_usd", "web_raw_usd", "web_norm_usd", "deliv_usd", "ret_usd",
        "diff_raw_usd", "pct_raw", "flag_raw", "diff_norm_usd", "pct_norm", "flag_norm"}), {{"period", Order.Ascending}})
in
    #"Chọn cột"
