# Dự án Power BI: NexaRecon

> Dự án Power BI dạng thư mục (`.pbip`, Power BI Project): mô hình dữ liệu viết bằng TMDL (Tabular Model Definition Language, file chữ mô tả bảng, quan hệ, công thức), báo cáo dạng PBIR (Power BI enhanced report format, mỗi trang và mỗi hình là một file JSON – JavaScript Object Notation, file chữ lưu dữ liệu có cấu trúc). Nhờ vậy cả nhóm đọc và so sánh được từng thay đổi trên Git.
> Dữ liệu: file `data/Nexa_Home_Recon_Dataset.xlsx` mentor (người hướng dẫn) đã chuẩn bị cho Power BI. Đây là cách tính thứ hai (Việc 5 của roadmap) để kiểm tra lại số của Power Query.
> Flash là báo cáo nhanh doanh số của phòng Kinh doanh; sổ cái là sổ kế toán của phòng Tài chính.

---

## 1. Mở dự án

1. Cài Power BI Desktop (bản Microsoft Store). Cả nhóm dùng cùng một phiên bản (xem `plans/backlog.md` mục 2).
2. Mở file `powerbi/NexaRecon.pbip` bằng Power BI Desktop.
3. Nếu thư mục dự án trên máy bạn khác `D:\DS-AI\AIO-BA\Sale-Domain-ProjectI`: ở thẻ **Home**, bấm mũi tên nhỏ dưới nút **Transform data**, chọn **Edit parameters**, sửa `DataFolder` thành đường dẫn thư mục `data` của bạn (có dấu `\` ở cuối) và `PQFile` thành đường dẫn file `excel\Nexa_Home_Recon_PQ.xlsx` của bạn, bấm **OK**. Nếu hiện thanh vàng có nút **Apply changes** thì bấm nút đó.
4. Bấm **Refresh** (Làm mới). Dự án không lưu sẵn dữ liệu nên lần đầu mở sẽ thấy hình trống cho tới khi làm mới. Nếu báo không tìm thấy file thì kiểm tra lại bước 3.
5. Không bấm **Save** (Lưu) trong Power BI Desktop nếu không định đưa thay đổi lên Git: khi lưu, Power BI viết lại các file `.tmdl` và file JSON của trang báo cáo (xem mục 4).

---

## 2. Các bảng và quan hệ (slide 19)

- 6 bảng danh mục (dim): `dim_date`, `dim_store`, `dim_channel`, `dim_currency`, `dim_journal_type`, `dim_order_status`.
- 4 bảng giao dịch (fact): `fact_pos_line`, `fact_web_order`, `fact_gl_entry`, `fact_sales_flash`.
- 2 bảng tỷ giá: `fact_fx_daily`, `fact_fx_month_end` (không nối với bảng nào; các bảng giao dịch đã có sẵn cột tỷ giá).
- 2 bảng đọc từ file Power Query (tham số `PQFile`), để hai cách tính dùng chung danh mục khoản và so số với nhau:
  - `dim_bridge_item`: danh mục khoản cầu nối (mã, thứ tự, tên, nhóm), từ bảng `q_BridgeItems`.
  - `pq_br_long`: bảng cầu nối dạng dài Power Query tính, từ bảng `q_BR_Long` (708 dòng); nối `item_code` → `dim_bridge_item`.
- Cột tính thêm (công thức DAX tính một lần khi làm mới):
  - `fact_pos_line[is_duplicate]`: dòng xuất lặp (cùng số hóa đơn + số dòng, lần xuất sau).
  - `fact_pos_line[fx_rate_daily_posting]`, `fact_gl_entry[fx_rate_daily_posting]`: tỷ giá ngày của ngày ghi sổ (cho khoản lỗi chuyển dữ liệu).
  - `fact_pos_line[fx_rate_month_end_sale]`: tỷ giá cuối tháng bán (cho chênh lệch cửa hàng × tháng "trước xử lý").
  - `dim_date[trong_ky_doi_soat]`: TRUE nếu tháng có trong Flash. Mọi công thức cầu nối chỉ tính trong các tháng này, nên không phải ghi cứng năm.
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

**Thư mục "2. Cầu nối (DAX)":** mỗi khoản một công thức, cùng định nghĩa với truy vấn `q_BR_Long` của Power Query, tính lại từ nội tệ ÷ tỷ giá từng dòng (không cộng cột USD đã làm tròn).

| Khoản | Tính theo ngày nào (quan hệ) | Tỷ giá |
|---|---|---|
| Chiết khấu | POS: ngày bán; online: ngày đặt (`USERELATIONSHIP`) | Ngày bán / ngày đặt |
| Dòng POS bị trùng | Ngày bán | Ngày bán |
| Đơn online bị hủy | Ngày đặt | Ngày đặt |
| Lệch thời điểm online | Ngày giao − ngày đặt | Ngày đặt |
| Lệch ngày ghi sổ của cửa hàng | Ngày ghi sổ − ngày bán | Ngày bán |
| Lỗi chuyển dữ liệu | Ngày ghi sổ (bút toán POS trên sổ cái − dòng POS bỏ trùng) | Ngày của ngày ghi sổ, cho cả 2 phía |
| Hàng trả lại | Ngày nhận hàng trả | Ngày đặt |
| Phí vận chuyển, chuyển kênh, chưa giải thích được | Ngày ghi sổ (bút toán tay MJ-SHIP, MJ-RCL, MJ-ADJ) | Số sổ cái ghi |
| Tỷ giá | Bút toán sổ cái tự động theo tỷ giá cuối tháng (chưa làm tròn) − cùng giao dịch theo tỷ giá ngày | Định nghĩa slide 34 |
| Làm tròn | (Giá trước giảm giá chưa làm tròn − Flash) + (sổ cái đã làm tròn − chưa làm tròn) | |

`Kiểm tra cầu nối` = Flash + các khoản − sổ cái, phải bằng 0. Thư mục con "Phần tính chung" chứa các phần dùng lại ở nhiều khoản.

**Thư mục "3. So với Power Query":** `Cầu nối (DAX)` trả về số của khoản đang chọn trong `dim_bridge_item`; `Cầu nối (Power Query)` lấy số cùng khoản, cùng tháng trong `pq_br_long` (chọn đúng 1 kênh thì lấy bảng của kênh đó, không thì bảng toàn công ty); `Lệch DAX − Power Query` phải bằng 0.

**Thư mục "4. Đối soát cửa hàng × tháng (slide 30)":** chênh lệch Sổ cái − POS trước xử lý (mọi dòng, theo tháng bán, tỷ giá cuối tháng bán) và sau xử lý (bỏ dòng trùng, theo tháng ghi sổ, tỷ giá cuối tháng ghi sổ); cờ vượt ngưỡng 200 USD và 1% của |sổ cái|; số ô vượt ngưỡng.

**Kết quả so (18/10/2026):**
- `checks/bridge_compare.csv`: 709 ô (toàn công ty và 3 kênh × 12 tháng × khoản), lệch DAX − Power Query lớn nhất 0,000000007 USD.
- `checks/store_month_compare.csv`: 679/679 ô cửa hàng × tháng của Power Query (sheet `Doi_soat_CH_thang`) khớp tuyệt đối, cả 2 cờ.
- `checks/store_month_flags.csv`: 137 → 2 ô vượt ngưỡng cả kỳ; tháng 11: 21 → 1.

Toàn bộ công thức (đọc, không cần mở Power BI): `dax_measures.dax`, xuất bằng truy vấn `EVALUATE INFO.VIEW.MEASURES()`.

---

## 4. File trong thư mục này

| File | Dùng để |
|---|---|
| `NexaRecon.pbip`, `NexaRecon.SemanticModel/`, `NexaRecon.Report/` | Dự án Power BI |
| `build_report.py` | <ul><li>Sinh các trang báo cáo (`NexaRecon.Report/definition`)</li><li>Sửa trang thì sửa file này rồi chạy `D:/Anaconda/python.exe -I powerbi/build_report.py`, không sửa tay file JSON</li><li>Mỗi lần chạy, script xóa cả thư mục `NexaRecon.Report/definition` rồi tạo lại: phần nào sửa bằng giao diện Power BI Desktop rồi lưu sẽ mất (cách làm dashboard đang chờ nhóm chốt, xem `plans/backlog.md` mục 4)</li></ul> |
| `dax_query.ps1` | <ul><li>Mở dự án, làm mới, chạy truy vấn DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) ra file CSV (Comma-Separated Values, file bảng dạng chữ) để so với Power Query</li><li>Cách gọi: xem các dòng ví dụ ở đầu file</li><li>Lệnh `-Close` tắt hẳn Power BI, không lưu</li></ul> |
| `checks/*.dax`, `checks/*.csv` | <ul><li>Các truy vấn kiểm tra và kết quả</li><li>So cầu nối: `-QueryFile powerbi\checks\bridge_compare.dax -OutCsv powerbi\checks\bridge_compare.csv` (tương tự cho `store_month_compare`, `store_month_flags`)</li></ul> |
| `dax_measures.dax` | Toàn bộ công thức DAX của mô hình, xuất ra để đọc và nộp. Bản gốc là các file `.tmdl`; sửa công thức thì sửa `.tmdl` rồi xuất lại |
| `checks/screenshot_*.png` | Ảnh chụp trang báo cáo làm bằng chứng |
