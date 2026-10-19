# Đối soát online và hàng trả, chứng minh 5 lý do lệch bằng số, xếp các khoản vào 4 nhóm

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 3 – Đối soát chi tiết (phần online, hàng trả, 5 lý do, 4 nhóm) |
| Mốc phải đạt | Mốc 3 (23/10) |
| Phần báo cáo liên quan | <ul><li>Phần IV.2 (đối soát online và hàng trả)</li><li>Phần IV.3 (5 lý do lệch, chứng minh bằng số; xếp 4 nhóm)</li><li>Câu hỏi riêng 3 (phần online)</li></ul> |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [store-recon](../completed/thanhlnp-18-10-2026-store-recon.md)</li><li>Plan tiếp theo dùng kết quả này: `bridge-monthly` (danh mục khoản, lệch thời điểm online), `bridge-template-log` (nhóm của từng khoản), `dashboard`</li></ul> |

---

## 1. Mục tiêu

Đối soát kênh online ở mức chi tiết nhất: **ngày giao × loại tiền** cho bút toán doanh thu online và **ngày trả × loại tiền** cho bút toán hàng trả, so bằng nội tệ. Sau đó chứng minh bằng số trên dữ liệu **5 lý do** khiến Flash và sổ cái lệch nhau, và xếp mỗi khoản lệch vào **1 trong 4 nhóm**.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - `q_RC_Web`: ô ngày giao × loại tiền, so đơn online chưa hủy với bút toán `WEB_DELIVERY`; 4 trường hợp; ô ngoài kỳ đối soát (tháng không có trong Flash) ghi riêng.
  - `q_RC_Return`: ô ngày trả × loại tiền, so đơn bị trả với bút toán `WEB_RETURN`.
  - `q_RC_Web_Month`: online theo tháng, chênh lệch trước (theo tháng đặt) và sau (theo tháng giao, trừ hàng trả theo tháng trả), cờ ⚠ theo cùng ngưỡng.
  - `q_Web_Timing`: lệch thời điểm online theo tháng (theo tháng giao − theo tháng đặt), tách phần đơn vắt qua năm.
  - `q_FiveReasons`: bảng 5 lý do, mỗi lý do có số tiền và số lượng tính từ dữ liệu.
  - `q_BridgeItems`: danh mục các khoản cầu nối: mã, tên, thứ tự, nhóm, vì sao thuộc nhóm đó. Bảng cầu nối ở plan sau đọc nhóm từ đây.
  - Viết phần IV.2 và IV.3 của báo cáo.
- **Không làm (để cho plan khác):**
  - Bảng cầu nối 12 tháng → `bridge-monthly`.
  - Nhật ký ngoại lệ → `bridge-template-log`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Bảng giao dịch chung | `excel/queries/q_Transactions.m` | Dòng `channel` = WEB: `status` (Delivered, Returned, Cancelled), `sale_date` = ngày đặt, `recognition_date` = ngày giao, `return_date`, `net_local`, `net_usd_daily`, `net_usd_month_end`, `net_usd_month_end_return`, `discount_usd_daily` |
| Sổ cái | `excel/queries/q_GL.m` | Bút toán `WEB_DELIVERY`, `WEB_RETURN`, bút toán tay (`MANUAL`: MJ-SHIP, MJ-RCL, ADJ-0925; MJ = Manual Journal, bút toán tay; ADJ = Adjustment, bút toán điều chỉnh) |
| Flash | `excel/queries/q_FLASH.m` | Danh sách tháng đối soát (không ghi cứng năm) |
| Đối soát cửa hàng | `excel/queries/q_RC_Store*.m` | Lệch ngày ghi sổ, lỗi chuyển dữ liệu, dòng trùng cho bảng 5 lý do |
| Số đúng | `checks/numbers_of_record.csv` | `det_web_*`, `det_cancelled_*`, `det_returns_*`, `tim_web_*`, `br_y_*`, `nov_web_*` |
| Dashboard mẫu của mentor (người hướng dẫn) | `docs/template/Nexa_Home_Recon_Dashboard.html` | Dữ liệu `det`, dòng mã 999999 = kênh online theo tháng |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − nguồn bán hàng; % cho cờ ⚠ chia cho |sổ cái|; ngưỡng 200 USD (đô la Mỹ) và 1%.
- Mọi khoản đổi ra USD theo tỷ giá ngày đặt hàng; hàng trả cũng theo tỷ giá ngày đặt (−349.148,23).
- Thứ tự khoản và tên khoản theo mục 1 của file quy ước; ADJ-0925 luôn ở "Chưa giải thích được".

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| 6 truy vấn | `excel/queries/q_RC_Web.m`, `q_RC_Return.m`, `q_RC_Web_Month.m`, `q_Web_Timing.m`, `q_FiveReasons.m`, `q_BridgeItems.m` | Cầu nối, nhật ký ngoại lệ, dashboard |
| Sheet `Doi_soat_online`, `Doi_soat_hang_tra`, `Doi_soat_online_thang`, `Lech_thoi_diem_online`, `Nam_ly_do`, `Danh_muc_khoan` | `excel/Nexa_Home_Recon_PQ.xlsx` | Báo cáo, dashboard |
| Phần IV.2, IV.3 | `report/sections/04_phan_tich_chinh.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Ô online × ngày giao × loại tiền trong kỳ: tổng / khớp | 1.647 / 1.647 | `det_web_delivery_cells` | 1.647 / 1.647 (8.427 đơn); 155 ô ngoài kỳ | sheet `Doi_soat_online` | Đạt |
| Ô hàng trả × ngày trả × loại tiền trong kỳ: tổng / khớp | 159 / 159 | `det_web_return_cells` | 159 / 159 (169 đơn); 12 ô ngoài kỳ | sheet `Doi_soat_hang_tra` | Đạt |
| Online tháng 11 trước / sau khi đưa về cùng cách tính | −12.064,26 / ≈ 0 | slide 28, 44; dashboard mẫu | −12.064,26 / −0,01 | sheet `Doi_soat_online_thang` | Đạt |
| Lệch thời điểm online: cả năm / tháng 3 | −52.597,90 / +281.787,98 | `br_y_online_timing`, file quy ước | −52.597,90 / +281.787,98 | sheet `Lech_thoi_diem_online` | Đạt |
| Đơn vắt qua năm: đầu năm / cuối năm | +122.107,89 (77 đơn) / −174.705,79 (105 đơn) | `tim_web_*` | +122.107,89 (77) / −174.705,79 (105); dòng kiểm tra 0,00 | như trên | Đạt |
| Đơn hủy đặt trong kỳ: số đơn / USD | 124 / −215.658,92 | `det_cancelled_orders_2025`, `br_y_cancelled` | 124 / −215.658,92 | sheet `Nam_ly_do` | Đạt |
| Hàng trả nhận trong kỳ: số đơn / USD (tỷ giá ngày đặt) | 169 / −349.148,23 | `det_returned_orders_2025`, `br_y_returns` | 169 / −349.148,23 (tỷ giá ngày trả −349.652,76; sổ cái −349.066,23) | như trên | Đạt |
| Chiết khấu | −1.834.297,47 | `br_y_discount` | −1.834.297,47 | như trên | Đạt |
| Tỷ giá | −57.598,01 | `br_y_fx` | −57.598,01 | như trên | Đạt |

**Việc phải có (không phải con số):**
- [x] Ghép đủ 2 bên, chia 4 trường hợp, ô ngoài kỳ đối soát không bị tính là lệch.
- [x] Mỗi lý do trong 5 lý do có ít nhất 1 con số tính từ dữ liệu (không chép mô tả của đề).
- [x] Mỗi khoản cầu nối có nhóm và lý do xếp nhóm; ADJ-0925 ở "Chưa giải thích được".
- [x] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên; không ghi cứng năm.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Đưa đơn hủy vào phía online khi so với `WEB_DELIVERY` | Hàng trăm ô "chỉ có ở WEB" | Chỉ lấy đơn Delivered và Returned (đơn bị trả cũng đã giao) |
| Đơn giao tháng 12/2024 hoặc tháng 1/2026 bị tính là lệch | 155 ô "chỉ có ở WEB" | Ô có tháng ngoài danh sách tháng của Flash ghi trạng thái "Ngoài kỳ đối soát" |
| Dấu của hàng trả | Lệch gấp đôi | Sổ cái ghi hàng trả là số dương (ghi Nợ), sau đổi dấu là âm; phía WEB lấy −`net_local` |
| Tỷ giá hàng trả | −349.652,76 hoặc −349.066,23 thay vì −349.148,23 | Dùng `net_usd_daily` (tỷ giá ngày đặt) |
| Lệch thời điểm online cả năm khác 0 bị hiểu là lỗi | Kết luận sai | Tách phần đơn vắt qua năm: cộng hai phần ra đúng −52.597,90 |

---

## 7. Các bước

- [x] **Bước 1: Viết `q_RC_Web`, `q_RC_Return`**
  - Kiểm tra: 1.647 và 159 ô trong kỳ, khớp 100%.
- [x] **Bước 2: Viết `q_RC_Web_Month`, `q_Web_Timing`**
  - Kiểm tra: tháng 11 −12.064,26 trước xử lý; lệch thời điểm cả năm, tháng 3, hai phần vắt qua năm.
- [x] **Bước 3: Viết `q_BridgeItems`, `q_FiveReasons`**
  - Kiểm tra: số tiền từng lý do khớp số chuẩn; mỗi khoản có nhóm.
- [x] **Bước 4: Dựng lại file, kiểm tra số, viết phần IV.2 và IV.3, lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Chạy thử bằng Python trên sheet giao dịch chung và dữ liệu `det` của dashboard mẫu | <ul><li>Dòng online của dashboard mẫu tháng 11: chưa xử lý 1.205.561,30 = đơn chưa hủy theo tháng đặt, tỷ giá cuối tháng đặt; sổ cái 1.193.497,04 = `WEB_DELIVERY` + `WEB_RETURN`; chênh lệch −12.064,26</li><li>1.647 / 159 ô trong kỳ khớp 100%; ngoài kỳ có 155 ô online và 12 ô hàng trả</li><li>Các số chuẩn của đơn hủy, hàng trả, chiết khấu, lệch thời điểm, tỷ giá đều ra đúng</li></ul> | |
| 18/10 | Viết 6 truy vấn, nạp 6 sheet, dựng lại file (2 lần) | <ul><li>Online 1.647/1.647 ô khớp, hàng trả 159/159; ngoài kỳ 155 và 12 ô</li><li>Online chưa xử lý: 12/12 tháng vượt ngưỡng; sau xử lý: 0 tháng, mỗi tháng lệch ≤ 0,05 USD</li><li>Lệch thời điểm online cả năm −52.597,90 = +122.107,89 − 174.705,79; tháng 3 +281.787,98</li><li>Bảng 5 lý do: 14 dòng, mọi số tiền khớp số chuẩn; làm tròn 1,01 = 0,95 + 0,05</li></ul> | <ul><li>Lần dựng đầu, số chèn vào cột chữ của bảng 5 lý do viết kiểu Mỹ (17,124; 0.95); đổi sang kiểu Việt Nam (vi-VN) rồi dựng lại</li><li>Mỗi lần dựng mất khoảng 15 phút; tăng giới hạn thời gian của script lên 30 phút</li></ul> |
| 18/10 | Cập nhật ghi chú số chuẩn | Số −12.064 của slide nay đã tái lập; cả 3 số "chỉ tham khảo" của plan `setup-baseline` đều đã giải thích | Phát hiện 2 dòng ghi chú (dòng 130, 132) có dấu phẩy làm lệch cột CSV (Comma-Separated Values, file chữ ngăn cột bằng dấu phẩy) từ commit `c2d1beb` của plan 7; đã sửa, `python_check.py` chạy lại vẫn đạt |
| 18/10 | Viết phần IV.2 và IV.3 (Bảng 11–13, Hình 3) | PDF 21 trang | Tiêu đề hình bị cắt vì quá dài; rút ngắn |
| 18/10 | Rà soát plan: đọc lại 7 sheet bằng pandas, đọc 6 truy vấn, lời văn IV.2–IV.3 | <ul><li>Mọi số ở mục 5 và mục 11 khớp sheet; cả 140 đơn vào tháng 3 đều đặt tháng 2 (22/02–28/02), cả 20 đơn rời tháng 3 đều giao tháng 4</li><li>Mọi bước có tên tiếng Việt và ghi chú `//`; không ghi cứng năm; nhóm của từng khoản khớp `docs/cau_truc_du_lieu.md` mục 7</li><li>PDF 22 trang</li></ul> | <ul><li>Lời văn và tiêu đề Hình 3 gọi +281.787,98 là số "nhận từ đơn đặt tháng trước", thật ra là số nhận về (315.819,08) trừ số chuyển đi (34.031,10): sửa lời văn, tiêu đề hình (`make_figures.py`), thêm phép tính "bỏ khoản này thì tháng 3 còn −182.770,45"</li><li>Bảng 12 dòng 1b ghi "2025-03": `make_figures.py` đổi thành "tháng 3"</li><li>Phụ lục nhãn nguồn chưa có các sheet mới: thêm vào dòng RC-WEB, RC-RET</li></ul> |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Kỳ đối soát = các tháng có trong Flash; ô ngoài kỳ ghi "Ngoài kỳ đối soát", không tính là lệch và không tô đỏ | Không ghi cứng năm; sổ cái chỉ có năm 2025 nên đơn giao tháng 12/2024 hay tháng 1/2026 luôn "thiếu" bên sổ cái mà không phải lỗi | Không |
| 18/10 | Online theo tháng: "chưa xử lý" theo tháng đặt, tỷ giá cuối tháng đặt; sổ cái chỉ lấy `WEB_DELIVERY` và `WEB_RETURN` | Đúng cách dashboard mẫu tính (tái lập −12.064,26); bút toán tay là khoản riêng của bảng cầu nối | Không |
| 18/10 | Danh mục khoản `q_BridgeItems` là bảng gõ tay duy nhất, ghi cả lý do xếp nhóm | Nhóm là quyết định phân loại, không phải số liệu; bảng cầu nối, nhật ký ngoại lệ, dashboard cùng đọc một chỗ | Không |
| 18/10 | Dòng POS (Point of Sale, bán tại cửa hàng) trùng và lỗi chuyển dữ liệu không gắn vào lý do nào trong 5 lý do | Đó là lỗi dữ liệu, không phải khác biệt về cách tính; gắn vào thì sai nghĩa của 5 lý do | Không |
| 18/10 | Nhãn nhóm làm tròn ghi "Sai số chấp nhận" | Đúng chữ của file mẫu nộp (nhật ký ngoại lệ) | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Đọc dữ liệu `det` của dashboard mẫu, viết 6 truy vấn, viết phần IV.2–IV.3 | `excel/queries/q_RC_Web.m`, `q_RC_Return.m`, `q_RC_Web_Month.m`, `q_Web_Timing.m`, `q_FiveReasons.m`, `q_BridgeItems.m`; phần sinh Bảng 11–13 và Hình 3 trong `make_figures.py`; mục IV.2–IV.3 | <ul><li>Chạy thử bằng Python trước khi viết truy vấn</li><li>So từng số với `numbers_of_record.csv`, slide 28 và 44, dữ liệu `det` của dashboard mẫu</li><li>Dòng kiểm tra "cả năm − hai phần vắt qua năm" bằng 0</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Đối soát online so ở mức nào, kết quả ra sao?
   **Trả lời:** Ở đúng mức sổ cái ghi: một bút toán `WEB_DELIVERY` cho mỗi ngày giao × loại tiền, một bút toán `WEB_RETURN` cho mỗi ngày nhận hàng trả × loại tiền. So bằng nội tệ, 1.647/1.647 ô doanh thu và 159/159 ô hàng trả khớp đến từng xu. Hệ thống chuyển đơn online sang sổ cái không có lỗi; chênh lệch online hoàn toàn do quy tắc ghi nhận.
2. **Hỏi:** Vì sao tháng 3 sổ cái cao hơn Flash?
   **Trả lời:** Lệch thời điểm online: Flash ghi theo ngày đặt, sổ cái theo ngày giao. Tháng 3 nhận +315.819,08 USD từ 140 đơn đặt từ 22/02 đến 28/02 nhưng giao tháng 3, chỉ chuyển đi 34.031,10 sang tháng 4 (20 đơn), nên khoản lệch thời điểm tháng 3 là +281.787,98 (sheet `Lech_thoi_diem_online`). Chênh lệch sổ cái − Flash tháng 3 là +99.017,53 (sheet `Chenh_lech_thang`); bỏ khoản này đi thì còn −182.770,45, tức sổ cái thấp hơn Flash như mọi tháng khác. Khoản này lớn hơn cả tổng 4 khoản làm giảm doanh thu tháng 3 (chiết khấu, dòng trùng, đơn hủy, hàng trả: −199.029,23 theo bảng kiểm tra Python `checks/python_bridge.csv`).
3. **Hỏi:** Lệch thời điểm online cả năm sao không bằng 0?
   **Trả lời:** Vì có đơn vắt qua năm: 77 đơn đặt tháng 12/2024 giao năm 2025 (+122.107,89, sổ cái có, Flash không có) và 105 đơn đặt năm 2025 giao năm 2026 (−174.705,79). Cộng hai phần ra đúng −52.597,90; trong năm mọi tháng tự bù trừ.
4. **Hỏi:** Chứng minh 5 lý do bằng số thế nào?
   **Trả lời:** Sheet `Nam_ly_do`: thời điểm (860 đơn đặt năm 2025 nhưng giao tháng khác, 267 dòng POS ghi sổ sang tháng sau), giá trị (chiết khấu −1.834.297,47), phạm vi (124 đơn hủy −215.658,92, 169 đơn trả −349.148,23, 12 bút toán phí vận chuyển +94.766,95), tiền tệ (khoản tỷ giá −57.598,01; cùng hàng trả cho 3 số tùy tỷ giá), mức chi tiết (17.124 dòng POS → 5.119 bút toán, 8.596 lượt đơn giao và trả trong kỳ → 1.806 bút toán; làm tròn 1,01).
5. **Hỏi:** Dòng online "vượt ngưỡng" trong 22 dòng của slide 44 là gì?
   **Trả lời:** Online tháng 11 so theo tháng đặt lệch −12.064,26 USD, tức −1,01% so với |sổ cái|, vừa vượt ngưỡng 1%. So theo tháng giao và trừ hàng trả theo tháng trả thì còn −0,01.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 9 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục IV.2 (Bảng 11, Hình 3), IV.3 (Bảng 12 năm lý do, Bảng 13 bốn nhóm); câu hỏi riêng 3 phần online.
- **Đã cập nhật số chuẩn:** số online −12.064 của slide nay đã tái lập; không còn số "chỉ tham khảo" nào trong `checks/numbers_of_record.csv`.
- **Việc còn lại:**
  - Bảng cầu nối 12 tháng đọc danh mục khoản từ `q_BridgeItems` → `bridge-monthly`.
  - Nhật ký ngoại lệ lấy nhóm từ danh mục khoản → `bridge-template-log`.
  - Dashboard trang 3 dùng sheet đối soát online và hàng trả → `dashboard`.
- **Các lần lưu vào Git (commit):** `3661ba0` (tạo plan), `d60e1c8` (đối soát online, hàng trả), `2233fa3` (online theo tháng, lệch thời điểm), `f3bbad9` (5 lý do, danh mục khoản), `0fb71e0` (số chuẩn), `f0abcb8` (nạp sheet, file Excel), `7f335ca` (báo cáo IV.2–IV.3), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
