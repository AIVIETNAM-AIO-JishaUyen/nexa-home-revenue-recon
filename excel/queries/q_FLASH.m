// q_FLASH – Báo cáo nhanh doanh số của phòng Kinh doanh: mỗi dòng là 1 tháng × 1 kênh × 1 thị trường.
// Flash tính theo ngày đặt hàng, giá trước giảm giá, gồm cả đơn hủy, đổi USD theo tỷ giá ngày đặt, làm tròn đến USD.
let
    // Lấy bảng đọc thô từ q_FLASH_Raw
    #"Flash đọc thô" = q_FLASH_Raw,
    // BẪY 2 – file có 3 dòng tiêu đề và 1 dòng trống ở trên: bỏ các dòng đầu cho đến dòng có chữ "Tháng"
    // (không bỏ cố định 4 dòng, để file tháng sau thêm bớt dòng tiêu đề vẫn đọc đúng)
    #"Bỏ các dòng tiêu đề" = Table.Skip(#"Flash đọc thô", each [Column1] <> "Tháng"),
    // Dòng có chữ "Tháng" là tên cột
    #"Dòng Tháng là tên cột" = Table.PromoteHeaders(#"Bỏ các dòng tiêu đề", [PromoteAllScalars = true]),
    // BẪY 2 – dòng TỔNG CỘNG ở cuối: bỏ đi, nếu không tổng Flash bị gấp đôi (bỏ luôn dòng trống nếu có)
    #"Bỏ dòng TỔNG CỘNG" = Table.SelectRows(#"Dòng Tháng là tên cột",
        each [Tháng] <> null and [Tháng] <> "" and not Text.StartsWith(Text.Upper(Text.From([Tháng])), "TỔNG")),
    // Tên cột giữ tiếng Anh như các nguồn khác (slide 7)
    #"Đổi tên cột sang tiếng Anh" = Table.RenameColumns(#"Bỏ dòng TỔNG CỘNG", {
        {"Tháng", "period"}, {"Kênh", "channel_name"}, {"Thị trường", "market"}, {"Số đơn", "orders"}, {"Doanh số (USD)", "revenue_usd"}}),
    // Đổi kiểu theo vùng en-US
    #"Đổi kiểu dữ liệu" = Table.TransformColumnTypes(#"Đổi tên cột sang tiếng Anh", {
        {"period", type text}, {"channel_name", type text}, {"market", type text}, {"orders", Int64.Type}, {"revenue_usd", type number}}, "en-US"),
    // Mã kênh giống sổ cái: Cửa hàng → STORE, Online → WEB (kênh lạ ghi KHAC để dễ thấy)
    #"Thêm mã kênh" = Table.AddColumn(#"Đổi kiểu dữ liệu", "channel_code",
        each if [channel_name] = "Cửa hàng" then "STORE" else if [channel_name] = "Online" then "WEB" else "KHAC", type text),
    // Ngày đầu tháng (từ chữ YYYY-MM) để nối với lịch
    #"Thêm ngày đầu tháng" = Table.AddColumn(#"Thêm mã kênh", "month_start",
        each #date(Number.From(Text.Start([period], 4)), Number.From(Text.End([period], 2)), 1), type date)
in
    #"Thêm ngày đầu tháng"
