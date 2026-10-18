# Chạy thử làm mới ở thư mục khác với dữ liệu giả của tháng 01/2026 và một cửa hàng mới

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 2 – Nạp và làm sạch dữ liệu (chạy thử làm mới) |
| Mốc phải đạt | Mốc 4 (25/10): chạy thử làm mới đạt, trên máy khác và với dữ liệu giả của một tháng mới |
| Phần báo cáo liên quan | <ul><li>Phần II (dữ liệu và chuẩn bị: chạy lại cho tháng mới)</li><li>Phần VII (giới hạn: chưa thử trên máy thật thứ hai)</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [dax-bridge](../completed/thanhlnp-18-10-2026-dax-bridge.md)</li><li>Plan tiếp theo dùng kết quả này: `review-submit` (hướng dẫn chạy lại trong bộ file nộp)</li></ul> |

---

## 1. Mục tiêu

Chứng minh file Power Query **chạy lại được cho tháng mới chỉ bằng thay file dữ liệu rồi làm mới** (rubric Band 5), ở một thư mục khác, **không sửa truy vấn nào**: tháng 01/2026 và cửa hàng mới tự vào mọi bảng, các phép kiểm tra vẫn đạt.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - `checks/refresh_test/make_fake_month.py`: chép thư mục dữ liệu sang chỗ khác, thêm dữ liệu giả tháng 01/2026 vào 4 file (đổi tên file, giữ phần đầu tên), thêm cửa hàng mới NX068 vào danh mục, cập nhật bảng tổng kiểm soát QC_Summary (QC – Quality Control, kiểm soát chất lượng) như bên cung cấp dữ liệu sẽ làm; tự tính số mong đợi của tháng mới.
  - `excel/refresh_workbook.ps1`: mở file Excel, sửa ô `FolderPath`, làm mới toàn bộ (Data > Refresh All), lưu; có giới hạn thời gian.
  - `checks/refresh_test/check_refresh.py`: đọc file đã làm mới, so với số mong đợi và với file gốc; ghi kết quả ra `checks/refresh_test/ket_qua_2026_01.txt`.
  - Ghi kết quả vào báo cáo phần II.
- **Không làm (để cho plan khác):**
  - Chạy trên máy thật thứ hai → backlog (cần người dùng).
  - Làm mới Power BI với tháng mới: Power BI đọc file dữ liệu mentor chuẩn bị (chỉ có năm 2025), không có file tháng mới để thay → ghi ở giới hạn.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| File Power Query đã dựng | `excel/Nexa_Home_Recon_PQ.xlsx` | 30 sheet; ô `Cai_dat!B2` = thư mục dữ liệu |
| 4 file dữ liệu và file danh mục | `data/` | Lịch và 2 bảng tỷ giá trong file danh mục đã có sẵn đến 31/01/2026 |
| Cách dựng file, chống treo | `excel/build_workbook.ps1` | Chép cách giới hạn thời gian, tắt đúng tiến trình Excel |
| Backlog mục 3, 7, 8 | `plans/backlog.md` | Cách đưa file tháng mới; kiểm tra thiếu tỷ giá, thiếu ngày ghi sổ; thời gian làm mới |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Kỳ đối soát = các tháng có trong Flash (không ghi cứng năm): thêm tháng 01/2026 vào Flash thì kỳ tự dài ra 13 tháng.
- Không sửa truy vấn nào trong lúc chạy thử; nếu phải sửa thì ghi rõ là lỗi tìm được.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Script sinh dữ liệu giả, số mong đợi | `checks/refresh_test/make_fake_month.py`, `checks/refresh_test/expected_2026_01.csv` | `review-submit` |
| Script làm mới | `excel/refresh_workbook.ps1` | Hướng dẫn chạy lại cho người dùng |
| Script so và kết quả | `checks/refresh_test/check_refresh.py`, `checks/refresh_test/ket_qua_2026_01.txt` | Báo cáo phần II |
| Bản sao thư mục chạy thử | Ngoài kho (thư mục tạm của phiên làm việc), không lưu vào Git | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Sheet `Kiem_tra` (13 chỉ tiêu, so với QC_Summary mới) | 13/13 đạt | QC_Summary do script sinh dữ liệu ghi | | file đã làm mới | |
| Sheet `Chat_luong_du_lieu` | Mọi phép kiểm tra đạt (số dòng trùng thêm 1 dòng giả) | Script sinh dữ liệu | | như trên | |
| Bảng cầu nối: số tháng, dòng kiểm tra | 13 tháng; mọi bảng × tháng ≤ 1 USD | Điều kiện của plan tổng | | sheet `BR_Long`, `Canh_bao_cau_noi` | |
| 12 tháng năm 2025 của `BR_Long` | Giống hệt file gốc | `excel/Nexa_Home_Recon_PQ.xlsx` | | như trên | |
| Tháng 01/2026: Flash, sổ cái, chiết khấu, dòng trùng, đơn hủy, lệch thời điểm online, hàng trả, phí vận chuyển | Số mong đợi | `checks/refresh_test/expected_2026_01.csv` | | như trên | |
| Đối soát cửa hàng × ngày, online × ngày × loại tiền của tháng 01/2026 (kể cả NX068) | Mọi ô khớp | Dữ liệu giả sinh sổ cái đúng bằng POS và đơn online | | sheet `Doi_soat_CH_ngay`, `Doi_soat_online` | |

**Việc phải có (không phải con số):**
- [ ] Không sửa file truy vấn nào; chỉ thay file dữ liệu và sửa ô `FolderPath`.
- [ ] Bản sao nằm ở đường dẫn khác hẳn thư mục dự án.
- [ ] Ghi lại thời gian làm mới.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Dữ liệu giả sai định dạng của file thật (ngày kiểu Mỹ ở file online, dòng tiêu đề và dòng tổng ở file Flash) | Truy vấn báo lỗi hoặc nạp sai | Sinh dữ liệu bằng đúng định dạng của từng file; dòng tổng Flash chuyển xuống cuối |
| Bán ngày 31/01/2026 (thứ Bảy) thì ngày ghi sổ là 02/02/2026, lịch không có | Dòng POS không có ngày ghi sổ | Chỉ sinh ngày bán đến 30/01; ghi lại đây là giới hạn của lịch |
| Sổ cái giả không có các đơn đặt tháng 12/2025 giao tháng 01/2026 | Ô online tháng 1 lệch | Sổ cái giả ghi theo mọi đơn giao / trả trong tháng 01/2026, kể cả đơn cũ |
| Sheet `Cau_noi` của file mẫu chỉ có 12 cột tháng 2025 | Tháng 01/2026 không hiện trên file mẫu | Ghi lại là giới hạn của file mẫu; số vẫn có trong `BR_Long` |

---

## 7. Các bước

- [ ] **Bước 1: Viết `make_fake_month.py`, sinh bản sao dữ liệu và số mong đợi**
  - Kiểm tra: đọc lại các file giả bằng pandas, đúng số dòng thêm vào.
- [ ] **Bước 2: Viết `refresh_workbook.ps1`, chép file Excel sang bản sao, làm mới**
  - Kiểm tra: làm mới xong không lỗi, ghi thời gian.
- [ ] **Bước 3: Viết `check_refresh.py`, so kết quả**
- [ ] **Bước 4: Viết kết quả vào báo cáo phần II, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc file danh mục, 4 file dữ liệu | <ul><li>Lịch, tỷ giá ngày, tỷ giá cuối tháng có đến 31/01/2026</li><li>File online đã có 105 đơn giao và 7 đơn trả trong tháng 01/2026; sổ cái năm 2025 chưa có bút toán nào của tháng này</li><li>Mã cửa hàng lớn nhất NX067 (mã POS 670); NX068 còn trống</li></ul> | |

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
