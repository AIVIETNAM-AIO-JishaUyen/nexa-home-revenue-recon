# Đối soát online và hàng trả, chứng minh 5 lý do lệch bằng số, xếp các khoản vào 4 nhóm

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 3 – Đối soát chi tiết (phần online, hàng trả, 5 lý do, 4 nhóm) |
| Mốc phải đạt | Mốc 3 (23/10) |
| Phần báo cáo liên quan | <ul><li>Phần IV.2 (đối soát online và hàng trả)</li><li>Phần IV.3 (5 lý do lệch, chứng minh bằng số; xếp 4 nhóm)</li><li>Câu hỏi riêng 3 (phần online)</li></ul> |
| Trạng thái | Đang làm |
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
| Sổ cái | `excel/queries/q_GL.m` | Bút toán `WEB_DELIVERY`, `WEB_RETURN`, bút toán tay (`MANUAL`: MJ-SHIP, MJ-RCL, ADJ-0925) |
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
| Ô online × ngày giao × loại tiền trong kỳ: tổng / khớp | 1.647 / 1.647 | `det_web_delivery_cells` | | sheet `Doi_soat_online` | |
| Ô hàng trả × ngày trả × loại tiền trong kỳ: tổng / khớp | 159 / 159 | `det_web_return_cells` | | sheet `Doi_soat_hang_tra` | |
| Online tháng 11 trước / sau khi đưa về cùng cách tính | −12.064,26 / ≈ 0 | slide 28, 44; dashboard mẫu | | sheet `Doi_soat_online_thang` | |
| Lệch thời điểm online: cả năm / tháng 3 | −52.597,90 / +281.787,98 | `br_y_online_timing`, file quy ước | | sheet `Lech_thoi_diem_online` | |
| Đơn vắt qua năm: đầu năm / cuối năm | +122.107,89 (77 đơn) / −174.705,79 (105 đơn) | `tim_web_*` | | như trên | |
| Đơn hủy đặt trong kỳ: số đơn / USD | 124 / −215.658,92 | `det_cancelled_orders_2025`, `br_y_cancelled` | | sheet `Nam_ly_do` | |
| Hàng trả nhận trong kỳ: số đơn / USD (tỷ giá ngày đặt) | 169 / −349.148,23 | `det_returned_orders_2025`, `br_y_returns` | | như trên | |
| Chiết khấu | −1.834.297,47 | `br_y_discount` | | như trên | |
| Tỷ giá | −57.598,01 | `br_y_fx` | | như trên | |

**Việc phải có (không phải con số):**
- [ ] Ghép đủ 2 bên, chia 4 trường hợp, ô ngoài kỳ đối soát không bị tính là lệch.
- [ ] Mỗi lý do trong 5 lý do có ít nhất 1 con số tính từ dữ liệu (không chép mô tả của đề).
- [ ] Mỗi khoản cầu nối có nhóm và lý do xếp nhóm; ADJ-0925 ở "Chưa giải thích được".
- [ ] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên; không ghi cứng năm.

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

- [ ] **Bước 1: Viết `q_RC_Web`, `q_RC_Return`**
  - Kiểm tra: 1.647 và 159 ô trong kỳ, khớp 100%.
- [ ] **Bước 2: Viết `q_RC_Web_Month`, `q_Web_Timing`**
  - Kiểm tra: tháng 11 −12.064,26 trước xử lý; lệch thời điểm cả năm, tháng 3, hai phần vắt qua năm.
- [ ] **Bước 3: Viết `q_BridgeItems`, `q_FiveReasons`**
  - Kiểm tra: số tiền từng lý do khớp số chuẩn; mỗi khoản có nhóm.
- [ ] **Bước 4: Dựng lại file, kiểm tra số, viết phần IV.2 và IV.3, lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Chạy thử bằng Python trên sheet giao dịch chung và dữ liệu `det` của dashboard mẫu | <ul><li>Dòng online của dashboard mẫu tháng 11: chưa xử lý 1.205.561,30 = đơn chưa hủy theo tháng đặt, tỷ giá cuối tháng đặt; sổ cái 1.193.497,04 = `WEB_DELIVERY` + `WEB_RETURN`; chênh lệch −12.064,26</li><li>1.647 / 159 ô trong kỳ khớp 100%; ngoài kỳ có 155 ô online và 12 ô hàng trả</li><li>Các số chuẩn của đơn hủy, hàng trả, chiết khấu, lệch thời điểm, tỷ giá đều ra đúng</li></ul> | |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|

---

## 11. Chuẩn bị vấn đáp

---

## 12. Kết quả khi đóng plan

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
