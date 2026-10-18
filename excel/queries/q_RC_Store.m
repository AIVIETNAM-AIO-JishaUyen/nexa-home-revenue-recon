// q_RC_Store – Đối soát cửa hàng × ngày ghi sổ × loại tiền, so bằng nội tệ. Nhãn nguồn khi trích số: [RC-CH].
// POS (đã bỏ dòng trùng) cộng theo ngày ghi sổ; sổ cái lấy bút toán POS_DAILY và POS_CATCHUP. Ghép đủ 2 bên rồi chia 4 trường hợp:
// Khớp · Chỉ có ở POS · Chỉ có ở sổ cái · Có cả hai nhưng lệch tiền.
let
    // POS đã bỏ dòng trùng, lấy từ bảng giao dịch chung
    #"POS đã bỏ trùng" = Table.Buffer(Table.SelectRows(q_Transactions, each [channel] = "STORE" and not [is_duplicate])),
    // Cộng POS theo ô cửa hàng × ngày ghi sổ × loại tiền
    #"POS theo ô" = Table.Group(#"POS đã bỏ trùng", {"store_code", "recognition_date", "currency"},
        {{"pos_local", each List.Sum([net_local]), type number}, {"pos_lines", each Table.RowCount(_), Int64.Type}}),
    // Bút toán doanh thu POS của sổ cái (POS_DAILY, POS_CATCHUP)
    #"Bút toán POS của sổ cái" = Table.Buffer(Table.SelectRows(q_GL, each Text.StartsWith([journal_type], "POS_"))),
    // Cộng sổ cái theo cùng ô; giữ mã bút toán để tra ngược
    #"Sổ cái theo ô" = Table.Group(#"Bút toán POS của sổ cái", {"store_code", "posting_date", "currency"},
        {{"gl_local", each List.Sum([revenue_local]), type number},
         {"journal_ids", each Text.Combine([journal_id], ", "), type text},
         {"journal_types", each Text.Combine(List.Distinct([journal_type]), ", "), type text}}),
    // Đổi tên khóa bên sổ cái để ghép không trùng tên cột
    #"Sổ cái đổi tên khóa" = Table.RenameColumns(#"Sổ cái theo ô", {{"store_code", "k_store_code"}, {"posting_date", "k_posting_date"}, {"currency", "k_currency"}}),
    // Ghép đủ 2 bên (giữ mọi ô của cả POS và sổ cái – full outer join)
    #"Ghép POS với sổ cái" = Table.Join(#"POS theo ô", {"store_code", "recognition_date", "currency"},
        #"Sổ cái đổi tên khóa", {"k_store_code", "k_posting_date", "k_currency"}, JoinKind.FullOuter),
    // Ghi nhận ô có mặt ở bên nào (trước khi điền 0 cho bên thiếu)
    #"Đánh dấu bên có mặt" = Table.AddColumn(Table.AddColumn(#"Ghép POS với sổ cái",
        "co_pos", each [pos_local] <> null, type logical),
        "co_so_cai", each [gl_local] <> null, type logical),
    // Gộp khóa của 2 bên thành một: mã cửa hàng, ngày ghi sổ, loại tiền
    #"Gộp khóa" = Table.AddColumn(Table.AddColumn(Table.AddColumn(#"Đánh dấu bên có mặt",
        "store", each if [store_code] <> null then [store_code] else [k_store_code], type text),
        "posting_date", each if [recognition_date] <> null then [recognition_date] else [k_posting_date], type date),
        "ccy", each if [currency] <> null then [currency] else [k_currency], type text),
    // Bỏ các cột khóa cũ, đặt lại tên
    #"Bỏ khóa cũ" = Table.RenameColumns(Table.RemoveColumns(#"Gộp khóa", {"store_code", "recognition_date", "currency", "k_store_code", "k_posting_date", "k_currency"}),
        {{"store", "store_code"}, {"ccy", "currency"}}),
    // Bên thiếu thì coi số tiền là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Bỏ khóa cũ", null, 0, Replacer.ReplaceValue, {"pos_local", "gl_local", "pos_lines"}),
    // Chênh lệch theo nội tệ = sổ cái − POS (làm tròn 2 chữ số)
    #"Chênh lệch nội tệ" = Table.AddColumn(#"Ô trống thành 0", "diff_local", each Number.Round([gl_local] - [pos_local], 2), type number),
    // Chia 4 trường hợp
    #"Trường hợp" = Table.AddColumn(#"Chênh lệch nội tệ", "match_status",
        each if not [co_pos] then "Chỉ có ở sổ cái"
             else if not [co_so_cai] then "Chỉ có ở POS"
             else if Number.Abs([diff_local]) <= 0.005 then "Khớp"
             else "Có cả hai nhưng lệch tiền", type text),
    // Tỷ giá ngày của ngày ghi sổ, để đổi phần lệch ra USD (quy ước cho lỗi chuyển dữ liệu)
    #"Tỷ giá ngày" = Table.Buffer(Table.RenameColumns(q_FX_Daily, {{"rate_date", "fx_date"}, {"currency", "fx_currency"}, {"usd_to_ccy", "fx_daily_posting"}})),
    // Ghép tỷ giá ngày ghi sổ
    #"Ghép tỷ giá" = Table.Join(#"Trường hợp", {"posting_date", "currency"}, #"Tỷ giá ngày", {"fx_date", "fx_currency"}, JoinKind.LeftOuter),
    // Phần lệch đổi ra USD (chia cho tỷ giá)
    #"Lệch ra USD" = Table.AddColumn(#"Ghép tỷ giá", "diff_usd", each [diff_local] / [fx_daily_posting], type number),
    // Tháng ghi sổ
    #"Thêm tháng" = Table.AddColumn(#"Lệch ra USD", "period", each Date.ToText([posting_date], "yyyy-MM", "en-US"), type text),
    // Chọn cột và sắp: ô lệch lên đầu
    #"Chọn cột" = Table.SelectColumns(#"Thêm tháng", {"store_code", "posting_date", "period", "currency", "pos_lines", "pos_local", "gl_local",
        "diff_local", "diff_usd", "match_status", "journal_ids", "journal_types"}),
    // Sắp: ô không khớp lên trên, rồi theo ngày và cửa hàng
    #"Sắp xếp" = Table.Sort(Table.AddColumn(#"Chọn cột", "thu_tu", each if [match_status] = "Khớp" then 1 else 0, Int64.Type),
        {{"thu_tu", Order.Ascending}, {"posting_date", Order.Ascending}, {"store_code", Order.Ascending}}),
    // Bỏ cột thứ tự phụ
    #"Bỏ cột phụ" = Table.RemoveColumns(#"Sắp xếp", {"thu_tu"})
in
    #"Bỏ cột phụ"
