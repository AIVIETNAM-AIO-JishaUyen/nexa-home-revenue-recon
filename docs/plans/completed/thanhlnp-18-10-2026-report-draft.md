# Hoàn thiện bản nháp báo cáo: phụ lục mã Power Query, khai báo AI, rà toàn bộ

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 19/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 8 – Báo cáo, vấn đáp và nộp bài (bản nháp đủ) |
| Mốc phải đạt | Mốc 5 (29/10): đủ mọi sản phẩm ở dạng bản nháp, kể cả báo cáo |
| Phần báo cáo liên quan | <ul><li>Phụ lục A (mã Power Query), phụ lục khai báo AI</li><li>Rà toàn bộ 8 phần</li></ul> |
| Trạng thái | Xong |
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
| Số truy vấn trong bảng phụ lục A | 31 | `excel/queries/*.m` | 31 (1.696 dòng code) | `bang_truy_van.tex`, macro `SoTruyVan`, `SoDongMa` | Đạt |
| Số plan có dòng khai báo AI | 14 plan đã đóng | `plans/completed/` | 14 plan, 19 dòng | `bang_ai.tex`, macro `SoPlanAI`, `SoDongAI` | Đạt |

**Việc phải có (không phải con số):**
- [x] Không còn `\choviet` trong báo cáo.
- [x] PDF chuyển được, không có lỗi; không có tham chiếu bảng / hình bị trống ("??").
- [x] Code trong phụ lục đọc được (không tràn lề, chữ tiếng Việt hiện đúng).

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| In code có dòng dài | Tràn lề phải | Ngắt dòng dài trước khi in, có ký hiệu dòng nối tiếp |
| Chữ tiếng Việt trong khối code | Lỗi dịch hoặc mất dấu | Thử trước với một file |
| Bảng AI có ký hiệu Markdown (`` ` ``, `<ul><li>`) | Lỗi dịch LaTeX | Đổi sang LaTeX khi sinh bảng |

---

## 7. Các bước

- [x] **Bước 1: Sinh bảng truy vấn và code truy vấn chính; viết phụ lục A**
- [x] **Bước 2: Sinh bảng khai báo AI; viết phụ lục khai báo AI**
- [x] **Bước 3: Rà toàn bộ báo cáo, chuyển ra PDF, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Thêm vào `make_figures.py` phần sinh bảng truy vấn (từ dòng ghi chú đầu mỗi file `.m`), code của `q_Transactions`, `q_BR_Long` (ngắt dòng dài quá 104 ký tự), bảng khai báo AI (gom mục 10 của 14 plan đã đóng) | 31 truy vấn; 19 dòng khai báo AI | Hàm ngắt dòng lặp vô hạn: nó ngắt ngay tại dấu cách sau ký hiệu ".." của dòng nối tiếp; sửa bằng cách chỉ tìm chỗ ngắt sau phần ký hiệu |
| 19/10 | Viết phụ lục A và phụ lục khai báo AI, chuyển ra PDF | Báo cáo 45 trang, không còn chỗ giữ chỗ, không có tham chiếu trống | <ul><li>Bản dịch đầu lỗi vì ký tự ⚠ (và ×, ÷, ≈, ≤, …) không có trong phông chữ; thêm bảng đổi ký tự: trong bảng dùng ký hiệu toán, trong khối code dùng chữ ASCII</li><li>Bảng khai báo AI: hiện "&amp;", đường dẫn dài tràn cột, dòng tiêu đề lọt lên trước tên bảng; sửa bằng cách giải mã ký tự HTML, cho phép xuống dòng sau "/", "_", ".", và sang trang mới trước bảng</li></ul> |
| 19/10 | Rà soát độc lập toàn bài (một phiên AI khác): đối chiếu 8 phần với slide 45 và rubric, kiểm số gõ tay với macro và dữ liệu, kiểm mọi tham chiếu bảng / hình / phụ lục / mục, chữ viết tắt, xem từng trang PDF (dựng thử vào thư mục nháp, không đè `report/main.pdf`) | <ul><li>Đủ 8 phần + phụ lục A–G; mọi số gõ tay khớp macro hoặc dữ liệu; không có tham chiếu trống</li><li>Đã sửa: 5 bảng chưa có nhãn và chưa được nhắc trong lời văn (Bảng 1, 2, 4, 6, nhãn nguồn), Hình 4, 7, 8 và Bảng 14 chưa được nhắc; bảng nhật ký ngoại lệ (phụ lục B) chưa có tên bảng; II.6 ghi "3 lỗi dữ liệu" mâu thuẫn với "2 lỗi + 1 khoản chưa giải thích"; thêm tên đầy đủ POS, mentor, script, dashboard, ADJ / MJ (và mã MJ-ADJ-2509 của ADJ-0925); bỏ "code M"; bảng khai báo AI đổi tên plan sang tên phần việc tiếng Việt (`make_figures.py`); tiêu đề trang bìa bị dấu chồng lên dòng trên; đường dẫn tràn lề 35 pt ở II.8</li><li>Lỗi trình bày: dòng tiêu đề bảng in lên trước tên bảng mỗi khi tên bảng bị đẩy sang trang mới (trước đây ở Bảng 21, sau khi sửa chữ thì xuất hiện ở Bảng 1, 5). Nguyên nhân: `\needspace` để TeX chọn chỗ ngắt sau khi longtable đã bắt đầu. Sửa: `\captab` dùng `\Needspace` (ngắt trang ngay); soát lại bằng script: 0 trang lỗi</li></ul> | <ul><li>Chưa chạy lại `build_pdf.ps1`: `report/main.pdf` vẫn là bản cũ</li><li>Ba việc cần người dùng quyết ghi ở backlog mục 12–14: tiêu đề mục là nhận định kèm số, lặp ý giữa phần IV và V, ảnh dashboard và code phụ lục A nhỏ khi in</li></ul> |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Phụ lục A in đầy đủ 2 truy vấn chính, còn lại chỉ liệt kê trong bảng (tên, việc làm, sheet) | In cả 31 truy vấn (1.696 dòng) thêm khoảng 30 trang; rubric chấm "ngắn gọn". Code đầy đủ nằm trong `excel/queries` và trong file Excel | Không |
| 18/10 | Bảng khai báo AI sinh tự động từ mục 10 của các file plan | Không chép tay hai lần; plan sửa thì bảng tự đổi | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết phần sinh phụ lục trong `make_figures.py` và lời văn phụ lục A, khai báo AI | Phần "Phụ lục A" và "Phụ lục khai báo AI" trong `make_figures.py`; `09_phu_luc.tex` | <ul><li>Đếm số truy vấn, số dòng code, số plan so với thư mục</li><li>Xem từng trang PDF của phụ lục</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Code Power Query ở đâu, đọc thế nào?
   **Trả lời:** Mỗi truy vấn một file `.m` trong `excel/queries`, bước nào cũng có tên tiếng Việt và ghi chú. Phụ lục A có bảng 31 truy vấn và code đầy đủ của 2 truy vấn chính: `q_Transactions` (bảng giao dịch chung) và `q_BR_Long` (bảng cầu nối).
2. **Hỏi:** Nhóm dùng AI thế nào?
   **Trả lời:** AI viết nháp code và lời văn; mọi số trong báo cáo ra từ file Power Query hoặc truy vấn Power BI, không lấy từ câu trả lời của AI. Mỗi plan ghi AI làm gì và nhóm kiểm lại bằng cách nào (bảng khai báo AI ở phụ lục); mỗi plan có một lần rà soát độc lập.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 2 dòng số và 3 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** phụ lục A (bảng truy vấn, code 2 truy vấn chính), phụ lục khai báo AI.
- **Việc còn lại:**
  - Tên thành viên 2, 3 và tên mentor trên trang bìa → backlog mục 5 (người dùng).
  - Tự chấm theo rubric, gom file nộp → `review-submit`.
- **Các lần lưu vào Git (commit):** `5c0b2cc` (tạo plan), `c838e4f` (sinh bảng, code, khai báo AI), `a86ac63` (phụ lục A, khai báo AI), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
