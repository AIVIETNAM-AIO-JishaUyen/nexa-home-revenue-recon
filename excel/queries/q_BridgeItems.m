// q_BridgeItems – Danh mục các khoản của bảng cầu nối: mã, thứ tự, tên, nhóm (1 trong 4 nhóm), bảng nào có khoản này,
// thuộc lý do nào trong 5 lý do lệch, và vì sao xếp vào nhóm đó. Bảng cầu nối, nhật ký ngoại lệ, dashboard đọc nhóm từ đây.
// Đây là bảng gõ tay duy nhất của phần phân tích: nó là quyết định phân loại của nhóm, không phải số liệu.
let
    // Danh mục khoản, theo thứ tự các bước cầu nối đã chốt (docs/quy_uoc_va_so_chuan.md, mục 1)
    #"Danh mục" = #table(
        type table [item_code = text, item_order = Int64.Type, item_name = text, item_group = text, bang = text, ly_do = text, vi_sao_nhom = text],
        {
            {"flash", 0, "Doanh số Flash", "", "Cả 4 bảng", "", "Điểm bắt đầu của bảng cầu nối"},
            {"discount", 1, "Chiết khấu", "Quy tắc ghi nhận", "Cửa hàng, online", "2. Giá trị",
                "Flash ghi giá niêm yết, sổ cái ghi giá sau giảm giá; cả hai đều đúng theo cách của mình"},
            {"pos_duplicate", 2, "Dòng POS bị trùng", "Lỗi dữ liệu", "Cửa hàng", "",
                "12 dòng hóa đơn bị xuất ra file 2 lần; Flash đếm cả bản trùng, sổ cái không – Flash sai"},
            {"cancelled", 3, "Đơn online bị hủy", "Quy tắc ghi nhận", "Online", "3. Phạm vi",
                "Flash tính mọi đơn đặt, sổ cái không ghi đơn chưa giao; đúng theo quy tắc của mỗi bên"},
            {"online_timing", 4, "Lệch thời điểm online", "Quy tắc ghi nhận", "Online", "1. Thời điểm",
                "Flash ghi theo ngày đặt, sổ cái theo ngày giao; tự bù trừ ở tháng sau, trừ phần đơn vắt qua năm"},
            {"store_posting", 5, "Lệch ngày ghi sổ của cửa hàng", "Quy tắc ghi nhận", "Cửa hàng", "1. Thời điểm",
                "Bán ngày nghỉ thì sổ cái ghi ngày làm việc kế tiếp; tự bù trừ ở tháng sau, cả năm bằng 0"},
            {"transfer_error", 6, "Lỗi chuyển dữ liệu từ POS sang sổ cái", "Lỗi dữ liệu", "Cửa hàng", "",
                "Doanh thu NX057 ngày 21/11 không sang được sổ cái, ghi bù ngày 02/12; sổ cái tháng 11 thiếu, tháng 12 thừa"},
            {"returns", 7, "Hàng trả lại", "Quy tắc ghi nhận", "Online", "3. Phạm vi",
                "Flash không trừ hàng trả, sổ cái trừ vào ngày nhận hàng trả; đúng theo quy tắc của mỗi bên"},
            {"shipping", 8, "Phí vận chuyển (bút toán tay MJ-SHIP)", "Quy tắc ghi nhận", "Online", "3. Phạm vi",
                "Sổ cái ghi phí vận chuyển vào doanh thu bằng bút toán tay có giấy tờ, Flash không có khoản này"},
            {"channel_reclass", 9, "Chuyển kênh (bút toán tay MJ-RCL)", "Quy tắc ghi nhận", "Cửa hàng, online (không có ở toàn công ty)", "3. Phạm vi",
                "Bút toán tay có giấy tờ chuyển doanh thu giữa hai kênh; toàn công ty không đổi"},
            {"fx", 10, "Tỷ giá", "Quy tắc ghi nhận", "Cửa hàng, online", "4. Tiền tệ",
                "Flash đổi theo tỷ giá ngày đặt / ngày bán, sổ cái theo tỷ giá cuối tháng ghi sổ"},
            {"rounding", 11, "Làm tròn", "Sai số chấp nhận", "Cả 4 bảng", "5. Mức chi tiết",
                "Flash làm tròn từng dòng đến USD, sổ cái làm tròn từng bút toán đến 2 chữ số; vài USD mỗi năm"},
            {"unexplained", 12, "Chưa giải thích được (bút toán ADJ-0925)", "Chưa giải thích được", "Chưa gắn kênh", "",
                "Bút toán điều chỉnh 1.250 USD không gắn kênh, không có giấy tờ; dữ liệu không đủ để biết nguyên nhân"},
            {"gl", 13, "Doanh thu theo sổ cái", "", "Cả 4 bảng", "", "Điểm kết thúc của bảng cầu nối"},
            {"check", 14, "Kiểm tra (Flash + các khoản − sổ cái)", "", "Cả 4 bảng", "", "Phải về 0 (chấp nhận ≤ 1 USD)"}
        })
in
    #"Danh mục"
