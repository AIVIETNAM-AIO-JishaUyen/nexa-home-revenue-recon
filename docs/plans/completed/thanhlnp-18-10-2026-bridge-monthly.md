# Bảng cầu nối 12 tháng theo kênh và toàn công ty, có dòng kiểm tra và tự cảnh báo

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 4 – Bảng cầu nối và nhật ký ngoại lệ (phần bảng cầu nối) |
| Mốc phải đạt | Mốc 4 (25/10) |
| Phần báo cáo liên quan | <ul><li>Phần IV.4 (bảng cầu nối 12 tháng)</li><li>Phụ lục D (ba phiên bản số làm tròn: thay số Python bằng số Power Query)</li><li>Câu hỏi riêng 2 (tháng nào còn lệch sau khi trừ quy tắc ghi nhận)</li></ul> |
| Trạng thái | Xong |
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
| Số dòng `BR_Long` | 708 (4 bảng × 12 tháng × 15 khoản − 12 dòng chuyển kênh của toàn công ty) | `python_bridge.csv` | 708; ghép đủ 708/708 dòng với Python | sheet `BR_Long` | Đạt |
| Lệch lớn nhất so với Python, mọi dòng | ≤ 0,01 | `python_bridge.csv` | 0,00005 (Python làm tròn 4 chữ số); thứ tự, tên, nhóm khoản khớp 100% | so bằng pandas | Đạt |
| Cả năm toàn công ty: 13 khoản | `br_y_*` (Flash 31.124.401 … sổ cái 28.698.496,23) | `numbers_of_record.csv` | Khớp cả 13 khoản đến xu | sheet `Cau_noi_toan_cong_ty` | Đạt |
| Tháng 12 toàn công ty: 13 khoản | `br_m12_*` (slide 36) | như trên | Khớp cả 13 khoản đến xu (tỷ giá −27.080,93, làm tròn 0,67) | như trên | Đạt |
| Tháng 11 lỗi chuyển dữ liệu / tháng 3 dòng trùng, lệch thời điểm / tháng 9 chưa giải thích | −7.227,56 / −12.622,20, +281.787,98 / +1.250 | `br_m11_*`, `br_m03_*`, `br_m09_*` | −7.227,56 / −12.622,20, +281.787,98 / +1.250,00 | như trên | Đạt |
| Dòng kiểm tra mọi bảng × tháng | ≤ 1 USD | quy ước | Lớn nhất 0,00 ở cả 48 bảng × tháng; làm tròn lớn nhất 1,83 (tháng 9) | sheet `Canh_bao_cau_noi` | Đạt |
| Cảnh báo | chỉ tháng 9 (phần chưa giải thích 1.250 > 200) ở bảng toàn công ty và bảng chưa gắn kênh | tự tính | Đúng 2 dòng “Cần xem”: toàn công ty tháng 9 và chưa gắn kênh tháng 9 | như trên | Đạt |

**Việc phải có (không phải con số):**
- [x] Mỗi khoản tính trực tiếp từ dữ liệu, không lấy phần dư; dòng kiểm tra là phép thử thật.
- [x] Toàn công ty = tổng ba bảng kênh (không tính riêng), dòng chuyển kênh không có ở bảng toàn công ty.
- [x] Cảnh báo tự tính từ ngưỡng, không gõ tay; ngưỡng đặt ở đầu truy vấn.
- [x] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên; không ghi cứng năm.

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

- [x] **Bước 1: Viết `q_BR_Long`**
  - Kiểm tra: 708 dòng; so với `python_bridge.csv` lệch ≤ 0,01.
- [x] **Bước 2: Viết `q_BR_Check`, `q_BR_Company`**
  - Kiểm tra: chỉ tháng 9 có cảnh báo; cả năm và tháng 12 khớp số chuẩn.
- [x] **Bước 3: Dựng lại file, viết phần IV.4, sửa phụ lục D, lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Viết `q_BR_Long` theo đúng cách tính của `docs/cau_truc_du_lieu.md` mục 7: mỗi khoản là tổng vài "mảnh" (một cột cộng theo một loại tháng, có dấu); lưới đủ bảng × tháng × khoản | 708 dòng; so với `python_bridge.csv` lệch lớn nhất 0,00005 | Viết sẵn trong lúc chờ rà soát plan 8, chỉ đưa vào Git sau khi tạo plan này |
| 18/10 | Viết `q_BR_Check`, `q_BR_Company`, dựng lại file (khoảng 20 phút) | <ul><li>Cả năm và tháng 12 khớp số chuẩn 13/13 khoản</li><li>Dòng kiểm tra 0,00 ở 48/48 bảng × tháng</li><li>2 cảnh báo, đều tháng 9 do ADJ-0925</li></ul> | |
| 18/10 | Viết phần IV.4 (Hình 4 thác nước, Bảng 14, Bảng 15), sửa phụ lục D lấy số từ Power Query | <ul><li>Câu hỏi riêng 2: 4 tháng còn lệch quá 200 USD sau khi trừ quy tắc ghi nhận (tháng 3, 9, 11, 12)</li><li>Quy tắc ghi nhận giải thích −2.414.533,58 trên −2.425.904,77; phần còn lại −11.371,19</li></ul> | <ul><li>Dòng kiểm tra hiện "−0,00": sửa hàm định dạng số</li><li>Bảng 14 có cột nhóm làm bảng dài: bỏ, trỏ sang Bảng 13</li></ul> |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Mỗi khoản là danh sách "mảnh" khai báo trong một hàm chung (`Cộng theo tháng`), đặt cạnh nhau theo từng bảng | Đọc truy vấn là thấy ngay công thức của từng khoản; sửa một khoản không ảnh hưởng khoản khác | Không |
| 18/10 | Cảnh báo có 3 ngưỡng: chưa giải thích 200 USD, làm tròn 5 USD, kiểm tra 1 USD | <ul><li>200 USD theo slide 12 (ngưỡng phải giải thích cho một tháng)</li><li>5 USD và 1 USD theo quy ước đã chốt</li></ul> | Không |
| 18/10 | Câu hỏi riêng 2 đo "phần còn lại" = lỗi dữ liệu + chưa giải thích được + sai số chấp nhận, theo nhóm trong `q_BridgeItems` | Nhóm là quyết định đã chốt ở plan 8; không gõ lại danh sách khoản | Không |
| 18/10 | Bảng cầu nối trong báo cáo chỉ in cả năm và 3 tháng mốc (tháng 3, 11, 12); đủ 12 tháng để ở sheet `Cau_noi_toan_cong_ty` | Bảng 12 cột không vừa khổ dọc; rubric chấm "ngắn gọn" | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Chuyển cách tính của bảng kiểm tra Python sang Power Query, viết phần IV.4 | `excel/queries/q_BR_Long.m`, `q_BR_Check.m`, `q_BR_Company.m`; phần sinh Bảng 14–15 và Hình 4 trong `make_figures.py`; mục IV.4 | <ul><li>So 708/708 dòng với `python_bridge.csv` (lệch ≤ 0,00005)</li><li>So cả năm, tháng 12, tháng 3, 9, 11 với số chuẩn của slide</li><li>Dòng kiểm tra bằng 0 ở mọi bảng × tháng</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Dòng kiểm tra luôn bằng 0 có phải vì khoản tỷ giá được lấy làm phần dư không?
   **Trả lời:** Không. Mọi khoản đều tính trực tiếp. Tỷ giá = bút toán sổ cái ghi tự động đổi theo tỷ giá cuối tháng chưa làm tròn trừ đi cùng các giao dịch đó theo tỷ giá ngày (slide 34); làm tròn = phần Flash làm tròn đến USD + phần sổ cái làm tròn từng bút toán. Nếu một khoản xếp nhầm tháng, dòng kiểm tra của tháng đó sẽ khác 0. Bảng tính Python viết độc lập cũng ra cùng số, lệch ≤ 0,00005. Riêng dòng tỷ giá còn được kiểm bằng cách tính thứ hai trong bảng Python, đi từ từng giao dịch: nội tệ × (1 ÷ tỷ giá cuối tháng − 1 ÷ tỷ giá ngày); hai cách lệch 0,00 mỗi tháng (`checks/python_check_result.txt`).
2. **Hỏi:** Toàn công ty có phải tính riêng không?
   **Trả lời:** Không, toàn công ty = cửa hàng + online + chưa gắn kênh, cộng từng khoản. Dòng chuyển kênh MJ-RCL (cửa hàng −3.480, online +3.480, tháng 6) cộng lại bằng 0 nên không có ở bảng toàn công ty; bút toán ADJ-0925 không thuộc kênh nào nên có bảng "chưa gắn kênh" riêng để tổng các kênh vẫn bằng tổng sổ cái.
3. **Hỏi:** Tháng nào thật sự cần điều tra? (câu hỏi riêng 2)
   **Trả lời:** Trừ hết các khoản do quy tắc ghi nhận (−2.414.533,58 cả năm), chỉ 4 tháng còn lệch quá 200 USD: tháng 3 (−12.620,75: 12 dòng POS trùng), tháng 9 (+1.248,17: ADJ-0925), tháng 11 (−7.227,68) và tháng 12 (+7.228,23): lỗi chuyển dữ liệu NX057. 8 tháng còn lại chỉ lệch dưới 2 USD do làm tròn.
4. **Hỏi:** File tự cảnh báo thế nào?
   **Trả lời:** Sheet `Canh_bao_cau_noi` soát 48 bảng × tháng: phần chưa giải thích > 200 USD, làm tròn > 5 USD, dòng kiểm tra > 1 USD thì ghi "Cần xem" (chữ đỏ) kèm lời nhắc. Năm 2025 có đúng 2 dòng: toàn công ty và chưa gắn kênh tháng 9, do ADJ-0925. Khi nạp tháng mới, cảnh báo tự tính lại, không cần sửa gì.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 7 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục IV.4 (Hình 4, Bảng 14, Bảng 15), câu hỏi riêng 2; phụ lục D nay lấy số từ bảng cầu nối Power Query.
- **Việc còn lại:**
  - File mẫu nộp đọc `BR_Long` bằng SUMIFS, nhật ký ngoại lệ, bảng so khi đổi thứ tự các bước → `bridge-template-log`.
  - Công thức DAX từng khoản, so với `BR_Long` → `dax-bridge`.
- **Các lần lưu vào Git (commit):** `b88f3e4` (tạo plan), `7944a6c` (bảng cầu nối dạng dài), `bd7b051` (cảnh báo, bảng ngang), `954df2c` (nạp sheet, file Excel), `0a5ec63` (báo cáo IV.4, phụ lục D), `19478bd` (ghi kết quả, quyết định, chuẩn bị vấn đáp), và các lần lưu rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
