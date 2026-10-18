# Hoàn thiện bản nháp báo cáo: phụ lục mã Power Query, khai báo AI, rà toàn bộ

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 8 – Báo cáo, vấn đáp và nộp bài (bản nháp đủ) |
| Mốc phải đạt | Mốc 5 (29/10): đủ mọi sản phẩm ở dạng bản nháp, kể cả báo cáo |
| Phần báo cáo liên quan | <ul><li>Phụ lục A (mã Power Query), phụ lục khai báo AI</li><li>Rà toàn bộ 8 phần</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [conclusions](../completed/thanhlnp-18-10-2026-conclusions.md)</li><li>Plan tiếp theo dùng kết quả này: `review-submit`</li></ul> |

---

## 1. Mục tiêu

Báo cáo PDF (Portable Document Format) đủ 8 phần và phụ lục, không còn chỗ trống: phụ lục A cho thấy code Power Query đọc được (bảng mọi truy vấn và code đầy đủ của truy vấn chính), phụ lục khai báo AI tổng hợp từ mục "Dùng AI" của mọi plan.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Phụ lục A: bảng 31 truy vấn (tên, việc làm, sheet) và code đầy đủ của `q_Transactions`, `q_BR_Long`. Sinh tự động từ `excel/queries/` bằng `make_figures.py`, không chép tay.
  - Phụ lục khai báo AI: bảng sinh tự động từ mục 10 của các file plan đã đóng.
  - Rà toàn bộ báo cáo: số trang, mục lục, tham chiếu bảng / hình, chữ viết tắt, thống nhất số liệu giữa các phần.
- **Không làm (để cho plan khác):**
  - Tự chấm theo rubric, tập vấn đáp, gom file nộp → `review-submit`.
  - Điền tên thành viên 2, 3 và tên mentor (backlog mục 5, việc của người dùng).

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Code Power Query | `excel/queries/*.m`, `excel/queries/manifest.csv` | 31 file, 1.696 dòng; dòng đầu mỗi file là ghi chú mô tả |
| Mục "Dùng AI" của các plan | `plans/completed/*.md` (mục 10) | Bảng 4 cột |
| Báo cáo | `report/` | Đã có phần I–VII, phụ lục B–F |

**Quy ước áp dụng:** viết tiếng Việt dễ hiểu; số trong lời văn lấy từ macro; mỗi kết luận có nhãn nguồn.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Bảng truy vấn, code truy vấn chính, bảng khai báo AI | `report/generated/bang_truy_van.tex`, `ma_*.txt`, `bang_ai.tex` (sinh từ `make_figures.py`) | `review-submit` |
| Báo cáo PDF đầy đủ | `report/main.pdf` | `review-submit` |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Số truy vấn trong bảng phụ lục A | 31 | `excel/queries/*.m` | | `bang_truy_van.tex` | |
| Số plan có dòng khai báo AI | Mọi plan đã đóng | `plans/completed/` | | `bang_ai.tex` | |

**Việc phải có (không phải con số):**
- [ ] Không còn `\choviet` trong báo cáo.
- [ ] PDF chuyển được, không có lỗi; không có tham chiếu bảng / hình bị trống ("??").
- [ ] Code trong phụ lục đọc được (không tràn lề, chữ tiếng Việt hiện đúng).

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| In code có dòng dài | Tràn lề phải | Ngắt dòng dài trước khi in, có ký hiệu dòng nối tiếp |
| Chữ tiếng Việt trong khối code | Lỗi dịch hoặc mất dấu | Thử trước với một file |
| Bảng AI có ký hiệu Markdown (`` ` ``, `<ul><li>`) | Lỗi dịch LaTeX | Đổi sang LaTeX khi sinh bảng |

---

## 7. Các bước

- [ ] **Bước 1: Sinh bảng truy vấn và code truy vấn chính; viết phụ lục A**
- [ ] **Bước 2: Sinh bảng khai báo AI; viết phụ lục khai báo AI**
- [ ] **Bước 3: Rà toàn bộ báo cáo, chuyển ra PDF, lưu vào Git (commit)**

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
