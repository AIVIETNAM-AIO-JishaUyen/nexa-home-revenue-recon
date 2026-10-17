// q_WEB – Đơn online, mỗi dòng là 1 đơn hàng (khóa web_order_id).
// Sổ cái ghi doanh thu online vào ngày giao thành công, không ghi đơn hủy, ghi giảm doanh thu vào ngày nhận hàng trả.
let
    Nguon = q_WEB_Raw,
    // Ô trống (đơn hủy không có ngày giao, đơn không bị trả không có ngày trả) đổi thành null, nếu không bước đổi kiểu ngày sẽ báo lỗi
    #"Ô trống thành null" = Table.ReplaceValue(Nguon, "", null, Replacer.ReplaceValue, {"delivery_date", "return_date"}),
    // BẪY 1 – ngày kiểu Mỹ MM/DD/YYYY: đổi kiểu theo vùng en-US.
    // Nếu đọc theo vùng Việt Nam (ngày/tháng): đơn có ngày > 12 báo lỗi, đơn có ngày ≤ 12 bị đảo ngày với tháng mà không báo lỗi
    #"Đổi kiểu dữ liệu (ngày kiểu Mỹ, en-US)" = Table.TransformColumnTypes(#"Ô trống thành null", {
        {"web_order_id", type text}, {"order_date", type date}, {"delivery_date", type date}, {"order_status", type text},
        {"return_date", type date}, {"currency", type text}, {"items_qty", Int64.Type},
        {"gross_amount", type number}, {"discount_amount", type number}, {"net_amount", type number}}, "en-US")
in
    #"Đổi kiểu dữ liệu (ngày kiểu Mỹ, en-US)"
