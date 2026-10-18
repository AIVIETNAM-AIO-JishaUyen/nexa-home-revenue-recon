# Cấu trúc dữ liệu và các tên dùng chung

> Tài liệu tham khảo cho [roadmap](../roadmap.md). Từ khó xem ở [từ điển](../tu_dien_roadmap.md). Quy ước tính xem ở [quy ước tính và số chuẩn](quy_uoc_va_so_chuan.md).
> Tên file, tên cột, tên truy vấn giữ tiếng Anh như dữ liệu gốc (slide 7). Phần giải thích viết tiếng Việt.

---

## 1. Bốn nguồn dữ liệu (slide 16)

| Nguồn | 1 dòng là gì | Khóa (cột phân biệt từng dòng) | Ngày | Loại tiền | Dấu | Số dòng |
|---|---|---|---|---|---|---:|
| POS (Point of Sale, bán tại cửa hàng) `POS_Sales_Export_2025.csv` | 1 món hàng trên 1 hóa đơn | `receipt_no` + `line_no` | `business_date`: ngày bán, dạng YYYY-MM-DD (năm-tháng-ngày) | Nội tệ của nước có cửa hàng | Dương | 17.124 |
| WEB (đơn online) `WEB_Orders_Export.csv` | 1 đơn hàng | `web_order_id` | <ul><li>`order_date`: ngày đặt</li><li>`delivery_date`: ngày giao (trống nếu đơn hủy)</li><li>`return_date`: ngày nhận hàng trả</li><li>Cả 3 ghi kiểu Mỹ MM/DD/YYYY (tháng/ngày/năm)</li></ul> | Loại tiền khách trả | Dương | 9.441 |
| Sổ cái (GL – General Ledger) `Finance_GL_Revenue_FY2025.xlsx` | <ul><li>1 bút toán (dòng ghi sổ)</li><li>Bút toán tự động gộp nhiều giao dịch: cửa hàng × ngày ghi sổ, hoặc ngày giao × loại tiền</li></ul> | `journal_id` | `posting_date`: ngày ghi sổ | <ul><li>`amount_local`: nội tệ</li><li>`amount_usd`: USD (đô la Mỹ) theo tỷ giá cuối tháng, làm tròn 2 chữ số</li></ul> | <ul><li>Doanh thu mang dấu âm (kế toán gọi là ghi Có)</li><li>Hàng trả mang dấu dương (kế toán gọi là ghi Nợ)</li></ul> | 6.940 |
| Flash `Sales_Flash_Report_2025.xlsx` | 1 tháng × 1 kênh × 1 thị trường | Không có khóa | Tháng đặt hàng | USD theo tỷ giá ngày đặt, làm tròn đến USD | Dương | 156 dòng chi tiết |

**Bốn bảng danh mục** trong `Nexa_Home_Master_Data.xlsx`:

| Sheet | Có gì | Số dòng | Lưu ý |
|---|---|---:|---|
| `store_master` | Mã cửa hàng bên POS (`pos_store_id`) và mã bên kế toán (`finance_store_code`, dạng NX001; online là WEB), nước, loại tiền, ngày mở, ngày đóng | 74 | <ul><li>Một mã NX có thể có nhiều mã POS: NX007 có 3 mã; NX003, NX025, NX046, NX058, NX060 có 2 mã</li><li>Có 57 cửa hàng bán hàng trong năm 2025</li><li>Thêm cửa hàng mới chỉ cần thêm dòng vào bảng này</li></ul> |
| `calendar` | Mỗi ngày từ 01/12/2024 đến 31/01/2026, cờ `working_day` (1 = ngày làm việc) | 427 | 135 ngày nghỉ (cuối tuần, ngày lễ) |
| `fx_daily` | Tỷ giá theo ngày × loại tiền | 2.135 | Tỷ giá là **số ngoại tệ đổi được 1 USD**, nên muốn đổi nội tệ ra USD thì **chia** cho tỷ giá |
| `fx_month_end` | Tỷ giá ngày cuối tháng × loại tiền | 70 | Chia như trên |

---

## 2. Mỗi bên ghi doanh thu thế nào (slide 17)

| Lý do lệch (đề gọi là "trục khác biệt") | Flash (phòng Kinh doanh) | Sổ cái – cửa hàng | Sổ cái – online |
|---|---|---|---|
| Thời điểm | Ngày khách đặt hàng | <ul><li>Ngày ghi sổ</li><li>Bán vào ngày nghỉ thì ghi sổ vào ngày làm việc kế tiếp</li></ul> | <ul><li>Ngày giao hàng thành công</li><li>Hàng trả ghi giảm doanh thu vào ngày nhận hàng trả</li></ul> |
| Giá trị | Giá niêm yết, **trước** giảm giá | Sau giảm giá | Sau giảm giá |
| Phạm vi | <ul><li>Gồm cả đơn sau đó bị hủy</li><li>Không trừ hàng trả</li></ul> | <ul><li>Mọi hóa đơn POS</li><li>Có thêm bút toán tay chuyển doanh thu một cửa hàng sang kênh online (slide 17, xem mục 3)</li></ul> | <ul><li>Không ghi đơn hủy</li><li>Trừ hàng trả</li><li>Có thêm bút toán tay phí vận chuyển</li></ul> |
| Tiền tệ | Tỷ giá ngày đặt | Tỷ giá cuối tháng ghi sổ | Tỷ giá cuối tháng ghi sổ |
| Mức chi tiết | Tháng × kênh × thị trường, làm tròn đến USD | 1 bút toán = 1 cửa hàng × 1 ngày ghi sổ | 1 bút toán = 1 ngày giao × 1 loại tiền |

---

## 3. Các loại bút toán của sổ cái

| `journal_type` | Là gì | Tài khoản | Số bút toán | Kênh |
|---|---|---|---:|---|
| `POS_DAILY` | Doanh thu bán lẻ tự động từ POS, gộp cửa hàng × ngày ghi sổ | 5111 (doanh thu bán hàng) | 5.118 | Cửa hàng |
| `POS_CATCHUP` | Bổ sung doanh thu POS bị thiếu (NX057, bán ngày 21/11, ghi ngày 02/12) | 5111 | 1 | Cửa hàng |
| `WEB_DELIVERY` | Doanh thu online tự động, gộp ngày giao × loại tiền | 5111 | 1.647 | Online |
| `WEB_RETURN` | Hàng bán bị trả lại, ghi vào ngày nhận hàng trả | 5213 (hàng bán bị trả lại, thuộc nhóm tài khoản 521 theo VAS 14 – Chuẩn mực kế toán Việt Nam số 14 về doanh thu) | 159 | Online |
| `MANUAL` | Bút toán tay do kế toán nhập (xem cột `source_ref`) | 5111 | 15 | <ul><li>12 bút toán `MJ-SHIP-25xx` (MJ = Manual Journal, bút toán tay; SHIP = Shipping, vận chuyển): phí vận chuyển mỗi tháng, kênh online</li><li>2 bút toán `MJ-RCL-2506` (RCL = Reclassification, phân loại lại): chuyển 3.480 USD từ cửa hàng NX019 sang online, tháng 6</li><li>1 bút toán `MJ-ADJ-2509`, diễn giải ghi ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh): 1.250 USD, không gắn kênh (UNALLOCATED), không có giấy tờ</li></ul> |

---

## 4. Tên các truy vấn Power Query

Ý nghĩa các nhãn nguồn (QC = Quality Control, kiểm soát chất lượng; RC = Reconciliation, đối soát; BR = Bridge, cầu nối; EX = Exception, ngoại lệ) xem dòng "Nhãn nguồn số liệu" trong [quy ước tính và số chuẩn](quy_uoc_va_so_chuan.md).

| Truy vấn | Làm gì | Nhãn nguồn khi trích số |
|---|---|---|
| `q_POS`, `q_WEB`, `q_GL`, `q_FLASH` | Nạp 4 file dữ liệu, xử lý 5 bẫy | |
| `q_Store`, `q_Calendar`, `q_FX_Daily`, `q_FX_MonthEnd` | Nạp 4 bảng danh mục; `q_Calendar` thêm cột ngày ghi sổ `posting_date` | |
| `q_WEB_Raw`, `q_FLASH_Raw` | Đọc thô file đơn online và file Flash, chưa xử lý; `q_WEB`, `q_FLASH` đọc tiếp từ đây | |
| `q_Check` | Sheet kiểm tra tổng: so với bảng tổng kiểm soát QC_Summary | `[QC]` |
| `q_Traps` | Sheet 5 bẫy: số trước và sau khi xử lý, kèm tên truy vấn và tên bước | `[QC]` |
| `q_Delta_Month`, `q_Delta_Channel` | Chênh lệch tổng theo tháng và theo kênh, có dòng kiểm tra | `[BR-Tổng]` (chỉ dòng Flash và sổ cái) |
| `q_Transactions` | Bảng giao dịch chung (mục 5) | |
| `q_DataQuality` | Sheet chất lượng dữ liệu: dòng trùng, ngày thiếu bút toán, bút toán không gắn cửa hàng… | `[QC]` |
| `q_RC_Store` | Đối soát cửa hàng × ngày ghi sổ | `[RC-CH]` |
| `q_RC_Web` | Đối soát online × ngày giao × loại tiền | `[RC-WEB]` |
| `q_RC_Return` | Đối soát hàng trả × ngày trả × loại tiền | `[RC-RET]` |
| `q_BR_Long` | Bảng cầu nối dạng dài (mục 6) | `[BR-Tổng]`, `[BR-CH]`, `[BR-WEB]` |
| `q_ExceptionLog` | Nhật ký ngoại lệ, mỗi khoản lệch một dòng | `[EX-xx]` |

---

## 5. Bảng giao dịch chung `q_Transactions`

Mỗi dòng giữ đúng mức chi tiết của nguồn: 1 dòng POS hoặc 1 đơn online (năm 2025: 17.124 + 9.441 = 26.565 dòng, nạp ra sheet `Giao_dich_chung`). Các bảng đối soát và bảng cầu nối lấy số POS và online từ bảng này. Các cột dưới đây xếp đúng thứ tự trong sheet.

| Cột | Kiểu | Ý nghĩa |
|---|---|---|
| `channel` | chữ | `STORE` hoặc `WEB` |
| `source_key` | chữ | Khóa của nguồn: `receipt_no-line_no` hoặc `web_order_id` |
| `pos_store_id` | số | Mã cửa hàng bên POS (online để trống) |
| `store_code` | chữ | Mã bên kế toán: NX… hoặc WEB |
| `country` | chữ | Nước của cửa hàng (online để trống) |
| `status` | chữ | POS: `Sold`; online: `Delivered`, `Returned`, `Cancelled` |
| `sale_date` | ngày | Ngày bán (POS) hoặc ngày đặt (online) |
| `recognition_date` | ngày | Ngày sổ cái ghi doanh thu: ngày ghi sổ (POS) hoặc ngày giao (online); trống nếu đơn hủy |
| `return_date` | ngày | Ngày nhận hàng trả (chỉ đơn `Returned`) |
| `currency` | chữ | USD, EUR (euro), GBP (bảng Anh), CAD (đô la Canada), AUD (đô la Úc) |
| `gross_local`, `discount_local`, `net_local` | số | Tiền trước giảm giá, chiết khấu, sau giảm giá theo nội tệ |
| `fx_daily` | số | Tỷ giá ngày bán / ngày đặt |
| `fx_month_end` | số | Tỷ giá cuối tháng của `recognition_date` |
| `fx_month_end_return` | số | Tỷ giá cuối tháng của `return_date` |
| `is_duplicate` | đúng/sai | Dòng POS bị xuất trùng (lần xuất thứ hai trở đi); online luôn là sai |
| `duplicate_reason` | chữ | Lý do, ví dụ "Trùng receipt_no + line_no, xuất lại lúc 2025-03-30 08:42" |
| `sale_period`, `recognition_period`, `return_period` | chữ | Tháng dạng YYYY-MM (năm-tháng) của ngày bán / đặt, ngày ghi nhận, ngày nhận hàng trả, để cộng theo tháng |
| `gross_usd_daily`, `discount_usd_daily`, `net_usd_daily` | số | Nội tệ ÷ `fx_daily`, **không làm tròn** |
| `net_usd_month_end` | số | `net_local` ÷ `fx_month_end`, không làm tròn (trống nếu đơn hủy) |
| `net_usd_month_end_return` | số | `net_local` ÷ `fx_month_end_return`, không làm tròn (chỉ đơn bị trả) |

---

## 6. Bảng cầu nối dạng dài `BR_Long`

- Một dòng = **một khoản của một bảng cầu nối trong một tháng**.
- Power Query, bảng kiểm tra Python và DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) đều cho ra bảng cùng dạng này, nên so với nhau chỉ cần ghép theo `bridge` + `period` + `item_code`.
- File mẫu nộp, dashboard và hình trong báo cáo đều lấy số từ bảng này.

| Cột | Ý nghĩa |
|---|---|
| `bridge` | Bảng cầu nối nào: `COMPANY` (toàn công ty), `STORE` (cửa hàng), `WEB` (online), `UNALLOCATED` (chưa gắn kênh) |
| `period` | Tháng, dạng `2025-01`. Số cả năm là tổng 12 tháng, không lưu riêng |
| `item_code` | Mã khoản (mục 7) |
| `item_order` | Thứ tự trong bảng cầu nối |
| `item_name` | Tên tiếng Việt của khoản |
| `item_group` | Nhóm: Quy tắc ghi nhận · Lỗi dữ liệu · Chưa giải thích được · Sai số chấp nhận |
| `usd` | Số tiền USD, dấu theo quy ước: khoản làm Flash cao hơn sổ cái ghi số âm |

Mỗi bảng ghi **đủ mọi khoản** của danh mục ở mục 7, khoản không áp dụng cho bảng đó thì bằng 0 (ví dụ bảng cửa hàng có dòng "Đơn online bị hủy" = 0), để 4 bảng cùng một hình dạng (quyết định ngày 18/10, plan `python-check`).

Toàn công ty = cửa hàng + online + chưa gắn kênh. Riêng dòng chuyển kênh MJ-RCL: cửa hàng −3.480, online +3.480, nên toàn công ty bằng 0 và không hiện dòng này.

---

## 7. Danh mục khoản cầu nối

- Tất cả khoản trước dòng tỷ giá đều tính theo **tỷ giá ngày** (ngày bán / ngày đặt). Riêng lỗi chuyển dữ liệu (khoản 6) dùng tỷ giá ngày của ngày ghi sổ.
- Cột "Bảng nào có" dưới đây ghi bảng cầu nối theo kênh nào có khoản đó. Bảng toàn công ty có mọi khoản (bằng tổng các bảng theo kênh), trừ khoản 9 vì cộng lại bằng 0.
- "Sau giảm giá" = nội tệ trước giảm giá − chiết khấu.
- Mọi số đổi ra USD đều **không làm tròn từng dòng**; chỉ làm tròn khi trình bày.

| Thứ tự | `item_code` | Tên | Nhóm | Bảng nào có | Cách tính |
|---:|---|---|---|---|---|
| 0 | `flash` | Doanh số Flash | | Cả 4 | Tổng Flash theo tháng đặt hàng (đã làm tròn đến USD) |
| 1 | `discount` | Chiết khấu | Quy tắc ghi nhận | Cửa hàng, online | −(chiết khấu của mọi dòng POS bán trong tháng, kể cả dòng trùng + chiết khấu của mọi đơn online đặt trong tháng, kể cả đơn hủy) |
| 2 | `pos_duplicate` | Dòng POS bị trùng | Lỗi dữ liệu | Cửa hàng | −(tiền sau giảm giá của các dòng trùng khóa `receipt_no + line_no`, bản xuất lần sau) |
| 3 | `cancelled` | Đơn online bị hủy | Quy tắc ghi nhận | Online | −(tiền sau giảm giá của đơn `Cancelled`, theo tháng đặt) |
| 4 | `online_timing` | Lệch thời điểm online | Quy tắc ghi nhận | Online | (tiền sau giảm giá của đơn không hủy, theo **tháng giao**) − (cùng các đơn đó theo **tháng đặt**) |
| 5 | `store_posting` | Lệch ngày ghi sổ của cửa hàng | Quy tắc ghi nhận | Cửa hàng | (POS đã bỏ trùng, sau giảm giá, theo **tháng ghi sổ**) − (cùng các dòng đó theo **tháng bán**) |
| 6 | `transfer_error` | Lỗi chuyển dữ liệu từ POS sang sổ cái | Lỗi dữ liệu | Cửa hàng | <ul><li>Tại từng ô cửa hàng × ngày ghi sổ: (nội tệ trên bút toán `POS_*` − nội tệ POS đã bỏ trùng) ÷ tỷ giá ngày của ngày ghi sổ</li><li>Năm 2025 chỉ có NX057: tháng 11 −7.227,56, tháng 12 +7.227,56</li></ul> |
| 7 | `returns` | Hàng trả lại | Quy tắc ghi nhận | Online | −(tiền sau giảm giá của đơn `Returned`, theo **tháng nhận hàng trả**, tỷ giá ngày đặt) |
| 8 | `shipping` | Phí vận chuyển (bút toán tay MJ-SHIP) | Quy tắc ghi nhận | Online | Doanh thu của các bút toán `MJ-SHIP` |
| 9 | `channel_reclass` | Chuyển kênh (bút toán tay MJ-RCL) | Quy tắc ghi nhận | Cửa hàng, online | Doanh thu của bút toán `MJ-RCL` theo kênh: cửa hàng −3.480, online +3.480 (tháng 6) |
| 10 | `fx` | Tỷ giá | Quy tắc ghi nhận | Cửa hàng, online | Với các giao dịch sổ cái ghi tự động (`POS_*`, `WEB_DELIVERY`, `WEB_RETURN`): <ul><li>Σ nội tệ ÷ tỷ giá cuối tháng ghi sổ, không làm tròn từng bút toán</li><li>Trừ đi cũng các giao dịch đó tính theo tỷ giá ngày, đúng như ở các khoản trước: dòng POS theo ngày bán, đơn online và hàng trả theo ngày đặt, phần lỗi chuyển dữ liệu theo ngày ghi sổ</li><li>Công thức theo slide 34</li></ul> |
| 11 | `rounding` | Làm tròn | Sai số chấp nhận | Cả 4 | <ul><li>Phần của Flash: (Flash tính lại từ POS và WEB theo giá trước giảm giá, tỷ giá ngày, chưa làm tròn) − (Flash trong file, đã làm tròn đến USD)</li><li>Cộng phần của sổ cái: (doanh thu sổ cái đã làm tròn từng bút toán) − (cùng doanh thu đó chưa làm tròn)</li></ul> |
| 12 | `unexplained` | Chưa giải thích được (bút toán ADJ-0925) | Chưa giải thích được | Chưa gắn kênh | <ul><li>Doanh thu bút toán `MJ-ADJ`</li><li>**Luôn để ở dòng này, không gộp vào khoản khác**</li></ul> |
| 13 | `gl` | Doanh thu theo sổ cái | | Cả 4 | Σ `amount_usd` đổi dấu |
| 14 | `check` | Kiểm tra | | Cả 4 | Flash + các khoản 1–12 − sổ cái. Phải về 0, chấp nhận sai ≤ 1 USD |

**Khớp với file mẫu nộp `Mau_nop_Bang_cau_noi.xlsx`** (sheet `Cau_noi`, bảng toàn công ty):
- 10 dòng "Khoản giải thích" = khoản 1–8, 10, 11.
- Dòng "Chưa giải thích được" = khoản 12.
- Khoản 9 không có ở bảng toàn công ty vì cộng lại bằng 0.
