# File mẫu nộp lấy số từ bảng cầu nối, nhật ký ngoại lệ, bảng so khi đổi thứ tự các bước

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 4 – Bảng cầu nối và nhật ký ngoại lệ (file mẫu nộp, nhật ký) |
| Mốc phải đạt | Mốc 4 (25/10) |
| Phần báo cáo liên quan | <ul><li>Phần IV.4 (đoạn cuối: file mẫu nộp, nhật ký)</li><li>Phụ lục B (nhật ký ngoại lệ đầy đủ)</li><li>Phụ lục E (so sánh khi đổi thứ tự các bước)</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [bridge-monthly](../completed/thanhlnp-18-10-2026-bridge-monthly.md)</li><li>Plan tiếp theo dùng kết quả này: `dashboard` (trang nhật ký), `conclusions` (đề xuất theo người phụ trách), `review-submit` (bộ file nộp)</li></ul> |

---

## 1. Mục tiêu

Điền **file mẫu nộp của đề** (sheet `Cau_noi`, `Nhat_ky_ngoai_le`) mà **không gõ tay ô số nào**: ô vàng lấy số từ bảng cầu nối dạng dài bằng công thức SUMIFS, nhật ký ngoại lệ sinh từ một truy vấn. Thêm bảng cho thấy số của từng khoản đổi thế nào nếu đổi thứ tự các bước, để giải thích vì sao nhóm chốt thứ tự hiện tại.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - `q_ExceptionLog`: nhật ký ngoại lệ, mỗi khoản lệch một dòng, đủ 10 cột của file mẫu; số tiền và mô tả lấy từ các bảng đã có; tổng cột tiền = tổng chênh lệch cả năm.
  - `q_OrderSwap`: 3 cách đổi thứ tự các bước, mỗi cách cho số cũ và số mới của hai khoản bị ảnh hưởng; tổng không đổi.
  - Sửa `excel/build_workbook.ps1`: chép sheet `Cau_noi` và `Nhat_ky_ngoai_le` của file mẫu vào file Power Query; ô vàng dùng SUMIFS đọc bảng `q_BR_Long`; thêm `Cau_noi_cua_hang`, `Cau_noi_online` cùng bố cục (thêm 1 dòng chuyển kênh); nhật ký dùng công thức INDEX đọc bảng `q_ExceptionLog`, bỏ dòng ví dụ EX-00.
  - Viết đoạn cuối phần IV.4, phụ lục B và E.
- **Không làm (để cho plan khác):**
  - Tạo bản sao file nộp riêng và đóng gói → `review-submit`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| File mẫu nộp | `data/Mau_nop_Bang_cau_noi.xlsx` | Sheet `Huong_dan`, `Cau_noi` (A1:N16, ô vàng B2:M13 và B15:M15), `Nhat_ky_ngoai_le` (10 cột, dòng ví dụ EX-00) |
| Bảng cầu nối | `excel/queries/q_BR_Long.m` | 708 dòng |
| Danh mục khoản | `excel/queries/q_BridgeItems.m` | Tên, nhóm |
| Các bảng đối soát | `q_RC_Store*.m`, `q_Web_Timing.m`, `q_DataQuality.m` | Chi tiết cho cột mô tả |
| Slide 31, 40 | `docs/other_resources/[Slide_v2]-Project1-Sales-Domain.pdf` | Cách xử lý từng nhóm; mẫu nhật ký và 4 trạng thái: Cần sửa nguồn, Đã sửa kỳ sau, Đã giải thích, Chờ phản hồi |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Mục 3 của file quy ước: các dòng phải có trong nhật ký, nhãn nhóm đúng chữ "Quy tắc ghi nhận · Lỗi dữ liệu · Chưa giải thích được · Sai số chấp nhận".
- Dấu theo file mẫu: khoản làm Flash cao hơn sổ cái ghi số âm.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| 2 truy vấn | `excel/queries/q_ExceptionLog.m`, `q_OrderSwap.m` | Dashboard, báo cáo |
| Sheet `Cau_noi`, `Cau_noi_cua_hang`, `Cau_noi_online`, `Nhat_ky_ngoai_le`, `Nhat_ky_du_lieu`, `Doi_thu_tu` | `excel/Nexa_Home_Recon_PQ.xlsx` | Bộ file nộp |
| Đoạn cuối IV.4, phụ lục B, E | `report/sections/04_phan_tich_chinh.tex`, `09_phu_luc.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| `Cau_noi` dòng 16 (kiểm tra) 12 tháng và cả năm | 0 | file mẫu | | sheet `Cau_noi` (đọc lại bằng Excel sau khi tính) | |
| `Cau_noi` cột cả năm: Flash / sổ cái / chưa giải thích | 31.124.401 / 28.698.496,23 / 1.250 | `br_y_*` | | như trên | |
| `Cau_noi_cua_hang`, `Cau_noi_online` dòng kiểm tra | 0 | | | 2 sheet đó | |
| Tổng cột tiền của nhật ký | −2.425.904,77 | `tot_delta` | | sheet `Nhat_ky_du_lieu` | |
| Đổi thứ tự: dòng trùng theo giá trước giảm giá | −13.695,13 | file quy ước | | sheet `Doi_thu_tu` | |
| Đổi thứ tự: hàng trả theo tỷ giá ngày trả | −349.652,76 | `det_returns_return_date_rate` | | như trên | |

**Việc phải có (không phải con số):**
- [ ] Không ô số nào trong `Cau_noi*` và `Nhat_ky_ngoai_le` gõ tay; dòng EX-00 đã xóa.
- [ ] Nhật ký có đủ các dòng ở mục 3 file quy ước; mỗi dòng có người phụ trách và trạng thái theo slide 40.
- [ ] Mọi bước có tên tiếng Việt và ghi chú `//`; không ghi cứng năm trong truy vấn.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| File mẫu có 10 dòng khoản, bảng theo kênh có 11 khoản | Thiếu dòng chuyển kênh, kiểm tra khác 0 ở tháng 6 | Chèn 1 dòng vào sheet theo kênh; kiểm tra dòng 16/17 bằng 0 |
| Công thức tham chiếu sai tên bảng | `#REF!` hoặc 0 khắp nơi | Đọc lại giá trị đã tính bằng pandas sau khi dựng |
| Nhật ký đếm trùng (ví dụ ghi cả lệch thời điểm cả năm lẫn hai phần vắt qua năm) | Tổng cột tiền khác tổng chênh lệch | Thiết kế để tổng nhật ký = tổng chênh lệch; kiểm tra bằng pandas |

---

## 7. Các bước

- [ ] **Bước 1: Viết `q_ExceptionLog`, `q_OrderSwap`**
  - Kiểm tra: tổng nhật ký = −2.425.904,77; 3 dòng đổi thứ tự có tổng thay đổi = 0.
- [ ] **Bước 2: Sửa `build_workbook.ps1` để chép và điền file mẫu**
  - Kiểm tra: dòng kiểm tra của 3 sheet cầu nối bằng 0; nhật ký hiện đủ dòng.
- [ ] **Bước 3: Viết báo cáo (IV.4 đoạn cuối, phụ lục B, E), lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc file mẫu nộp bằng openpyxl, đọc slide 10, 31, 40 | <ul><li>`Cau_noi`: 10 dòng khoản + "Chưa giải thích được"; dòng 14 cộng, dòng 16 = ROUND(dòng 14 − dòng 15, 2)</li><li>Nhật ký 10 cột; slide 40 có 4 trạng thái và ví dụ EX-02, EX-06, EX-07, EX-10</li></ul> | |

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
