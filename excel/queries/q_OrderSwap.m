// q_OrderSwap – Nếu đổi thứ tự các bước cầu nối thì số của từng khoản đổi thế nào (cả năm, toàn công ty). Nhãn nguồn: [BR-Tổng].
// Mỗi cách đổi làm hai khoản đổi số ngược chiều nhau; tổng không đổi. Bảng cho thấy vì sao phải ghi rõ thứ tự đã chốt
// (slide 10: "ghi rõ thứ tự các bước trong cầu nối") và vì sao nhóm chọn thứ tự hiện tại.
let
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = List.Buffer(List.Distinct(q_FLASH[period])),
    // Hàm: tháng có thuộc kỳ đối soát không
    #"Trong kỳ?" = (p as nullable text) as logical => p <> null and List.Contains(#"Tháng đối soát", p),
    // Bảng giao dịch chung (đọc một lần)
    #"Giao dịch" = Table.Buffer(q_Transactions),
    // Hàm: tổng một khoản cả năm của bảng cầu nối toàn công ty (thứ tự đã chốt)
    #"Khoản" = (ma as text) as number => List.Sum(Table.SelectRows(q_BR_Long, each [bridge] = "COMPANY" and [item_code] = ma)[usd]),

    // ---- Cách 1: tính dòng POS trùng TRƯỚC chiết khấu, tức theo giá trước giảm giá
    #"POS trùng" = Table.SelectRows(#"Giao dịch", each [channel] = "STORE" and [is_duplicate] and #"Trong kỳ?"([sale_period])),
    // Dòng trùng theo giá trước giảm giá; chiết khấu khi đó không còn phần chiết khấu của dòng trùng
    #"Trùng theo giá gốc" = - List.Sum(#"POS trùng"[gross_usd_daily]),
    // Chiết khấu của các dòng trùng
    #"Chiết khấu của dòng trùng" = List.Sum(#"POS trùng"[discount_usd_daily]),

    // ---- Cách 2: tính đơn hủy TRƯỚC chiết khấu
    #"Đơn hủy" = Table.SelectRows(#"Giao dịch", each [channel] = "WEB" and [status] = "Cancelled" and #"Trong kỳ?"([sale_period])),
    // Đơn hủy theo giá trước giảm giá
    #"Hủy theo giá gốc" = - List.Sum(#"Đơn hủy"[gross_usd_daily]),
    // Chiết khấu của các đơn hủy
    #"Chiết khấu của đơn hủy" = List.Sum(#"Đơn hủy"[discount_usd_daily]),

    // ---- Cách 3: tính tỷ giá TRƯỚC hàng trả. Khi đó dòng tỷ giá đã đưa mọi giao dịch về tỷ giá cuối tháng của sổ cái,
    // nên hàng trả đứng sau phải đo theo tỷ giá cuối tháng nhận hàng trả (đúng số sổ cái ghi), thay vì tỷ giá ngày đặt
    #"Hàng trả" = Table.SelectRows(#"Giao dịch", each [channel] = "WEB" and [status] = "Returned" and #"Trong kỳ?"([return_period])),
    // Hàng trả theo tỷ giá cuối tháng nhận hàng trả (chưa làm tròn)
    #"Trả theo tỷ giá cuối tháng" = - List.Sum(#"Hàng trả"[net_usd_month_end_return]),

    // ---- Bảng kết quả
    #"Bảng" = #table(
        type table [stt = Int64.Type, cach_doi = text, khoan_1 = text, cu_1 = number, moi_1 = number, khoan_2 = text, cu_2 = number, moi_2 = number],
        {
            {1, "Tính dòng POS trùng trước chiết khấu (theo giá trước giảm giá)", "Dòng POS bị trùng", #"Khoản"("pos_duplicate"), #"Trùng theo giá gốc",
                "Chiết khấu", #"Khoản"("discount"), #"Khoản"("discount") + #"Chiết khấu của dòng trùng"},
            {2, "Tính đơn hủy trước chiết khấu (theo giá trước giảm giá)", "Đơn online bị hủy", #"Khoản"("cancelled"), #"Hủy theo giá gốc",
                "Chiết khấu", #"Khoản"("discount"), #"Khoản"("discount") + #"Chiết khấu của đơn hủy"},
            {3, "Tính tỷ giá trước hàng trả (hàng trả theo tỷ giá cuối tháng của sổ cái)", "Hàng trả lại", #"Khoản"("returns"), #"Trả theo tỷ giá cuối tháng",
                "Tỷ giá", #"Khoản"("fx"), #"Khoản"("fx") + #"Khoản"("returns") - #"Trả theo tỷ giá cuối tháng"}
        }),
    // Kiểm tra: tổng thay đổi của hai khoản, tính từ số chưa làm tròn (phải bằng 0: đổi thứ tự chỉ chuyển tiền giữa hai dòng)
    #"Tổng thay đổi" = Table.AddColumn(#"Bảng", "tong_thay_doi_usd", each Number.Round(([moi_1] - [cu_1]) + ([moi_2] - [cu_2]), 2), type number),
    // Làm tròn ba số đến 2 chữ số thập phân
    #"Làm tròn" = Table.TransformColumns(#"Tổng thay đổi", List.Transform({"cu_1", "moi_1", "cu_2"}, (c) => {c, each Number.Round(_, 2), type number})),
    // Số mới của khoản thứ hai = số cũ trừ đúng phần đã chuyển sang khoản thứ nhất, để hai cột thay đổi trên bảng cộng lại đúng 0
    #"Khoản thứ hai" = Table.ReplaceValue(#"Làm tròn", each [moi_2], each [cu_2] - ([moi_1] - [cu_1]), Replacer.ReplaceValue, {"moi_2"}),
    // Làm tròn số mới của khoản thứ hai
    #"Kết quả" = Table.TransformColumns(#"Khoản thứ hai", {{"moi_2", each Number.Round(_, 2), type number}})
in
    #"Kết quả"
