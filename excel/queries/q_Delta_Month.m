// q_Delta_Month – Flash và sổ cái theo từng tháng và cả năm. Chênh lệch = Sổ cái − Flash; % chênh lệch chia cho Flash.
// Đây mới là chênh lệch tổng, chưa tách thành từng khoản (việc của bảng cầu nối).
let
    // Cộng Flash theo tháng đặt hàng
    #"Flash theo tháng" = Table.Group(q_FLASH, {"period"}, {{"flash_usd", each List.Sum([revenue_usd]), type number}}),
    // Cộng sổ cái (đã đổi dấu) theo tháng ghi sổ, làm tròn 2 chữ số
    #"Sổ cái theo tháng" = Table.Group(q_GL, {"period"}, {{"gl_usd", each Number.Round(List.Sum([revenue_usd]), 2), type number}}),
    // Ghép đủ tháng của cả hai bên (tháng chỉ có ở một bên vẫn giữ, không ghi cứng năm)
    #"Ghép Flash với sổ cái" = Table.NestedJoin(#"Flash theo tháng", {"period"}, #"Sổ cái theo tháng", {"period"}, "SoCai", JoinKind.FullOuter),
    // Mở tháng và số sổ cái ra từ bảng vừa ghép
    #"Mở cột sổ cái" = Table.ExpandTableColumn(#"Ghép Flash với sổ cái", "SoCai", {"period", "gl_usd"}, {"period_gl", "gl_usd"}),
    // Gộp cột tháng của hai bên thành một
    #"Gộp cột tháng" = Table.RemoveColumns(Table.AddColumn(#"Mở cột sổ cái", "thang", each if [period] <> null then [period] else [period_gl], type text), {"period", "period_gl"}),
    // Đặt lại tên cột tháng là period
    #"Đổi tên cột tháng" = Table.RenameColumns(#"Gộp cột tháng", {{"thang", "period"}}),
    // Tháng chỉ có ở một bên: bên còn lại coi là 0
    #"Ô trống thành 0" = Table.ReplaceValue(#"Đổi tên cột tháng", null, 0, Replacer.ReplaceValue, {"flash_usd", "gl_usd"}),
    // Xếp cột theo thứ tự tháng, Flash, sổ cái rồi sắp theo tháng
    #"Sắp theo tháng" = Table.Sort(Table.ReorderColumns(#"Ô trống thành 0", {"period", "flash_usd", "gl_usd"}), {{"period", Order.Ascending}}),
    // Chênh lệch = Sổ cái − Flash
    #"Chênh lệch" = Table.AddColumn(#"Sắp theo tháng", "delta_usd", each Number.Round([gl_usd] - [flash_usd], 2), type number),
    // % chênh lệch so với Flash (để trống nếu Flash bằng 0)
    #"% so với Flash" = Table.AddColumn(#"Chênh lệch", "delta_pct_flash", each if [flash_usd] = 0 then null else [delta_usd] / [flash_usd], type nullable number),
    // Dòng cả năm = tổng 12 tháng; dòng kiểm tra = tổng sổ cái theo tháng − tổng sổ cái của cả file (phải bằng 0)
    #"Tổng Flash" = List.Sum(#"% so với Flash"[flash_usd]),
    // Tổng sổ cái của các tháng trong bảng
    #"Tổng sổ cái các tháng" = Number.Round(List.Sum(#"% so với Flash"[gl_usd]), 2),
    // Dòng cả năm và dòng kiểm tra (tổng các tháng − tổng của cả file, phải bằng 0)
    #"Dòng cả năm và kiểm tra" = #table(
        type table [period = text, flash_usd = number, gl_usd = number, delta_usd = number, delta_pct_flash = number],
        {
            {"Cả năm", #"Tổng Flash", #"Tổng sổ cái các tháng", Number.Round(#"Tổng sổ cái các tháng" - #"Tổng Flash", 2),
                (#"Tổng sổ cái các tháng" - #"Tổng Flash") / #"Tổng Flash"},
            {"Kiểm tra (phải bằng 0)", Number.Round(#"Tổng Flash" - List.Sum(q_FLASH[revenue_usd]), 2),
                Number.Round(#"Tổng sổ cái các tháng" - List.Sum(q_GL[revenue_usd]), 2), null, null}
        }),
    // Nối dòng cả năm và dòng kiểm tra vào cuối bảng
    #"Thêm dòng cả năm" = Table.Combine({#"% so với Flash", #"Dòng cả năm và kiểm tra"})
in
    #"Thêm dòng cả năm"
