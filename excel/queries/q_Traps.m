// q_Traps – Sheet 5 bẫy khi nạp dữ liệu: mỗi bẫy 1 dòng, có số trước và sau khi xử lý, chỉ rõ truy vấn và tên bước xử lý.
// Mọi số trong bảng được tính lại mỗi lần làm mới, không gõ tay.
let
    // Table.Buffer: giữ sẵn mỗi bảng trong bộ nhớ, để truy vấn này không phải đọc lại file nhiều lần
    WEBTho = Table.Buffer(q_WEB_Raw),
    WEB = Table.Buffer(q_WEB),
    FLTho = Table.Buffer(q_FLASH_Raw),
    FL = Table.Buffer(q_FLASH),
    GL = Table.Buffer(q_GL),
    POS = Table.Buffer(q_POS),
    TyGiaNgay = Table.Buffer(Table.RenameColumns(q_FX_Daily, {{"currency", "fx_currency"}})),
    SoNguyen = (x as number) as text => Number.ToText(x, "#,##0", "vi-VN"),
    SoTien = (x as number) as text => Number.ToText(x, "#,##0.00", "vi-VN"),
    NgayVN = (d as date) as text => Date.ToText(d, "dd/MM/yyyy"),

    // Bẫy 1 – thử đọc ngày đặt hàng theo kiểu ngày/tháng của Việt Nam để đếm số đơn bị ảnh hưởng
    #"Tách ngày và tháng của chữ ngày đặt" = Table.AddColumn(
        Table.AddColumn(WEBTho, "phan_dau", each Number.From(Text.Start([order_date], 2))),
        "phan_giua", each Number.From(Text.Middle([order_date], 3, 2))),
    SoDonLoiNeuDocNgayThang = Table.RowCount(Table.SelectRows(#"Tách ngày và tháng của chữ ngày đặt", each [phan_giua] > 12)),
    SoDonDaoNgamNeuDocNgayThang = Table.RowCount(Table.SelectRows(#"Tách ngày và tháng của chữ ngày đặt", each [phan_giua] <= 12 and [phan_giua] <> [phan_dau])),
    SoOLoiSauXuLy = Table.RowCount(Table.SelectRowsWithErrors(WEB)),

    // Bẫy 2 – Flash thô
    SoDongFlashTho = Table.RowCount(FLTho),
    TongCotDoanhSoTho = List.Sum(List.Transform(Table.Column(FLTho, Table.ColumnNames(FLTho){4}), each try Number.From(_) otherwise null)),
    TongFlash = List.Sum(FL[revenue_usd]),

    // Bẫy 3 – dấu của sổ cái
    TongSoCaiGoc = List.Sum(GL[amount_usd]),
    TongSoCaiDoiDau = List.Sum(GL[revenue_usd]),

    // Bẫy 4 và 5 – đổi từng dòng POS ra USD theo tỷ giá ngày bán (chia cho tỷ giá)
    #"POS ghép tỷ giá ngày bán" = Table.Join(POS, {"business_date", "currency"}, TyGiaNgay, {"rate_date", "fx_currency"}, JoinKind.LeftOuter),
    #"POS đổi ra USD" = Table.AddColumn(
        Table.AddColumn(#"POS ghép tỷ giá ngày bán", "gross_usd", each [line_amount] / [usd_to_ccy], type number),
        "net_usd", each [net_amount] / [usd_to_ccy], type number),
    DongTrung = Table.SelectRows(#"POS đổi ra USD", each [is_duplicate]),
    MoTaDongTrung = "cửa hàng POS " & Text.Combine(List.Transform(List.Distinct(DongTrung[store_id]), Text.From), ", ")
        & ", ngày bán " & Text.Combine(List.Transform(List.Distinct(DongTrung[business_date]), NgayVN), ", ")
        & ", xuất lại lúc " & Text.Combine(List.Transform(List.Distinct(DongTrung[exported_at]), each DateTime.ToText(_, "dd/MM/yyyy HH:mm")), ", "),
    TongThangLineAmount = List.Sum(POS[line_amount]),
    SoLoaiTien = List.Count(List.Distinct(POS[currency])),
    TongGrossUSD = List.Sum(#"POS đổi ra USD"[gross_usd]),
    FlashCuaHang = List.Sum(Table.SelectRows(FL, each [channel_code] = "STORE")[revenue_usd]),

    #"Bảng 5 bẫy" = #table(
        type table [stt = Int64.Type, bay = text, truy_van = text, buoc_xu_ly = text, truoc_khi_xu_ly = text, sau_khi_xu_ly = text, neu_bo_buoc_nay = text],
        {
            {1, "Ngày kiểu Mỹ MM/DD/YYYY trong file đơn online", "q_WEB", "Đổi kiểu dữ liệu (ngày kiểu Mỹ, en-US)",
                "Nếu đọc theo kiểu ngày/tháng của Việt Nam: " & SoNguyen(SoDonLoiNeuDocNgayThang) & " đơn báo lỗi (phần ngày lớn hơn 12) và "
                    & SoNguyen(SoDonDaoNgamNeuDocNgayThang) & " đơn bị đảo ngày với tháng mà không báo lỗi",
                SoNguyen(Table.RowCount(WEB)) & " đơn đọc đúng, " & SoNguyen(SoOLoiSauXuLy) & " ô lỗi; ngày đặt từ "
                    & NgayVN(List.Min(WEB[order_date])) & " đến " & NgayVN(List.Max(WEB[order_date])),
                "Tháng đặt và tháng giao của hàng nghìn đơn bị sai, nên chênh lệch theo tháng và khoản lệch thời điểm online sai"},
            {2, "File Flash có 3 dòng tiêu đề, 1 dòng trống và dòng TỔNG CỘNG", "q_FLASH", "Bỏ các dòng tiêu đề; Bỏ dòng TỔNG CỘNG",
                SoNguyen(SoDongFlashTho) & " dòng thô; cộng cả cột doanh số ra " & SoNguyen(TongCotDoanhSoTho) & " USD (gấp đôi vì có dòng TỔNG CỘNG)",
                SoNguyen(Table.RowCount(FL)) & " dòng chi tiết, tổng " & SoNguyen(TongFlash) & " USD",
                "Flash bị gấp đôi, chênh lệch sai hoàn toàn"},
            {3, "Sổ cái ghi doanh thu là số âm (ghi Có), hàng trả là số dương (ghi Nợ)", "q_GL", "Đổi dấu doanh thu (USD)",
                "Tổng amount_usd = " & SoTien(TongSoCaiGoc) & " USD",
                "Tổng revenue_usd = " & SoTien(TongSoCaiDoiDau) & " USD",
                "Chênh lệch Sổ cái − Flash thành " & SoTien(TongSoCaiGoc - TongFlash) & " thay vì " & SoTien(TongSoCaiDoiDau - TongFlash) & " USD"},
            {4, "Dòng POS bị xuất trùng (trùng khóa receipt_no + line_no)", "q_POS", "Sắp theo giờ xuất; Lần xuất đầu tiên của mỗi khóa; Cờ dòng trùng; Lý do trùng",
                SoNguyen(Table.RowCount(POS)) & " dòng, trong đó " & SoNguyen(Table.RowCount(DongTrung)) & " dòng lặp khóa: " & MoTaDongTrung,
                SoNguyen(Table.RowCount(POS) - Table.RowCount(DongTrung)) & " dòng không trùng; dòng trùng có cờ is_duplicate kèm lý do, không bị xóa",
                "Doanh số POS cao hơn sổ cái " & SoTien(List.Sum(DongTrung[net_usd])) & " USD (tiền sau giảm giá, tỷ giá ngày bán)"},
            {5, "Dữ liệu có nhiều loại tiền", "q_POS, q_WEB; đổi ra USD ở q_Transactions", "Giữ cột currency; chia cho tỷ giá ngày rồi mới cộng",
                "Cộng thẳng line_amount của " & SoNguyen(SoLoaiTien) & " loại tiền ra " & SoTien(TongThangLineAmount) & " (con số không có nghĩa)",
                "Đổi từng dòng ra USD theo tỷ giá ngày bán rồi cộng: " & SoTien(TongGrossUSD) & " USD; Flash kênh cửa hàng: " & SoNguyen(FlashCuaHang) & " USD",
                "Doanh số cửa hàng bị cộng lẫn tiền, lệch " & SoTien(TongThangLineAmount - TongGrossUSD) & " đơn vị tiền so với số USD đúng"}
        })
in
    #"Bảng 5 bẫy"
