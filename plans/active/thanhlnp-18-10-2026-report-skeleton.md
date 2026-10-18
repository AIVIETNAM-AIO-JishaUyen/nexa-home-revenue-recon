# Khung báo cáo 8 phần, viết phần I–III, chuyển ra PDF

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | <ul><li>Việc 8 – Báo cáo (phần đầu: khung, viết dần từ Mốc 2)</li><li>Việc 1 – câu hỏi riêng của nhóm</li></ul> |
| Mốc phải đạt | Mốc 2 (19/10): "Đã có khung báo cáo, chuyển ra PDF được"; "Đã đặt 2–4 câu hỏi riêng của nhóm" |
| Phần báo cáo liên quan | Cả báo cáo: khung 8 phần + phụ lục; viết thật phần I, II, III và phụ lục D (so 3 phiên bản làm tròn) |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [powerbi-totals](../completed/thanhlnp-18-10-2026-powerbi-totals.md)</li><li>Plan tiếp theo dùng kết quả này: mọi plan sau viết tiếp phần của mình vào `report/`</li></ul> |

---

## 1. Mục tiêu

Có báo cáo LaTeX (cách soạn tài liệu bằng file chữ rồi chuyển ra PDF – Portable Document Format) **đúng khung 8 phần + phụ lục của slide 45**, dùng khung trình bày của file mẫu `main.tex`, chuyển ra PDF không lỗi. Phần I (vấn đề, 3 câu hỏi của Giám đốc Tài chính, 3 câu hỏi riêng của nhóm, quy ước chốt trước), phần II (dữ liệu, 5 bẫy, kiểm tra tổng) và phần III (chênh lệch theo tháng, kênh) viết thật bằng số đã có; các phần sau có khung và ghi chú plan nào viết.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Thư mục `report/`: `main.tex` (giữ phần khai báo và trang bìa của file mẫu, đổi tên đề tài), mỗi phần 1 file trong `report/sections/`, `references.bib` mới.
  - Script `report/figures_src/make_figures.py` đọc file Excel Power Query, sinh hình và bảng LaTeX vào `report/generated/` (số trong bảng không gõ tay).
  - Script `report/build_pdf.ps1` chạy pdflatex → bibtex → pdflatex ×2.
  - 3 câu hỏi riêng của nhóm, đo được bằng số, mỗi câu ghi rõ đo bằng gì và lấy số ở bảng nào.
- **Không làm (để cho plan khác):**
  - Phần IV (phân tích chính) → `store-recon`, `web-return-recon`, `bridge-monthly`, `dax-bridge`.
  - Phần V–VII (phát hiện, đề xuất, giới hạn) → `conclusions`.
  - Hoàn thiện, cắt gọn, phụ lục mã M (ngôn ngữ của Power Query) → `report-draft`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| File mẫu báo cáo | `docs/template/report_template/` | Giữ khai báo gói, hộp, trang bìa; bỏ nội dung Steel Plates |
| Cấu trúc 8 phần | slide 45 | I. Vấn đề và câu hỏi … VIII. Tham khảo + Phụ lục |
| Số đã có | `excel/Nexa_Home_Recon_PQ.xlsx` (sheet `Kiem_tra`, `Bay_du_lieu`, `Chenh_lech_thang`, `Chenh_lech_kenh`) | Nguồn số của phần II, III |
| Mô tả dữ liệu, quy ước | `docs/cau_truc_du_lieu.md`, `docs/quy_uoc_va_so_chuan.md` | Phần I, II |
| Nội dung đã ghi sẵn | mục 12 của các plan `load-clean-data`, `python-check`, `powerbi-totals` | |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Mọi kết luận ghi kèm nhãn nguồn số (`[QC]`, `[BR-Tổng]`…).
- Tiêu đề hình nói luôn kết luận kèm con số; không dùng biểu đồ tròn, 3D.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Báo cáo LaTeX | `report/main.tex`, `report/sections/*.tex`, `report/references.bib` | Mọi plan sau |
| Script hình, bảng | `report/figures_src/make_figures.py` → `report/generated/` | Mọi plan sau thêm hình vào đây |
| Script chuyển PDF | `report/build_pdf.ps1` | |
| Bản PDF | `report/main.pdf` | Xem thử, nộp ở plan cuối |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Số trong bảng phần II, III bằng số trên sheet Excel | khớp 100% | `excel/Nexa_Home_Recon_PQ.xlsx` | | `report/generated/*.tex` (sinh tự động) | |
| Chênh lệch cả năm nêu trong phần III | −2.425.904,77 (−7,79%) | sheet `Chenh_lech_thang` | | `report/sections/03_kham_pha.tex` | |

**Việc phải có (không phải con số):**
- [ ] PDF có đủ 8 phần đánh số I–VIII + phụ lục, mục lục, trang bìa đúng đề tài.
- [ ] Biên dịch không có lỗi LaTeX (chỉ cảnh báo nhỏ).
- [ ] Phần I có 3 câu hỏi của Giám đốc Tài chính và 3 câu hỏi riêng, mỗi câu riêng có thước đo và bảng nguồn.
- [ ] Không còn nội dung Steel Plates.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Gõ tay số vào bảng LaTeX | Số báo cáo lệch số Power Query khi làm mới | Bảng sinh tự động từ file Excel bằng script |
| Câu hỏi riêng trôi sang phân tích kinh doanh (tăng trưởng, sản phẩm bán chạy) | Rubric hạ xuống Band 2 | Mọi câu hỏi phải về chênh lệch giữa hai nguồn hoặc về quy trình |
| Chép nguyên văn khung của file mẫu | Rubric Band 5 yêu cầu giọng văn của nhóm | Viết lại theo câu chuyện đối soát của Nexa Home |
| Báo cáo dài, sáo rỗng | Rubric chấm "ngắn gọn" | Mỗi đoạn trả lời 1 câu hỏi; số đi kèm nhãn nguồn |
| Gói LaTeX thiếu, lỗi tiếng Việt | Không ra PDF | Giữ nguyên phần khai báo gói của file mẫu (đã chạy được với TeX Live) |

---

## 7. Các bước

- [ ] **Bước 1: Dựng khung `report/`**
  - Làm: chép khai báo từ file mẫu; đổi tên đề tài, tác giả; 10 file phần (tóm tắt, I–VIII, phụ lục); `references.bib`.
  - Kiểm tra: chuyển ra PDF được.
- [ ] **Bước 2: Script sinh hình và bảng**
  - Làm: đọc file Excel Power Query, sinh hình chênh lệch theo tháng, bảng tháng, bảng kênh, bảng 5 bẫy, bảng kiểm tra tổng.
  - Kiểm tra: số trong file `.tex` sinh ra bằng số trên sheet.
- [ ] **Bước 3: Viết phần I, II, III và phụ lục D**
  - Làm: theo nội dung đã ghi ở các plan trước; đặt 3 câu hỏi riêng.
  - Kiểm tra: mỗi kết luận có nhãn nguồn.
- [ ] **Bước 4: Chuyển PDF, xem lại, lưu vào Git (commit)**
  - Kiểm tra: mở PDF xem từng trang (chuyển trang ra ảnh để xem).

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
