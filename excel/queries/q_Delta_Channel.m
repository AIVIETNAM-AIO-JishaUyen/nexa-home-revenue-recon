// q_Delta_Channel – Flash và sổ cái theo kênh bán cả năm: cửa hàng (STORE), online (WEB), chưa gắn kênh (UNALLOCATED).
// Dòng cuối kiểm tra tổng 3 kênh của sổ cái có bằng tổng sổ cái không: phát hiện bút toán không gắn kênh (ADJ-0925, 1.250 USD).
let
    #"Flash theo kênh" = Table.Group(q_FLASH, {"channel_code"}, {{"flash_usd", each List.Sum([revenue_usd]), type number}}),
    #"Sổ cái theo kênh" = Table.Group(q_GL, {"channel"}, {{"gl_usd", each Number.Round(List.Sum([revenue_usd]), 2), type number}}),
    // Ghép đủ kênh của cả hai bên (kênh chỉ có ở một bên vẫn giữ)
    #"Ghép hai bên" = Table.NestedJoin(#"Sổ cái theo kênh", {"channel"}, #"Flash theo kênh", {"channel_code"}, "Flash", JoinKind.FullOuter),
    #"Mở cột Flash" = Table.ExpandTableColumn(#"Ghép hai bên", "Flash", {"channel_code", "flash_usd"}, {"channel_code_flash", "flash_usd"}),
    #"Gộp mã kênh" = Table.AddColumn(#"Mở cột Flash", "channel_code", each if [channel] <> null then [channel] else [channel_code_flash], type text),
    #"Ô trống thành 0" = Table.ReplaceValue(#"Gộp mã kênh", null, 0, Replacer.ReplaceValue, {"flash_usd", "gl_usd"}),
    #"Tên kênh tiếng Việt" = Table.AddColumn(#"Ô trống thành 0", "channel_name",
        each if [channel_code] = "STORE" then "Cửa hàng" else if [channel_code] = "WEB" then "Online"
             else if [channel_code] = "UNALLOCATED" then "Chưa gắn kênh" else [channel_code], type text),
    #"Thứ tự kênh" = Table.AddColumn(#"Tên kênh tiếng Việt", "thu_tu",
        each if [channel_code] = "STORE" then 1 else if [channel_code] = "WEB" then 2 else if [channel_code] = "UNALLOCATED" then 3 else 9, Int64.Type),
    #"Sắp theo kênh" = Table.Sort(#"Thứ tự kênh", {{"thu_tu", Order.Ascending}}),
    #"Chênh lệch" = Table.AddColumn(#"Sắp theo kênh", "delta_usd", each Number.Round([gl_usd] - [flash_usd], 2), type number),
    #"% so với Flash" = Table.AddColumn(#"Chênh lệch", "delta_pct_flash", each if [flash_usd] = 0 then null else [delta_usd] / [flash_usd], type nullable number),
    #"Chọn cột" = Table.SelectColumns(#"% so với Flash", {"channel_code", "channel_name", "flash_usd", "gl_usd", "delta_usd", "delta_pct_flash"}),
    TongFlash = List.Sum(#"Chọn cột"[flash_usd]),
    TongSoCaiCacKenh = Number.Round(List.Sum(#"Chọn cột"[gl_usd]), 2),
    TongSoCai = Number.Round(List.Sum(q_GL[revenue_usd]), 2),
    #"Dòng tổng và kiểm tra" = #table(
        type table [channel_code = text, channel_name = text, flash_usd = number, gl_usd = number, delta_usd = number, delta_pct_flash = number],
        {
            {"TOTAL", "Tổng các kênh", TongFlash, TongSoCaiCacKenh, Number.Round(TongSoCaiCacKenh - TongFlash, 2), (TongSoCaiCacKenh - TongFlash) / TongFlash},
            {"CHECK", "Kiểm tra: tổng các kênh − tổng sổ cái (phải bằng 0)", null, Number.Round(TongSoCaiCacKenh - TongSoCai, 2), null, null}
        }),
    #"Thêm dòng tổng" = Table.Combine({#"Chọn cột", #"Dòng tổng và kiểm tra"})
in
    #"Thêm dòng tổng"
