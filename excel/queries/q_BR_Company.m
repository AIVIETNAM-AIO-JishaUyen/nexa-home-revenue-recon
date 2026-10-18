// q_BR_Company – Bảng cầu nối toàn công ty dạng ngang để đọc: mỗi khoản một dòng, mỗi tháng một cột, thêm cột cả năm. Nhãn nguồn: [BR-Tổng].
// Chỉ đọc lại q_BR_Long (cột bridge = COMPANY), không tính thêm gì.
let
    // Bảng toàn công ty từ bảng cầu nối dạng dài
    #"Toàn công ty" = Table.SelectRows(q_BR_Long, each [bridge] = "COMPANY"),
    // Danh sách tháng theo thứ tự (làm tên cột)
    #"Các tháng" = List.Sort(List.Distinct(#"Toàn công ty"[period])),
    // Xoay: mỗi tháng thành một cột
    #"Xoay cột" = Table.Pivot(Table.SelectColumns(#"Toàn công ty", {"item_order", "item_name", "item_group", "period", "usd"}), #"Các tháng", "period", "usd", List.Sum),
    // Cột cả năm = tổng các tháng
    #"Cột cả năm" = Table.AddColumn(#"Xoay cột", "Cả năm", each List.Sum(Record.ToList(Record.SelectFields(_, #"Các tháng"))), type number),
    // Làm tròn mọi cột tiền đến 2 chữ số
    #"Làm tròn" = Table.TransformColumns(#"Cột cả năm", List.Transform(#"Các tháng" & {"Cả năm"}, (c) => {c, each Number.Round(_, 2), type number})),
    // Sắp theo thứ tự khoản
    #"Sắp xếp" = Table.Sort(#"Làm tròn", {{"item_order", Order.Ascending}})
in
    #"Sắp xếp"
