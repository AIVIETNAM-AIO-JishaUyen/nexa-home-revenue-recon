# Power BI: mô hình dữ liệu và số tổng (Flash, sổ cái, chênh lệch)

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 5 – Kiểm tra lại bằng cách tính thứ hai (phần đầu: mô hình và số tổng) |
| Mốc phải đạt | Mốc 2 (19/10): "Power BI ra đúng số tổng" |
| Phần báo cáo liên quan | <ul><li>Phần II (Dữ liệu và chuẩn bị): mô hình dữ liệu Power BI</li><li>Phụ lục: cách kiểm chứng bằng DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI)</li></ul> |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [python-check](../completed/thanhlnp-18-10-2026-python-check.md)</li><li>Plan tiếp theo dùng kết quả này: `dax-bridge`, `dashboard`</li></ul> |

---

## 1. Mục tiêu

Có dự án Power BI nạp file dữ liệu mentor (người hướng dẫn) đã chuẩn bị (`Nexa_Home_Recon_Dataset.xlsx`), nối bảng đúng slide 19, đánh dấu bảng ngày, và có các công thức DAX cho Flash (báo cáo nhanh doanh số của phòng Kinh doanh), sổ cái (sổ kế toán của phòng Tài chính), chênh lệch, % chênh lệch, ra **đúng số tổng cả năm và 12 tháng**.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Dự án Power BI dạng thư mục (`.pbip`, Power BI Project) trong `powerbi/`: mô hình viết bằng TMDL (Tabular Model Definition Language, ngôn ngữ mô tả mô hình bằng file chữ), báo cáo dạng PBIR (Power BI enhanced report format).
  - Nạp đủ 12 bảng của file dữ liệu mentor; nối bảng theo slide 19 và sheet README của file đó.
  - Tham số đường dẫn thư mục dữ liệu `DataFolder`.
  - 5 công thức: Flash, Sổ cái, Chênh lệch, % chênh lệch so với Flash, % chênh lệch so với sổ cái.
  - 1 trang báo cáo "Số tổng" để nhìn nhanh: 4 ô số (Flash, Sổ cái, Chênh lệch, % chênh lệch so với Flash), bảng 12 tháng, bảng sổ cái theo kênh.
  - Script `powerbi/dax_query.ps1` mở dự án, làm mới dữ liệu, chạy truy vấn DAX ra file CSV (Comma-Separated Values, file bảng dạng chữ, các cột cách nhau bằng dấu phẩy) để so số.
  - `powerbi/README.md`: cách mở, đổi đường dẫn, làm mới.
- **Không làm (để cho plan khác):**
  - Công thức từng khoản cầu nối → `dax-bridge`.
  - Dashboard 4 trang → `dashboard`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| File dữ liệu mentor đã nối sẵn cho Power BI | `data/Nexa_Home_Recon_Dataset.xlsx` | 12 bảng: 6 bảng danh mục (dim), 4 bảng giao dịch (fact), 2 bảng tỷ giá |
| Quan hệ đề xuất | slide 19; sheet README của file trên | <ul><li>Quan hệ chủ động (active): Power BI tự dùng khi lọc</li><li>Quan hệ bị động (inactive): chỉ dùng khi công thức bật bằng hàm `USERELATIONSHIP`</li></ul> |
| Kết quả chạy thử Power BI | [setup-baseline](../completed/thanhlnp-18-10-2026-setup-baseline.md), mục 8 và 9 | Cách viết dự án bằng file chữ, cách hỏi số bằng DAX |
| Số chuẩn | `checks/numbers_of_record.csv` | Tổng năm, 12 tháng, theo kênh |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash.
- % hiển thị trên thẻ KPI (Key Performance Indicator, ô số liệu chính) chia cho Flash; % dùng cho cờ vượt ngưỡng chia cho |sổ cái| (giá trị tuyệt đối của sổ cái, tức bỏ dấu âm).

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Dự án Power BI | `powerbi/NexaRecon.pbip`, `powerbi/NexaRecon.SemanticModel/`, `powerbi/NexaRecon.Report/` | `dax-bridge`, `dashboard` |
| Script sinh trang báo cáo | `powerbi/build_report.py` | `dashboard` |
| Script hỏi số bằng DAX | `powerbi/dax_query.ps1` | So DAX với Power Query |
| Truy vấn và kết quả hỏi số | <ul><li>`powerbi/checks/totals_by_month.dax`, `.csv`</li><li>`powerbi/checks/totals_by_channel.dax`, `.csv`</li><li>Ảnh trang "Số tổng": `powerbi/checks/screenshot_so_tong.png`</li></ul> | Bằng chứng |
| Hướng dẫn | `powerbi/README.md` | Cả nhóm |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Flash, Sổ cái, Chênh lệch cả năm | 31.124.401 / 28.698.496,23 / −2.425.904,77 | `numbers_of_record.csv` | 31.124.401 / 28.698.496,23 / −2.425.904,77 | `powerbi/checks/totals_by_month.csv`, dòng Cả năm | Đạt |
| Flash, Sổ cái, Chênh lệch từng tháng | Các dòng `m01_*` … `m12_*` (tháng 1 đến tháng 12) | `numbers_of_record.csv` | Khớp cả 12 tháng (lệch ≤ 0,005) | `powerbi/checks/totals_by_month.csv` | Đạt |
| Sổ cái theo kênh (lọc từ bảng kênh qua bảng cửa hàng): cửa hàng / online / chưa gắn kênh | 13.181.898,25 / 15.515.347,98 / 1.250 | `numbers_of_record.csv` | <ul><li>13.181.898,25 / 15.515.347,98 / 1.250</li><li>Flash theo kênh cũng khớp: 14.060.500 / 17.063.901 / trống (tức 0)</li></ul> | `powerbi/checks/totals_by_channel.csv` | Đạt |
| % chênh lệch so với Flash cả năm | −7,79% | <ul><li>`numbers_of_record.csv` (−0,077942)</li><li>Slide 3 làm tròn thành 7,8%</li></ul> | −7,794% | `powerbi/checks/totals_by_month.csv` | Đạt |

**Việc phải có (không phải con số):**
- [x] Quan hệ đúng slide 19: ngày ghi nhận là quan hệ chủ động; ngày bán, ngày đặt, ngày trả là quan hệ bị động; lọc một chiều từ bảng danh mục xuống bảng giao dịch; không nối thẳng 2 bảng giao dịch với nhau.
- [x] Bảng ngày được đánh dấu là bảng ngày.
- [x] Mở dự án trong Power BI Desktop không có lỗi; trang "Số tổng" hiện đúng số.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Nối thêm sổ cái với bảng kênh bằng quan hệ chủ động | Power BI báo có 2 đường lọc, không cho tạo | Quan hệ sổ cái → bảng kênh để bị động, kênh của sổ cái đi qua bảng cửa hàng |
| Đơn hủy không có ngày giao | Bộ lọc tháng có mục "(Blank)" | Biết trước; dashboard lọc `dim_date[is_fiscal_2025] = TRUE` thì mục trống cũng bị bỏ |
| Đường dẫn dữ liệu khác nhau giữa các máy | Làm mới báo lỗi không tìm thấy file | Một tham số `DataFolder`; hướng dẫn đổi trong `powerbi/README.md` |
| Tổng sổ cái lấy cột `amount_usd` (dấu kế toán) | Sổ cái ra số âm | Dùng cột `revenue_usd` (đã đổi dấu) |
| Xem chênh lệch theo cửa hàng, loại tiền hay loại bút toán (thêm khi rà soát) | Flash không đổi theo bộ lọc đó, chênh lệch ra số vô nghĩa | <ul><li>Flash chỉ nối với bảng ngày (ngày cuối tháng) và bảng kênh, không có cửa hàng hay loại tiền</li><li>Ở mức cửa hàng phải so sổ cái với POS (Point of Sale, bán tại cửa hàng) đã đưa về cùng cách tính, như slide 30</li></ul> |
| Quên lọc năm tài chính 2025 (thêm khi rà soát) | Công thức online ra sai, ví dụ chiết khấu ra −1.938.937,08 thay vì −1.834.297,47 (cộng thêm cả đơn đặt tháng 12/2024) | <ul><li>Bảng ngày có cả tháng 12/2024 và tháng 1/2026; bảng đơn online có 862 đơn đặt tháng 12/2024, 105 đơn giao năm 2026</li><li>Lọc `dim_date[is_fiscal_2025] = TRUE`, đúng gợi ý ở sheet README của file mentor</li><li>Sổ cái và Flash không có dòng ngoài năm 2025 nên số tổng ở plan này không bị ảnh hưởng</li></ul> |
| Cộng thẳng các cột `*_usd_*` có sẵn trong file mentor (thêm khi rà soát) | Lệch vài USD (đô la Mỹ) so với Power Query, ví dụ chiết khấu −1.834.298,38 thay vì −1.834.297,47 | <ul><li>Các cột này đã làm tròn 2 chữ số ở từng dòng</li><li>Quy ước nhóm: nội tệ ÷ tỷ giá, không làm tròn từng dòng (xem `plans/backlog.md`, câu hỏi xin mentor số 4)</li></ul> |

---

## 7. Các bước

- [x] **Bước 1: Viết mô hình bằng TMDL**
  - Làm: 12 bảng, quan hệ, bảng ngày, tham số `DataFolder`, bảng `_Measures` chứa 5 công thức.
  - Kiểm tra: mở dự án trong Power BI Desktop không báo lỗi.
- [x] **Bước 2: Trang báo cáo "Số tổng"**
  - Làm: 4 ô số (Flash, Sổ cái, Chênh lệch, % chênh lệch so với Flash), bảng 12 tháng, bảng sổ cái theo kênh.
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
| 18/10 | Viết mô hình bằng TMDL | <ul><li>12 bảng: sinh một lần bằng script tạm (không lưu vào kho) theo đúng tên cột và kiểu dữ liệu của file mentor</li><li>Quan hệ, tham số, bảng `_Measures`: viết tay</li><li>Kết quả: 12 bảng, 18 quan hệ (4 bị động), 5 công thức</li></ul> | |
| 18/10 | <ul><li>Viết `powerbi/build_report.py` sinh trang "Số tổng"</li><li>Viết `powerbi/dax_query.ps1`</li></ul> | 1 trang, 8 hình (tiêu đề, 4 ô số, bảng tháng, bảng kênh, dòng ghi nguồn) | |
| 18/10 | Mở dự án lần 1, lần 2 | Power BI mở ra báo cáo trống ("Untitled") | <ul><li>Liệt kê các cửa sổ của Power BI thì thấy hộp thoại "Issues were found": thuộc tính "description" không được phép</li><li>Nguyên nhân: các dòng mô tả `///` đặt trên quan hệ; quan hệ trong Power BI không có mô tả</li><li>Sửa: bỏ các dòng đó, chuyển phần giải thích quan hệ sang `powerbi/README.md`</li></ul> |
| 18/10 | Mở lại, làm mới dữ liệu bằng script, chạy 2 truy vấn DAX | <ul><li>Cả năm, 12 tháng, 3 kênh: khớp `numbers_of_record.csv`, 0 dòng lệch</li><li>Trang "Số tổng" hiện đúng số (ảnh `powerbi/checks/screenshot_so_tong.png`)</li><li>Power BI không tự ghi thêm file nào vào thư mục dự án</li></ul> | |
| 18/10 | Rà soát bằng một trợ lý AI khác (không mở Excel, Power BI) | <ul><li>12 bảng: tên cột và kiểu dữ liệu khớp từng sheet của file mentor; khóa của 6 bảng danh mục không trùng; mọi khóa ở bảng giao dịch đều có trong bảng danh mục</li><li>18 quan hệ khớp slide 19 và sheet README; không có 2 đường lọc cùng đi tới một bảng</li><li>Tính lại bằng Python từ file mentor: 12 tháng, cả năm, 3 kênh khớp 2 file CSV (lệch dưới 0,000001) và `numbers_of_record.csv`</li><li>Sổ cái theo kênh tính qua bảng cửa hàng hay qua cột kênh của sổ cái đều ra cùng 3 số, vì 2 dòng của bút toán tay chuyển kênh MJ-RCL-2506 (MJ = Manual Journal, bút toán tay; RCL = Reclassification, phân loại lại) ghi đúng cửa hàng: NX019 −3.480 ở kênh cửa hàng, online +3.480</li><li>Chạy lại `build_report.py` ra thư mục tạm: các file JSON (JavaScript Object Notation, file chữ lưu dữ liệu có cấu trúc) giống hệt bản trong kho, tức không có file nào bị sửa tay</li></ul> | <ul><li>Công thức `% chênh lệch so với sổ cái` chưa dùng được cho cờ vượt ngưỡng cửa hàng × tháng (Flash không có cửa hàng); đã sửa câu trả lời vấn đáp số 3 và `powerbi/README.md`</li><li>Thêm 3 dòng vào mục 6 cho các plan sau: lọc năm 2025, cột USD đã làm tròn, Flash không lọc theo cửa hàng</li><li>Ghi chú kỹ thuật Việc 5 yêu cầu xuất công thức ra `powerbi/dax_measures.dax`: chưa làm, chuyển sang `dax-bridge`</li><li>Sửa cách viết: thêm tên đầy đủ của từ viết tắt, tách ý trong ô bảng</li></ul> |
| 18/10 | Sửa theo rà soát | <ul><li>Mô tả công thức "% chênh lệch so với sổ cái": dùng ở mức tháng, kênh; cờ cửa hàng × tháng dùng chênh lệch sau khi đưa về cùng cách tính (plan `dax-bridge`)</li><li>Gợi ý sửa tham số: Home > Transform data > Edit parameters</li><li>8 cột tỷ giá hiện 5 chữ số thập phân</li><li>Tắt tính năng Power BI tự tạo bảng ngày ẩn cho mỗi cột ngày</li></ul> | Mở lại dự án, làm mới: số tổng theo tháng không đổi |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Các file `.tmdl` và `build_report.py` là bản gốc; file JSON của trang báo cáo sinh từ `build_report.py` | <ul><li>Sửa ở một chỗ</li><li>File chữ so sánh được trên Git</li><li>Tránh sửa tay nhiều file JSON (hiện 12 file, trong đó mỗi hình một file; sẽ tăng khi thêm trang)</li><li>Hệ quả: sửa trang trong Power BI Desktop rồi lưu thì lần chạy `build_report.py` sau sẽ xóa phần đã sửa; cần nhóm chốt cách làm dashboard (`plans/backlog.md` mục 4)</li></ul> | Không |
| 18/10 | Công thức đặt trong bảng riêng `_Measures`, đặt tên tiếng Việt theo cách gọi của nhóm: Flash, Sổ cái, Chênh lệch, % chênh lệch so với Flash, % chênh lệch so với sổ cái | <ul><li>Dễ tìm trong khung Data (danh sách bảng ở bên phải màn hình Power BI)</li><li>Tên trùng với cách gọi trong báo cáo</li><li>Slide 29 gọi là Báo cáo nhanh, Sổ cái, Δ, Δ %; nhóm không dùng ký hiệu Δ cho dễ đọc</li></ul> | Không |
| 18/10 | Quan hệ sổ cái → bảng kênh để **bị động**; kênh của sổ cái đi qua bảng cửa hàng | <ul><li>Đúng gợi ý ở sheet README của file mentor</li><li>Để chủ động sẽ có 2 đường lọc</li><li>Kiểm tra: sổ cái theo kênh vẫn ra đúng 3 số</li></ul> | Không |
| 18/10 | Không lưu dữ liệu đệm của Power BI vào Git; người mở dự án bấm Refresh (Làm mới) | Dữ liệu đệm là file lớn, riêng từng máy | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết mô hình Power BI, trang báo cáo, script hỏi số | `powerbi/NexaRecon.SemanticModel/`, `powerbi/build_report.py`, `powerbi/dax_query.ps1` | <ul><li>So kết quả truy vấn DAX với `numbers_of_record.csv`: 0 dòng lệch</li><li>Mở Power BI, xem trang "Số tổng" bằng mắt</li><li>Nhóm nên mở Model view (màn hình sơ đồ nối bảng, nút thứ ba ở cột trái) trong Power BI để xem các đường nối, so với bảng quan hệ ở `powerbi/README.md`</li><li>Một trợ lý AI khác rà soát, tính lại số bằng Python (xem mục 8)</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Vì sao ngày bán của POS là quan hệ bị động mà ngày ghi sổ lại chủ động?
   **Trả lời:** Sổ cái là nguồn chuẩn, ghi doanh thu cửa hàng theo ngày ghi sổ, nên mặc định mọi con số lọc theo ngày ghi sổ. Ngày bán chỉ dùng khi cần tính theo cách của Flash (chiết khấu, dòng trùng, lệch ngày ghi sổ), lúc đó bật bằng hàm `USERELATIONSHIP`. Một bảng chỉ có 1 quan hệ chủ động tới bảng ngày.
2. **Hỏi:** Sổ cái có cột kênh riêng, sao không nối thẳng với bảng kênh?
   **Trả lời:** Sổ cái đã đi tới bảng kênh qua bảng cửa hàng (mỗi cửa hàng thuộc 1 kênh). Nối thêm đường thẳng thì có 2 đường lọc, Power BI không cho. Quan hệ thẳng vẫn có nhưng để bị động. Kiểm tra: sổ cái theo kênh vẫn ra 13.181.898,25 / 15.515.347,98 / 1.250.
3. **Hỏi:** % chênh lệch trên thẻ KPI chia cho số nào?
   **Trả lời:** Chia cho Flash, theo slide 12, ra −7,79% cả năm. Riêng cờ vượt ngưỡng cửa hàng × tháng chia cho |sổ cái| (giá trị tuyệt đối, tức bỏ dấu âm; slide 28). Nhưng ở mức cửa hàng không so với Flash được, vì Flash không có số theo cửa hàng; cờ dùng chênh lệch sau khi đưa về cùng cách tính (sổ cái − POS), như slide 30, sẽ làm ở plan `store-recon` (Power Query) và `dax-bridge` (DAX). Công thức `% chênh lệch so với sổ cái` hiện có là mẫu "Δ %" của slide 29 (Δ là ký hiệu chênh lệch), dùng được ở mức tháng hoặc kênh. Tên công thức luôn ghi rõ "so với Flash" hay "so với sổ cái".

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 4 dòng số và 3 việc phải có (mục 5).
- **Nội dung cho báo cáo** (plan `report-skeleton`, `report-draft` đưa vào):
  - Phần II: hình mô hình dữ liệu Power BI (chụp Model view ở plan `dashboard`) và bảng quan hệ ở `powerbi/README.md`.
  - Phụ lục, mục kiểm chứng: Power BI ra đúng số tổng cả năm, 12 tháng, 3 kênh (`powerbi/checks/totals_by_month.csv`, `totals_by_channel.csv`).
- **Việc còn lại:**
  - Công thức từng khoản cầu nối, so với Power Query → `dax-bridge`. Lưu ý khi viết (mục 6):
    - Đổi ra USD bằng nội tệ ÷ tỷ giá từng dòng (hàm `SUMX`), không cộng thẳng các cột `*_usd_*` đã làm tròn.
    - Lọc `dim_date[is_fiscal_2025] = TRUE` cho mọi công thức đọc bảng đơn online.
  - Cờ vượt ngưỡng cửa hàng × tháng: chênh lệch sau khi đưa về cùng cách tính (sổ cái − POS) ÷ \|sổ cái\| → `store-recon`, `dax-bridge`.
  - Xuất toàn bộ công thức ra `powerbi/dax_measures.dax` như ghi chú kỹ thuật Việc 5 yêu cầu → `dax-bridge`.
  - Dashboard 4 trang, bộ lọc chung → `dashboard`:
    - Lọc cả trang theo `dim_date[is_fiscal_2025] = TRUE`: bỏ được cùng lúc mục "(Blank)" của tháng, tháng 12/2024 và tháng 1/2026.
    - Không đặt bộ lọc cửa hàng, loại tiền, loại bút toán cạnh ô chênh lệch (Flash không đổi theo các bộ lọc này).
    - Chọn cách hiện số: mô hình đang đặt kiểu Mỹ (`culture: en-US`, ví dụ 2,859,589.00), còn tài liệu nhóm và slide viết kiểu Việt Nam (2.859.589,00); ô số đang tự rút gọn thành "31M".
  - Cách sửa trang báo cáo (bằng `build_report.py` hay bằng giao diện Power BI Desktop) → `plans/backlog.md` mục 4.
  - Lưu dự án thành file `.pbix` nếu mentor yêu cầu → `plans/backlog.md` mục 1 (câu hỏi 3).
- **Các lần lưu vào Git (commit):** `021caab` (tạo plan), `e11e96d` (mô hình), `d0077e5` (trang báo cáo), `ca19c9b` (script hỏi số, kết quả), `9413319` (hướng dẫn), `89c7508` (ghi kết quả, quyết định, chuẩn bị vấn đáp), và các lần lưu sửa theo rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
