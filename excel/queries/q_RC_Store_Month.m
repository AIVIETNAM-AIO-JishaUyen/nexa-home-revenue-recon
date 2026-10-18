// q_RC_Store_Month – Cửa hàng × tháng: chênh lệch Sổ cái − POS TRƯỚC và SAU khi đưa hai bên về cùng cách tính, cờ ⚠ vượt ngưỡng.
// Nhãn nguồn: [RC-CH-THANG]. So bằng USD theo tỷ giá cuối tháng (cách sổ cái quy đổi) để chênh lệch không lẫn phần tỷ giá.
//   Trước (chưa xử lý): POS lấy mọi dòng (kể cả dòng trùng), cộng theo THÁNG BÁN, đổi theo tỷ giá cuối tháng bán – cách dashboard mẫu tính.
//   Sau (cùng cách tính): POS bỏ dòng trùng, cộng theo THÁNG GHI SỔ, đổi theo tỷ giá cuối tháng ghi sổ – giống sổ cái.
//   Sổ cái: bút toán doanh thu POS (POS_DAILY, POS_CATCHUP) theo tháng ghi sổ.
// Ngưỡng: |chênh lệch| > 200 USD VÀ |chênh lệch| / |sổ cái| > 1% (sổ cái = 0 thì chỉ xét 200 USD).
let
    // Ngưỡng tiền và ngưỡng phần trăm (đổi ở đây nếu Giám đốc Tài chính đổi ngưỡng)
    #"Ngưỡng USD" = 200,
    // Ngưỡng phần trăm so với |sổ cái|
    #"Ngưỡng phần trăm" = 0.01,
    // Dòng POS của bảng giao dịch chung
    #"Dòng POS" = Table.Buffer(Table.SelectRows(q_Transactions, each [channel] = "STORE")),
    // Tỷ giá cuối tháng, đổi tên để ghép theo tháng bán
    #"Tỷ giá cuối tháng" = Table.Buffer(Table.RenameColumns(Table.SelectColumns(q_FX_MonthEnd, {"period", "currency", "usd_to_ccy"}),
        {{"period", "me_period"}, {"currency", "me_currency"}, {"usd_to_ccy", "fx_month_end_sale"}})),
    // Ghép tỷ giá cuối THÁNG BÁN vào từng dòng POS
    #"Ghép tỷ giá tháng bán" = Table.Join(#"Dòng POS", {"sale_period", "currency"}, #"Tỷ giá cuối tháng", {"me_period", "me_currency"}, JoinKind.LeftOuter),
    // Đổi từng dòng ra USD theo tỷ giá cuối tháng bán (chia cho tỷ giá)
    #"USD theo tỷ giá tháng bán" = Table.AddColumn(#"Ghép tỷ giá tháng bán", "net_usd_sale_month_end", each [net_local] / [fx_month_end_sale], type number),
    // Phần "trước": mọi dòng, theo tháng bán, tỷ giá cuối tháng bán
    #"POS trước xử lý" = Table.Group(#"USD theo tỷ giá tháng bán", {"store_code", "sale_period"},
        {{"pos_raw_usd", each List.Sum([net_usd_sale_month_end]), type number}}),
    // Phần "sau": bỏ dòng trùng, theo tháng ghi sổ, tỷ giá cuối tháng ghi sổ (cột có sẵn trong bảng giao dịch chung)
    #"POS sau xử lý" = Table.Group(Table.SelectRows(#"Dòng POS", each not [is_duplicate]), {"store_code", "recognition_period"},
        {{"pos_norm_usd", each List.Sum([net_usd_month_end]), type number}}),
    // Sổ cái: bút toán POS theo cửa hàng × tháng ghi sổ
    #"Sổ cái theo tháng" = Table.Group(Table.SelectRows(q_GL, each Text.StartsWith([journal_type], "POS_")), {"store_code", "period"},
        {{"gl_usd", each List.Sum([revenue_usd]), type number}}),
    // Đưa 3 bảng về cùng tên cột (store_code, period) rồi nối dọc; cột không có ở bảng nào thì để trống
    #"Nối 3 bảng" = Table.Combine({
        Table.RenameColumns(#"POS trước xử lý", {{"sale_period", "period"}}),
        Table.RenameColumns(#"POS sau xử lý", {{"recognition_period", "period"}}),
        #"Sổ cái theo tháng"}),
    // Cộng lại theo cửa hàng × tháng (giữ mọi ô có ở ít nhất một bảng – tương đương ghép đủ 2 bên)
    #"Cộng theo cửa hàng và tháng" = Table.Group(#"Nối 3 bảng", {"store_code", "period"},
        {{"gl_usd", each List.Sum(List.RemoveNulls([gl_usd]) & {0}), type number},
         {"pos_raw_usd", each List.Sum(List.RemoveNulls([pos_raw_usd]) & {0}), type number},
         {"pos_norm_usd", each List.Sum(List.RemoveNulls([pos_norm_usd]) & {0}), type number}}),
    // Chênh lệch trước và sau (Sổ cái − POS), làm tròn 2 chữ số
    #"Chênh lệch" = Table.AddColumn(Table.AddColumn(#"Cộng theo cửa hàng và tháng",
        "diff_raw_usd", each Number.Round([gl_usd] - [pos_raw_usd], 2), type number),
        "diff_norm_usd", each Number.Round([gl_usd] - [pos_norm_usd], 2), type number),
    // % chênh lệch so với |sổ cái| (để trống khi sổ cái = 0)
    #"Phần trăm" = Table.AddColumn(Table.AddColumn(#"Chênh lệch",
        "pct_raw", each if [gl_usd] = 0 then null else [diff_raw_usd] / Number.Abs([gl_usd]), type nullable number),
        "pct_norm", each if [gl_usd] = 0 then null else [diff_norm_usd] / Number.Abs([gl_usd]), type nullable number),
    // Hàm cờ ⚠: vượt cả ngưỡng tiền và ngưỡng phần trăm (phần trăm trống thì chỉ xét ngưỡng tiền)
    #"Vượt ngưỡng?" = (diff as number, pct as nullable number) as logical =>
        Number.Abs(diff) > #"Ngưỡng USD" and (pct = null or Number.Abs(pct) > #"Ngưỡng phần trăm"),
    // Cờ trước và sau
    #"Cờ vượt ngưỡng" = Table.AddColumn(Table.AddColumn(#"Phần trăm",
        "flag_raw", each #"Vượt ngưỡng?"([diff_raw_usd], [pct_raw]), type logical),
        "flag_norm", each #"Vượt ngưỡng?"([diff_norm_usd], [pct_norm]), type logical),
    // Ký hiệu ⚠ cho dễ nhìn trên bảng
    #"Ký hiệu cờ" = Table.AddColumn(#"Cờ vượt ngưỡng", "canh_bao_sau", each if [flag_norm] then "⚠ vượt ngưỡng" else "", type text),
    // Sắp theo tháng rồi theo mức lệch sau xử lý (lệch lớn lên trên)
    #"Sắp xếp" = Table.Sort(Table.AddColumn(#"Ký hiệu cờ", "abs_norm", each Number.Abs([diff_norm_usd]), type number),
        {{"period", Order.Ascending}, {"abs_norm", Order.Descending}, {"store_code", Order.Ascending}}),
    // Bỏ cột phụ
    #"Bỏ cột phụ" = Table.RemoveColumns(#"Sắp xếp", {"abs_norm"})
in
    #"Bỏ cột phụ"
