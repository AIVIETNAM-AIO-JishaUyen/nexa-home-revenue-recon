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
| Flash, Sổ cái, Chênh lệch cả năm | 31.124.401 / 28.698.496,23 / −2.425.904,77 | `numbers_of_record.csv` | 31.124.401 / 28.698.496,23 / −2.425.904,77 | `powerbi/checks/totals_by_month.csv`, dòng Cả năm | Đạt |
| Flash, Sổ cái, Chênh lệch từng tháng | `m01_*` … `m12_*` | `numbers_of_record.csv` | Khớp cả 12 tháng (lệch ≤ 0,005) | `powerbi/checks/totals_by_month.csv` | Đạt |
| Sổ cái theo kênh (lọc qua bảng kênh) | 13.181.898,25 / 15.515.347,98 / 1.250 | `numbers_of_record.csv` | 13.181.898,25 / 15.515.347,98 / 1.250; Flash theo kênh cũng khớp | `powerbi/checks/totals_by_channel.csv` | Đạt |
| % chênh lệch so với Flash cả năm | −7,79% | slide 3 | −7,794% | `powerbi/checks/totals_by_month.csv` | Đạt |

**Việc phải có (không phải con số):**
- [x] Quan hệ đúng slide 19: ngày ghi nhận là quan hệ chủ động; ngày bán, ngày đặt, ngày trả là quan hệ bị động; lọc một chiều từ bảng danh mục xuống bảng giao dịch; không nối thẳng 2 bảng giao dịch với nhau.
- [x] Bảng ngày được đánh dấu là bảng ngày.
- [x] Mở dự án trong Power BI Desktop không có lỗi; trang "Số tổng" hiện đúng số.

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

- [x] **Bước 1: Viết mô hình bằng TMDL**
  - Làm: 12 bảng, quan hệ, bảng ngày, tham số `DataFolder`, bảng `_Measures` chứa 5 công thức.
  - Kiểm tra: mở dự án trong Power BI Desktop không báo lỗi.
- [x] **Bước 2: Trang báo cáo "Số tổng"**
  - Làm: 3 ô số (Flash, Sổ cái, Chênh lệch) và bảng 12 tháng.
  - Kiểm tra: chụp cửa sổ Power BI, thấy đủ số.
- [x] **Bước 3: Script hỏi số và so với số chuẩn**
  - Làm: `powerbi/dax_query.ps1`; truy vấn tổng theo tháng và theo kênh, lưu CSV; so bằng Python.
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [x] **Bước 4: Hướng dẫn, ghi phần cho báo cáo, lưu vào Git (commit)**
  - Làm: `powerbi/README.md`; nội dung phần II, phụ lục vào mục 12.
  - Kiểm tra: lời nhắn khi lưu bắt đầu bằng `powerbi-totals:`.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Viết mô hình bằng TMDL: 12 bảng sinh một lần từ đúng kiểu dữ liệu của file mentor; quan hệ, tham số, bảng `_Measures` viết tay | 12 bảng, 18 quan hệ (4 bị động), 5 công thức | |
| 18/10 | Viết `powerbi/build_report.py` sinh trang "Số tổng"; viết `powerbi/dax_query.ps1` | 1 trang, 8 hình | |
| 18/10 | Mở dự án lần 1, lần 2 | Power BI mở ra báo cáo trống ("Untitled") | <ul><li>Liệt kê các cửa sổ của Power BI thì thấy hộp thoại "Issues were found": thuộc tính "description" không được phép</li><li>Nguyên nhân: các dòng mô tả `///` đặt trên quan hệ; quan hệ trong Power BI không có mô tả</li><li>Sửa: bỏ các dòng đó, chuyển phần giải thích quan hệ sang `powerbi/README.md`</li></ul> |
| 18/10 | Mở lại, làm mới dữ liệu bằng script, chạy 2 truy vấn DAX | <ul><li>Cả năm, 12 tháng, 3 kênh: khớp `numbers_of_record.csv`, 0 dòng lệch</li><li>Trang "Số tổng" hiện đúng số (ảnh `powerbi/checks/screenshot_so_tong.png`)</li><li>Power BI không tự ghi thêm file nào vào thư mục dự án</li></ul> | |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Các file `.tmdl` và `build_report.py` là bản gốc; file JSON của trang báo cáo sinh từ `build_report.py` | Sửa ở một chỗ, file chữ so sánh được trên Git; tránh sửa tay hàng chục file JSON | Không |
| 18/10 | Công thức đặt trong bảng riêng `_Measures`, tên tiếng Việt giống slide 29 (Sổ cái, Chênh lệch…) | Dễ tìm trong khung Data; tên trùng với cách gọi trong báo cáo | Không |
| 18/10 | Quan hệ sổ cái → bảng kênh để **bị động**; kênh của sổ cái đi qua bảng cửa hàng | Đúng gợi ý ở sheet README của file mentor; để chủ động sẽ có 2 đường lọc. Kiểm tra: sổ cái theo kênh vẫn ra đúng 3 số | Không |
| 18/10 | Không lưu dữ liệu đệm của Power BI vào Git; người mở dự án bấm Refresh | Dữ liệu đệm là file lớn, riêng từng máy | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết mô hình Power BI, trang báo cáo, script hỏi số | `powerbi/NexaRecon.SemanticModel/`, `powerbi/build_report.py`, `powerbi/dax_query.ps1` | <ul><li>So kết quả truy vấn DAX với `numbers_of_record.csv`: 0 dòng lệch</li><li>Mở Power BI, xem trang "Số tổng" bằng mắt</li><li>Nhóm nên mở Model view trong Power BI để xem các đường nối, so với bảng quan hệ ở `powerbi/README.md`</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Vì sao ngày bán của POS là quan hệ bị động mà ngày ghi sổ lại chủ động?
   **Trả lời:** Sổ cái là nguồn chuẩn, ghi doanh thu cửa hàng theo ngày ghi sổ, nên mặc định mọi con số lọc theo ngày ghi sổ. Ngày bán chỉ dùng khi cần tính theo cách của Flash (chiết khấu, dòng trùng, lệch ngày ghi sổ), lúc đó bật bằng hàm `USERELATIONSHIP`. Một bảng chỉ có 1 quan hệ chủ động tới bảng ngày.
2. **Hỏi:** Sổ cái có cột kênh riêng, sao không nối thẳng với bảng kênh?
   **Trả lời:** Sổ cái đã đi tới bảng kênh qua bảng cửa hàng (mỗi cửa hàng thuộc 1 kênh). Nối thêm đường thẳng thì có 2 đường lọc, Power BI không cho. Quan hệ thẳng vẫn có nhưng để bị động. Kiểm tra: sổ cái theo kênh vẫn ra 13.181.898,25 / 15.515.347,98 / 1.250.
3. **Hỏi:** % chênh lệch trên thẻ KPI chia cho số nào?
   **Trả lời:** Chia cho Flash, theo slide 12, ra −7,79% cả năm. Riêng cờ vượt ngưỡng cửa hàng × tháng chia cho |sổ cái| (slide 28); nhóm có 2 công thức riêng, tên ghi rõ "so với Flash" hay "so với sổ cái".

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 4 dòng số và 3 việc phải có (mục 5).
- **Nội dung cho báo cáo** (plan `report-skeleton`, `report-draft` đưa vào):
  - Phần II: hình mô hình dữ liệu Power BI (chụp Model view ở plan `dashboard`) và bảng quan hệ ở `powerbi/README.md`.
  - Phụ lục, mục kiểm chứng: Power BI ra đúng số tổng cả năm, 12 tháng, 3 kênh (`powerbi/checks/totals_by_month.csv`, `totals_by_channel.csv`).
- **Việc còn lại:**
  - Công thức từng khoản cầu nối, so với Power Query → `dax-bridge`.
  - Dashboard 4 trang, bộ lọc chung, lọc bỏ mục "(Blank)" của tháng → `dashboard`.
  - Lưu dự án thành file `.pbix` nếu mentor yêu cầu → `plans/backlog.md` mục 1 (câu hỏi 3).
- **Các lần lưu vào Git (commit):** `021caab` (tạo plan), `e11e96d` (mô hình), `d0077e5` (trang báo cáo), `ca19c9b` (script hỏi số, kết quả), `9413319` (hướng dẫn), và các lần lưu đóng plan.
