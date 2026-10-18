// q_RC_Return – Đối soát hàng trả × ngày trả × loại tiền, so bằng nội tệ. Nhãn nguồn: [RC-RET].
// Bên WEB: đơn có trạng thái Returned, ghi âm vào ngày nhận hàng trả. Bên sổ cái: bút toán WEB_RETURN (sau khi đổi dấu là số âm).
// Ghép đủ 2 bên rồi chia 4 trường hợp; ô có tháng không thuộc kỳ đối soát ghi "Ngoài kỳ đối soát".
let
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = List.Buffer(List.Distinct(q_FLASH[period])),
    // Đơn bị trả
    #"Đơn bị trả" = Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] = "Returned"),
    // Cộng theo ngày trả × loại tiền; hàng trả làm giảm doanh thu nên lấy số âm
    #"WEB theo ô" = Table.Group(#"Đơn bị trả", {"return_date", "currency"},
        {{"web_local", each - List.Sum([net_local]), type number}, {"orders", each Table.RowCount(_), Int64.Type}}),
    // Bút toán hàng trả của sổ cái theo ngày ghi sổ × loại tiền
    #"Sổ cái theo ô" = Table.Group(Table.SelectRows(q_GL, each [journal_type] = "WEB_RETURN"), {"posting_date", "currency"},
        {{"gl_local", each List.Sum([revenue_local]), type number}, {"journal_ids", each Text.Combine([journal_id], ", "), type text}}),
    // Đổi tên khóa bên sổ cái
    #"Sổ cái đổi tên khóa" = Table.RenameColumns(#"Sổ cái theo ô", {{"posting_date", "k_date"}, {"currency", "k_currency"}}),
    // Ghép đủ 2 bên (full outer join)
    #"Ghép WEB với sổ cái" = Table.Join(#"WEB theo ô", {"return_date", "currency"}, #"Sổ cái đổi tên khóa", {"k_date", "k_currency"}, JoinKind.FullOuter),
    // Ghi nhận bên có mặt, gộp khóa của 2 bên
    #"Gộp khóa" = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(#"Ghép WEB với sổ cái",
        "co_web", each [web_local] <> null, type logical),
        "co_so_cai", each [gl_local] <> null, type logical),
        "ngay_tra", each if [return_date] <> null then [return_date] else [k_date], type date),
        "ccy", each if [currency] <> null then [currency] else [k_currency], type text),
    // Bỏ khóa cũ, đặt lại tên
    #"Bỏ khóa cũ" = Table.RenameColumns(Table.RemoveColumns(#"Gộp khóa", {"return_date", "currency", "k_date", "k_currency"}), {{"ngay_tra", "return_date"}, {"ccy", "currency"}}),
    // Bên thiếu thì coi là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Bỏ khóa cũ", null, 0, Replacer.ReplaceValue, {"web_local", "gl_local", "orders"}),
    // Tháng của ô và chênh lệch nội tệ = sổ cái − WEB
    #"Tháng và chênh lệch" = Table.AddColumn(Table.AddColumn(#"Ô trống thành 0",
        "period", each Date.ToText([return_date], "yyyy-MM", "en-US"), type text),
        "diff_local", each Number.Round([gl_local] - [web_local], 2), type number),
    // Chia trường hợp; ô ngoài kỳ đối soát để riêng
    #"Trường hợp" = Table.AddColumn(#"Tháng và chênh lệch", "match_status",
        each if not List.Contains(#"Tháng đối soát", [period]) then "Ngoài kỳ đối soát"
             else if not [co_web] then "Chỉ có ở sổ cái"
             else if not [co_so_cai] then "Chỉ có ở WEB"
             else if Number.Abs([diff_local]) <= 0.005 then "Khớp"
             else "Có cả hai nhưng lệch tiền", type text),
    // Chọn cột
    #"Chọn cột" = Table.SelectColumns(#"Trường hợp", {"return_date", "period", "currency", "orders", "web_local", "gl_local", "diff_local", "match_status", "journal_ids"}),
    // Thứ tự: lệch → khớp → ngoài kỳ
    #"Sắp xếp" = Table.RemoveColumns(Table.Sort(Table.AddColumn(#"Chọn cột", "thu_tu",
        each if [match_status] = "Ngoài kỳ đối soát" then 2 else if [match_status] = "Khớp" then 1 else 0, Int64.Type),
        {{"thu_tu", Order.Ascending}, {"return_date", Order.Ascending}, {"currency", Order.Ascending}}), {"thu_tu"})
in
    #"Sắp xếp"
