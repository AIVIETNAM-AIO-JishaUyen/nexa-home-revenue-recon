# Dashboard Power BI 4 trang theo yêu cầu của đề

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 6 – Dashboard 4 trang |
| Mốc phải đạt | Mốc 5 (29/10) |
| Phần báo cáo liên quan | Phần IV.6 (dashboard) |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [dax-bridge](../completed/thanhlnp-18-10-2026-dax-bridge.md) (công thức từng khoản, cờ vượt ngưỡng)</li><li>Plan tiếp theo dùng kết quả này: `conclusions`, `review-submit` (ảnh chụp, file nộp)</li></ul> |

---

## 1. Mục tiêu

Dựng dashboard Power BI 4 trang (Tổng quan · Cầu nối · Đối soát chi tiết · Hoàn trả, hủy và chất lượng dữ liệu) đúng [yêu cầu dashboard](../../docs/yeu_cau_dashboard.md). Giám đốc Tài chính nhìn trang 1 là biết chênh lệch bao nhiêu, bao nhiêu là quy tắc ghi nhận, bao nhiêu là lỗi; kế toán xuống trang 3 là thấy đúng ô cửa hàng × ngày còn lệch.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Thêm công thức DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) cho dashboard: tổng theo nhóm lệch, so với tháng trước, câu "Điểm chính" và tiêu đề biểu đồ có số, màu tô đỏ khi vượt ngưỡng, đối soát cửa hàng × ngày, hàng trả, đơn hủy.
  - Đọc thêm bảng kiểm tra chất lượng dữ liệu từ file Power Query (bảng `q_DataQuality`).
  - Sửa `powerbi/build_report.py` sinh 4 trang (bỏ trang "Số tổng" cũ, số tổng nằm ở trang 1); bộ lọc tháng, kênh, quốc gia dùng chung 4 trang.
  - Mở Power BI, làm mới, chụp ảnh 4 trang vào `powerbi/checks/`; hỏi số bằng DAX để đối chiếu vài ô với Power Query.
  - Viết phần IV.6.
- **Không làm (để cho plan khác):**
  - Gói file nộp (zip dự án Power BI) → `review-submit`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Yêu cầu dashboard | `docs/yeu_cau_dashboard.md` (slide 11–14) | KPI (Key Performance Indicator, ô số liệu chính) và biểu đồ bắt buộc từng trang |
| Bản mẫu của mentor (người hướng dẫn) | `docs/template/Nexa_Home_Recon_Dashboard.html` | Bố cục tham khảo |
| Mô hình Power BI | `powerbi/NexaRecon.SemanticModel/` | 37 công thức (plan `powerbi-totals`, `dax-bridge`) |
| Script sinh trang | `powerbi/build_report.py` | Hiện có 1 trang "Số tổng" |
| Cấu trúc JSON (JavaScript Object Notation, file chữ lưu dữ liệu có cấu trúc) các loại hình | Bản mẫu PBIR (Power BI enhanced report format) chính thức, đã tải ở plan `setup-baseline` | Thư mục tạm của phiên làm việc |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash, cùng dấu ở mọi trang; % trên thẻ KPI chia cho Flash.
- Ngưỡng tô đỏ: phần còn lại sau quy tắc ghi nhận > 200 USD (đô la Mỹ) một tháng; ô cửa hàng × tháng: 200 USD và 1% của |sổ cái|.
- 4 nhóm: Quy tắc ghi nhận · Lỗi dữ liệu · Chưa giải thích được · Sai số chấp nhận.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Công thức dashboard, bảng chất lượng dữ liệu | `powerbi/NexaRecon.SemanticModel/definition/` | |
| 4 trang báo cáo | `powerbi/build_report.py` → `powerbi/NexaRecon.Report/definition/` | `review-submit` |
| Ảnh 4 trang | `powerbi/checks/dashboard_trang_1.png` … `_4.png` | Báo cáo IV.6 |
| Phần IV.6 | `report/sections/04_phan_tich_chinh.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Trang 1, tháng 12/2025: Flash / sổ cái / chênh lệch | 3.481.253 / 3.222.760,41 / −258.492,59 | `checks/numbers_of_record.csv` (`m12_flash`, `m12_gl`, `m12_delta`) | 3.481.253 / 3.222.760,41 / −258.492,59 | Truy vấn DAX `powerbi/checks/dashboard_numbers.dax` → `.csv` | Đạt |
| Trang 1, cả năm: quy tắc ghi nhận / lỗi dữ liệu / chưa giải thích / sai số chấp nhận | −2.414.533,58 / −12.622,20 / 1.250 / 1,01 | Tổng theo nhóm của `BR_Long` (`excel/Nexa_Home_Recon_PQ.xlsx`) | −2.414.533,58 / −12.622,20 / 1.250 / 1,01 | như trên | Đạt |
| Trang 3: số ô cửa hàng × ngày; số ô lệch theo ngày ghi sổ / theo ngày bán | 5.120; 2; 2.929 | Plan `store-recon` | 5.120; 2; 2.929 | như trên | Đạt |
| Trang 4: số dòng POS (Point of Sale, bán tại cửa hàng) trùng / số đơn hủy / số bút toán tay | 12 / 124 (đặt trong năm) / 15 | `checks/numbers_of_record.csv` (`det_cancelled_orders_2025`, `det_manual_entries`); plan `transactions-quality` | 12 / 124 / 15 | như trên | Đạt |
| Online tháng 11: chênh lệch theo ngày đặt / theo ngày giao | −12.064,26 / −0,01 | Sheet `Doi_soat_online_thang` (plan `web-return-recon`) | −12.064,26 / −0,01 | như trên | Đạt |
| Công thức Flash mới (lọc theo nước) không làm lệch bảng cầu nối | 709 ô khớp, 137 → 2 | Plan `dax-bridge` | Chạy lại 3 truy vấn so: kết quả không đổi | `powerbi/checks/*_compare.csv` | Đạt |

**Việc phải có (không phải con số):**
- [x] 4 trang mở được trong Power BI Desktop, không có hình lỗi; có ảnh chụp từng trang.
- [x] Mỗi trang có câu "Điểm chính", KPI có so với tháng trước, tiêu đề biểu đồ nói kết luận kèm số, dòng nguồn và ngày lấy dữ liệu ở cuối.
- [x] Bộ lọc tháng (mặc định 12/2025), kênh, quốc gia dùng chung 4 trang.
- [x] Không có biểu đồ tròn, vành khuyên, 3D; màu đỏ chỉ cho ô vượt ngưỡng.
- [x] Trang 2 có ô đối chiếu DAX – Power Query theo tháng.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Bộ lọc tháng làm biểu đồ 12 tháng chỉ còn 1 cột | Biểu đồ xu hướng chỉ có 1 điểm | Tắt tác động của bộ lọc tháng lên các biểu đồ 12 tháng (`visualInteractions`) |
| Công thức `Cầu nối (DAX)` chỉ trả số khi chọn đúng 1 khoản | Thác nước theo nhóm trống | Viết công thức cộng các khoản (`SUMX` trên danh mục khoản) |
| Chọn một nước: Flash không nối với bảng cửa hàng | Flash không đổi theo nước, chênh lệch sai | Flash lọc theo cột thị trường khi có chọn nước, chỉ kênh cửa hàng |
| JSON của trang viết tay sai cấu trúc | Power BI báo "Issues were found" hoặc mở báo cáo trống | Theo đúng bản mẫu chính thức; mở thử sau mỗi trang |

---

## 7. Các bước

- [x] **Bước 1: Công thức DAX cho dashboard, bảng chất lượng dữ liệu; hỏi số để kiểm**
- [x] **Bước 2: Trang 1 và 2 trong `build_report.py`; mở thử, chụp ảnh**
- [x] **Bước 3: Trang 3 và 4; mở thử, chụp ảnh**
- [x] **Bước 4: Viết phần IV.6, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc yêu cầu dashboard, script sinh trang, bản mẫu PBIR | Lược đồ trang PBIR có `visualInteractions` (đặt bộ lọc không tác động lên một hình) | |
| 18/10 | Viết 75 công thức thư mục "5. Dashboard", 3 cột tính, bảng `pq_data_quality`; sửa công thức `Flash` để lọc theo nước | Truy vấn `dashboard_numbers.dax`: mọi số ở mục 5 khớp | <ul><li>Lần làm mới đầu báo phụ thuộc vòng tròn: cột thứ tự nhóm tính từ cột tên nhóm, trong khi cột tên nhóm lại sắp theo cột thứ tự. Sửa: cột thứ tự tính thẳng từ mã khoản và nhóm</li><li>Các tiêu đề duyệt từng tháng dùng `REMOVEFILTERS ( dim_date )` sẽ xóa luôn tháng đang duyệt; sửa bằng cách giữ tháng trong biến</li><li>Câu "Điểm chính" in "chưa giải thích được  USD" khi nhóm trống; sửa công thức nhóm trả về 0</li></ul> |
| 18/10 | Viết lại `build_report.py`: 4 trang, 80 hình; mở Power BI, chụp từng trang | Cả 4 trang mở được, không có hình lỗi | <ul><li>Lần đầu: số tự rút gọn thành K/M, chú thích tiếng Anh, tên trục là tên cột, dòng "Total" trên bảng, câu "Điểm chính" bị cắt, biểu đồ 12 tháng hiện cả tháng ngoài kỳ</li><li>Sửa: hiện đủ số, ẩn chú thích và tên trục, đặt tên cột tiếng Việt, bỏ dòng tổng, đưa câu "Điểm chính" thành một dòng riêng trải hết chiều ngang, lọc tháng đối soát cho biểu đồ 12 tháng</li><li>Script chụp lấy nhầm cửa sổ nhỏ cùng tên; sửa thành chờ tải xong rồi lấy cửa sổ lớn nhất</li></ul> |
| 18/10 | Chạy lại 3 truy vấn so của plan `dax-bridge`, xuất lại `dax_measures.dax` (112 công thức), viết IV.6 và phụ lục F | Kết quả so không đổi | |
| 18/10 | Rà soát plan: đối chiếu yêu cầu dashboard với ảnh chụp và `build_report.py`, so số với số chuẩn và Power Query, đọc lại công thức và lời văn | <ul><li>Mọi số đọc được trên 4 ảnh (tháng 12/2025 và 12 tháng) và trong `dashboard_numbers.csv` khớp `numbers_of_record.csv` và các sheet `BR_Long`, `Doi_soat_online_thang`, `So_ngay_ban_ngay_ghi_so`, `Doi_soat_CH_thang`</li><li>Đã sửa lời: ghi chú 4 công thức, `powerbi/README.md`, chú thích Hình 5 và 6, thêm câu "chưa làm" ở IV.6; ghi backlog mục 11, làm rõ mục 10</li></ul> | Công thức cần sửa, chưa sửa vì phải mở Power BI để kiểm lại:<ul><li>Tháng 01/2025: các ô "So với tháng trước" của nhóm lệch, số đơn hủy, dòng POS trùng, bút toán tay so với tháng 12/2024 (ra 0 vì công thức có "+ 0") thay vì ghi "Tháng đầu kỳ"</li><li>Tháng không còn ô lệch (tháng 1 đến tháng 10): câu "Điểm chính" trang 3 ra "thì còn  ô", tiêu đề bảng ô còn lệch mất số, vì công thức đếm trả về ô trống thay cho 0</li><li>Chọn một nước: bảng đối chiếu DAX – Power Query trang 2 báo lệch giả, vì bảng cầu nối Power Query không có số theo nước</li></ul> |
| 18/10 | Sửa theo rà soát: 17 công thức "so với tháng trước" (tháng đầu kỳ, tỷ lệ hàng trả không đổi), câu "Điểm chính" trang 3, 4 và tiêu đề ô còn lệch khi trống, đối chiếu DAX – Power Query khi chọn nước, cờ ⚠ khi chọn nhiều tháng, bỏ mục trống ở danh sách nước | Thêm 9 trường hợp biên vào `dashboard_numbers.dax` (tháng 01/2025, tháng 06/2025, chọn online, chọn cửa hàng, chọn Canada): câu chữ đúng ở mọi trường hợp | Lần mở đầu báo lỗi thụt lề trong file `.tmdl` (dòng nối tiếp thiếu 3 tab); sửa xong mở bình thường |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Câu "Điểm chính" và tiêu đề biểu đồ là công thức DAX | Đổi tháng hay kênh thì lời đổi theo, không phải sửa tay; đúng yêu cầu "tiêu đề nói luôn kết luận kèm con số" | Không |
| 18/10 | Biểu đồ 12 tháng không bị bộ lọc tháng tác động; chưa làm phần "tháng đang chọn có nhãn / cột tháng đang chọn tô màu" | <ul><li>Bộ lọc tháng mặc định 12/2025, nếu tác động thì biểu đồ xu hướng chỉ còn 1 điểm</li><li>Đã tắt tác động thì hình không biết tháng nào đang chọn; muốn tô tháng đang chọn phải dựng bảng tháng riêng không nối với dữ liệu và viết lại mọi công thức. Ghi vào backlog</li></ul> | Không |
| 18/10 | Thác nước trang 2 bỏ cột Flash, đi từ 0 đến tổng chênh lệch | Flash 3,5 triệu USD làm các khoản (vài nghìn đến vài trăm nghìn) gần như không thấy; Flash và sổ cái đã có ở ô số liệu chính | Không |
| 18/10 | Khi chọn nước, Flash lấy dòng Flash cửa hàng có thị trường là nước đó | Flash không nối với bảng cửa hàng; online chia theo 5 thị trường nên bỏ, đúng yêu cầu "chọn một nước thì bỏ kênh online" | Không |
| 18/10 | Số trên dashboard theo kiểu Anh – Mỹ (vùng en-US của mô hình) | Đổi vùng của mô hình sẽ ảnh hưởng cách đọc số trong các bước nạp; ghi rõ ở chú thích hình | Không |
| 18/10 | Chưa làm nút "Đặt lại" bộ lọc | Nút cần dấu trang (bookmark) lưu trạng thái mặc định; dạng file chữ của dấu trang phức tạp, chưa thử. Ghi vào backlog | Không |
| 18/10 | Bảng 13 phép kiểm tra dữ liệu ở trang 4 là số cả năm | Bảng đọc từ Power Query, không nối với bảng ngày; tiêu đề ghi rõ "cả năm" | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết công thức dashboard, script sinh 4 trang, script chụp ảnh, mục IV.6 | Thư mục "5. Dashboard" trong `_Measures.tmdl`, `pq_data_quality.tmdl`, `build_report.py`, `dashboard_numbers.dax`, mục IV.6 và phụ lục F | <ul><li>So số với `numbers_of_record.csv` và Power Query (mục 5)</li><li>Xem ảnh chụp từng trang</li><li>Chạy lại các truy vấn so của plan `dax-bridge`</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Giám đốc Tài chính mở dashboard thì thấy gì đầu tiên?
   **Trả lời:** Câu "Điểm chính" của tháng đang chọn, ví dụ tháng 12/2025: sổ cái thấp hơn Flash 258.493 USD (−7,4%), quy tắc ghi nhận giải thích −265.721, lỗi dữ liệu +7.228, chưa giải thích 0. Bên dưới là 5 ô số liệu chính có mức thay đổi so với tháng trước, rồi thác nước Flash → 4 nhóm → sổ cái.
2. **Hỏi:** Tiêu đề biểu đồ có tự đổi khi đổi bộ lọc không?
   **Trả lời:** Có, vì tiêu đề là công thức DAX. Ví dụ tiêu đề "4 tháng còn lệch quá 200 USD sau khi trừ quy tắc ghi nhận" tự đếm lại khi chọn kênh khác.
3. **Hỏi:** Kế toán muốn xem đúng ô nào lệch?
   **Trả lời:** Trang 3, bảng góc dưới phải: các ô cửa hàng × ngày ghi sổ còn lệch sau khi đưa về cùng cách tính (năm 2025 chỉ còn 2 ô của NX057). Bấm một dòng thì các hình khác lọc theo ô đó.
4. **Hỏi:** Làm sao biết số trên dashboard đúng?
   **Trả lời:** Trang 2 có bảng đối chiếu DAX – Power Query từng tháng (lệch 0,00). Ngoài ra truy vấn `dashboard_numbers.dax` so các số chính với số chuẩn và Power Query.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 6 dòng số và 5 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục IV.6 (Hình 5, 6: trang 1, 2), phụ lục F (Hình 7, 8: trang 3, 4).
- **Việc còn lại:**
  - Nút "Đặt lại" bộ lọc, tô tháng đang chọn trên biểu đồ 12 tháng → backlog mục 10.
  - Gói dự án Power BI vào bộ file nộp, lưu thêm `.pbix` → `review-submit` (backlog mục 2).
- **Các lần lưu vào Git (commit):** `9e55e64` (tạo plan), `54f9526` (công thức dashboard), `3123957` (4 trang, ảnh chụp, truy vấn số), `34b76c3` (`powerbi/README.md`), `9cfa7a0` (báo cáo IV.6, phụ lục F), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
