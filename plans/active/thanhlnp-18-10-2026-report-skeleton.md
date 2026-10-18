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
| Số trong bảng phần II, III bằng số trên sheet Excel | khớp 100% | `excel/Nexa_Home_Recon_PQ.xlsx` | Bảng sinh tự động bằng script đọc thẳng sheet, không gõ tay | `report/generated/*.tex` | Đạt |
| Chênh lệch cả năm nêu trong phần III | −2.425.904,77 (−7,79%) | sheet `Chenh_lech_thang` | −2.425.904,77 (−7,79%), lấy qua lệnh `\SoChenhLechNam`, `\SoPctNam` sinh từ sheet | `report/generated/so_lieu.tex` | Đạt |

**Việc phải có (không phải con số):**
- [x] PDF có đủ 8 phần đánh số I–VIII + phụ lục, mục lục, trang bìa đúng đề tài.
- [x] Biên dịch không có lỗi LaTeX (chỉ cảnh báo nhỏ).
- [x] Phần I có 3 câu hỏi của Giám đốc Tài chính và 3 câu hỏi riêng, mỗi câu riêng có thước đo và bảng nguồn.
- [x] Không còn nội dung Steel Plates.

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

- [x] **Bước 1: Dựng khung `report/`**
  - Làm: chép khai báo từ file mẫu; đổi tên đề tài, tác giả; 10 file phần (tóm tắt, I–VIII, phụ lục); `references.bib`.
  - Kiểm tra: chuyển ra PDF được.
- [x] **Bước 2: Script sinh hình và bảng**
  - Làm: đọc file Excel Power Query, sinh hình chênh lệch theo tháng, bảng tháng, bảng kênh, bảng 5 bẫy, bảng kiểm tra tổng.
  - Kiểm tra: số trong file `.tex` sinh ra bằng số trên sheet.
- [x] **Bước 3: Viết phần I, II, III và phụ lục D**
  - Làm: theo nội dung đã ghi ở các plan trước; đặt 3 câu hỏi riêng.
  - Kiểm tra: mỗi kết luận có nhãn nguồn.
- [x] **Bước 4: Chuyển PDF, xem lại, lưu vào Git (commit)**
  - Kiểm tra: mở PDF xem từng trang (chuyển trang ra ảnh để xem).

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Dựng `report/main.tex` từ 681 dòng khai báo của file mẫu (đổi tên đề tài, tác giả); thêm lệnh chú thích bảng `\captab`, nhãn nguồn `\nguon`, ghi chú phần chưa viết `\choviet` | Khung 8 phần + phụ lục A–F | |
| 18/10 | Viết `report/figures_src/make_figures.py`: đọc 4 sheet của file Excel Power Query, sinh 1 hình, 4 bảng và 14 lệnh số liệu | Hình chênh lệch theo tháng: cột xám, tháng 3 tô màu nhấn, tiêu đề nói kết luận | |
| 18/10 | Viết phần I, II, III, tóm tắt, phụ lục C, D, F; chuyển PDF | 14 trang | <ul><li>Lỗi 1: dấu trừ Unicode "−" chưa khai báo trong LaTeX → script đổi sang `$-$`, thêm khai báo cho phép gõ dấu này</li><li>Lỗi 2: file mẫu chuyển sang tiếng Anh khi in danh mục tham khảo nên chữ Việt trong danh mục bị lỗi → bỏ lệnh chuyển ngôn ngữ</li><li>Cảnh báo "undefined references / rerun BibTeX" vẫn còn; dựng thử file mẫu gốc cũng có đúng cảnh báo này, số thứ tự tham khảo vẫn hiện đúng → chấp nhận</li></ul> |
| 18/10 | Xem lại PDF (chuyển các trang ra ảnh) | <ul><li>Bảng kiểm tra tổng tràn lề → gộp cột tên file thành cột nguồn ngắn</li><li>Chú thích hình nằm cạnh sơ đồ → xuống dòng</li><li>Chú thích bảng tách khỏi bảng → đặt bảng nhỏ trong môi trường giữ liền khối</li></ul> | Sau khi sửa: bố cục ổn |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Ba câu hỏi riêng của nhóm (Q1 phần hợp lệ / lỗi / chưa giải thích; Q2 tháng nào còn lệch sau khi trừ quy tắc ghi nhận; Q3 lệch thời điểm có tự bù trừ không, bao nhiêu vắt qua năm) | <ul><li>Cả 3 đều về chênh lệch và quy trình, không trôi sang phân tích kinh doanh</li><li>Mỗi câu đo được bằng một bảng cụ thể (cầu nối, đối soát)</li><li>Trả lời được câu hỏi "ai cần làm gì" chứ không chỉ "lệch bao nhiêu"</li></ul> | Không |
| 18/10 | Số trong lời văn lấy qua lệnh LaTeX sinh từ file Excel (`report/generated/so_lieu.tex`) | Làm mới dữ liệu thì chạy lại script là lời văn đổi theo, không sót số cũ | Không |
| 18/10 | Thêm phần "Tóm tắt" ngay dưới trang bìa | Rubric Band 5: người ngoài đọc 1 phút hiểu lệch bao nhiêu, vì sao, ai cần làm gì | Không |
| 18/10 | Trang bìa để chỗ trống tên 2 thành viên và tên mentor | AI không biết tên; ghi `plans/backlog.md` mục 5 | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Dựng khung báo cáo, viết phần I–III, script sinh hình và bảng | `report/main.tex` (phần thêm), `report/sections/*.tex`, `report/figures_src/make_figures.py` | <ul><li>Bảng và số trong lời văn sinh từ file Excel, không gõ tay</li><li>Nhóm cần đọc lại phần I–III, sửa câu chữ theo giọng của nhóm (rubric Band 5)</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Câu hỏi riêng của nhóm khác gì 3 câu hỏi của Giám đốc Tài chính?
   **Trả lời:** 3 câu của Giám đốc Tài chính hỏi "lệch bao nhiêu, gồm gì, sửa quy trình gì". 3 câu của nhóm hỏi phần nào cần hành động: bao nhiêu là hợp lệ, bao nhiêu là lỗi (Q1); tháng nào thật sự cần điều tra sau khi trừ phần hợp lệ (Q2); phần lệch thời điểm có tự hết ở tháng sau không (Q3). Mỗi câu đo bằng một bảng cụ thể, ghi trong Bảng 1 của báo cáo.
2. **Hỏi:** Số trong báo cáo lấy từ đâu, có gõ tay không?
   **Trả lời:** Bảng và số trong lời văn được script `report/figures_src/make_figures.py` sinh ra từ file Excel Power Query sau khi làm mới. Mỗi kết luận có nhãn nguồn (ví dụ `[QC]`, `[BR-Tổng]`), tra ở Phụ lục C.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 2 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** tóm tắt (tạm), phần I, II, III, phụ lục C, D, F (phần mở đầu).
- **Việc còn lại:**
  - Phần IV.1–IV.6 → `store-recon`, `web-return-recon`, `bridge-monthly`, `bridge-template-log`, `dax-bridge`, `dashboard`.
  - Phần V–VII, viết lại tóm tắt → `conclusions`.
  - Phụ lục A (mã M), B (nhật ký ngoại lệ), E (đổi thứ tự bước), F (bảng khai báo AI đầy đủ) → `report-draft`, `bridge-template-log`.
  - Phụ lục D đang lấy số của nhóm từ bảng kiểm tra Python → thay bằng số Power Query ở `bridge-monthly`.
  - Tên thành viên và mentor trên trang bìa → `plans/backlog.md` mục 5.
- **Các lần lưu vào Git (commit):** `3d9b306` (tạo plan), `50f31b8` (khung), `abc2770` (script sinh bảng, hình), `68a705c` (phần I–III), `dc67328` (PDF đầu tiên), và các lần lưu đóng plan.
