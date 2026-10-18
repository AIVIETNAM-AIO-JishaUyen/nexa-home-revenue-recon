# Tự chấm, tập vấn đáp, chạy lại toàn bộ và gom bộ file nộp

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 19/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 8 – Báo cáo, vấn đáp và nộp bài |
| Mốc phải đạt | Mốc 6 (02/11): nộp nội bộ, đã tự chấm và tập vấn đáp |
| Phần báo cáo liên quan | Toàn bộ báo cáo (tiêu đề các mục, độ dài) |
| Trạng thái | Đang làm |
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
| Sheet `Kiem_tra` | 13/13 | QC_Summary | | file Power Query dựng lại | |
| Bảng cầu nối: dòng kiểm tra lớn nhất; số dòng | ≤ 1 USD; 708 | Điều kiện plan tổng | | sheet `BR_Long` | |
| File mẫu nộp: dòng kiểm tra | 0 ở 12 tháng | File mẫu | | `submission/Mau_nop_Bang_cau_noi.xlsx` | |
| Bảng kiểm tra Python | Khớp `numbers_of_record.csv` | `checks/python_check_result.txt` | | như trên | |
| DAX − Power Query | ≤ 0,01 | Plan `dax-bridge` | | `powerbi/checks/bridge_compare.csv` | |

**Việc phải có (không phải con số):**
- [ ] Báo cáo: tiêu đề mục là nhận định kèm số; chuyển ra PDF không lỗi.
- [ ] Bảng tự chấm có bằng chứng cho từng tiêu chí; tài liệu vấn đáp đủ 6 câu.
- [ ] `submission/` đủ file, có file hướng dẫn.
- [ ] Cả 16 plan và plan tổng ở `plans/completed/`; `git status` sạch; chưa push.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Tiêu đề có số gõ tay lệch với số trong mục | Mâu thuẫn ngay trên trang | Dùng macro trong tiêu đề |
| File mẫu nộp chép số mà còn công thức trỏ sang file khác | Mở ra lỗi `#REF!` | Ghi giá trị, không ghi công thức; đọc lại bằng pandas |
| Zip Power BI thiếu file hoặc kèm file đệm cục bộ | Mở không được hoặc quá nặng | Nén thư mục dự án, bỏ thư mục `.pbi` cục bộ; mở thử |

---

## 7. Các bước

- [ ] **Bước 1: Sửa tiêu đề mục và bớt lặp ý trong báo cáo**
- [ ] **Bước 2: Viết bảng tự chấm và tài liệu vấn đáp; cập nhật sheet hướng dẫn**
- [ ] **Bước 3: Chạy lại toàn bộ; tạo lại bản Word**
- [ ] **Bước 4: Gom `submission/`; hoàn thiện backlog; đóng plan và plan tổng**

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

Xem `docs/chuan_bi_van_dap.md`.

---

## 12. Kết quả khi đóng plan

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
