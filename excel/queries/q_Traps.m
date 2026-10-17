// q_Traps – Sheet 5 bẫy khi nạp dữ liệu: mỗi bẫy 1 dòng, có số trước và sau khi xử lý, chỉ rõ truy vấn và tên bước xử lý.
// Mọi số trong bảng được tính lại mỗi lần làm mới, không gõ tay.
let
    // Giữ sẵn các bảng trong bộ nhớ (Table.Buffer), để truy vấn này không phải đọc lại file nhiều lần
    #"Đơn online đọc thô" = Table.Buffer(q_WEB_Raw),
    // Giữ sẵn bảng đơn online đã đổi kiểu
    #"Đơn online đã xử lý" = Table.Buffer(q_WEB),
    // Giữ sẵn bảng Flash đọc thô
    #"Flash đọc thô" = Table.Buffer(q_FLASH_Raw),
    // Giữ sẵn bảng Flash đã xử lý
    #"Flash đã xử lý" = Table.Buffer(q_FLASH),
    // Giữ sẵn bảng sổ cái
    #"Sổ cái" = Table.Buffer(q_GL),
    // Giữ sẵn bảng POS
    #"Bảng POS" = Table.Buffer(q_POS),
    // Tỷ giá ngày; đổi tên cột currency để ghép với POS không bị trùng tên cột
    #"Tỷ giá ngày" = Table.Buffer(Table.RenameColumns(q_FX_Daily, {{"currency", "fx_currency"}})),
    // Hàm phụ viết số theo kiểu Việt Nam (dấu chấm ngăn nghìn, dấu phẩy thập phân); số trống coi như 0
    #"Số nguyên" = (x as nullable number) as text => Number.ToText(if x = null then 0 else x, "#,##0", "vi-VN"),
    // Hàm phụ viết số tiền có 2 chữ số thập phân
    #"Số tiền" = (x as nullable number) as text => Number.ToText(if x = null then 0 else x, "#,##0.00", "vi-VN"),
    // Hàm phụ viết ngày dạng dd/MM/yyyy
    #"Ngày kiểu Việt Nam" = (d as date) as text => Date.ToText(d, "dd/MM/yyyy", "vi-VN"),

    // Bẫy 1 – thử đọc chữ ngày đặt hàng theo kiểu ngày/tháng của Việt Nam để đếm số đơn bị ảnh hưởng.
    // Tách chữ "MM/DD/YYYY" theo dấu "/": phần đầu là tháng, phần giữa là ngày
    #"Tách ngày và tháng của chữ ngày đặt" = Table.AddColumn(#"Đơn online đọc thô", "phan",
        each let Phan = Text.Split([order_date], "/") in [dau = Number.From(Phan{0}), giua = Number.From(Phan{1})]),
    // Đọc kiểu ngày/tháng: phần giữa (ngày thật) lớn hơn 12 sẽ bị hiểu là tháng > 12, nên báo lỗi
    #"Số đơn lỗi nếu đọc ngày/tháng" = Table.RowCount(Table.SelectRows(#"Tách ngày và tháng của chữ ngày đặt", each [phan][giua] > 12)),
    // Phần giữa ≤ 12 và khác phần đầu: đọc được nhưng ra ngày khác (đảo ngày với tháng), không báo lỗi
    #"Số đơn đảo ngầm nếu đọc ngày/tháng" = Table.RowCount(Table.SelectRows(#"Tách ngày và tháng của chữ ngày đặt",
        each [phan][giua] <= 12 and [phan][giua] <> [phan][dau])),
    // Sau khi xử lý: đếm số dòng còn lỗi ở bảng đã đổi kiểu (phải bằng 0)
    #"Số dòng lỗi sau xử lý" = Table.RowCount(Table.SelectRowsWithErrors(#"Đơn online đã xử lý")),

    // Bẫy 2 – Flash thô: đếm dòng và cộng thẳng cột doanh số (Column5), kể cả dòng TỔNG CỘNG
    #"Số dòng Flash thô" = Table.RowCount(#"Flash đọc thô"),
    // Cộng thẳng cột doanh số (Column5) của bảng thô, bỏ qua ô chữ
    #"Tổng cột doanh số thô" = List.Sum(List.Transform(#"Flash đọc thô"[Column5], each try Number.From(_) otherwise null)),
    // Tổng Flash sau khi xử lý
    #"Tổng Flash" = List.Sum(#"Flash đã xử lý"[revenue_usd]),

    // Bẫy 3 – tổng sổ cái trước và sau khi đổi dấu
    #"Tổng sổ cái theo dấu kế toán" = List.Sum(#"Sổ cái"[amount_usd]),
    // Tổng sổ cái sau khi đổi dấu
    #"Tổng sổ cái sau đổi dấu" = List.Sum(#"Sổ cái"[revenue_usd]),

    // Bẫy 4 và 5 – ghép tỷ giá ngày bán vào từng dòng POS (cùng ngày, cùng loại tiền)
    #"POS ghép tỷ giá ngày bán" = Table.Join(#"Bảng POS", {"business_date", "currency"}, #"Tỷ giá ngày", {"rate_date", "fx_currency"}, JoinKind.LeftOuter),
    // Đổi ra USD bằng cách CHIA cho tỷ giá: tiền trước giảm giá và sau giảm giá
    #"POS đổi ra USD" = Table.AddColumn(
        Table.AddColumn(#"POS ghép tỷ giá ngày bán", "gross_usd", each [line_amount] / [usd_to_ccy], type number),
        "net_usd", each [net_amount] / [usd_to_ccy], type number),
    // Các dòng trùng và mô tả chúng: cửa hàng, ngày bán, giờ xuất lại
    #"Dòng trùng" = Table.SelectRows(#"POS đổi ra USD", each [is_duplicate]),
    // Mô tả các dòng trùng: cửa hàng, ngày bán, giờ xuất lại
    #"Mô tả dòng trùng" = if Table.RowCount(#"Dòng trùng") = 0 then "không có" else
        "cửa hàng POS " & Text.Combine(List.Transform(List.Distinct(#"Dòng trùng"[store_id]), Text.From), ", ")
        & ", ngày bán " & Text.Combine(List.Transform(List.Distinct(#"Dòng trùng"[business_date]), #"Ngày kiểu Việt Nam"), ", ")
        & ", xuất lại lúc " & Text.Combine(List.Transform(List.Distinct(#"Dòng trùng"[exported_at]), each DateTime.ToText(_, "dd/MM/yyyy HH:mm", "vi-VN")), ", "),
    // Bẫy 5 – cộng thẳng nhiều loại tiền so với đổi từng dòng ra USD rồi mới cộng
    #"Tổng line_amount cộng thẳng" = List.Sum(#"Bảng POS"[line_amount]),
    // Đếm số loại tiền trong file POS
    #"Số loại tiền" = List.Count(List.Distinct(#"Bảng POS"[currency])),
    // Tổng tiền trước giảm giá sau khi đổi từng dòng ra USD
    #"Tổng trước giảm giá theo USD" = List.Sum(#"POS đổi ra USD"[gross_usd]),
    // Flash của kênh cửa hàng, để so
    #"Flash kênh cửa hàng" = List.Sum(Table.SelectRows(#"Flash đã xử lý", each [channel_code] = "STORE")[revenue_usd]),

    // Gom lại thành bảng 5 bẫy
    #"Bảng 5 bẫy" = #table(
        type table [stt = Int64.Type, bay = text, truy_van = text, buoc_xu_ly = text, truoc_khi_xu_ly = text, sau_khi_xu_ly = text, neu_bo_buoc_nay = text],
        {
            {1, "Ngày kiểu Mỹ MM/DD/YYYY trong file đơn online", "q_WEB", "Ô trống thành null; Đổi kiểu dữ liệu (ngày kiểu Mỹ, en-US)",
                "Nếu đọc ngày đặt hàng theo kiểu ngày/tháng của Việt Nam: " & #"Số nguyên"(#"Số đơn lỗi nếu đọc ngày/tháng") & " đơn báo lỗi (phần ngày lớn hơn 12) và "
                    & #"Số nguyên"(#"Số đơn đảo ngầm nếu đọc ngày/tháng") & " đơn bị đảo ngày với tháng mà không báo lỗi",
                #"Số nguyên"(Table.RowCount(#"Đơn online đã xử lý")) & " đơn đọc đúng, " & #"Số nguyên"(#"Số dòng lỗi sau xử lý") & " dòng lỗi; ngày đặt từ "
                    & #"Ngày kiểu Việt Nam"(List.Min(#"Đơn online đã xử lý"[order_date])) & " đến " & #"Ngày kiểu Việt Nam"(List.Max(#"Đơn online đã xử lý"[order_date])),
                "Tháng đặt và tháng giao của hàng nghìn đơn bị sai, nên chênh lệch theo tháng và khoản lệch thời điểm online sai"},
            {2, "File Flash có 3 dòng tiêu đề, 1 dòng trống và dòng TỔNG CỘNG", "q_FLASH", "Bỏ các dòng tiêu đề; Bỏ dòng TỔNG CỘNG",
                #"Số nguyên"(#"Số dòng Flash thô") & " dòng thô; cộng cả cột doanh số ra " & #"Số nguyên"(#"Tổng cột doanh số thô") & " USD (gấp đôi vì có dòng TỔNG CỘNG)",
                #"Số nguyên"(Table.RowCount(#"Flash đã xử lý")) & " dòng chi tiết, tổng " & #"Số nguyên"(#"Tổng Flash") & " USD",
                "Flash bị gấp đôi, chênh lệch sai hoàn toàn"},
            {3, "Sổ cái ghi doanh thu là số âm (ghi Có), hàng trả là số dương (ghi Nợ)", "q_GL", "Đổi dấu doanh thu (USD)",
                "Tổng amount_usd = " & #"Số tiền"(#"Tổng sổ cái theo dấu kế toán") & " USD",
                "Tổng revenue_usd = " & #"Số tiền"(#"Tổng sổ cái sau đổi dấu") & " USD",
                "Chênh lệch Sổ cái − Flash thành " & #"Số tiền"(#"Tổng sổ cái theo dấu kế toán" - #"Tổng Flash") & " thay vì "
                    & #"Số tiền"(#"Tổng sổ cái sau đổi dấu" - #"Tổng Flash") & " USD"},
            {4, "Dòng POS bị xuất trùng (trùng khóa receipt_no + line_no)", "q_POS", "Sắp theo giờ xuất; Lần xuất đầu tiên của mỗi khóa; Cờ dòng trùng; Lý do trùng",
                #"Số nguyên"(Table.RowCount(#"Bảng POS")) & " dòng, trong đó " & #"Số nguyên"(Table.RowCount(#"Dòng trùng")) & " dòng lặp khóa: " & #"Mô tả dòng trùng",
                #"Số nguyên"(Table.RowCount(#"Bảng POS") - Table.RowCount(#"Dòng trùng")) & " dòng không trùng; dòng trùng có cờ is_duplicate kèm lý do, không bị xóa",
                "Doanh số POS cao hơn sổ cái " & #"Số tiền"(List.Sum(#"Dòng trùng"[net_usd])) & " USD (tiền sau giảm giá, tỷ giá ngày bán)"},
            {5, "Dữ liệu có nhiều loại tiền", "q_Traps (ví dụ ở đây); bảng giao dịch chung q_Transactions đổi tiền cho mọi dòng",
                "POS ghép tỷ giá ngày bán; POS đổi ra USD (chia cho tỷ giá rồi mới cộng)",
                "Cộng thẳng line_amount của " & #"Số nguyên"(#"Số loại tiền") & " loại tiền ra " & #"Số tiền"(#"Tổng line_amount cộng thẳng") & " (con số không có nghĩa)",
                "Đổi từng dòng ra USD theo tỷ giá ngày bán rồi cộng: " & #"Số tiền"(#"Tổng trước giảm giá theo USD") & " USD (kể cả 12 dòng trùng, giống Flash); Flash kênh cửa hàng: "
                    & #"Số nguyên"(#"Flash kênh cửa hàng") & " USD",
                "Doanh số cửa hàng bị cộng lẫn tiền, lệch " & #"Số tiền"(#"Tổng line_amount cộng thẳng" - #"Tổng trước giảm giá theo USD") & " đơn vị tiền so với số USD đúng"}
        })
in
    #"Bảng 5 bẫy"
