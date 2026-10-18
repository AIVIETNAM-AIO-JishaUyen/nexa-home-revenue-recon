# Bảng cầu nối 12 tháng theo kênh và toàn công ty, có dòng kiểm tra và tự cảnh báo

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 4 – Bảng cầu nối và nhật ký ngoại lệ (phần bảng cầu nối) |
| Mốc phải đạt | Mốc 4 |
| Phần báo cáo liên quan | <ul><li>Phần IV.4 (bảng cầu nối 12 tháng)</li><li>Phụ lục D (ba phiên bản số làm tròn: thay số Python bằng số Power Query)</li><li>Câu hỏi riêng 2 (tháng nào còn lệch sau khi trừ quy tắc ghi nhận)</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [web-return-recon](../completed/thanhlnp-18-10-2026-web-return-recon.md)</li><li>Plan tiếp theo dùng kết quả này: `bridge-template-log` (file mẫu nộp đọc `BR_Long`), `dax-bridge` (so DAX với Power Query), `dashboard`</li></ul> |

---

## 1. Mục tiêu

Dựng **bảng cầu nối 12 tháng bằng Power Query** cho 4 bảng: cửa hàng, online, chưa gắn kênh và toàn công ty (= tổng ba bảng kia), dạng dài `BR_Long` đã chốt. Mỗi khoản tính trực tiếp từ dữ liệu, dòng kiểm tra về 0, và file **tự cảnh báo** khi phần chưa giải thích, làm tròn hoặc dòng kiểm tra vượt ngưỡng.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - `q_BR_Long`: 4 bảng × 12 tháng × 15 khoản (bảng toàn công ty không có dòng chuyển kênh).
  - `q_BR_Check`: mỗi bảng × tháng một dòng; phần chưa giải thích ≤ 200 USD (đô la Mỹ), làm tròn ≤ 5 USD, dòng kiểm tra ≤ 1 USD; vượt thì ghi "Cần xem" kèm lời nhắc.
  - `q_BR_Company`: bảng toàn công ty dạng ngang (khoản × tháng, cột cả năm) để đọc.
  - So `q_BR_Long` với `checks/python_bridge.csv` từng bảng × tháng × khoản.
  - Viết phần IV.4, trả lời câu hỏi riêng 2, thay số Python ở phụ lục D.
- **Không làm (để cho plan khác):**
  - File mẫu nộp `Mau_nop` và nhật ký ngoại lệ → `bridge-template-log`.
  - Bảng so khi đổi thứ tự các bước → `bridge-template-log`.
  - Công thức DAX → `dax-bridge`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Bảng giao dịch chung | `excel/queries/q_Transactions.m` | USD theo tỷ giá ngày, cột tháng bán / ghi nhận / trả |
| Sổ cái, Flash | `excel/queries/q_GL.m`, `q_FLASH.m` | |
| Ô cửa hàng × ngày | `excel/queries/q_RC_Store.m` | Cột `diff_usd` cho lỗi chuyển dữ liệu |
| Danh mục khoản | `excel/queries/q_BridgeItems.m` | Thứ tự, tên, nhóm |
| Bảng kiểm tra Python | `checks/python_bridge.csv` | 708 dòng, cùng dạng `BR_Long` |
| Số đúng | `checks/numbers_of_record.csv` | `br_y_*`, `br_m12_*`, `br_m11_*`, `br_m03_*`, `br_m09_*` |
| Cách tính từng khoản | `docs/cau_truc_du_lieu.md` mục 7 | |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Thứ tự 14 bước, mọi khoản theo tỷ giá ngày đặt / ngày bán; lỗi chuyển dữ liệu theo tỷ giá ngày của ngày ghi sổ.
- Tỷ giá = bút toán tự động (nội tệ ÷ tỷ giá cuối tháng, chưa làm tròn) − cùng giao dịch theo tỷ giá ngày (slide 34). Làm tròn = phần Flash + phần sổ cái.
- ADJ-0925 luôn ở dòng "Chưa giải thích được"; không ép khớp.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| 3 truy vấn | `excel/queries/q_BR_Long.m`, `q_BR_Check.m`, `q_BR_Company.m` | File mẫu nộp, DAX, dashboard |
| Sheet `BR_Long`, `Canh_bao_cau_noi`, `Cau_noi_toan_cong_ty` | `excel/Nexa_Home_Recon_PQ.xlsx` | |
| Phần IV.4, phụ lục D | `report/sections/04_phan_tich_chinh.tex`, `09_phu_luc.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Số dòng `BR_Long` | 708 (4 bảng × 12 tháng × 15 khoản − 12 dòng chuyển kênh của toàn công ty) | `python_bridge.csv` | | sheet `BR_Long` | |
| Lệch lớn nhất so với Python, mọi dòng | ≤ 0,01 | `python_bridge.csv` | | so bằng pandas | |
| Cả năm toàn công ty: 13 khoản | `br_y_*` (Flash 31.124.401 … sổ cái 28.698.496,23) | `numbers_of_record.csv` | | sheet `Cau_noi_toan_cong_ty` | |
| Tháng 12 toàn công ty: 13 khoản | `br_m12_*` (slide 36) | như trên | | như trên | |
| Tháng 11 lỗi chuyển dữ liệu / tháng 3 dòng trùng, lệch thời điểm / tháng 9 chưa giải thích | −7.227,56 / −12.622,20, +281.787,98 / +1.250 | `br_m11_*`, `br_m03_*`, `br_m09_*` | | như trên | |
| Dòng kiểm tra mọi bảng × tháng | ≤ 1 USD | quy ước | | sheet `Canh_bao_cau_noi` | |
| Cảnh báo | chỉ tháng 9 (phần chưa giải thích 1.250 > 200) ở bảng toàn công ty và bảng chưa gắn kênh | tự tính | | như trên | |

**Việc phải có (không phải con số):**
- [ ] Mỗi khoản tính trực tiếp từ dữ liệu, không lấy phần dư; dòng kiểm tra là phép thử thật.
- [ ] Toàn công ty = tổng ba bảng kênh (không tính riêng), dòng chuyển kênh không có ở bảng toàn công ty.
- [ ] Cảnh báo tự tính từ ngưỡng, không gõ tay; ngưỡng đặt ở đầu truy vấn.
- [ ] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên; không ghi cứng năm.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Lấy dòng tỷ giá làm phần dư | Dòng kiểm tra luôn bằng 0, không bắt được lỗi | Tỷ giá tính trực tiếp theo slide 34; so với Python |
| Đơn đặt tháng 12 năm trước hoặc giao năm sau lọt vào | Tháng 1 hoặc tháng 12 lệch hàng trăm nghìn | Chỉ giữ tháng có trong Flash, sau khi cộng các mảnh |
| Khoản không áp dụng bị thiếu dòng | `BR_Long` ít hơn 708 dòng; file mẫu nộp SUMIFS ra trống | Lưới đủ bảng × tháng × khoản, ô trống = 0 |
| Bút toán tay lọc theo mã tham chiếu trống | Lỗi khi so chữ với giá trị trống | Kiểm tra `source_ref <> null` trước |

---

## 7. Các bước

- [ ] **Bước 1: Viết `q_BR_Long`**
  - Kiểm tra: 708 dòng; so với `python_bridge.csv` lệch ≤ 0,01.
- [ ] **Bước 2: Viết `q_BR_Check`, `q_BR_Company`**
  - Kiểm tra: chỉ tháng 9 có cảnh báo; cả năm và tháng 12 khớp số chuẩn.
- [ ] **Bước 3: Dựng lại file, viết phần IV.4, sửa phụ lục D, lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|

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
