# Dự án Power BI: NexaRecon

> Dự án Power BI dạng thư mục (`.pbip`, Power BI Project): mô hình dữ liệu viết bằng TMDL (Tabular Model Definition Language, file chữ mô tả bảng, quan hệ, công thức), báo cáo dạng PBIR (Power BI enhanced report format, mỗi trang và mỗi hình là một file JSON). Nhờ vậy cả nhóm đọc và so sánh được từng thay đổi trên Git.
> Dữ liệu: file `data/Nexa_Home_Recon_Dataset.xlsx` mentor (người hướng dẫn) đã chuẩn bị cho Power BI. Đây là cách tính thứ hai (Việc 5 của roadmap) để kiểm tra lại số của Power Query.

---

## 1. Mở dự án

1. Cài Power BI Desktop (bản Microsoft Store). Cả nhóm dùng cùng một phiên bản (xem `plans/backlog.md` mục 2).
2. Mở file `powerbi/NexaRecon.pbip` bằng Power BI Desktop.
3. Nếu thư mục dự án trên máy bạn khác `D:\DS-AI\AIO-BA\Sale-Domain-ProjectI`: chọn **Transform data > Edit parameters**, sửa `DataFolder` thành đường dẫn thư mục `data` của bạn (có dấu `\` ở cuối).
4. Bấm **Refresh** (Làm mới). Dự án không lưu sẵn dữ liệu nên lần đầu mở sẽ thấy hình trống cho tới khi làm mới.

---

## 2. Các bảng và quan hệ (slide 19)

- 6 bảng danh mục (dim): `dim_date`, `dim_store`, `dim_channel`, `dim_currency`, `dim_journal_type`, `dim_order_status`.
- 4 bảng giao dịch (fact): `fact_pos_line`, `fact_web_order`, `fact_gl_entry`, `fact_sales_flash`.
- 2 bảng tỷ giá: `fact_fx_daily`, `fact_fx_month_end` (không nối với bảng nào; các bảng giao dịch đã có sẵn cột tỷ giá).
- `dim_date` được đánh dấu là bảng ngày (cột `date` là khóa).
- Mọi quan hệ là nhiều-một, lọc một chiều từ bảng danh mục xuống bảng giao dịch; không nối thẳng 2 bảng giao dịch với nhau.

| Quan hệ | Nối | Chủ động? | Vì sao |
|---|---|---|---|
| `pos_posting_date` | `fact_pos_line.posting_date` → `dim_date.date` | Có | Sổ cái ghi doanh thu cửa hàng theo ngày ghi sổ |
| `pos_business_date` | `fact_pos_line.business_date` → `dim_date.date` | Không | Ngày bán; chỉ bật bằng hàm `USERELATIONSHIP` khi cần tính theo ngày bán (Flash, chiết khấu, dòng trùng) |
| `web_delivery_date` | `fact_web_order.delivery_date` → `dim_date.date` | Có | Sổ cái ghi doanh thu online theo ngày giao |
| `web_order_date` | `fact_web_order.order_date` → `dim_date.date` | Không | Ngày đặt; Flash tính theo ngày đặt |
| `web_return_date` | `fact_web_order.return_date` → `dim_date.date` | Không | Ngày nhận hàng trả |
| `gl_posting_date` | `fact_gl_entry.posting_date` → `dim_date.date` | Có | |
| `flash_month_end_date` | `fact_sales_flash.month_end_date` → `dim_date.date` | Có | Flash chỉ có số theo tháng |
| `pos_store`, `web_store`, `gl_store` | `store_key` → `dim_store.store_key` | Có | |
| `pos_currency`, `web_currency`, `gl_currency` | `currency` → `dim_currency.currency` | Có | |
| `store_channel` | `dim_store.channel_code` → `dim_channel.channel_code` | Có | Kênh của POS, online và sổ cái đi qua bảng cửa hàng |
| `gl_channel` | `fact_gl_entry.channel_code` → `dim_channel.channel_code` | Không | Để chủ động sẽ có 2 đường lọc từ bảng kênh xuống sổ cái |
| `flash_channel` | `fact_sales_flash.channel_code` → `dim_channel.channel_code` | Có | |
| `gl_journal_type` | `fact_gl_entry.journal_type` → `dim_journal_type.journal_type` | Có | |
| `web_order_status` | `fact_web_order.order_status` → `dim_order_status.order_status` | Có | |

Lưu ý: đơn hủy không có ngày giao, nên bộ lọc theo tháng có thể hiện mục "(Blank)". Dashboard lọc bỏ mục này.

---

## 3. Công thức (bảng `_Measures`)

| Công thức | Cách tính |
|---|---|
| `Flash` | Tổng `fact_sales_flash[revenue_usd]` |
| `Sổ cái` | Tổng `fact_gl_entry[revenue_usd]` (đã đổi dấu) |
| `Chênh lệch` | `[Sổ cái] − [Flash]` |
| `% chênh lệch so với Flash` | Chênh lệch ÷ Flash (thẻ KPI – Key Performance Indicator, slide 12) |
| `% chênh lệch so với sổ cái` | Chênh lệch ÷ \|Sổ cái\| (cờ vượt ngưỡng, slide 28) |

Công thức từng khoản cầu nối: plan `dax-bridge`.

---

## 4. File trong thư mục này

| File | Dùng để |
|---|---|
| `NexaRecon.pbip`, `NexaRecon.SemanticModel/`, `NexaRecon.Report/` | Dự án Power BI |
| `build_report.py` | Sinh các trang báo cáo (`NexaRecon.Report/definition`). Sửa trang thì sửa file này rồi chạy `D:/Anaconda/python.exe -I powerbi/build_report.py`, không sửa tay file JSON |
| `dax_query.ps1` | Mở dự án, làm mới, chạy truy vấn DAX (Data Analysis Expressions) ra file CSV để so với Power Query |
| `checks/*.dax`, `checks/*.csv` | Các truy vấn kiểm tra và kết quả |
| `checks/screenshot_*.png` | Ảnh chụp trang báo cáo làm bằng chứng |
