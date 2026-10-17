# Power BI: mô hình dữ liệu và số tổng (Flash, sổ cái, chênh lệch)

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 5 – Kiểm tra lại bằng cách tính thứ hai (phần đầu: mô hình và số tổng) |
| Mốc phải đạt | Mốc 2 (19/10): "Power BI ra đúng số tổng" |
| Phần báo cáo liên quan | <ul><li>Phần II (Dữ liệu và chuẩn bị): mô hình dữ liệu Power BI</li><li>Phụ lục: cách kiểm chứng bằng DAX</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [python-check](../completed/thanhlnp-18-10-2026-python-check.md)</li><li>Plan tiếp theo dùng kết quả này: `dax-bridge`, `dashboard`</li></ul> |

---

## 1. Mục tiêu

Có dự án Power BI nạp file dữ liệu mentor đã chuẩn bị (`Nexa_Home_Recon_Dataset.xlsx`), nối bảng đúng slide 19, đánh dấu bảng ngày, và có các công thức DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) cho Flash, sổ cái, chênh lệch, % chênh lệch, ra **đúng số tổng cả năm và 12 tháng**.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Dự án Power BI dạng thư mục (`.pbip`, Power BI Project) trong `powerbi/`: mô hình viết bằng TMDL (Tabular Model Definition Language, ngôn ngữ mô tả mô hình bằng file chữ), báo cáo dạng PBIR (Power BI enhanced report format).
  - Nạp đủ 12 bảng của file dữ liệu mentor; nối bảng theo slide 19 và sheet README của file đó.
  - Tham số đường dẫn thư mục dữ liệu `DataFolder`.
  - 5 công thức: Flash, Sổ cái, Chênh lệch, % chênh lệch so với Flash, % chênh lệch so với sổ cái.
  - 1 trang báo cáo "Số tổng" để nhìn nhanh: 3 ô số và bảng 12 tháng.
  - Script `powerbi/dax_query.ps1` mở dự án, làm mới dữ liệu, chạy truy vấn DAX ra file CSV để so số.
  - `powerbi/README.md`: cách mở, đổi đường dẫn, làm mới.
- **Không làm (để cho plan khác):**
  - Công thức từng khoản cầu nối → `dax-bridge`.
  - Dashboard 4 trang → `dashboard`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| File dữ liệu mentor đã nối sẵn cho Power BI | `data/Nexa_Home_Recon_Dataset.xlsx` | 12 bảng: 6 bảng danh mục (dim), 4 bảng giao dịch (fact), 2 bảng tỷ giá |
| Quan hệ đề xuất | slide 19; sheet README của file trên | Ngày chủ động / bị động |
| Kết quả chạy thử Power BI | [setup-baseline](../completed/thanhlnp-18-10-2026-setup-baseline.md), mục 8 và 9 | Cách viết dự án bằng file chữ, cách hỏi số bằng DAX |
| Số chuẩn | `checks/numbers_of_record.csv` | Tổng năm, 12 tháng, theo kênh |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash.
- % hiển thị trên thẻ KPI (Key Performance Indicator, ô số liệu chính) chia cho Flash; % dùng cho cờ vượt ngưỡng chia cho |sổ cái|.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Dự án Power BI | `powerbi/NexaRecon.pbip`, `powerbi/NexaRecon.SemanticModel/`, `powerbi/NexaRecon.Report/` | `dax-bridge`, `dashboard` |
| Script hỏi số bằng DAX | `powerbi/dax_query.ps1` | So DAX với Power Query |
| Kết quả hỏi số | `powerbi/checks/totals_by_month.csv` | Bằng chứng |
| Hướng dẫn | `powerbi/README.md` | Cả nhóm |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Flash, Sổ cái, Chênh lệch cả năm | 31.124.401 / 28.698.496,23 / −2.425.904,77 | `numbers_of_record.csv` | | `powerbi/checks/totals_by_month.csv` | |
| Flash, Sổ cái, Chênh lệch từng tháng | `m01_*` … `m12_*` | `numbers_of_record.csv` | | `powerbi/checks/totals_by_month.csv` | |
| Sổ cái theo kênh (lọc qua bảng kênh) | 13.181.898,25 / 15.515.347,98 / 1.250 | `numbers_of_record.csv` | | `powerbi/checks/totals_by_channel.csv` | |
| % chênh lệch so với Flash cả năm | −7,79% | slide 3 | | `powerbi/checks/totals_by_month.csv` | |

**Việc phải có (không phải con số):**
- [ ] Quan hệ đúng slide 19: ngày ghi nhận là quan hệ chủ động; ngày bán, ngày đặt, ngày trả là quan hệ bị động; lọc một chiều từ bảng danh mục xuống bảng giao dịch; không nối thẳng 2 bảng giao dịch với nhau.
- [ ] Bảng ngày được đánh dấu là bảng ngày.
- [ ] Mở dự án trong Power BI Desktop không có lỗi; trang "Số tổng" hiện đúng số.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Nối thêm sổ cái với bảng kênh bằng quan hệ chủ động | Power BI báo có 2 đường lọc, không cho tạo | Quan hệ sổ cái → bảng kênh để bị động, kênh của sổ cái đi qua bảng cửa hàng |
| Đơn hủy không có ngày giao | Bộ lọc tháng có mục "(Blank)" | Biết trước; dashboard sẽ lọc bỏ mục trống |
| Đường dẫn dữ liệu khác nhau giữa các máy | Làm mới báo lỗi không tìm thấy file | Một tham số `DataFolder`; hướng dẫn đổi trong `powerbi/README.md` |
| Tổng sổ cái lấy cột `amount_usd` (dấu kế toán) | Sổ cái ra số âm | Dùng cột `revenue_usd` (đã đổi dấu) |

---

## 7. Các bước

- [ ] **Bước 1: Viết mô hình bằng TMDL**
  - Làm: 12 bảng, quan hệ, bảng ngày, tham số `DataFolder`, bảng `_Measures` chứa 5 công thức.
  - Kiểm tra: mở dự án trong Power BI Desktop không báo lỗi.
- [ ] **Bước 2: Trang báo cáo "Số tổng"**
  - Làm: 3 ô số (Flash, Sổ cái, Chênh lệch) và bảng 12 tháng.
  - Kiểm tra: chụp cửa sổ Power BI, thấy đủ số.
- [ ] **Bước 3: Script hỏi số và so với số chuẩn**
  - Làm: `powerbi/dax_query.ps1`; truy vấn tổng theo tháng và theo kênh, lưu CSV; so bằng Python.
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [ ] **Bước 4: Hướng dẫn, ghi phần cho báo cáo, lưu vào Git (commit)**
  - Làm: `powerbi/README.md`; nội dung phần II, phụ lục vào mục 12.
  - Kiểm tra: lời nhắn khi lưu bắt đầu bằng `powerbi-totals:`.

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
