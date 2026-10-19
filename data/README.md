# Dữ liệu của đề

> Các file do đề cung cấp. **Không sửa tay**: mọi xử lý nằm trong Power Query (`excel/`) và Power BI (`powerbi/`). Cấu trúc từng file (mỗi dòng là gì, khóa, cột ngày, cột tiền) xem ở [`docs/cau_truc_du_lieu.md`](../docs/cau_truc_du_lieu.md).

| File | Là gì | Ai đọc |
|---|---|---|
| `POS_Sales_Export_2025.csv` | Bán hàng tại cửa hàng (POS – Point of Sale): mỗi dòng là một món hàng trên một hóa đơn | Power Query, Python |
| `WEB_Orders_Export.csv` | Đơn online: mỗi dòng là một đơn; ngày ghi kiểu Mỹ (tháng/ngày/năm) | Power Query, Python |
| `Finance_GL_Revenue_FY2025.xlsx` | Sổ cái (GL – General Ledger) của phòng Tài chính: mỗi dòng là một bút toán | Power Query, Python |
| `Sales_Flash_Report_2025.xlsx` | Báo cáo nhanh doanh số (Flash) của phòng Kinh doanh: tháng × kênh × thị trường | Power Query, Python |
| `Nexa_Home_Master_Data.xlsx` | Danh mục: cửa hàng, lịch, tỷ giá ngày, tỷ giá cuối tháng, bảng tổng kiểm soát QC_Summary (QC – Quality Control) | Power Query, Python |
| `Nexa_Home_Recon_Dataset.xlsx` | Cùng bộ số trên, mentor (người hướng dẫn) đã gom sẵn thành mô hình cho Power BI. Bản trong `docs/template/` chỉ khác bản này ở sheet `QC_Summary`; Power BI đọc bản trong `data/` | Power BI |
| `Mau_nop_Bang_cau_noi.xlsx` | File mẫu nộp của đề: bảng cầu nối và nhật ký ngoại lệ | Script dựng file Power Query (chép sheet), script gom bộ file nộp (điền số) |

**Đổi thư mục dữ liệu:** file Power Query đọc đường dẫn ở ô `Cai_dat!B2`; Power BI đọc tham số `DataFolder`. Không file nào ghi cứng đường dẫn trong code truy vấn.
