// q_POS – Bán hàng tại cửa hàng (POS – Point of Sale): mỗi dòng là 1 món hàng trên 1 hóa đơn (khóa receipt_no + line_no).
// line_amount là tiền TRƯỚC giảm giá, discount_amount là chiết khấu; tiền là nội tệ của nước có cửa hàng.
let
    // Đọc đường dẫn thư mục dữ liệu từ ô FolderPath (sheet Cai_dat); thêm dấu \ ở cuối nếu người dùng gõ thiếu
    #"Thư mục dữ liệu" = let DuongDan = Text.Trim(Excel.CurrentWorkbook(){[Name = "FolderPath"]}[Content]{0}[Column1])
        in if Text.EndsWith(DuongDan, "\") then DuongDan else DuongDan & "\",
    // Tìm file POS theo phần đầu tên, không ghi cứng năm
    #"Các file POS tìm thấy" = Table.SelectRows(Folder.Contents(#"Thư mục dữ liệu"),
        each Text.StartsWith([Name], "POS_Sales_Export") and Text.Lower([Extension]) = ".csv"),
    // Phải có đúng 1 file, nếu không thì báo lỗi rõ ràng
    #"Nội dung file POS" = if Table.RowCount(#"Các file POS tìm thấy") = 1 then #"Các file POS tìm thấy"{0}[Content]
        else error Error.Record("Sai số file", "Thư mục dữ liệu phải có đúng 1 file bắt đầu bằng POS_Sales_Export (.csv), đang có "
            & Text.From(Table.RowCount(#"Các file POS tìm thấy"))),
    // Đọc file CSV (dấu phẩy ngăn cột, mã UTF-8)
    #"Đọc file CSV" = Csv.Document(#"Nội dung file POS", [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    // Dòng đầu của file là tên cột
    #"Dòng đầu là tên cột" = Table.PromoteHeaders(#"Đọc file CSV", [PromoteAllScalars = true]),
    // Đổi kiểu theo vùng en-US: số dùng dấu chấm thập phân, ngày dạng YYYY-MM-DD
    #"Đổi kiểu dữ liệu (en-US)" = Table.TransformColumnTypes(#"Dòng đầu là tên cột", {
        {"receipt_no", type text}, {"line_no", Int64.Type}, {"business_date", type date}, {"store_id", Int64.Type},
        {"product_id", Int64.Type}, {"qty", Int64.Type}, {"unit_price", type number}, {"discount_amount", type number},
        {"line_amount", type number}, {"currency", type text}, {"exported_at", type datetime}}, "en-US"),
    // BẪY 4 – dòng trùng khóa receipt_no + line_no (file bị xuất lại lần 2).
    // Sắp theo giờ xuất; Table.Buffer giữ đúng thứ tự đã sắp cho các bước sau
    #"Sắp theo giờ xuất" = Table.Buffer(Table.Sort(#"Đổi kiểu dữ liệu (en-US)", {{"exported_at", Order.Ascending}})),
    // Đánh số thứ tự từng dòng theo thứ tự giờ xuất: dòng xuất sớm hơn có số nhỏ hơn
    #"Đánh số thứ tự dòng" = Table.AddIndexColumn(#"Sắp theo giờ xuất", "row_id", 1, 1, Int64.Type),
    // Với mỗi khóa receipt_no + line_no: lấy số thứ tự nhỏ nhất (lần xuất đầu tiên) và đếm số lần xuất
    #"Lần xuất đầu tiên của mỗi khóa" = Table.Group(#"Đánh số thứ tự dòng", {"receipt_no", "line_no"},
        {{"first_row_id", each List.Min([row_id]), Int64.Type}, {"export_count", each Table.RowCount(_), Int64.Type}}),
    // Ghép lần xuất đầu tiên vào từng dòng (đổi tên khóa bên phải để không trùng tên cột)
    #"Ghép lần xuất đầu tiên" = Table.Join(#"Đánh số thứ tự dòng", {"receipt_no", "line_no"},
        Table.RenameColumns(#"Lần xuất đầu tiên của mỗi khóa", {{"receipt_no", "k_receipt_no"}, {"line_no", "k_line_no"}}), {"k_receipt_no", "k_line_no"}),
    // Dòng nào không phải lần xuất đầu tiên của khóa thì là dòng trùng.
    // Giữ đủ mọi dòng để số dòng khớp bảng tổng kiểm soát; các bước sau lọc theo cột is_duplicate
    #"Cờ dòng trùng" = Table.AddColumn(Table.RemoveColumns(#"Ghép lần xuất đầu tiên", {"k_receipt_no", "k_line_no"}),
        "is_duplicate", each [row_id] <> [first_row_id], type logical),
    // Ghi lý do cho dòng trùng: giờ xuất lại
    #"Lý do trùng" = Table.AddColumn(#"Cờ dòng trùng", "duplicate_reason",
        each if [is_duplicate] then "Trùng receipt_no + line_no, xuất lại lúc " & DateTime.ToText([exported_at], "yyyy-MM-dd HH:mm") else null, type text),
    // Tiền sau giảm giá, vẫn là nội tệ.
    // BẪY 5 – nhiều loại tiền: chưa cộng tiền ở đây; chỉ cộng sau khi đã đổi từng dòng ra USD (bảng giao dịch chung q_Transactions)
    #"Tiền sau giảm giá" = Table.AddColumn(#"Lý do trùng", "net_amount", each [line_amount] - [discount_amount], type number),
    // Bỏ cột phụ chỉ dùng để tìm dòng trùng
    #"Bỏ cột phụ" = Table.RemoveColumns(#"Tiền sau giảm giá", {"first_row_id"}),
    // Sắp lại theo ngày bán, hóa đơn, dòng hàng cho dễ đọc
    #"Sắp lại theo ngày bán" = Table.Sort(#"Bỏ cột phụ", {{"business_date", Order.Ascending}, {"receipt_no", Order.Ascending}, {"line_no", Order.Ascending}, {"row_id", Order.Ascending}})
in
    #"Sắp lại theo ngày bán"
