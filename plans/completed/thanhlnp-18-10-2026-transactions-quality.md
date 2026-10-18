# Bảng giao dịch chung và sheet chất lượng dữ liệu

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 2 – Nạp và làm sạch dữ liệu (phần sau: nối mã cửa hàng, gộp bảng giao dịch chung, sheet kiểm tra chất lượng) |
| Mốc phải đạt | Trước Mốc 3 (23/10) |
| Phần báo cáo liên quan | <ul><li>Phần II (Dữ liệu và chuẩn bị): bảng giao dịch chung, kiểm tra chất lượng dữ liệu</li><li>Dashboard trang 4 (chất lượng dữ liệu)</li></ul> |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [report-skeleton](../completed/thanhlnp-18-10-2026-report-skeleton.md)</li><li>Plan tiếp theo dùng kết quả này: `store-recon`, `web-return-recon`, `bridge-monthly`</li></ul> |

---

## 1. Mục tiêu

Có **một bảng giao dịch chung** `q_Transactions` gộp mọi dòng POS (Point of Sale, bán tại cửa hàng) và mọi đơn online về cùng một dạng: mã cửa hàng bên kế toán (mã NX, ví dụ NX001), ngày bán / ngày đặt, ngày sổ cái ghi nhận, tiền trước giảm giá, chiết khấu, sau giảm giá, **USD (đô la Mỹ) theo 2 tỷ giá** (tỷ giá ngày và tỷ giá cuối tháng), cờ dòng trùng kèm lý do. Các bảng đối soát và bảng cầu nối về sau lấy số POS và online từ bảng này (số sổ cái và Flash vẫn lấy từ `q_GL`, `q_FLASH`). Kèm theo là **sheet chất lượng dữ liệu** tự đếm các lỗi dữ liệu mỗi lần làm mới.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Truy vấn `q_Transactions`, nạp ra sheet `Giao_dich_chung`.
  - Truy vấn `q_DataQuality`, nạp ra sheet `Chat_luong_du_lieu`: dòng trùng, ngày có bán mà thiếu bút toán, bút toán không gắn cửa hàng, đơn hủy mà có ngày giao, đơn giao trước ngày đặt, hàng trả trước ngày giao, dòng bán ở cửa hàng đã đóng cửa, dòng thiếu tỷ giá, mã cửa hàng POS không có trong danh mục, bút toán tay không có giấy tờ.
  - Sửa dòng bẫy 5 (nhiều loại tiền) ở `q_Traps` để trỏ vào bước đổi tiền của `q_Transactions`.
  - Viết phần báo cáo: bảng giao dịch chung, bảng kiểm tra chất lượng.
- **Không làm (để cho plan khác):**
  - So POS với sổ cái theo cửa hàng × ngày → `store-recon`.
  - So đơn online với sổ cái → `web-return-recon`.
  - Cảnh báo khi phần chưa giải thích vượt ngưỡng (ghi chú kỹ thuật Việc 2 xếp vào sheet kiểm tra chất lượng) → `bridge-monthly`, vì phải có bảng cầu nối mới tính được phần chưa giải thích.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Các truy vấn nạp | `excel/queries/q_POS.m`, `q_WEB.m`, `q_GL.m`, `q_Store.m`, `q_Calendar.m`, `q_FX_Daily.m`, `q_FX_MonthEnd.m` | Plan `load-clean-data` |
| Cột của bảng giao dịch chung | `docs/cau_truc_du_lieu.md` mục 5 | |
| Số đúng để so | `checks/python_bridge.csv` | Plan `python-check` |
| 7 phép kiểm tra của dashboard mẫu | `docs/template/Nexa_Home_Recon_Dashboard.html` (dữ liệu nhúng, mục `checks`) | 12 dòng trùng, 1 ô thiếu bút toán, 1 bút toán không gắn cửa hàng, 4 phép còn lại bằng 0 |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Đổi nội tệ ra USD bằng cách **chia** cho tỷ giá, không làm tròn từng dòng.
- Tỷ giá ngày: ngày bán (POS) hoặc ngày đặt (online). Tỷ giá cuối tháng: tháng sổ cái ghi nhận (ngày ghi sổ, ngày giao, ngày nhận hàng trả).

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Truy vấn bảng giao dịch chung | `excel/queries/q_Transactions.m` → sheet `Giao_dich_chung` | Đối soát, cầu nối |
| Truy vấn kiểm tra chất lượng | `excel/queries/q_DataQuality.m` → sheet `Chat_luong_du_lieu` | Báo cáo phần II, dashboard trang 4 |
| File Excel dựng lại | `excel/Nexa_Home_Recon_PQ.xlsx` | |
| Phần báo cáo | `report/sections/02_du_lieu_chuan_bi.tex`, bảng sinh tự động | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Số dòng bảng giao dịch chung | 17.124 POS + 9.441 online = 26.565 | QC_Summary | 26.565 (17.124 + 9.441) | sheet `Giao_dich_chung` | Đạt |
| Tiền trước giảm giá theo tỷ giá ngày, theo tháng bán/đặt, từng kênh (chính là Flash – báo cáo nhanh doanh số của phòng Kinh doanh – trước khi làm tròn) | Flash + phần Flash làm tròn, từng tháng | `checks/python_bridge.csv` | Cả năm: cửa hàng 14.060.501,00; online (đơn đặt năm 2025) 17.063.900,96 | sheet `Giao_dich_chung` (cộng bằng Python) | Đạt |
| Chiết khấu, dòng trùng, đơn hủy theo tháng | khoản `discount`, `pos_duplicate`, `cancelled` | `checks/python_bridge.csv` | <ul><li>Khớp cả 12 tháng, lệch lớn nhất 0,00005 USD (do file `python_bridge.csv` chỉ lưu 4 chữ số thập phân)</li><li>So thêm lệch thời điểm online, lệch ngày ghi sổ, hàng trả, tỷ giá (cửa hàng và online): cũng khớp</li></ul> | như trên | Đạt |
| Dòng thiếu tỷ giá, mã cửa hàng không ghép được | 0 / 0 | dữ liệu | 0 / 0 | sheet `Chat_luong_du_lieu`, dòng 8, 9 | Đạt |
| Dòng POS trùng / ô ngày có bán mà thiếu bút toán / bút toán không gắn cửa hàng | 12 / 1 / 1 | dashboard mẫu, slide 26, 35 | <ul><li>12 dòng (NX007 ngày 29/03/2025)</li><li>1 ô (NX057 ngày 21/11/2025)</li><li>1 bút toán: JE20250904892, mã MJ-ADJ-2509, tức bút toán ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh 1.250 USD không có giấy tờ)</li></ul> | sheet `Chat_luong_du_lieu`, dòng 1–3 | Đạt |
| Đơn hủy có ngày giao / giao trước ngày đặt / trả trước ngày giao / bán ở cửa hàng đã đóng | 0 / 0 / 0 / 0 | dashboard mẫu | 0 / 0 / 0 / 0 | sheet `Chat_luong_du_lieu`, dòng 4–7 | Đạt |

**Việc phải có (không phải con số):**
- [x] Bảng giao dịch chung có đủ cột ở `docs/cau_truc_du_lieu.md` mục 5.
- [x] Nối mã cửa hàng POS → mã NX qua `store_master` (không ghi cứng mã nào).
- [x] Sheet chất lượng dữ liệu có cột trạng thái tự đổi màu chữ "Đạt" / "Cần xem".
- [x] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Ghép tỷ giá cuối tháng cho đơn hủy (không có ngày giao) | Lỗi hoặc tỷ giá rỗng | <ul><li>Ghép kiểu giữ dòng bên trái</li><li>Đơn hủy để trống tỷ giá cuối tháng</li></ul> |
| Ghép bảng làm nhân đôi dòng (khóa ghép không duy nhất) | Số dòng lớn hơn 26.565 | <ul><li>Kiểm tra khóa của bảng tỷ giá, lịch, danh mục là duy nhất</li><li>So số dòng (hiện so bằng tay; phép tự động đang chờ ở [backlog](../backlog.md) dòng 7)</li></ul> |
| Bảng lớn làm Excel chậm | Dựng file quá giờ | <ul><li>Giữ sẵn các bảng nhỏ trong bộ nhớ (hàm `Table.Buffer`) trước khi ghép</li><li>Ghép bằng hàm `Table.Join`</li></ul> |
| Đếm "ngày có bán mà thiếu bút toán" theo ngày bán thay vì ngày ghi sổ | Ra 1.528 ô thay vì 1 ô: 1.527 ô là ngày nghỉ (sổ cái ghi sang ngày làm việc kế tiếp) | So theo ngày ghi sổ, mã NX |

---

## 7. Các bước

- [x] **Bước 1: Viết `q_Transactions`**
  - Làm: phần POS (ghép mã NX, ngày ghi sổ, tỷ giá ngày, tỷ giá cuối tháng), phần online (ghép tỷ giá ngày đặt, tỷ giá cuối tháng của tháng giao và tháng trả), gộp 2 phần.
  - Kiểm tra: 26.565 dòng; không dòng nào thiếu tỷ giá ngày.
- [x] **Bước 2: Viết `q_DataQuality`, sửa dòng bẫy 5 của `q_Traps`**
  - Kiểm tra: 12 / 1 / 1 và các phép còn lại bằng 0.
- [x] **Bước 3: Dựng lại file, so với `python_bridge.csv`**
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [x] **Bước 4: Viết phần báo cáo, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Viết `q_Transactions` (phần POS, phần online, gộp, đổi USD theo 2 tỷ giá) và `q_DataQuality` (10 phép kiểm tra) | Chưa chạy; số ra ở dòng "Dựng lại file Excel" bên dưới | <ul><li>Trước khi chạy đã thấy 2 lỗi</li><li>Ghép bảng cửa hàng làm trùng tên cột mã POS (Power Query báo lỗi khi 2 bảng ghép có cột cùng tên) → đổi tên cột khóa bên bảng danh mục</li><li>Ký hiệu `??` (lấy giá trị thay thế khi ô trống) có thể chưa có trong Power Query của Excel 2021 → viết lại bằng `if … then … else`</li></ul> |
| 18/10 | Sửa dòng bẫy 5 của `q_Traps`: lấy số USD từ bảng giao dịch chung | Dòng bẫy 5 trỏ đúng bước `Đổi ra USD theo tỷ giá ngày` | |
| 18/10 | Dựng lại file Excel | <ul><li>9 sheet nạp, 26.565 dòng giao dịch</li><li>Khoảng 4 phút (trước là 2 phút), file khoảng 4 MB (megabyte)</li></ul> | |
| 18/10 | So với `python_bridge.csv` bằng Python | <ul><li>Chiết khấu, dòng trùng, đơn hủy, lệch thời điểm online, lệch ngày ghi sổ, hàng trả: khớp mọi tháng</li><li>Tỷ giá cửa hàng tính từ bảng giao dịch chung cũng khớp</li></ul> | |
| 18/10 | Viết phần II.6 của báo cáo, sinh bảng chất lượng dữ liệu | Báo cáo PDF (Portable Document Format) dựng lại được | |
| 18/10 | Rà soát plan (người rà soát làm lại độc lập từ file gốc bằng Python) | <ul><li>Bảng giao dịch chung: 26.565 dòng, mọi cột của mọi dòng khớp file gốc (mã NX, ngày ghi sổ, 3 loại tỷ giá, USD chưa làm tròn, 3 cột tháng); soát tay thêm 60 dòng POS ngẫu nhiên, 60 đơn online ngẫu nhiên, cả 139 đơn hủy, 181 đơn trả và 12 dòng trùng</li><li>10 phép kiểm tra chất lượng tính lại ra đúng 12 / 1 / 1 / 0 / 0 / 0 / 0 / 0 / 0 / 1</li><li>Tỷ giá online tính từ bảng giao dịch chung cũng khớp `python_bridge.csv`</li></ul> | <ul><li>Bảng 7 trong PDF bị ngắt trang sau 2 dòng → giữ cả bảng trên một trang (báo cáo thành 15 trang, phần III bắt đầu ở trang mới)</li><li>Báo cáo ghi 3 lỗi "đã ghi vào nhật ký ngoại lệ" trong khi nhật ký chưa làm (plan `bridge-template-log`) → bỏ câu này; bảng tra nhãn nguồn ở phụ lục thêm sheet `Chat_luong_du_lieu`</li><li>Sheet chất lượng dữ liệu chưa bắt được thiếu tỷ giá cuối tháng, thiếu ngày trong lịch, ghép bảng làm nhân đôi dòng khi nạp tháng mới → ghi vào [backlog](../backlog.md) dòng 7</li></ul> |
| 18/10 | Sửa theo rà soát: thêm 3 phép kiểm tra cho dữ liệu tháng mới (11: thiếu tỷ giá cuối tháng; 12: dòng POS không tìm được ngày ghi sổ; 13: số dòng bảng giao dịch chung khác số dòng POS + đơn online); sửa tên bảng nguồn của phép 1, 7; chi tiết ghi "(không rõ cửa hàng)" khi thiếu mã | Dựng lại: 13 phép, 4 "Cần xem" (như cũ), 3 phép mới đều 0 |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Bảng giao dịch chung giữ cả 12 dòng trùng (có cờ), không lọc | Bảng cầu nối cần chiết khấu của mọi dòng (kể cả dòng trùng, vì Flash có tính) và số tiền của dòng trùng | Không |
| 18/10 | Thêm 3 cột tháng (`sale_period`, `recognition_period`, `return_period`) và cột `net_usd_month_end_return` | Mọi khoản cầu nối đều cộng theo một trong ba tháng này; tính sẵn một lần thì các truy vấn sau gọn hơn | Không (bổ sung vào `docs/cau_truc_du_lieu.md` mục 5) |
| 18/10 | Sheet chất lượng dữ liệu có thêm 3 phép so với dashboard mẫu (thiếu tỷ giá, mã cửa hàng không ghép được, bút toán tay không có giấy tờ) | <ul><li>Rubric (bảng tiêu chí chấm) mức cao nhất Band 5, năng lực 2: "Có kiểm tra tự động: cảnh báo khi phần chưa giải thích vượt ngưỡng, đếm dòng trùng, đếm ngày thiếu"</li><li>Phép số 10 lộ ra ADJ-0925 ngay ở bước nạp</li></ul> | Không |
| 18/10 | Ô "ngày có bán mà thiếu bút toán" so theo **mã NX + ngày ghi sổ** | <ul><li>Bút toán sổ cái ghi theo ngày ghi sổ</li><li>So theo ngày bán sẽ ra 1.528 ô "thiếu" (1.527 ô là ngày nghỉ, không phải lỗi)</li></ul> | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết 2 truy vấn mới, sửa `q_Traps`, viết phần báo cáo | `excel/queries/q_Transactions.m`, `q_DataQuality.m`, phần sửa của `q_Traps.m`, `report/sections/02_du_lieu_chuan_bi.tex` (mục II.6) | <ul><li>So bảng giao dịch chung với bảng kiểm tra Python từng tháng, từng khoản</li><li>So kết quả kiểm tra chất lượng với dashboard mẫu của mentor (12 / 1 / 1 / 0 …)</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Bảng giao dịch chung khác bảng POS và bảng đơn online ở chỗ nào?
   **Trả lời:** Cùng một dạng cho cả hai kênh: có mã cửa hàng bên kế toán (nối qua `store_master`), ngày bán / ngày đặt và ngày sổ cái ghi nhận, tiền trước giảm giá, chiết khấu, sau giảm giá, và USD theo cả tỷ giá ngày lẫn tỷ giá cuối tháng. Nhờ vậy các khoản cầu nối tính từ POS và online (chiết khấu, dòng trùng, đơn hủy, lệch thời điểm, hàng trả, tỷ giá) chỉ là cộng một cột theo một loại tháng.
2. **Hỏi:** Sheet chất lượng dữ liệu bắt được những lỗi nào?
   **Trả lời:** 4 phép "Cần xem", ứng với 3 lỗi: 12 dòng POS xuất trùng ở NX007 ngày 29/03/2025; ô NX057 ngày 21/11/2025 có bán mà sổ cái không có bút toán; bút toán ADJ-0925 vừa không gắn cửa hàng vừa không có giấy tờ. 6 phép còn lại bằng 0, ví dụ không có đơn hủy nào có ngày giao, không có dòng nào thiếu tỷ giá.
3. **Hỏi:** Vì sao đếm ô thiếu bút toán theo ngày ghi sổ mà không theo ngày bán?
   **Trả lời:** Sổ cái ghi doanh thu cửa hàng theo ngày ghi sổ: bán vào ngày nghỉ thì ghi sang ngày làm việc kế tiếp. So theo ngày bán ra 1.528 ô "thiếu", nhưng 1.527 ô trong đó là ngày nghỉ, không phải lỗi. So theo ngày ghi sổ chỉ còn 1 ô thật: NX057 ngày 21/11/2025, sổ cái ghi bù ngày 02/12/2025 (bút toán `POS_CATCHUP`).
4. **Hỏi:** Nạp thêm một tháng mới mà file danh mục chưa có tỷ giá của tháng đó thì sao?
   **Trả lời:** Thiếu tỷ giá ngày thì phép số 8 báo "Cần xem". Thiếu tỷ giá cuối tháng thì hiện các cột USD theo tỷ giá cuối tháng để trống mà chưa có phép nào báo; việc thêm phép kiểm tra này đang chờ quyết định ở [backlog](../backlog.md) dòng 7.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 6 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục II.6 "Bảng giao dịch chung và kiểm tra chất lượng dữ liệu" (Bảng 7, sinh từ sheet `Chat_luong_du_lieu`).
- **Việc còn lại:**
  - Đối soát cửa hàng × ngày theo 4 trường hợp → `store-recon`.
  - Đối soát online, hàng trả → `web-return-recon`.
  - Dashboard trang 4 dùng sheet chất lượng dữ liệu → `dashboard`.
  - Cảnh báo khi phần chưa giải thích vượt ngưỡng → `bridge-monthly`.
  - Thêm phép kiểm tra cho lúc nạp tháng mới (thiếu tỷ giá cuối tháng, thiếu ngày trong lịch, số dòng bảng giao dịch chung khác tổng POS + online) → chờ quyết định ở [backlog](../backlog.md) dòng 7, chạy thử ở `refresh-test`.
- **Các lần lưu vào Git (commit):** `0820f3f` (tạo plan), `f0ec89f` (bảng giao dịch chung), `2607e54` (kiểm tra chất lượng, sửa bẫy 5), `c177e26` (nạp sheet, tô chữ đỏ), `859deb3` (file Excel), `7d6316f` (báo cáo, tài liệu), `171504b` (ghi kết quả, quyết định, chuẩn bị vấn đáp), và các lần lưu đóng plan.
