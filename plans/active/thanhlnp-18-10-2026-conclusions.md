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
| Tổng 4 nhóm = chênh lệch cả năm | −2.425.904,77 | `checks/numbers_of_record.csv` (`tot_delta`) | | Macro sinh từ `BR_Long` | |
| Phần còn lại nếu Flash báo doanh số thuần (trừ chiết khấu và đơn hủy) | Tính từ `BR_Long` | `BR_Long` | | như trên | |

**Việc phải có (không phải con số):**
- [ ] Mỗi câu hỏi (3 của Giám đốc Tài chính, 3 của nhóm) có câu trả lời một đoạn, có số và nhãn nguồn.
- [ ] Bảng đề xuất có cột bộ phận, thời điểm, chỉ số theo dõi, lợi ích, công sức; xếp theo lợi ích so với công sức.
- [ ] Có danh sách việc trước khi khóa sổ, giả thuyết đã bác bỏ, rủi ro đề không nhắc.
- [ ] Không còn chỗ giữ chỗ `\choviet{conclusions}`; báo cáo chuyển ra PDF (Portable Document Format) được.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Gõ tay số vào lời văn | Số lệch với bảng khi dữ liệu đổi | Dùng macro; số mới thì thêm vào `make_figures.py` |
| Nêu nguyên nhân dữ liệu không chứng minh (ví dụ vì sao NX057 thiếu bút toán) | Rubric trừ điểm "suy diễn" | Chỉ nói điều thấy trong dữ liệu; điều chưa biết ghi "cần hỏi" |
| Đề xuất chung chung | Không đo được | Mỗi đề xuất có chỉ số và mục tiêu |

---

## 7. Các bước

- [ ] **Bước 1: Thêm macro số mới vào `make_figures.py`**
- [ ] **Bước 2: Viết phần V**
- [ ] **Bước 3: Viết phần VI, VII và hộp tóm tắt; chuyển ra PDF, lưu vào Git (commit)**

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
