// q_Delta_Channel – Flash và sổ cái theo kênh bán cả năm: cửa hàng (STORE), online (WEB), chưa gắn kênh (UNALLOCATED).
// Slide 26: tổng 2 kênh cửa hàng + online của sổ cái thiếu 1.250 USD so với tổng sổ cái – chỉ thấy khi kiểm tra các phần có cộng đủ tổng không.
let
    // Cộng Flash theo kênh
    #"Flash theo kênh" = Table.Group(q_FLASH, {"channel_code"}, {{"flash_usd", each List.Sum([revenue_usd]), type number}}),
    // Cộng sổ cái (đã đổi dấu) theo kênh, làm tròn 2 chữ số
    #"Sổ cái theo kênh" = Table.Group(q_GL, {"channel"}, {{"gl_usd", each Number.Round(List.Sum([revenue_usd]), 2), type number}}),
    // Ghép đủ kênh của cả hai bên (kênh chỉ có ở một bên vẫn giữ)
    #"Ghép hai bên" = Table.NestedJoin(#"Sổ cái theo kênh", {"channel"}, #"Flash theo kênh", {"channel_code"}, "Flash", JoinKind.FullOuter),
    // Mở mã kênh và số Flash ra từ bảng vừa ghép
    #"Mở cột Flash" = Table.ExpandTableColumn(#"Ghép hai bên", "Flash", {"channel_code", "flash_usd"}, {"channel_code_flash", "flash_usd"}),
    // Gộp mã kênh của hai bên thành một cột
    #"Gộp mã kênh" = Table.AddColumn(#"Mở cột Flash", "channel_code", each if [channel] <> null then [channel] else [channel_code_flash], type text),
    // Kênh chỉ có ở một bên: bên còn lại coi là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Gộp mã kênh", null, 0, Replacer.ReplaceValue, {"flash_usd", "gl_usd"}),
    // Tên kênh tiếng Việt để hiện trên sheet
    #"Tên kênh tiếng Việt" = Table.AddColumn(#"Ô trống thành 0", "channel_name",
        each if [channel_code] = "STORE" then "Cửa hàng" else if [channel_code] = "WEB" then "Online"
             else if [channel_code] = "UNALLOCATED" then "Chưa gắn kênh" else [channel_code], type text),
    // Thứ tự hiện: cửa hàng, online, chưa gắn kênh, kênh lạ
    #"Thứ tự kênh" = Table.AddColumn(#"Tên kênh tiếng Việt", "thu_tu",
        each if [channel_code] = "STORE" then 1 else if [channel_code] = "WEB" then 2 else if [channel_code] = "UNALLOCATED" then 3 else 9, Int64.Type),
    // Sắp các kênh theo thứ tự vừa đặt
    #"Sắp theo kênh" = Table.Sort(#"Thứ tự kênh", {{"thu_tu", Order.Ascending}}),
    // Chênh lệch = Sổ cái − Flash; % chia cho Flash (để trống nếu Flash bằng 0)
    #"Chênh lệch" = Table.AddColumn(#"Sắp theo kênh", "delta_usd", each Number.Round([gl_usd] - [flash_usd], 2), type number),
    // % chênh lệch chia cho Flash (để trống nếu Flash bằng 0)
    #"% so với Flash" = Table.AddColumn(#"Chênh lệch", "delta_pct_flash", each if [flash_usd] = 0 then null else [delta_usd] / [flash_usd], type nullable number),
    // Chọn các cột hiện trên sheet Chenh_lech_kenh
    #"Chọn cột" = Table.SelectColumns(#"% so với Flash", {"channel_code", "channel_name", "flash_usd", "gl_usd", "delta_usd", "delta_pct_flash"}),
    // Các tổng dùng cho dòng tổng và 2 dòng kiểm tra
    #"Tổng Flash" = List.Sum(#"Chọn cột"[flash_usd]),
    // Tổng sổ cái của mọi kênh trong bảng
    #"Tổng sổ cái các kênh" = Number.Round(List.Sum(#"Chọn cột"[gl_usd]), 2),
    // Tổng sổ cái chỉ của 2 kênh cửa hàng và online
    #"Sổ cái cửa hàng + online" = Number.Round(List.Sum(Table.SelectRows(#"Chọn cột", each List.Contains({"STORE", "WEB"}, [channel_code]))[gl_usd]), 2),
    // Tổng sổ cái của cả file, tính thẳng từ q_GL
    #"Tổng sổ cái của file" = Number.Round(List.Sum(q_GL[revenue_usd]), 2),
    // Dòng tổng các kênh và 2 dòng kiểm tra
    #"Dòng tổng và kiểm tra" = #table(
        type table [channel_code = text, channel_name = text, flash_usd = number, gl_usd = number, delta_usd = number, delta_pct_flash = number],
        {
            {"TOTAL", "Tổng các kênh", #"Tổng Flash", #"Tổng sổ cái các kênh", Number.Round(#"Tổng sổ cái các kênh" - #"Tổng Flash", 2),
                (#"Tổng sổ cái các kênh" - #"Tổng Flash") / #"Tổng Flash"},
            // Khác 0 nghĩa là sổ cái có bút toán không thuộc kênh cửa hàng hay online (năm 2025: ADJ-0925, −1.250)
            {"CHECK_2CH", "Kiểm tra: cửa hàng + online − tổng sổ cái (khác 0 là có bút toán không gắn kênh)", null,
                Number.Round(#"Sổ cái cửa hàng + online" - #"Tổng sổ cái của file", 2), null, null},
            // Phải bằng 0: đủ mọi kênh thì cộng lại đúng tổng sổ cái
            {"CHECK_ALL", "Kiểm tra: tổng mọi kênh − tổng sổ cái (phải bằng 0)", null,
                Number.Round(#"Tổng sổ cái các kênh" - #"Tổng sổ cái của file", 2), null, null}
        }),
    // Nối dòng tổng và dòng kiểm tra vào cuối bảng
    #"Thêm dòng tổng" = Table.Combine({#"Chọn cột", #"Dòng tổng và kiểm tra"})
in
    #"Thêm dòng tổng"
