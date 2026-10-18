# Kết luận, đề xuất và giới hạn (phần V–VII của báo cáo)

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 7 – Kết luận và đề xuất |
| Mốc phải đạt | Mốc 5 (29/10) |
| Phần báo cáo liên quan | <ul><li>Phần V (phát hiện chính), VI (đề xuất), VII (giới hạn và bước tiếp theo)</li><li>Hộp tóm tắt đầu báo cáo</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [dashboard](../completed/thanhlnp-18-10-2026-dashboard.md) và các plan đối soát, cầu nối</li><li>Plan tiếp theo dùng kết quả này: `report-draft`, `review-submit` (tập vấn đáp)</li></ul> |

---

## 1. Mục tiêu

Trả lời 3 câu hỏi của Giám đốc Tài chính và 3 câu hỏi riêng của nhóm bằng số có nhãn nguồn; đưa ra đề xuất xếp theo lợi ích so với công sức (bộ phận nào làm, khi nào, theo dõi bằng chỉ số nào); nêu rủi ro đề không nhắc, các giả thuyết đã kiểm tra và bác bỏ, và giới hạn của kết luận.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Phần V: trả lời từng câu hỏi; điều dữ liệu cho thấy tách khỏi giả thuyết; giả thuyết đã bác bỏ; điều bất ngờ.
  - Phần VI: bảng đề xuất xếp ưu tiên; danh sách việc trước khi khóa sổ (1 trang); so 2 cách xử lý tỷ giá.
  - Phần VII: giới hạn, rủi ro ngoài đề, bước tiếp theo.
  - Hộp tóm tắt đầu báo cáo: thay câu giữ chỗ bằng phần "vì sao lệch, khoản nào là lỗi, ai cần làm gì".
  - Các con số mới (tỷ trọng, phần còn lại nếu Flash báo doanh số thuần) sinh bằng `make_figures.py`, không gõ tay.
- **Không làm (để cho plan khác):**
  - Phụ lục A (mã M), khai báo AI, rà soát toàn bộ lời văn → `report-draft`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Số của báo cáo | `report/generated/so_lieu.tex` (sinh từ file Power Query, kết quả Power BI) | Mọi số trong phần V–VII lấy từ đây |
| Nhật ký ngoại lệ | Sheet `Nhat_ky_du_lieu` | Người phụ trách, hướng xử lý |
| Rubric, slide 45–47 | `docs/other_resources/` | Mạch Câu hỏi → Bằng chứng → Kết luận; Band 5 |
| Backlog | `plans/backlog.md` | Phần nào còn chờ người dùng / mentor |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Mỗi kết luận có nhãn nguồn số (`[QC]`, `[RC-CH]`, `[RC-WEB]`, `[RC-RET]`, `[BR-Tổng]`, `[BR-CH]`, `[BR-WEB]`, `[EX-xx]`).
- Không nêu nguyên nhân không có trong dữ liệu; ADJ-0925 để ở "chưa giải thích được".
- Không trôi sang phân tích kinh doanh.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Phần V, VI, VII | `report/sections/05_phat_hien.tex`, `06_de_xuat.tex`, `07_gioi_han.tex` | `report-draft` |
| Hộp tóm tắt | `report/sections/00_tom_tat.tex` | |
| Macro số mới | `report/figures_src/make_figures.py` → `report/generated/so_lieu.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Tổng 4 nhóm = chênh lệch cả năm | −2.425.904,77 | `checks/numbers_of_record.csv` (`tot_delta`) | −2.414.533,58 − 12.622,20 + 1.250 + 1,01 = −2.425.904,77 | Macro `SoTongNhom` sinh từ `BR_Long` | Đạt |
| Phần còn lại nếu Flash báo doanh số thuần (trừ chiết khấu và đơn hủy; trừ thêm hàng trả) | −2.425.904,77 + 1.834.297,47 + 215.658,92 = −375.948,38; + 349.148,23 = −26.800,15 | Các khoản cả năm của `BR_Long` | −375.948,38 (−1,21%); −26.800,15 (−0,09%) | Macro `SoFlashThuanConLai`, `SoFlashThuanTraConLai` | Đạt |

**Việc phải có (không phải con số):**
- [x] Mỗi câu hỏi (3 của Giám đốc Tài chính, 3 của nhóm) có câu trả lời một đoạn, có số và nhãn nguồn.
- [x] Bảng đề xuất có cột bộ phận, thời điểm, chỉ số theo dõi, lợi ích, công sức; xếp theo lợi ích so với công sức.
- [x] Có danh sách việc trước khi khóa sổ, giả thuyết đã bác bỏ, rủi ro đề không nhắc.
- [x] Không còn chỗ giữ chỗ `\choviet{conclusions}`; báo cáo chuyển ra PDF (Portable Document Format) được.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Gõ tay số vào lời văn | Số lệch với bảng khi dữ liệu đổi | Dùng macro; số mới thì thêm vào `make_figures.py` |
| Nêu nguyên nhân dữ liệu không chứng minh (ví dụ vì sao NX057 thiếu bút toán) | Rubric trừ điểm "suy diễn" | Chỉ nói điều thấy trong dữ liệu; điều chưa biết ghi "cần hỏi" |
| Đề xuất chung chung | Không đo được | Mỗi đề xuất có chỉ số và mục tiêu |

---

## 7. Các bước

- [x] **Bước 1: Thêm macro số mới vào `make_figures.py`**
- [x] **Bước 2: Viết phần V**
- [x] **Bước 3: Viết phần VI, VII và hộp tóm tắt; chuyển ra PDF, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Thêm 13 macro vào `make_figures.py`: tổng 4 nhóm, tỷ trọng chiết khấu / hàng trả / đơn hủy, phần còn lại nếu Flash báo doanh số thuần | <ul><li>Quy tắc ghi nhận 99,5% chênh lệch</li><li>Chiết khấu 76%, hàng trả 14%, đơn hủy 9%</li><li>Flash thuần (trừ chiết khấu, đơn hủy): còn −375.948,38 (−1,21%); trừ thêm hàng trả: còn −26.800,15 (−0,09%)</li></ul> | |
| 18/10 | Viết phần V, VI, VII, hộp tóm tắt; chuyển ra PDF | <ul><li>V: trả lời 3 + 3 câu hỏi, bảng 4 nhóm, 4 giả thuyết bị bác bỏ, 3 điều bất ngờ</li><li>VI: 6 đề xuất xếp ưu tiên, danh sách 7 việc trước khi khóa sổ, so 2 cách xử lý tỷ giá</li><li>VII: 5 giới hạn, 4 rủi ro đề không nhắc, 3 bước tiếp theo</li></ul> | Lệnh `sed` làm hỏng chuỗi `\nguon` ở hộp tóm tắt (lỡ lưu vào Git một lần); sửa lại bằng công cụ sửa file |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Xếp đề xuất theo lợi ích so với công sức: so ô trước khóa sổ, chặn xuất trùng, quy định bút toán tay lên đầu; Flash báo doanh số thuần đứng thứ 4 | Ba việc đầu sửa đúng 3 lỗi đã thấy và gần như không tốn công (phép kiểm tra đã có trong file Power Query); việc thứ 4 có lợi nhất về lâu dài nhưng phải sửa mẫu báo cáo của phòng Kinh doanh | Không |
| 18/10 | Chỉ nêu điều dữ liệu cho thấy; nguyên nhân lỗi NX057 và nội dung ADJ-0925 ghi là "phải hỏi" | Dữ liệu không có thông tin này; rubric cấm suy diễn nguyên nhân | Không |
| 18/10 | Giữ cách xử lý tỷ giá một dòng riêng | Mỗi dòng của bảng cầu nối chỉ nên có một nguyên nhân; trình bày cả cách khác (đổi mỗi khoản theo tỷ giá sổ cái) với số minh họa từ phụ lục E | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết nháp phần V–VII và hộp tóm tắt, thêm macro số | `05_phat_hien.tex`, `06_de_xuat.tex`, `07_gioi_han.tex`, `00_tom_tat.tex`; phần macro mới trong `make_figures.py` | <ul><li>Mọi số là macro sinh từ file Power Query, không gõ tay (trừ vài số đã có trong nhật ký như 7 đơn, 12 dòng)</li><li>Đối chiếu từng kết luận với bảng có nhãn nguồn</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Tóm lại vì sao sổ cái thấp hơn Flash 2,43 triệu USD?
   **Trả lời:** 99,5% là do hai phòng đo hai thứ khác nhau: Flash tính giá trước chiết khấu (−1,83 triệu), tính cả đơn hủy (−0,22 triệu), không trừ hàng trả (−0,35 triệu), ghi online theo ngày đặt. Lỗi thật chỉ có 12 dòng POS trùng (−12.622,20) và NX057 (cả năm bằng 0); còn ADJ-0925 (+1.250) chưa giải thích được.
2. **Hỏi:** Đề xuất nào làm trước?
   **Trả lời:** So từng ô cửa hàng × ngày trước khi khóa sổ (Tài chính, mỗi tháng): truy vấn đã có, chạy 3 phút, bắt được lỗi NX057 trước khi tháng 11 bị chốt. Tiếp đến chặn xuất trùng ở POS (IT) và quy định bút toán tay phải có giấy tờ (Tài chính).
3. **Hỏi:** Nhóm đã kiểm những giả thuyết nào và bác bỏ ra sao?
   **Trả lời:** Bốn giả thuyết: lỗi nhập liệu là chính (bác bỏ, chỉ 0,5%); tháng 11 nhiều cửa hàng ghi thiếu (bác bỏ, 21 cửa hàng còn 1 sau khi so cùng ngày ghi sổ); tháng 3 ghi thừa (bác bỏ, là đơn đặt cuối tháng 2 giao tháng 3); tỷ giá là chính (bác bỏ, chỉ −57.598,01).
4. **Hỏi:** Rủi ro nào đề không nhắc?
   **Trả lời:** Hàng trả sau ngày lấy dữ liệu (đã có 7 đơn trong tháng 01/2026); sổ cái tháng 11 đã khóa mà thiếu doanh thu; mã cửa hàng khác nhau giữa POS và sổ cái; Flash không có số theo cửa hàng.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 2 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** phần V (Bảng 17, 18), VI (Bảng 19, danh sách việc trước khi khóa sổ), VII; hộp tóm tắt.
- **Việc còn lại:**
  - Phụ lục A (mã M), khai báo AI, rà soát toàn bộ lời văn → `report-draft`.
- **Các lần lưu vào Git (commit):** `77eca5a` (tạo plan), `435895b` (phần V–VII, tóm tắt, macro), `98e05bd` (sửa nhãn nguồn ở tóm tắt), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
