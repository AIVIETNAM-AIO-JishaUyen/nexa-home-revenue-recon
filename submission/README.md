# Bộ file nộp – Project 1: Đối soát doanh thu Nexa Home 2025

| File | Là gì | Mở thế nào |
|---|---|---|
| `Bao_cao_Nexa_Home_2025.pdf` | Báo cáo 8 phần và phụ lục. Đọc hộp tóm tắt ở trang 1 trước | Trình đọc PDF |
| `Nexa_Home_Recon_PQ.xlsx` | File Power Query: nạp 4 file dữ liệu, đối soát, bảng cầu nối, nhật ký ngoại lệ, kiểm tra chất lượng dữ liệu. Sheet `Huong_dan` liệt kê mọi sheet | Excel 365. Sửa ô `Cai_dat!B2` thành thư mục chứa dữ liệu của đề rồi chọn Data > Refresh All (khoảng 3–5 phút) |
| `Mau_nop_Bang_cau_noi.xlsx` | File mẫu nộp của đề, đã điền số (giá trị chép từ file Power Query; dòng Kiểm tra bằng 0 ở 12 tháng) | Excel |
| `NexaRecon_PowerBI.zip` | Dự án Power BI dạng thư mục: mô hình, dashboard 4 trang, toàn bộ công thức DAX (`powerbi/dax_measures.dax`), truy vấn kiểm tra và ảnh chụp (`powerbi/checks/`) | Giải nén, mở `powerbi/NexaRecon.pbip` bằng Power BI Desktop; sửa 2 tham số `DataFolder`, `PQFile` (Home > Transform data > Edit parameters) rồi Refresh. Xem `powerbi/README.md` |
| `Ma_Power_Query.zip` | Code các truy vấn Power Query (file `.m`) và script dựng lại / làm mới file Excel | Trình soạn thảo chữ |

Chênh lệch = Sổ cái − Flash; số âm nghĩa là sổ cái thấp hơn Flash. Đơn vị USD.
