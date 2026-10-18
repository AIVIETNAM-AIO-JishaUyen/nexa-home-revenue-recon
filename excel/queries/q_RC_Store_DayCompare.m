// q_RC_Store_DayCompare – Theo từng tháng: số ô cửa hàng × ngày, số ô lệch khi so theo ngày ghi sổ (đúng cách),
// và số ô lệch nếu so POS theo NGÀY BÁN, chưa bỏ dòng trùng (cách "chưa xử lý"). Cho thấy vì sao phải đưa về cùng cách tính.
// Nhãn nguồn: [RC-CH].
let
    // Kết quả đối soát theo ngày ghi sổ
    #"Ô theo ngày ghi sổ" = Table.Buffer(q_RC_Store),
    // Đếm theo tháng: số ô và số ô không khớp
    #"Đếm theo ngày ghi sổ" = Table.Group(#"Ô theo ngày ghi sổ", {"period"},
        {{"cells_posting", each Table.RowCount(_), Int64.Type},
         {"mismatch_posting", each Table.RowCount(Table.SelectRows(_, each [match_status] <> "Khớp")), Int64.Type}}),
    // POS chưa xử lý: mọi dòng (kể cả dòng trùng), cộng theo NGÀY BÁN
    #"POS theo ngày bán" = Table.Group(Table.SelectRows(q_Transactions, each [channel] = "STORE"), {"store_code", "sale_date", "currency"},
        {{"pos_local", each List.Sum([net_local]), type number}}),
    // Sổ cái POS_* theo ngày ghi sổ, đổi tên khóa để ghép
    #"Sổ cái theo ngày" = Table.RenameColumns(Table.Group(Table.SelectRows(q_GL, each Text.StartsWith([journal_type], "POS_")), {"store_code", "posting_date", "currency"},
        {{"gl_local", each List.Sum([revenue_local]), type number}}), {{"store_code", "k_store_code"}, {"posting_date", "k_date"}, {"currency", "k_currency"}}),
    // Ghép đủ 2 bên: ngày bán của POS đối với ngày ghi sổ của sổ cái
    #"Ghép theo ngày bán" = Table.Join(#"POS theo ngày bán", {"store_code", "sale_date", "currency"}, #"Sổ cái theo ngày", {"k_store_code", "k_date", "k_currency"}, JoinKind.FullOuter),
    // Ngày của ô (bên nào có thì lấy bên đó) và chênh lệch
    #"Ngày và chênh lệch" = Table.AddColumn(Table.AddColumn(#"Ghép theo ngày bán",
        "cell_date", each if [sale_date] <> null then [sale_date] else [k_date], type date),
        "diff_local", each (if [gl_local] = null then 0 else [gl_local]) - (if [pos_local] = null then 0 else [pos_local]), type number),
    // Tháng của ô
    #"Tháng của ô" = Table.AddColumn(#"Ngày và chênh lệch", "period", each Date.ToText([cell_date], "yyyy-MM", "en-US"), type text),
    // Đếm số ô lệch khi so theo ngày bán
    #"Đếm theo ngày bán" = Table.Group(#"Tháng của ô", {"period"},
        {{"mismatch_sale_date", each Table.RowCount(Table.SelectRows(_, each Number.Abs([diff_local]) > 0.005)), Int64.Type}}),
    // Đổi tên khóa để ghép 2 bảng đếm
    #"Đổi tên khóa" = Table.RenameColumns(#"Đếm theo ngày bán", {{"period", "k_period"}}),
    // Ghép 2 bảng đếm theo tháng (chỉ giữ tháng của năm đối soát)
    #"Ghép 2 bảng đếm" = Table.Join(#"Đếm theo ngày ghi sổ", {"period"}, #"Đổi tên khóa", {"k_period"}, JoinKind.LeftOuter),
    // Chọn cột, sắp theo tháng
    #"Chọn cột" = Table.Sort(Table.SelectColumns(#"Ghép 2 bảng đếm", {"period", "cells_posting", "mismatch_posting", "mismatch_sale_date"}), {{"period", Order.Ascending}}),
    // Dòng cả năm
    #"Dòng cả năm" = #table(type table [period = text, cells_posting = Int64.Type, mismatch_posting = Int64.Type, mismatch_sale_date = Int64.Type],
        {{"Cả năm", List.Sum(#"Chọn cột"[cells_posting]), List.Sum(#"Chọn cột"[mismatch_posting]), List.Sum(#"Chọn cột"[mismatch_sale_date])}}),
    // Nối dòng cả năm vào cuối
    #"Thêm dòng cả năm" = Table.Combine({#"Chọn cột", #"Dòng cả năm"})
in
    #"Thêm dòng cả năm"
