// q_BR_Check – Tự cảnh báo trên bảng cầu nối, theo từng bảng × tháng. Nhãn nguồn: [BR-Tổng], [BR-CH], [BR-WEB].
// Ba phép: phần chưa giải thích ≤ 200 USD; làm tròn ≤ 5 USD; dòng kiểm tra (Flash + các khoản − sổ cái) ≤ 1 USD.
// Vượt một trong ba thì trang_thai = "Cần xem" (chữ đỏ trong file), kèm lời nhắc cần làm gì. Ngưỡng đặt ở 3 bước đầu.
let
    // Ngưỡng phần chưa giải thích (USD, theo slide 12: 200 USD cho một tháng)
    #"Ngưỡng chưa giải thích" = 200,
    // Ngưỡng làm tròn mỗi tháng (USD)
    #"Ngưỡng làm tròn" = 5,
    // Ngưỡng dòng kiểm tra (USD)
    #"Ngưỡng kiểm tra" = 1,
    // Bảng cầu nối dạng dài
    #"Cầu nối" = Table.Buffer(q_BR_Long),
    // Chỉ lấy 3 khoản cần soát
    #"Ba khoản" = Table.SelectRows(#"Cầu nối", each List.Contains({"unexplained", "rounding", "check"}, [item_code])),
    // Xoay thành cột: mỗi bảng × tháng một dòng
    #"Xoay cột" = Table.Pivot(Table.SelectColumns(#"Ba khoản", {"bridge", "period", "item_code", "usd"}), {"unexplained", "rounding", "check"}, "item_code", "usd", List.Sum),
    // Đặt tên cột rõ nghĩa
    #"Đổi tên" = Table.RenameColumns(#"Xoay cột", {{"unexplained", "unexplained_usd"}, {"rounding", "rounding_usd"}, {"check", "check_usd"}}),
    // Từng phép có đạt không
    #"Ba phép" = Table.AddColumn(Table.AddColumn(Table.AddColumn(#"Đổi tên",
        "chua_giai_thich_dat", each Number.Abs([unexplained_usd]) <= #"Ngưỡng chưa giải thích", type logical),
        "lam_tron_dat", each Number.Abs([rounding_usd]) <= #"Ngưỡng làm tròn", type logical),
        "kiem_tra_dat", each Number.Abs([check_usd]) <= #"Ngưỡng kiểm tra", type logical),
    // Trạng thái chung
    #"Trạng thái" = Table.AddColumn(#"Ba phép", "trang_thai",
        each if [chua_giai_thich_dat] and [lam_tron_dat] and [kiem_tra_dat] then "Đạt" else "Cần xem", type text),
    // Lời nhắc cho người đọc: phép nào không đạt, cần làm gì
    #"Lời nhắc" = Table.AddColumn(#"Trạng thái", "ghi_chu", each Text.Combine(List.RemoveNulls({
        if [chua_giai_thich_dat] then null else "Phần chưa giải thích " & Number.ToText([unexplained_usd], "N2", "vi-VN") & " USD vượt " & Text.From(#"Ngưỡng chưa giải thích") & " USD: ghi vào nhật ký ngoại lệ, hỏi phòng Tài chính",
        if [lam_tron_dat] then null else "Làm tròn " & Number.ToText([rounding_usd], "N2", "vi-VN") & " USD vượt " & Text.From(#"Ngưỡng làm tròn") & " USD: có khoản bị xếp nhầm vào dòng làm tròn",
        if [kiem_tra_dat] then null else "Dòng kiểm tra " & Number.ToText([check_usd], "N2", "vi-VN") & " USD: các khoản không cộng đủ ra sổ cái, phải tìm lỗi"}), "; "), type text),
    // Thứ tự bảng để sắp
    #"Sắp xếp" = Table.RemoveColumns(Table.Sort(Table.AddColumn(#"Lời nhắc", "bridge_order", each List.PositionOf({"COMPANY", "STORE", "WEB", "UNALLOCATED"}, [bridge]), Int64.Type),
        {{"bridge_order", Order.Ascending}, {"period", Order.Ascending}}), {"bridge_order"}),
    // Làm tròn 3 cột tiền đến 2 chữ số để dễ đọc
    #"Làm tròn" = Table.TransformColumns(#"Sắp xếp", {{"unexplained_usd", each Number.Round(_, 2), type number},
        {"rounding_usd", each Number.Round(_, 2), type number}, {"check_usd", each Number.Round(_, 2), type number}})
in
    #"Làm tròn"
