# Dashboard Power BI 4 trang theo yêu cầu của đề

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 6 – Dashboard 4 trang |
| Mốc phải đạt | Mốc 5 (29/10) |
| Phần báo cáo liên quan | Phần IV.6 (dashboard) |
| Trạng thái | Đang làm |
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
| Cấu trúc JSON các loại hình | Bản mẫu PBIR (Power BI enhanced report format) chính thức, đã tải ở plan `setup-baseline` | Thư mục tạm của phiên làm việc |

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
| Trang 1, tháng 12/2025: Flash / sổ cái / chênh lệch | Số chuẩn tháng 12 | `checks/numbers_of_record.csv` | | Truy vấn DAX `powerbi/checks/dashboard_numbers.dax` | |
| Trang 1, cả năm: quy tắc ghi nhận / lỗi dữ liệu / chưa giải thích / sai số chấp nhận | Tổng theo nhóm của `BR_Long` | `excel/Nexa_Home_Recon_PQ.xlsx` | | như trên | |
| Trang 3: số ô cửa hàng × ngày; số ô lệch theo ngày ghi sổ / theo ngày bán | 5.120; 2; 2.929 | Plan `store-recon` | | như trên | |
| Trang 4: số dòng POS trùng / số đơn hủy / số bút toán tay | 12 / 124 (đặt trong năm) / 15 | Plan `transactions-quality`, `web-return-recon` | | như trên | |

**Việc phải có (không phải con số):**
- [ ] 4 trang mở được trong Power BI Desktop, không có hình lỗi; có ảnh chụp từng trang.
- [ ] Mỗi trang có câu "Điểm chính", KPI có so với tháng trước, tiêu đề biểu đồ nói kết luận kèm số, dòng nguồn và ngày lấy dữ liệu ở cuối.
- [ ] Bộ lọc tháng (mặc định 12/2025), kênh, quốc gia dùng chung 4 trang.
- [ ] Không có biểu đồ tròn, vành khuyên, 3D; màu đỏ chỉ cho ô vượt ngưỡng.
- [ ] Trang 2 có ô đối chiếu DAX – Power Query theo tháng.

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

- [ ] **Bước 1: Công thức DAX cho dashboard, bảng chất lượng dữ liệu; hỏi số để kiểm**
- [ ] **Bước 2: Trang 1 và 2 trong `build_report.py`; mở thử, chụp ảnh**
- [ ] **Bước 3: Trang 3 và 4; mở thử, chụp ảnh**
- [ ] **Bước 4: Viết phần IV.6, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc yêu cầu dashboard, script sinh trang, bản mẫu PBIR | Lược đồ trang PBIR có `visualInteractions` (đặt bộ lọc không tác động lên một hình) | |

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
