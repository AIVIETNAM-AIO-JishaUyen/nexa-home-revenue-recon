// q_Delta_Month – Flash và sổ cái theo từng tháng và cả năm. Chênh lệch = Sổ cái − Flash; % chênh lệch chia cho Flash.
// Đây mới là chênh lệch tổng, chưa tách thành từng khoản (việc của bảng cầu nối).
let
    #"Flash theo tháng" = Table.Group(q_FLASH, {"period"}, {{"flash_usd", each List.Sum([revenue_usd]), type number}}),
    #"Sổ cái theo tháng" = Table.Group(q_GL, {"period"}, {{"gl_usd", each Number.Round(List.Sum([revenue_usd]), 2), type number}}),
    // Chỉ giữ các tháng có trong Flash: năm đối soát lấy từ dữ liệu, không ghi cứng
    #"Ghép Flash với sổ cái" = Table.NestedJoin(#"Flash theo tháng", {"period"}, #"Sổ cái theo tháng", {"period"}, "SoCai", JoinKind.LeftOuter),
    #"Mở cột sổ cái" = Table.ExpandTableColumn(#"Ghép Flash với sổ cái", "SoCai", {"gl_usd"}),
    #"Sắp theo tháng" = Table.Sort(#"Mở cột sổ cái", {{"period", Order.Ascending}}),
    #"Chênh lệch" = Table.AddColumn(#"Sắp theo tháng", "delta_usd", each Number.Round([gl_usd] - [flash_usd], 2), type number),
    #"% so với Flash" = Table.AddColumn(#"Chênh lệch", "delta_pct_flash", each [delta_usd] / [flash_usd], type number),
    #"Dòng cả năm" = #table(
        type table [period = text, flash_usd = number, gl_usd = number, delta_usd = number, delta_pct_flash = number],
        {{"Cả năm",
          List.Sum(#"% so với Flash"[flash_usd]),
          Number.Round(List.Sum(#"% so với Flash"[gl_usd]), 2),
          Number.Round(List.Sum(#"% so với Flash"[delta_usd]), 2),
          List.Sum(#"% so với Flash"[delta_usd]) / List.Sum(#"% so với Flash"[flash_usd])}}),
    #"Thêm dòng cả năm" = Table.Combine({#"% so với Flash", #"Dòng cả năm"})
in
    #"Thêm dòng cả năm"
