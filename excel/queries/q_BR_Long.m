// q_BR_Long – Bảng cầu nối 12 tháng dạng dài: mỗi dòng là một bảng × một tháng × một khoản. Nhãn nguồn: [BR-Tổng], [BR-CH], [BR-WEB].
// Bảng (cột bridge): STORE (cửa hàng), WEB (online), UNALLOCATED (bút toán không gắn kênh), COMPANY (toàn công ty = tổng 3 bảng trên).
// Mỗi khoản tính TRỰC TIẾP từ dữ liệu (không lấy phần dư); dòng kiểm tra = Flash + các khoản − sổ cái, phải ≈ 0.
// Tỷ giá: mọi khoản theo tỷ giá ngày đặt / ngày bán; lỗi chuyển dữ liệu theo tỷ giá ngày của ngày ghi sổ; dòng tỷ giá theo định nghĩa slide 34.
// Danh mục khoản (thứ tự, tên, nhóm) lấy từ q_BridgeItems. Kỳ đối soát = các tháng có trong Flash.
let
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = List.Buffer(List.Sort(List.Distinct(q_FLASH[period]))),
    // Hàm cộng một cột theo tháng, gắn tên bảng và mã khoản; dau = +1 hoặc −1
    #"Cộng theo tháng" = (t as table, cot_thang as text, cot_tien as text, bang as text, khoan as text, dau as number) as table =>
        let
            // Cộng cột tiền theo cột tháng, nhân dấu
            nhom = Table.Group(t, {cot_thang}, {{"usd", each dau * List.Sum(Table.Column(_, cot_tien)), type number}}),
            // Đổi tên cột tháng thành period (nếu chưa phải)
            doi_ten = if cot_thang = "period" then nhom else Table.RenameColumns(nhom, {{cot_thang, "period"}})
        in
            Table.AddColumn(Table.AddColumn(doi_ten, "bridge", each bang, type text), "item_code", each khoan, type text),

    // ---- Dữ liệu dùng chung
    // Bảng giao dịch chung (đọc một lần)
    #"Giao dịch" = Table.Buffer(q_Transactions),
    // Dòng POS (mọi dòng, kể cả dòng trùng)
    #"POS" = Table.Buffer(Table.SelectRows(#"Giao dịch", each [channel] = "STORE")),
    // Dòng POS đã bỏ trùng
    #"POS bỏ trùng" = Table.Buffer(Table.SelectRows(#"POS", each not [is_duplicate])),
    // Dòng POS bị trùng
    #"POS trùng" = Table.SelectRows(#"POS", each [is_duplicate]),
    // Mọi đơn online (kể cả đơn hủy – Flash có tính)
    #"WEB" = Table.Buffer(Table.SelectRows(#"Giao dịch", each [channel] = "WEB")),
    // Đơn online chưa hủy (đã giao)
    #"WEB chưa hủy" = Table.Buffer(Table.SelectRows(#"WEB", each [status] <> "Cancelled")),
    // Đơn online bị hủy
    #"WEB hủy" = Table.SelectRows(#"WEB", each [status] = "Cancelled"),
    // Đơn online bị trả
    #"WEB trả" = Table.Buffer(Table.SelectRows(#"WEB", each [status] = "Returned")),
    // Sổ cái, thêm USD chưa làm tròn = nội tệ ÷ tỷ giá cuối tháng của chính bút toán
    #"Sổ cái" = Table.Buffer(Table.AddColumn(q_GL, "usd_unrounded", each [revenue_local] / [fx_rate_month_end], type number)),
    // Hàm lọc bút toán tay theo phần đầu mã tham chiếu (MJ-SHIP, MJ-RCL, MJ-ADJ)
    #"Bút toán tay" = (kenh as text, ma as text) as table =>
        Table.SelectRows(#"Sổ cái", each [channel] = kenh and [source_ref] <> null and Text.StartsWith([source_ref], ma)),
    // Sổ cái của kênh cửa hàng
    #"Sổ cái cửa hàng" = Table.SelectRows(#"Sổ cái", each [channel] = "STORE"),
    // Sổ cái online
    #"Sổ cái online" = Table.SelectRows(#"Sổ cái", each [channel] = "WEB"),
    // Sổ cái chưa gắn kênh
    #"Sổ cái chưa gắn kênh" = Table.SelectRows(#"Sổ cái", each [channel] = "UNALLOCATED"),
    // Bút toán POS ghi tự động (POS_DAILY và bút toán ghi bù POS_CATCHUP)
    #"Bút toán POS" = Table.SelectRows(#"Sổ cái", each [journal_type] = "POS_DAILY" or [journal_type] = "POS_CATCHUP"),
    // Bút toán online ghi tự động (giao hàng và hàng trả)
    #"Bút toán online" = Table.SelectRows(#"Sổ cái", each [journal_type] = "WEB_DELIVERY" or [journal_type] = "WEB_RETURN"),
    // Flash của kênh cửa hàng
    #"Flash cửa hàng" = Table.SelectRows(q_FLASH, each [channel_code] = "STORE"),
    // Flash online
    #"Flash online" = Table.SelectRows(q_FLASH, each [channel_code] = "WEB"),
    // Ô lỗi chuyển dữ liệu (cửa hàng × ngày ghi sổ), phần lệch đã đổi theo tỷ giá ngày của ngày ghi sổ
    #"Ô cửa hàng" = Table.Buffer(q_RC_Store),

    // ---- Bảng cửa hàng (STORE): từng mảnh của từng khoản
    #"Mảnh cửa hàng" = {
        #"Cộng theo tháng"(#"Flash cửa hàng", "period", "revenue_usd", "STORE", "flash", 1),
        #"Cộng theo tháng"(#"POS", "sale_period", "discount_usd_daily", "STORE", "discount", -1),
        #"Cộng theo tháng"(#"POS trùng", "sale_period", "net_usd_daily", "STORE", "pos_duplicate", -1),
        #"Cộng theo tháng"(#"POS bỏ trùng", "recognition_period", "net_usd_daily", "STORE", "store_posting", 1),
        #"Cộng theo tháng"(#"POS bỏ trùng", "sale_period", "net_usd_daily", "STORE", "store_posting", -1),
        #"Cộng theo tháng"(#"Ô cửa hàng", "period", "diff_usd", "STORE", "transfer_error", 1),
        #"Cộng theo tháng"(#"Bút toán tay"("STORE", "MJ-RCL"), "period", "revenue_usd", "STORE", "channel_reclass", 1),
        // Tỷ giá = bút toán POS chưa làm tròn − (POS đã bỏ trùng theo tháng ghi sổ + lỗi chuyển dữ liệu), cùng theo tỷ giá ngày
        #"Cộng theo tháng"(#"Bút toán POS", "period", "usd_unrounded", "STORE", "fx", 1),
        #"Cộng theo tháng"(#"POS bỏ trùng", "recognition_period", "net_usd_daily", "STORE", "fx", -1),
        #"Cộng theo tháng"(#"Ô cửa hàng", "period", "diff_usd", "STORE", "fx", -1),
        // Làm tròn = (Flash tính lại chưa làm tròn − Flash trong file) + (sổ cái đã làm tròn − chưa làm tròn)
        #"Cộng theo tháng"(#"POS", "sale_period", "gross_usd_daily", "STORE", "rounding", 1),
        #"Cộng theo tháng"(#"Flash cửa hàng", "period", "revenue_usd", "STORE", "rounding", -1),
        #"Cộng theo tháng"(#"Sổ cái cửa hàng", "period", "revenue_usd", "STORE", "rounding", 1),
        #"Cộng theo tháng"(#"Sổ cái cửa hàng", "period", "usd_unrounded", "STORE", "rounding", -1),
        #"Cộng theo tháng"(#"Sổ cái cửa hàng", "period", "revenue_usd", "STORE", "gl", 1)
    },
    // ---- Bảng online (WEB)
    #"Mảnh online" = {
        #"Cộng theo tháng"(#"Flash online", "period", "revenue_usd", "WEB", "flash", 1),
        #"Cộng theo tháng"(#"WEB", "sale_period", "discount_usd_daily", "WEB", "discount", -1),
        #"Cộng theo tháng"(#"WEB hủy", "sale_period", "net_usd_daily", "WEB", "cancelled", -1),
        #"Cộng theo tháng"(#"WEB chưa hủy", "recognition_period", "net_usd_daily", "WEB", "online_timing", 1),
        #"Cộng theo tháng"(#"WEB chưa hủy", "sale_period", "net_usd_daily", "WEB", "online_timing", -1),
        #"Cộng theo tháng"(#"WEB trả", "return_period", "net_usd_daily", "WEB", "returns", -1),
        #"Cộng theo tháng"(#"Bút toán tay"("WEB", "MJ-SHIP"), "period", "revenue_usd", "WEB", "shipping", 1),
        #"Cộng theo tháng"(#"Bút toán tay"("WEB", "MJ-RCL"), "period", "revenue_usd", "WEB", "channel_reclass", 1),
        // Tỷ giá = bút toán online chưa làm tròn − (đơn chưa hủy theo tháng giao − hàng trả theo tháng trả), cùng theo tỷ giá ngày đặt
        #"Cộng theo tháng"(#"Bút toán online", "period", "usd_unrounded", "WEB", "fx", 1),
        #"Cộng theo tháng"(#"WEB chưa hủy", "recognition_period", "net_usd_daily", "WEB", "fx", -1),
        #"Cộng theo tháng"(#"WEB trả", "return_period", "net_usd_daily", "WEB", "fx", 1),
        // Làm tròn, cách tính như bảng cửa hàng
        #"Cộng theo tháng"(#"WEB", "sale_period", "gross_usd_daily", "WEB", "rounding", 1),
        #"Cộng theo tháng"(#"Flash online", "period", "revenue_usd", "WEB", "rounding", -1),
        #"Cộng theo tháng"(#"Sổ cái online", "period", "revenue_usd", "WEB", "rounding", 1),
        #"Cộng theo tháng"(#"Sổ cái online", "period", "usd_unrounded", "WEB", "rounding", -1),
        #"Cộng theo tháng"(#"Sổ cái online", "period", "revenue_usd", "WEB", "gl", 1)
    },
    // ---- Bảng chưa gắn kênh (UNALLOCATED): bút toán ADJ-0925 luôn ở dòng "chưa giải thích được"
    #"Mảnh chưa gắn kênh" = {
        #"Cộng theo tháng"(#"Bút toán tay"("UNALLOCATED", "MJ-ADJ"), "period", "revenue_usd", "UNALLOCATED", "unexplained", 1),
        #"Cộng theo tháng"(#"Sổ cái chưa gắn kênh", "period", "revenue_usd", "UNALLOCATED", "rounding", 1),
        #"Cộng theo tháng"(#"Sổ cái chưa gắn kênh", "period", "usd_unrounded", "UNALLOCATED", "rounding", -1),
        #"Cộng theo tháng"(#"Sổ cái chưa gắn kênh", "period", "revenue_usd", "UNALLOCATED", "gl", 1)
    },
    // Nối mọi mảnh, chỉ giữ các tháng đối soát (bỏ tháng 12 năm trước, tháng 1 năm sau)
    #"Nối các mảnh" = Table.SelectRows(Table.Combine(#"Mảnh cửa hàng" & #"Mảnh online" & #"Mảnh chưa gắn kênh"),
        each List.Contains(#"Tháng đối soát", [period])),
    // Cộng các mảnh của cùng một khoản
    #"Cộng mảnh" = Table.Group(#"Nối các mảnh", {"bridge", "period", "item_code"}, {{"usd", each List.Sum([usd]), type number}}),

    // ---- Lưới đủ: 3 bảng × mọi tháng × mọi khoản (trừ dòng kiểm tra); khoản không áp dụng = 0
    #"Mã khoản" = List.RemoveItems(q_BridgeItems[item_code], {"check"}),
    // Lưới bảng × tháng × khoản
    #"Lưới" = Table.FromRows(List.Combine(List.Transform({"STORE", "WEB", "UNALLOCATED"}, (b) =>
        List.Combine(List.Transform(#"Tháng đối soát", (p) => List.Transform(#"Mã khoản", (c) => {b, p, c}))))),
        type table [bridge = text, period = text, item_code = text]),
    // Ghép số vào lưới
    #"Ghép số vào lưới" = Table.Join(#"Lưới", {"bridge", "period", "item_code"},
        Table.RenameColumns(#"Cộng mảnh", {{"bridge", "k_bridge"}, {"period", "k_period"}, {"item_code", "k_item"}}), {"k_bridge", "k_period", "k_item"}, JoinKind.LeftOuter),
    // Ô trống = 0
    #"Ba bảng kênh" = Table.Buffer(Table.ReplaceValue(Table.SelectColumns(#"Ghép số vào lưới", {"bridge", "period", "item_code", "usd"}), null, 0, Replacer.ReplaceValue, {"usd"})),

    // ---- Toàn công ty = cửa hàng + online + chưa gắn kênh; bỏ dòng chuyển kênh (hai kênh cộng lại bằng 0)
    #"Toàn công ty" = Table.AddColumn(Table.Group(Table.SelectRows(#"Ba bảng kênh", each [item_code] <> "channel_reclass"), {"period", "item_code"},
        {{"usd", each List.Sum([usd]), type number}}), "bridge", each "COMPANY", type text),
    // Bốn bảng
    #"Bốn bảng" = Table.Combine({#"Toàn công ty", #"Ba bảng kênh"}),

    // ---- Dòng kiểm tra = Flash + các khoản ở giữa − sổ cái, theo từng bảng × tháng
    #"Dòng kiểm tra" = Table.AddColumn(Table.Group(#"Bốn bảng", {"bridge", "period"},
        {{"usd", each List.Sum(List.Transform(Table.ToRecords(_), (r) => if r[item_code] = "gl" then - r[usd] else r[usd])), type number}}),
        "item_code", each "check", type text),
    // Nối dòng kiểm tra
    #"Có dòng kiểm tra" = Table.Combine({#"Bốn bảng", #"Dòng kiểm tra"}),
    // Ghép thứ tự, tên, nhóm từ danh mục khoản
    #"Ghép danh mục" = Table.Join(#"Có dòng kiểm tra", {"item_code"},
        Table.RenameColumns(Table.SelectColumns(q_BridgeItems, {"item_code", "item_order", "item_name", "item_group"}), {{"item_code", "k_code"}}), {"k_code"}, JoinKind.LeftOuter),
    // Thứ tự bảng để sắp
    #"Thứ tự bảng" = Table.AddColumn(#"Ghép danh mục", "bridge_order", each List.PositionOf({"COMPANY", "STORE", "WEB", "UNALLOCATED"}, [bridge]), Int64.Type),
    // Sắp theo bảng, tháng, thứ tự khoản
    #"Sắp xếp" = Table.Sort(#"Thứ tự bảng", {{"bridge_order", Order.Ascending}, {"period", Order.Ascending}, {"item_order", Order.Ascending}}),
    // Chọn cột theo dạng BR_Long đã chốt (docs/cau_truc_du_lieu.md)
    #"Chọn cột" = Table.SelectColumns(#"Sắp xếp", {"bridge", "period", "item_code", "item_order", "item_name", "item_group", "usd"})
in
    #"Chọn cột"
