# Tự chấm, tập vấn đáp, chạy lại toàn bộ và gom bộ file nộp

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 19/10/2026 |
| Ngày xong | 19/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 8 – Báo cáo, vấn đáp và nộp bài |
| Mốc phải đạt | Mốc 6 (02/11): nộp nội bộ, đã tự chấm và tập vấn đáp |
| Phần báo cáo liên quan | Toàn bộ báo cáo (tiêu đề các mục, độ dài) |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [report-draft](../completed/thanhlnp-18-10-2026-report-draft.md)</li><li>Plan tiếp theo: không có (plan cuối của nhánh `baseline`)</li></ul> |

---

## 1. Mục tiêu

Có bộ file nộp hoàn chỉnh trong `submission/`, dựng lại từ đầu và kiểm lại lần cuối; có bảng tự chấm theo rubric kèm bằng chứng và tài liệu tập 6 câu vấn đáp của rubric; đóng plan tổng.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Sửa báo cáo theo rubric: tiêu đề mục thành nhận định kèm số (backlog mục 12), bớt lặp ý giữa phần IV và V (backlog mục 13).
  - Tự chấm 4 năng lực theo rubric, mỗi tiêu chí có bằng chứng (`docs/tu_cham_rubric.md`).
  - Tài liệu tập vấn đáp: 6 câu gợi ý của rubric (sheet `Lam_dung_AI`), mỗi câu có câu trả lời và chỗ mở ra để chỉ (`docs/chuan_bi_van_dap.md`).
  - Cập nhật danh sách sheet trong sheet hướng dẫn (`excel/huong_dan.txt`).
  - Chạy lại toàn bộ: dựng file Power Query, bảng kiểm tra Python, truy vấn Power BI, sinh hình, chuyển báo cáo ra PDF.
  - Tạo lại bản Word của file quy ước (đã sửa sau lần tạo Word gần nhất).
  - Gom `submission/`: file Power Query, file mẫu nộp đã điền số, dự án Power BI nén zip, báo cáo PDF, file hướng dẫn.
  - Hoàn thiện `plans/backlog.md`; chuyển plan tổng sang `completed/`.
- **Không làm:**
  - Việc chỉ người dùng làm được (backlog): hỏi mentor, chạy trên máy thứ hai, điền tên thành viên, lưu `.pbix`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Rubric | `docs/other_resources/Rubric_danh_gia_Project_1.xlsx` | 4 năng lực × 5 band; 6 câu vấn đáp gợi ý |
| Mọi đầu ra của 15 plan | `excel/`, `checks/`, `powerbi/`, `report/` | |
| Backlog | `plans/backlog.md` | 14 mục |
| Công cụ tạo Word | `tools/build_docx/build.js` | |

**Quy ước áp dụng:** như các plan trước; không đổi số liệu.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Ai dùng |
|---|---|---|
| Bảng tự chấm | `docs/tu_cham_rubric.md` | Nhóm, trước buổi nộp |
| Tài liệu tập vấn đáp | `docs/chuan_bi_van_dap.md` | Cả nhóm |
| Bộ file nộp | `submission/` | Nộp bài |

---

## 5. Điều kiện xong

**Con số phải khớp (lần chạy lại cuối):**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Sheet `Kiem_tra` | 13/13 | QC_Summary | 13/13 | file Power Query dựng lại (205 giây) | Đạt |
| Bảng cầu nối: dòng kiểm tra lớn nhất; số dòng | ≤ 1 USD; 708 | Điều kiện plan tổng | 0,00 (6e-9); 708 | sheet `BR_Long` | Đạt |
| File mẫu nộp: dòng kiểm tra | 0 ở 12 tháng | File mẫu | 0 ở 12 tháng và cột cả năm (Excel tính lại) | `submission/Mau_nop_Bang_cau_noi.xlsx` | Đạt |
| Bảng kiểm tra Python | Khớp `numbers_of_record.csv` | `checks/python_check_result.txt` | 102/102 phép đạt, 0 sai | như trên | Đạt |
| DAX − Power Query | ≤ 0,01 | Plan `dax-bridge` | Kết quả 6 truy vấn kiểm tra giống hệt lần trước (lệch lớn nhất 0,000000007) | `powerbi/checks/*.csv` | Đạt |

**Việc phải có (không phải con số):**
- [x] Báo cáo: tiêu đề mục là nhận định kèm số; chuyển ra PDF không lỗi.
- [x] Bảng tự chấm có bằng chứng cho từng tiêu chí; tài liệu vấn đáp đủ 6 câu.
- [x] `submission/` đủ file, có file hướng dẫn.
- [x] Cả 16 plan và plan tổng ở `plans/completed/`; `git status` sạch; chưa push.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Tiêu đề có số gõ tay lệch với số trong mục | Mâu thuẫn ngay trên trang | Dùng macro trong tiêu đề |
| File mẫu nộp chép số mà còn công thức trỏ sang file khác | Mở ra lỗi `#REF!` | Ghi giá trị, không ghi công thức; đọc lại bằng pandas |
| Zip Power BI thiếu file hoặc kèm file đệm cục bộ | Mở không được hoặc quá nặng | Nén thư mục dự án, bỏ thư mục `.pbi` cục bộ; mở thử |

---

## 7. Các bước

- [x] **Bước 1: Sửa tiêu đề mục và bớt lặp ý trong báo cáo**
- [x] **Bước 2: Viết bảng tự chấm và tài liệu vấn đáp; cập nhật sheet hướng dẫn**
- [x] **Bước 3: Chạy lại toàn bộ; tạo lại bản Word**
- [x] **Bước 4: Gom `submission/`; hoàn thiện backlog; đóng plan và plan tổng**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 19/10 | Đọc rubric (3 sheet): 4 năng lực × 5 band, 6 câu vấn đáp gợi ý | Band 4 phần trình bày cần "tiêu đề là nhận định kèm số", "báo cáo ngắn gọn" | |
| 19/10 | Đổi tiêu đề mục con phần II–V thành nhận định kèm số; rút mục V.2 thành bảng 3 dòng trỏ về phần IV (backlog 12, 13) | Mục lục đọc như một bản tóm tắt; báo cáo vẫn 45 trang | |
| 19/10 | Viết `docs/tu_cham_rubric.md`, `docs/chuan_bi_van_dap.md`; cập nhật danh sách sheet trong `excel/huong_dan.txt` | Tự chấm: 5 / 5 / 5 / 4–4,5; 6 câu vấn đáp có câu trả lời và chỗ mở ra để chỉ | |
| 19/10 | Chạy lại toàn bộ: dựng file Power Query, bảng kiểm tra Python, 6 truy vấn Power BI, sinh hình, PDF; tạo lại bản Word file quy ước | Mọi kết quả giống lần trước; chỉ bảng khai báo AI thêm dòng của plan 15 | |
| 19/10 | Viết `tools/make_submission.py`, gom `submission/` (6 file) | File mẫu nộp: Excel tính lại dòng kiểm tra = 0 ở 12 tháng và cả năm | Lần đầu làm tròn từng ô đến 2 chữ số nên dòng kiểm tra ra ±0,01 ở vài tháng; sửa: ghi đủ số lẻ |
| 19/10 | Thêm phần "Việc cần làm trước khi nộp" vào đầu `plans/backlog.md` | 6 việc xếp theo thứ tự | |
| 19/10 | Rà soát độc lập plan 16: đối chiếu mọi số của tài liệu vấn đáp với file Power Query, `data/` và các file `.m`; soát bằng chứng tự chấm, `submission/` (6 file, 2 zip, file mẫu nộp), tiêu đề mục mới, PDF | <ul><li>Số đúng, trừ 1 chỗ sai: 12 dòng trùng thuộc **2 hóa đơn** (R3376006, R3376008), không phải 1</li><li>File mẫu nộp: 10 khoản, 18 dòng nhật ký, không còn EX-00, không công thức trỏ sang file khác, dòng kiểm tra = 0; 2 zip không có `localSettings.json`, `cache.abf`</li><li>Tự chấm hạ năng lực 1 xuống 4,5, năng lực 4 xuống 4</li></ul> | <ul><li>Sửa `docs/chuan_bi_van_dap.md`, `docs/tu_cham_rubric.md`, `excel/huong_dan.txt` (dòng viết tắt), `plans/backlog.md` (việc 6)</li><li>Tiêu đề mục trong `report/sections/02`–`05`: số lấy từ macro; bỏ dấu ngoặc kép LaTeX làm hỏng dấu trang PDF ở V.4; đổi tiêu đề V.3 cho khớp bảng. Dịch thử ở thư mục tạm: 45 trang, không lỗi</li><li>Cần chuyển lại PDF, dựng lại file Power Query, chạy lại `make_submission.py`</li></ul> |
| 19/10 | Sau rà soát: sửa README trong `tools/make_submission.py` (thư mục dữ liệu phải có cả file danh mục; tham số `PQFile`); dựng lại file Power Query (164 giây), chuyển lại PDF (45 trang), gom lại `submission/` | File mẫu nộp: dòng kiểm tra = 0 ở 12 tháng; tổng nhật ký = sổ cái − Flash | |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 19/10 | Làm luôn backlog 12, 13 (tiêu đề mục, bớt lặp) thay vì chờ người dùng | Rubric Band 4 nêu rõ hai tiêu chí này; người dùng vẫn đổi lại được | Không |
| 19/10 | File mẫu nộp điền giá trị (không công thức trỏ sang file Power Query) | Mở riêng file mẫu vẫn thấy đủ số; công thức gốc của file mẫu (dòng 14, 16, cột N) giữ nguyên để người chấm thấy dòng kiểm tra tự tính | Không |
| 19/10 | Gom `submission/` bằng script, lưu cả thư mục vào Git | Nộp lại sau khi sửa chỉ cần chạy 1 lệnh; giữ đúng bản đã kiểm | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 19/10 | Sửa tiêu đề mục, viết bảng tự chấm, tài liệu vấn đáp, script gom file nộp | `docs/tu_cham_rubric.md`, `docs/chuan_bi_van_dap.md`, `tools/make_submission.py`, tiêu đề mục và bảng V.2 | <ul><li>Mỗi số trong tài liệu vấn đáp đối chiếu với sheet trong file Power Query (ví dụ sheet `Bay_du_lieu` cho câu 4)</li><li>Mở file mẫu nộp bằng Excel, tính lại, đọc dòng kiểm tra</li></ul> |

---

## 11. Chuẩn bị vấn đáp

Xem `docs/chuan_bi_van_dap.md`.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 5 dòng số và 4 việc phải có (mục 5).
- **Bộ file nộp:** `submission/` gồm báo cáo PDF, file Power Query, file mẫu nộp đã điền, dự án Power BI (zip), code Power Query (zip), README.
- **Việc còn lại:** chỉ còn các việc của người dùng, tóm tắt ở đầu `plans/backlog.md`.
- **Các lần lưu vào Git (commit):** `bae6bb3` (tạo plan), `44a7962` (tiêu đề mục, bảng V.2), `790bd27` (tự chấm, vấn đáp, sheet hướng dẫn), `f389984` (bản Word), `0f226c2` (chạy lại toàn bộ), `2892bd4` (bộ file nộp), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
