# Dự án Power BI: NexaRecon

> Dự án Power BI dạng thư mục (`.pbip`, Power BI Project): mô hình dữ liệu viết bằng TMDL (Tabular Model Definition Language, file chữ mô tả bảng, quan hệ, công thức), báo cáo dạng PBIR (Power BI enhanced report format, mỗi trang và mỗi hình là một file JSON – JavaScript Object Notation, file chữ lưu dữ liệu có cấu trúc). Nhờ vậy cả nhóm đọc và so sánh được từng thay đổi trên Git.
> Dữ liệu: file `data/Nexa_Home_Recon_Dataset.xlsx` mentor (người hướng dẫn) đã chuẩn bị cho Power BI. Đây là cách tính thứ hai (Việc 5 của roadmap) để kiểm tra lại số của Power Query.
> Flash là báo cáo nhanh doanh số của phòng Kinh doanh; sổ cái là sổ kế toán của phòng Tài chính.

---

## 1. Mở dự án

1. Cài Power BI Desktop (bản Microsoft Store). Cả nhóm dùng cùng một phiên bản (xem `plans/backlog.md` mục 2).
2. Mở file `powerbi/NexaRecon.pbip` bằng Power BI Desktop.
3. Nếu thư mục dự án trên máy bạn khác `D:\DS-AI\AIO-BA\Sale-Domain-ProjectI`: ở thẻ **Home**, bấm mũi tên nhỏ dưới nút **Transform data**, chọn **Edit parameters**, sửa `DataFolder` thành đường dẫn thư mục `data` của bạn (có dấu `\` ở cuối), bấm **OK**. Nếu hiện thanh vàng có nút **Apply changes** thì bấm nút đó.
4. Bấm **Refresh** (Làm mới). Dự án không lưu sẵn dữ liệu nên lần đầu mở sẽ thấy hình trống cho tới khi làm mới. Nếu báo không tìm thấy file thì kiểm tra lại bước 3.
5. Không bấm **Save** (Lưu) trong Power BI Desktop nếu không định đưa thay đổi lên Git: khi lưu, Power BI viết lại các file `.tmdl` và file JSON của trang báo cáo (xem mục 4).

---

## 2. Các bảng và quan hệ (slide 19)

- 6 bảng danh mục (dim): `dim_date`, `dim_store`, `dim_channel`, `dim_currency`, `dim_journal_type`, `dim_order_status`.
- 4 bảng giao dịch (fact): `fact_pos_line`, `fact_web_order`, `fact_gl_entry`, `fact_sales_flash`.
- 2 bảng tỷ giá: `fact_fx_daily`, `fact_fx_month_end` (không nối với bảng nào; các bảng giao dịch đã có sẵn cột tỷ giá).
- `dim_date` được đánh dấu là bảng ngày (cột `date` là khóa).
- Mọi quan hệ là nhiều-một, lọc một chiều từ bảng danh mục xuống bảng giao dịch; không nối thẳng 2 bảng giao dịch với nhau.
- Quan hệ chủ động (active): Power BI tự dùng khi lọc. Quan hệ bị động (inactive): chỉ dùng khi công thức bật bằng hàm `USERELATIONSHIP`. Giữa 2 bảng chỉ có 1 quan hệ chủ động.

| Quan hệ | Nối | Chủ động? | Vì sao |
|---|---|---|---|
| `pos_posting_date` | `fact_pos_line.posting_date` → `dim_date.date` | Có | Sổ cái ghi doanh thu cửa hàng (POS – Point of Sale, bán tại cửa hàng) theo ngày ghi sổ |
| `pos_business_date` | `fact_pos_line.business_date` → `dim_date.date` | Không | <ul><li>Ngày bán</li><li>Chỉ bật bằng hàm `USERELATIONSHIP` khi cần tính theo ngày bán (Flash, chiết khấu, dòng trùng)</li></ul> |
| `web_delivery_date` | `fact_web_order.delivery_date` → `dim_date.date` | Có | Sổ cái ghi doanh thu online theo ngày giao |
| `web_order_date` | `fact_web_order.order_date` → `dim_date.date` | Không | <ul><li>Ngày đặt</li><li>Flash tính theo ngày đặt</li></ul> |
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

**Lưu ý khi viết công thức và làm dashboard:**
- Bảng ngày có cả tháng 12/2024 và tháng 1/2026 (đơn online đặt tháng 12/2024, giao hoặc trả hàng đầu năm 2026). Đơn hủy không có ngày giao nên bộ lọc theo tháng có thể hiện mục "(Blank)". Lọc `dim_date[is_fiscal_2025] = TRUE` (gợi ý ở sheet README của file mentor) bỏ được cả 3 thứ này. Sổ cái và Flash không có dòng ngoài năm 2025, nên trang "Số tổng" chưa cần lọc.
- Flash chỉ nối với bảng ngày (ngày cuối tháng) và bảng kênh. Lọc theo cửa hàng, loại tiền hay loại bút toán thì Flash không đổi, nên `Chênh lệch` ở mức đó không có nghĩa. Flash ghi vào ngày cuối tháng, nên lọc một khoảng ngày không chứa ngày cuối tháng thì Flash ra trống; hãy lọc theo tháng.
- Các cột `*_usd_*` trong file mentor đã làm tròn 2 chữ số ở từng dòng. Muốn ra đúng số của Power Query thì tính nội tệ ÷ tỷ giá từng dòng bằng hàm `SUMX`, ví dụ chiết khấu: cộng cột làm tròn ra −1.834.298,38, tính từ nội tệ ra −1.834.297,47 (số chuẩn).

---

## 3. Công thức (bảng `_Measures`)

| Công thức | Cách tính |
|---|---|
| `Flash` | Tổng `fact_sales_flash[revenue_usd]` |
| `Sổ cái` | Tổng `fact_gl_entry[revenue_usd]` (đã đổi dấu) |
| `Chênh lệch` | `[Sổ cái] − [Flash]` |
| `% chênh lệch so với Flash` | Chênh lệch ÷ Flash (thẻ KPI – Key Performance Indicator, slide 12) |
| `% chênh lệch so với sổ cái` | <ul><li>Chênh lệch ÷ \|Sổ cái\| (\|x\| là giá trị tuyệt đối, tức bỏ dấu âm), mẫu "Δ %" của slide 29</li><li>Dùng được ở mức tháng hoặc kênh</li><li>Cờ vượt ngưỡng cửa hàng × tháng (slide 28, 30) không dùng công thức này, vì Flash không có số theo cửa hàng: cờ dùng chênh lệch sổ cái − POS sau khi đưa về cùng cách tính, làm ở plan `dax-bridge`</li></ul> |

Công thức từng khoản cầu nối: plan `dax-bridge`.

---

## 4. File trong thư mục này

| File | Dùng để |
|---|---|
| `NexaRecon.pbip`, `NexaRecon.SemanticModel/`, `NexaRecon.Report/` | Dự án Power BI |
| `build_report.py` | <ul><li>Sinh các trang báo cáo (`NexaRecon.Report/definition`)</li><li>Sửa trang thì sửa file này rồi chạy `D:/Anaconda/python.exe -I powerbi/build_report.py`, không sửa tay file JSON</li><li>Mỗi lần chạy, script xóa cả thư mục `NexaRecon.Report/definition` rồi tạo lại: phần nào sửa bằng giao diện Power BI Desktop rồi lưu sẽ mất (cách làm dashboard đang chờ nhóm chốt, xem `plans/backlog.md` mục 4)</li></ul> |
| `dax_query.ps1` | <ul><li>Mở dự án, làm mới, chạy truy vấn DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) ra file CSV (Comma-Separated Values, file bảng dạng chữ) để so với Power Query</li><li>Cách gọi: xem các dòng ví dụ ở đầu file</li><li>Lệnh `-Close` tắt hẳn Power BI, không lưu</li></ul> |
| `checks/*.dax`, `checks/*.csv` | Các truy vấn kiểm tra và kết quả |
| `checks/screenshot_*.png` | Ảnh chụp trang báo cáo làm bằng chứng |
