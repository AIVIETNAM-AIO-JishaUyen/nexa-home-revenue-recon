// q_ExceptionLog – Nhật ký ngoại lệ: mỗi khoản lệch một dòng, đủ 10 cột của file mẫu nộp (sheet Nhat_ky_ngoai_le). Nhãn nguồn: [EX-xx].
// Số tiền lấy từ bảng cầu nối toàn công ty (q_BR_Long), chi tiết lấy từ các bảng đối soát; nhóm lấy từ danh mục khoản (q_BridgeItems).
// Thiết kế để TỔNG cột "Ảnh hưởng (USD)" = tổng chênh lệch Sổ cái − Flash cả năm (không đếm trùng khoản nào).
// Trạng thái theo slide 40: Cần sửa nguồn · Đã sửa kỳ sau · Đã giải thích · Chờ phản hồi. Dấu theo file mẫu: làm Flash cao hơn sổ cái thì âm.
let
    // Các tháng đối soát = các tháng có trong Flash
    #"Tháng đối soát" = List.Buffer(List.Sort(List.Distinct(q_FLASH[period]))),
    // Kỳ cả năm, ví dụ "2025-01 đến 2025-12"
    #"Cả kỳ" = List.First(#"Tháng đối soát") & " đến " & List.Last(#"Tháng đối soát"),
    // Hàm: tháng có thuộc kỳ đối soát không
    #"Trong kỳ?" = (p as nullable text) as logical => p <> null and List.Contains(#"Tháng đối soát", p),
    // Hàm viết số kiểu Việt Nam để chèn vào mô tả
    #"Số" = (x as number, optional d as nullable number) as text => Number.ToText(x, "N" & Text.From(if d = null then 2 else d), "vi-VN"),
    // Hàm viết ngày dd/mm/yyyy
    #"Ngày" = (d as date) as text => Date.ToText(d, "dd/MM/yyyy", "vi-VN"),
    // Bảng cầu nối toàn công ty
    #"Cầu nối" = Table.Buffer(Table.SelectRows(q_BR_Long, each [bridge] = "COMPANY")),
    // Hàm: tổng một khoản cả năm, hoặc của một tháng
    #"Khoản" = (ma as text, optional thang as nullable text) as number =>
        List.Sum(Table.SelectRows(#"Cầu nối", each [item_code] = ma and (thang = null or [period] = thang))[usd]),
    // Hàm: nhóm của một khoản theo danh mục
    #"Nhóm" = (ma as text) as text => Table.SelectRows(q_BridgeItems, each [item_code] = ma){0}[item_group],
    // Hàm tạo một dòng nhật ký (mã EX-xx đánh sau)
    #"Dòng" = (buoc as text, nguon as text, mo_ta as text, usd as number, ky as text, nhom as text, huong as text, phu_trach as text, trang_thai as text) as record =>
        [#"Phát hiện ở bước" = buoc, #"Nguồn" = nguon, #"Mô tả" = mo_ta, #"Ảnh hưởng (USD)" = Number.Round(usd, 2), #"Kỳ" = ky,
         #"Phân loại" = nhom, #"Hướng xử lý" = huong, #"Người phụ trách" = phu_trach, #"Trạng thái" = trang_thai],

    // ---- Chi tiết lấy từ dữ liệu
    // Dòng POS bị trùng
    #"POS trùng" = Table.Buffer(Table.SelectRows(q_Transactions, each [channel] = "STORE" and [is_duplicate])),
    // Đơn online chưa hủy
    #"Đơn chưa hủy" = Table.Buffer(Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] <> "Cancelled")),
    // Đơn đặt trước kỳ, giao trong kỳ
    #"Vắt qua đầu kỳ" = Table.SelectRows(#"Đơn chưa hủy", each not #"Trong kỳ?"([sale_period]) and #"Trong kỳ?"([recognition_period])),
    // Đơn đặt trong kỳ, giao sau kỳ
    #"Vắt qua cuối kỳ" = Table.SelectRows(#"Đơn chưa hủy", each #"Trong kỳ?"([sale_period]) and not #"Trong kỳ?"([recognition_period])),
    // Tiền của hai phần vắt qua năm (tỷ giá ngày đặt)
    #"Tiền đầu kỳ" = List.Sum(#"Vắt qua đầu kỳ"[net_usd_daily]),
    // Phần cuối kỳ ghi âm (Flash có, sổ cái chưa có)
    #"Tiền cuối kỳ" = - List.Sum(#"Vắt qua cuối kỳ"[net_usd_daily]),
    // Tháng có khoản lệch thời điểm online lớn nhất
    #"Tháng lệch online lớn nhất" = Table.Max(Table.SelectRows(#"Cầu nối", each [item_code] = "online_timing"), each Number.Abs([usd])),
    // Đơn hủy và đơn bị trả trong kỳ (để đếm số đơn)
    #"Số đơn hủy" = Table.RowCount(Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] = "Cancelled" and #"Trong kỳ?"([sale_period]))),
    // Số đơn bị trả, nhận hàng trả trong kỳ
    #"Số đơn trả" = Table.RowCount(Table.SelectRows(q_Transactions, each [channel] = "WEB" and [status] = "Returned" and #"Trong kỳ?"([return_period]))),
    // Các cặp tháng lệch ngày ghi sổ của cửa hàng (tháng có tiền chuyển đi)
    #"Cặp tháng cửa hàng" = Table.SelectRows(q_RC_Store_Timing, each #"Trong kỳ?"([period]) and [moved_out_usd] < 0),
    // Các ô cửa hàng × ngày không khớp (lỗi chuyển dữ liệu)
    #"Ô lỗi chuyển dữ liệu" = Table.SelectRows(q_RC_Store, each [match_status] <> "Khớp" and #"Trong kỳ?"([period])),
    // Bút toán tay của sổ cái
    #"Bút toán tay" = Table.Buffer(Table.SelectRows(q_GL, each [source_ref] <> null and Text.StartsWith([source_ref], "MJ-"))),
    // Bút toán phí vận chuyển
    #"Phí vận chuyển" = Table.SelectRows(#"Bút toán tay", each Text.StartsWith([source_ref], "MJ-SHIP")),
    // Bút toán chuyển kênh, vế cửa hàng
    #"Chuyển kênh cửa hàng" = Table.SelectRows(#"Bút toán tay", each Text.StartsWith([source_ref], "MJ-RCL") and [channel] = "STORE"),
    // Bút toán điều chỉnh không gắn kênh
    #"Bút toán ADJ" = Table.SelectRows(#"Bút toán tay", each Text.StartsWith([source_ref], "MJ-ADJ")),

    // ---- Các dòng nhật ký, theo thứ tự các bước cầu nối
    #"Dòng chiết khấu" = {#"Dòng"("Bảng cầu nối: Flash ghi giá trước giảm giá", "Flash, POS, WEB",
        "Flash ghi giá niêm yết, sổ cái ghi giá sau giảm giá: tổng chiết khấu của mọi dòng POS và đơn online",
        #"Khoản"("discount"), #"Cả kỳ", #"Nhóm"("discount"), "Trình bày trong cầu nối; đề nghị Flash báo thêm doanh số sau giảm giá", "Kinh doanh", "Đã giải thích")},
    // Dòng POS trùng: một dòng cho mỗi tháng có dòng trùng
    #"Dòng POS trùng" = Table.TransformRows(Table.Group(#"POS trùng", {"sale_period"},
        {{"n", each Table.RowCount(_), Int64.Type}, {"cua_hang", each Text.Combine(List.Distinct([store_code]), ", "), type text},
         {"ma_pos", each Text.Combine(List.Transform(List.Distinct([pos_store_id]), Text.From), ", "), type text},
         {"ngay", each Text.Combine(List.Transform(List.Distinct([sale_date]), #"Ngày"), ", "), type text}}),
        (r) => #"Dòng"("Kiểm tra khóa receipt_no + line_no sau khi nạp", "POS",
            Text.From(r[n]) & " dòng POS trùng khóa ở cửa hàng " & r[cua_hang] & " (mã POS " & r[ma_pos] & ") ngày " & r[ngay] & ": file POS xuất 2 lần, Flash đếm cả bản trùng",
            #"Khoản"("pos_duplicate", r[sale_period]), r[sale_period], #"Nhóm"("pos_duplicate"), "Bỏ bản xuất sau; chặn xuất lặp ở hệ thống POS", "IT", "Cần sửa nguồn")),
    // Đơn hủy
    #"Dòng đơn hủy" = {#"Dòng"("Bảng cầu nối: đối soát online", "WEB",
        Text.From(#"Số đơn hủy") & " đơn online đặt trong kỳ rồi bị hủy: Flash có tính, sổ cái không ghi",
        #"Khoản"("cancelled"), #"Cả kỳ", #"Nhóm"("cancelled"), "Đề nghị Flash loại đơn hủy hoặc báo riêng", "Kinh doanh", "Đã giải thích")},
    // Lệch thời điểm online: phần trong năm (tự bù trừ) và hai phần vắt qua năm – ba dòng cộng lại đúng bằng khoản cả năm
    #"Dòng lệch thời điểm online" = {
        #"Dòng"("Đối soát online × ngày giao", "WEB, Flash",
            "Đơn đặt và giao khác tháng trong năm: tháng này chuyển đi, tháng sau nhận lại; lớn nhất " & #"Tháng lệch online lớn nhất"[period] & " (" & #"Số"(#"Tháng lệch online lớn nhất"[usd]) & ")",
            #"Khoản"("online_timing") - #"Tiền đầu kỳ" - #"Tiền cuối kỳ", #"Cả kỳ", #"Nhóm"("online_timing"), "Không sửa; ghi chú trên Flash rằng doanh thu tính theo ngày đặt", "Kinh doanh", "Đã giải thích"),
        #"Dòng"("Đối soát online × ngày giao", "WEB, Flash",
            Text.From(Table.RowCount(#"Vắt qua đầu kỳ")) & " đơn đặt trước kỳ, giao trong kỳ: sổ cái có, Flash của kỳ không có",
            #"Tiền đầu kỳ", Text.Combine(List.Sort(List.Distinct(#"Vắt qua đầu kỳ"[recognition_period])), ", "), #"Nhóm"("online_timing"), "Không sửa; trình bày riêng khi so cả năm", "Kinh doanh", "Đã giải thích"),
        #"Dòng"("Đối soát online × ngày giao", "WEB, Flash",
            Text.From(Table.RowCount(#"Vắt qua cuối kỳ")) & " đơn đặt trong kỳ, giao sau kỳ: Flash có, sổ cái kỳ sau mới ghi",
            #"Tiền cuối kỳ", Text.Combine(List.Sort(List.Distinct(#"Vắt qua cuối kỳ"[sale_period])), ", "), #"Nhóm"("online_timing"), "Theo dõi: sổ cái kỳ sau phải ghi nhận đủ số này", "Tài chính", "Đã giải thích")},
    // Lệch ngày ghi sổ của cửa hàng: một dòng cho mỗi cặp tháng (cặp tháng cộng lại bằng 0)
    #"Dòng lệch ngày ghi sổ" = Table.TransformRows(#"Cặp tháng cửa hàng", (r) => #"Dòng"("Đối soát cửa hàng × ngày ghi sổ", "POS, sổ cái",
        Text.From(r[lines_out]) & " dòng POS bán cuối tháng " & r[period] & " vào ngày nghỉ, ghi sổ tháng " & r[to_period] & ": " & #"Số"(- r[moved_out_usd]) & " USD chuyển tháng, tự bù trừ",
        #"Khoản"("store_posting", r[period]) + #"Khoản"("store_posting", r[to_period]), r[period] & ", " & r[to_period], #"Nhóm"("store_posting"),
        "Không sửa; tự bù trừ ở tháng sau", "Tài chính", "Đã giải thích")),
    // Lỗi chuyển dữ liệu: một dòng cho mỗi ô cửa hàng × ngày không khớp
    #"Dòng lỗi chuyển dữ liệu" = Table.TransformRows(#"Ô lỗi chuyển dữ liệu", (r) => #"Dòng"("Đối soát cửa hàng × ngày ghi sổ", "POS, sổ cái",
        r[store_code] & " ngày " & #"Ngày"(r[posting_date]) & ": " &
            (if r[match_status] = "Chỉ có ở POS" then "POS có " & #"Số"(r[pos_local]) & " " & r[currency] & " nhưng sổ cái không có bút toán"
             else if r[match_status] = "Chỉ có ở sổ cái" then "sổ cái có bút toán " & r[journal_ids] & " (" & r[journal_types] & ") nhưng POS không có dòng nào"
             else "POS và sổ cái lệch " & #"Số"(r[diff_local]) & " " & r[currency]),
        r[diff_usd], r[period], #"Nhóm"("transfer_error"),
        "So ô cửa hàng × ngày trước khi khóa sổ; IT kiểm tra giao diện chuyển dữ liệu POS sang sổ cái", "Tài chính, IT", "Đã sửa kỳ sau")),
    // Hàng trả
    #"Dòng hàng trả" = {#"Dòng"("Đối soát hàng trả × ngày trả", "WEB, sổ cái",
        Text.From(#"Số đơn trả") & " đơn bị trả, sổ cái ghi giảm vào ngày nhận hàng trả; Flash không trừ (tỷ giá ngày đặt)",
        #"Khoản"("returns"), #"Cả kỳ", #"Nhóm"("returns"), "Đề nghị tách báo cáo hàng trả bên cạnh Flash", "Kinh doanh", "Đã giải thích")},
    // Phí vận chuyển
    #"Dòng phí vận chuyển" = {#"Dòng"("Rà bút toán tay của sổ cái", "Sổ cái",
        Text.From(Table.RowCount(#"Phí vận chuyển")) & " bút toán tay MJ-SHIP ghi phí vận chuyển vào doanh thu online; Flash không có khoản này",
        #"Khoản"("shipping"), #"Cả kỳ", #"Nhóm"("shipping"), "Trình bày riêng trong cầu nối", "Tài chính", "Đã giải thích")},
    // Chuyển kênh (toàn công ty bằng 0; chỉ thấy ở bảng theo kênh)
    #"Dòng chuyển kênh" = Table.TransformRows(#"Chuyển kênh cửa hàng", (r) => #"Dòng"("So tổng theo kênh", "Sổ cái",
        "Bút toán tay " & r[source_ref] & " chuyển " & #"Số"(Number.Abs(r[revenue_usd])) & " USD doanh thu của " & r[store_code] & " sang kênh online; toàn công ty không đổi",
        0, r[period], #"Nhóm"("channel_reclass"), "Trình bày ở bảng cầu nối theo kênh", "Tài chính", "Đã giải thích")),
    // Tỷ giá
    #"Dòng tỷ giá" = {#"Dòng"("Bảng cầu nối: dòng tỷ giá (slide 34)", "Flash, sổ cái",
        "Flash đổi theo tỷ giá ngày đặt / ngày bán, sổ cái theo tỷ giá cuối tháng ghi sổ",
        #"Khoản"("fx"), #"Cả kỳ", #"Nhóm"("fx"), "Trình bày riêng một dòng; không sửa", "Tài chính", "Đã giải thích")},
    // Làm tròn
    #"Dòng làm tròn" = {#"Dòng"("Bảng cầu nối: dòng làm tròn", "Flash, sổ cái",
        "Flash làm tròn từng dòng đến USD, sổ cái làm tròn từng bút toán đến 2 chữ số",
        #"Khoản"("rounding"), #"Cả kỳ", #"Nhóm"("rounding"), "Ghi một dòng, không đào thêm", "Tài chính", "Đã giải thích")},
    // Bút toán chưa giải thích được
    #"Dòng chưa giải thích" = Table.TransformRows(#"Bút toán ADJ", (r) => #"Dòng"("So tổng theo kênh: tổng các kênh thiếu so với tổng sổ cái", "Sổ cái",
        "Bút toán " & r[journal_id] & " (" & r[source_ref] & ") ghi " & #"Số"(r[revenue_usd]) & " USD doanh thu, không gắn kênh, không có giấy tờ làm căn cứ",
        r[revenue_usd], r[period], #"Nhóm"("unexplained"), "Yêu cầu phòng Tài chính gửi chứng từ; không gán vào khoản khác", "Tài chính", "Chờ phản hồi")),
    // Nối mọi dòng theo thứ tự
    #"Mọi dòng" = Table.FromRecords(#"Dòng chiết khấu" & #"Dòng POS trùng" & #"Dòng đơn hủy" & #"Dòng lệch thời điểm online" & #"Dòng lệch ngày ghi sổ"
        & #"Dòng lỗi chuyển dữ liệu" & #"Dòng hàng trả" & #"Dòng phí vận chuyển" & #"Dòng chuyển kênh" & #"Dòng tỷ giá" & #"Dòng làm tròn" & #"Dòng chưa giải thích"),
    // Đánh mã EX-01, EX-02, …
    #"Đánh số" = Table.AddIndexColumn(#"Mọi dòng", "stt", 1, 1, Int64.Type),
    // Cột mã
    #"Thêm mã" = Table.AddColumn(#"Đánh số", "Mã", each "EX-" & Text.PadStart(Text.From([stt]), 2, "0"), type text),
    // Đúng thứ tự 10 cột của file mẫu
    #"Chọn cột" = Table.SelectColumns(#"Thêm mã", {"Mã", "Phát hiện ở bước", "Nguồn", "Mô tả", "Ảnh hưởng (USD)", "Kỳ", "Phân loại", "Hướng xử lý", "Người phụ trách", "Trạng thái"}),
    // Đặt kiểu cột
    #"Đổi kiểu" = Table.TransformColumnTypes(#"Chọn cột", {{"Ảnh hưởng (USD)", type number}, {"Mã", type text}, {"Phát hiện ở bước", type text}, {"Nguồn", type text},
        {"Mô tả", type text}, {"Kỳ", type text}, {"Phân loại", type text}, {"Hướng xử lý", type text}, {"Người phụ trách", type text}, {"Trạng thái", type text}})
in
    #"Đổi kiểu"
