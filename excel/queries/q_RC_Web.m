// q_RC_Web – Đối soát online × ngày giao × loại tiền, so bằng nội tệ. Nhãn nguồn: [RC-WEB].
// Bên WEB: đơn đã giao (Delivered và Returned – đơn bị trả cũng đã giao), cộng theo ngày giao. Bên sổ cái: bút toán WEB_DELIVERY.
// Ghép đủ 2 bên rồi chia 4 trường hợp; ô có tháng không thuộc kỳ đối soát (tháng không có trong Flash) ghi "Ngoài kỳ đối soát".
let
    // Các tháng đối soát = các tháng có trong Flash (không ghi cứng năm)
    #"Tháng đối soát" = List.Buffer(List.Distinct(q_FLASH[period])),
    // Đơn online đã giao (bỏ đơn hủy: đơn hủy không có ngày giao và không vào sổ cái)
    #"Đơn đã giao" = Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] <> "Cancelled"),
    // Cộng theo ngày giao × loại tiền
    #"WEB theo ô" = Table.Group(#"Đơn đã giao", {"recognition_date", "currency"},
        {{"web_local", each List.Sum([net_local]), type number}, {"orders", each Table.RowCount(_), Int64.Type}}),
    // Bút toán doanh thu online của sổ cái, cộng theo ngày ghi sổ × loại tiền
    #"Sổ cái theo ô" = Table.Group(Table.SelectRows(q_GL, each [journal_type] = "WEB_DELIVERY"), {"posting_date", "currency"},
        {{"gl_local", each List.Sum([revenue_local]), type number}, {"journal_ids", each Text.Combine([journal_id], ", "), type text}}),
    // Đổi tên khóa bên sổ cái để ghép
    #"Sổ cái đổi tên khóa" = Table.RenameColumns(#"Sổ cái theo ô", {{"posting_date", "k_date"}, {"currency", "k_currency"}}),
    // Ghép đủ 2 bên (full outer join)
    #"Ghép WEB với sổ cái" = Table.Join(#"WEB theo ô", {"recognition_date", "currency"}, #"Sổ cái đổi tên khóa", {"k_date", "k_currency"}, JoinKind.FullOuter),
    // Ghi nhận bên có mặt, gộp khóa của 2 bên
    #"Gộp khóa" = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(#"Ghép WEB với sổ cái",
        "co_web", each [web_local] <> null, type logical),
        "co_so_cai", each [gl_local] <> null, type logical),
        "delivery_date", each if [recognition_date] <> null then [recognition_date] else [k_date], type date),
        "ccy", each if [currency] <> null then [currency] else [k_currency], type text),
    // Bỏ khóa cũ, đặt lại tên cột loại tiền
    #"Bỏ khóa cũ" = Table.RenameColumns(Table.RemoveColumns(#"Gộp khóa", {"recognition_date", "currency", "k_date", "k_currency"}), {{"ccy", "currency"}}),
    // Bên thiếu thì coi là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Bỏ khóa cũ", null, 0, Replacer.ReplaceValue, {"web_local", "gl_local", "orders"}),
    // Tháng của ô và chênh lệch nội tệ = sổ cái − WEB
    #"Tháng và chênh lệch" = Table.AddColumn(Table.AddColumn(#"Ô trống thành 0",
        "period", each Date.ToText([delivery_date], "yyyy-MM", "en-US"), type text),
        "diff_local", each Number.Round([gl_local] - [web_local], 2), type number),
    // Chia trường hợp; ô ngoài kỳ đối soát để riêng
    #"Trường hợp" = Table.AddColumn(#"Tháng và chênh lệch", "match_status",
        each if not List.Contains(#"Tháng đối soát", [period]) then "Ngoài kỳ đối soát"
             else if not [co_web] then "Chỉ có ở sổ cái"
             else if not [co_so_cai] then "Chỉ có ở WEB"
             else if Number.Abs([diff_local]) <= 0.005 then "Khớp"
             else "Có cả hai nhưng lệch tiền", type text),
    // Chọn cột, sắp: ô không khớp trong kỳ lên đầu, rồi theo ngày và loại tiền
    #"Chọn cột" = Table.SelectColumns(#"Trường hợp", {"delivery_date", "period", "currency", "orders", "web_local", "gl_local", "diff_local", "match_status", "journal_ids"}),
    // Thứ tự: lệch → khớp → ngoài kỳ
    #"Sắp xếp" = Table.RemoveColumns(Table.Sort(Table.AddColumn(#"Chọn cột", "thu_tu",
        each if [match_status] = "Ngoài kỳ đối soát" then 2 else if [match_status] = "Khớp" then 1 else 0, Int64.Type),
        {{"thu_tu", Order.Ascending}, {"delivery_date", Order.Ascending}, {"currency", Order.Ascending}}), {"thu_tu"})
in
    #"Sắp xếp"
