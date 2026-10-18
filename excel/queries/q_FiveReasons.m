// q_FiveReasons – 5 lý do khiến Flash và sổ cái lệch nhau, mỗi lý do chứng minh bằng số tính từ dữ liệu (không chép mô tả của đề).
// Nhãn nguồn: [RC-WEB] cho phần online, [RC-CH] cho phần cửa hàng. Mỗi dòng: hai bên tính khác nhau thế nào, đếm được bao nhiêu, bao nhiêu USD.
// USD theo tỷ giá ngày đặt / ngày bán (cùng cách tính với bảng cầu nối), trừ khi dòng ghi khác. Chỉ tính các tháng có trong Flash.
// Số chèn vào cột chữ bang_chung viết theo kiểu Việt Nam (vi-VN: dấu chấm ngăn nghìn, dấu phẩy thập phân) vì cột này đưa thẳng vào báo cáo.
let
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = List.Buffer(List.Distinct(q_FLASH[period])),
    // Hàm: tháng có thuộc kỳ đối soát không
    #"Trong kỳ?" = (p as nullable text) as logical => p <> null and List.Contains(#"Tháng đối soát", p),
    // Bảng giao dịch chung (đọc một lần)
    #"Giao dịch" = Table.Buffer(q_Transactions),
    // Sổ cái (đọc một lần)
    #"Sổ cái" = Table.Buffer(q_GL),

    // ---- Lý do 1: thời điểm
    // Lệch thời điểm online: dòng cả năm và tháng lệch nhiều nhất của bảng lệch thời điểm online
    #"Online theo tháng" = Table.SelectRows(q_Web_Timing, each #"Trong kỳ?"([period])),
    // Dòng cả năm của bảng lệch thời điểm online
    #"Online cả năm" = Table.SelectRows(q_Web_Timing, each [period] = "Cả năm"){0},
    // Tháng có khoản lệch thời điểm online lớn nhất (theo trị tuyệt đối)
    #"Online tháng lệch nhất" = Table.Max(#"Online theo tháng", each Number.Abs([online_timing_usd])),
    // Lệch ngày ghi sổ của cửa hàng: dòng cả năm của bảng lệch ngày ghi sổ
    #"Cửa hàng cả năm" = Table.SelectRows(q_RC_Store_Timing, each [period] = "Cả năm"){0},

    // ---- Lý do 2: giá trị (giá niêm yết hay giá sau giảm giá)
    // Mọi dòng POS và đơn online bán / đặt trong kỳ (kể cả dòng trùng, đơn hủy – Flash có tính)
    #"Dòng bán trong kỳ" = Table.SelectRows(#"Giao dịch", each #"Trong kỳ?"([sale_period])),
    // Khoản chiết khấu = − tổng chiết khấu (USD theo tỷ giá ngày)
    #"Chiết khấu" = - List.Sum(#"Dòng bán trong kỳ"[discount_usd_daily]),
    // Số dòng / đơn có chiết khấu khác 0
    #"Số dòng có chiết khấu" = Table.RowCount(Table.SelectRows(#"Dòng bán trong kỳ", each [discount_local] <> 0)),
    // Tổng tiền trước giảm giá (Flash tính lại từ dữ liệu gốc, chưa làm tròn)
    #"Tiền trước giảm giá" = List.Sum(#"Dòng bán trong kỳ"[gross_usd_daily]),

    // ---- Lý do 3: phạm vi (đơn hủy, hàng trả, phí vận chuyển)
    // Đơn online bị hủy, đặt trong kỳ
    #"Đơn hủy trong kỳ" = Table.SelectRows(#"Giao dịch", each [channel] = "WEB" and [status] = "Cancelled" and #"Trong kỳ?"([sale_period])),
    // Đơn bị trả, nhận hàng trả trong kỳ
    #"Hàng trả trong kỳ" = Table.Buffer(Table.SelectRows(#"Giao dịch", each [channel] = "WEB" and [status] = "Returned" and #"Trong kỳ?"([return_period]))),
    // Bút toán tay phí vận chuyển (mã tham chiếu bắt đầu bằng MJ-SHIP)
    #"Phí vận chuyển" = Table.SelectRows(#"Sổ cái", each [source_ref] <> null and Text.StartsWith([source_ref], "MJ-SHIP")),

    // ---- Lý do 4: tiền tệ (tỷ giá ngày hay tỷ giá cuối tháng)
    // Hàng trả theo 3 cách đổi tiền: tỷ giá ngày đặt, tỷ giá ngày trả, tỷ giá cuối tháng của sổ cái
    #"Tỷ giá ngày" = Table.Buffer(Table.RenameColumns(q_FX_Daily, {{"rate_date", "k_date"}, {"currency", "k_currency"}, {"usd_to_ccy", "fx_return_date"}})),
    // Hàng trả đổi theo tỷ giá ngày trả (để so)
    #"Hàng trả theo tỷ giá ngày trả" = - List.Sum(Table.AddColumn(
        Table.Join(#"Hàng trả trong kỳ", {"return_date", "currency"}, #"Tỷ giá ngày", {"k_date", "k_currency"}, JoinKind.LeftOuter),
        "usd", each [net_local] / [fx_return_date])[usd]),
    // Hàng trả trên sổ cái (tỷ giá cuối tháng, đã làm tròn từng bút toán)
    #"Hàng trả trên sổ cái" = List.Sum(Table.SelectRows(#"Sổ cái", each [journal_type] = "WEB_RETURN")[revenue_usd]),
    // Khoản tỷ giá (slide 34): bút toán sổ cái ghi tự động đổi theo tỷ giá cuối tháng, CHƯA làm tròn,
    // trừ cũng các giao dịch đó theo tỷ giá ngày (POS theo ngày bán, online và hàng trả theo ngày đặt, lỗi chuyển dữ liệu theo ngày ghi sổ)
    #"Bút toán tự động" = Table.SelectRows(#"Sổ cái", each List.Contains({"POS_DAILY", "POS_CATCHUP", "WEB_DELIVERY", "WEB_RETURN"}, [journal_type]) and #"Trong kỳ?"([period])),
    // Nội tệ ÷ tỷ giá cuối tháng, chưa làm tròn từng bút toán
    #"Sổ cái tự động, chưa làm tròn" = List.Sum(List.Transform(Table.ToRecords(#"Bút toán tự động"), each [revenue_local] / [fx_rate_month_end])),
    // POS đã bỏ trùng, ghi sổ trong kỳ, theo tỷ giá ngày bán
    #"POS theo tỷ giá ngày" = List.Sum(Table.SelectRows(#"Giao dịch", each [channel] = "STORE" and not [is_duplicate] and #"Trong kỳ?"([recognition_period]))[net_usd_daily]),
    // Lỗi chuyển dữ liệu trong kỳ (theo tỷ giá ngày của ngày ghi sổ)
    #"Lỗi chuyển dữ liệu" = List.Sum(Table.SelectRows(q_RC_Store, each #"Trong kỳ?"([period]))[diff_usd]),
    // Đơn chưa hủy, giao trong kỳ, theo tỷ giá ngày đặt
    #"Online theo tỷ giá ngày" = List.Sum(Table.SelectRows(#"Giao dịch", each [channel] = "WEB" and [status] <> "Cancelled" and #"Trong kỳ?"([recognition_period]))[net_usd_daily]),
    // Hàng trả trong kỳ theo tỷ giá ngày đặt (ghi âm)
    #"Hàng trả theo tỷ giá ngày đặt" = - List.Sum(#"Hàng trả trong kỳ"[net_usd_daily]),
    // Khoản tỷ giá = sổ cái tự động chưa làm tròn − cùng các giao dịch theo tỷ giá ngày
    #"Tỷ giá" = #"Sổ cái tự động, chưa làm tròn" - (#"POS theo tỷ giá ngày" + #"Lỗi chuyển dữ liệu" + #"Online theo tỷ giá ngày" + #"Hàng trả theo tỷ giá ngày đặt"),
    // Số bút toán tự động bằng loại tiền khác USD
    #"Số bút toán ngoại tệ" = Table.RowCount(Table.SelectRows(#"Bút toán tự động", each [currency] <> "USD")),

    // ---- Lý do 5: mức chi tiết của một dòng
    // Số dòng POS (mỗi dòng là một món hàng trên hóa đơn)
    #"Số dòng POS" = Table.RowCount(Table.SelectRows(#"Giao dịch", each [channel] = "STORE")),
    // Số đơn online trong cùng phạm vi với bút toán online: đơn giao trong kỳ + đơn trả trong kỳ (không tính đơn hủy, đơn ngoài kỳ)
    #"Số đơn online" = Table.RowCount(Table.SelectRows(#"Giao dịch", each [channel] = "WEB" and [status] <> "Cancelled" and #"Trong kỳ?"([recognition_period])))
        + Table.RowCount(#"Hàng trả trong kỳ"),
    // Số bút toán doanh thu POS của sổ cái
    #"Số bút toán POS" = Table.RowCount(Table.SelectRows(#"Sổ cái", each Text.StartsWith([journal_type], "POS_"))),
    // Số bút toán online của sổ cái trong kỳ (giao hàng và hàng trả)
    #"Số bút toán online" = Table.RowCount(Table.SelectRows(#"Sổ cái", each ([journal_type] = "WEB_DELIVERY" or [journal_type] = "WEB_RETURN") and #"Trong kỳ?"([period]))),
    // Số dòng của Flash
    #"Số dòng Flash" = Table.RowCount(q_FLASH),
    // Làm tròn: Flash làm tròn từng dòng đến USD; sổ cái làm tròn từng bút toán đến 2 chữ số
    #"Làm tròn phần Flash" = #"Tiền trước giảm giá" - List.Sum(q_FLASH[revenue_usd]),
    // Mọi bút toán sổ cái trong kỳ
    #"Sổ cái trong kỳ" = Table.SelectRows(#"Sổ cái", each #"Trong kỳ?"([period])),
    // Làm tròn phần sổ cái = USD đã làm tròn − nội tệ ÷ tỷ giá cuối tháng
    #"Làm tròn phần sổ cái" = List.Sum(List.Transform(Table.ToRecords(#"Sổ cái trong kỳ"), each [revenue_usd] - [revenue_local] / [fx_rate_month_end])),

    // ---- Bảng kết quả: mỗi lý do một hoặc vài dòng
    #"Bảng 5 lý do" = #table(
        type table [stt = text, ly_do = text, flash_tinh = text, so_cai_tinh = text, bang_chung = text, so_luong = number, don_vi = text, usd = number, khoan = text],
        {
            {"1a", "1. Thời điểm", "Đơn online ghi theo ngày đặt", "Ghi theo ngày giao",
                "Đơn chưa hủy đặt và giao khác tháng; USD là khoản lệch thời điểm cả năm", #"Online cả năm"[orders_out], "đơn", #"Online cả năm"[online_timing_usd], "online_timing"},
            {"1b", "1. Thời điểm", "Như trên", "Như trên",
                "Tháng lệch thời điểm online nhiều nhất: " & #"Online tháng lệch nhất"[period], null, "", #"Online tháng lệch nhất"[online_timing_usd], "online_timing"},
            {"1c", "1. Thời điểm", "Bán tại cửa hàng ghi theo ngày bán", "Bán ngày nghỉ thì ghi ngày làm việc kế tiếp",
                "Dòng POS bán tháng này, ghi sổ tháng sau; USD là số tiền chuyển tháng (cả năm tự bù trừ về " & Number.ToText(#"Cửa hàng cả năm"[store_posting_usd], "N2", "vi-VN") & ")",
                #"Cửa hàng cả năm"[lines_out], "dòng POS", #"Cửa hàng cả năm"[moved_in_usd], "store_posting"},
            {"2", "2. Giá trị", "Giá niêm yết, trước giảm giá", "Giá sau giảm giá",
                "Dòng POS và đơn online có chiết khấu (kể cả dòng trùng, đơn hủy); USD là tổng chiết khấu", #"Số dòng có chiết khấu", "dòng", #"Chiết khấu", "discount"},
            {"3a", "3. Phạm vi", "Gồm cả đơn sau đó bị hủy", "Không ghi đơn hủy",
                "Đơn hủy đặt trong kỳ", Table.RowCount(#"Đơn hủy trong kỳ"), "đơn", - List.Sum(#"Đơn hủy trong kỳ"[net_usd_daily]), "cancelled"},
            {"3b", "3. Phạm vi", "Không trừ hàng trả", "Trừ vào ngày nhận hàng trả",
                "Đơn bị trả, nhận hàng trả trong kỳ (tỷ giá ngày đặt)", Table.RowCount(#"Hàng trả trong kỳ"), "đơn", #"Hàng trả theo tỷ giá ngày đặt", "returns"},
            {"3c", "3. Phạm vi", "Không có phí vận chuyển", "Ghi phí vận chuyển vào doanh thu bằng bút toán tay",
                "Bút toán tay MJ-SHIP", Table.RowCount(#"Phí vận chuyển"), "bút toán", List.Sum(#"Phí vận chuyển"[revenue_usd]), "shipping"},
            {"4a", "4. Tiền tệ", "Tỷ giá ngày đặt / ngày bán", "Tỷ giá cuối tháng ghi sổ",
                "Bút toán tự động bằng ngoại tệ (khác USD); USD là khoản tỷ giá", #"Số bút toán ngoại tệ", "bút toán", #"Tỷ giá", "fx"},
            {"4b", "4. Tiền tệ", "Cùng các đơn bị trả", "",
                "Hàng trả nếu đổi theo tỷ giá ngày trả (so với tỷ giá ngày đặt ở dòng 3b)", Table.RowCount(#"Hàng trả trong kỳ"), "đơn", #"Hàng trả theo tỷ giá ngày trả", ""},
            {"4c", "4. Tiền tệ", "", "Cùng các đơn bị trả",
                "Hàng trả trên sổ cái (tỷ giá cuối tháng, làm tròn từng bút toán)", null, "", #"Hàng trả trên sổ cái", ""},
            {"5a", "5. Mức chi tiết", "Một dòng = tháng × kênh × thị trường", "Một bút toán = cửa hàng × ngày, hoặc ngày giao × loại tiền",
                "Số dòng Flash", #"Số dòng Flash", "dòng", null, ""},
            {"5b", "5. Mức chi tiết", "Một dòng POS = một món hàng trên hóa đơn", "Một bút toán POS gộp cả ngày của cửa hàng",
                "Số dòng POS so với số bút toán POS: " & Number.ToText(#"Số dòng POS", "N0", "vi-VN") & " dòng → " & Number.ToText(#"Số bút toán POS", "N0", "vi-VN") & " bút toán",
                #"Số dòng POS" / #"Số bút toán POS", "dòng / bút toán", null, ""},
            {"5c", "5. Mức chi tiết", "Một dòng online = một đơn", "Một bút toán gộp mọi đơn giao (hoặc trả) trong ngày cùng loại tiền",
                "Đơn giao và đơn trả trong kỳ so với số bút toán online: " & Number.ToText(#"Số đơn online", "N0", "vi-VN") & " lượt đơn → " & Number.ToText(#"Số bút toán online", "N0", "vi-VN") & " bút toán",
                #"Số đơn online" / #"Số bút toán online", "đơn / bút toán", null, ""},
            {"5d", "5. Mức chi tiết", "Làm tròn từng dòng đến USD", "Làm tròn từng bút toán đến 2 chữ số",
                "Khoản làm tròn = phần Flash (" & Number.ToText(#"Làm tròn phần Flash", "N2", "vi-VN") & ") + phần sổ cái (" & Number.ToText(#"Làm tròn phần sổ cái", "N2", "vi-VN") & ")",
                null, "", #"Làm tròn phần Flash" + #"Làm tròn phần sổ cái", "rounding"}
        }),
    // Làm tròn cột USD và cột số lượng (tỷ lệ) đến 2 chữ số
    #"Làm tròn" = Table.TransformColumns(#"Bảng 5 lý do", {{"usd", each if _ = null then null else Number.Round(_, 2), type nullable number},
        {"so_luong", each if _ = null then null else Number.Round(_, 2), type nullable number}})
in
    #"Làm tròn"
