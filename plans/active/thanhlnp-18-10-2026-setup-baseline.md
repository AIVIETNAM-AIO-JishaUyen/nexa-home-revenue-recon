# Chuẩn bị nền: số chuẩn, mô tả dữ liệu, phần mềm và chạy thử công cụ

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 1 – Hiểu đề và chốt quy ước tính (phần còn lại) |
| Mốc phải đạt | Mốc 2 (19/10) |
| Phần báo cáo liên quan | Phần II (Dữ liệu và chuẩn bị): bảng mô tả nguồn dữ liệu, quy tắc ghi nhận |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [plan tổng](thanhlnp-18-10-2026-master-plan.md)</li><li>Plan tiếp theo dùng kết quả này: `load-clean-data`, `python-check`, `powerbi-totals`</li></ul> |

---

## 1. Mục tiêu

Trước khi làm số, nhóm có đủ 3 thứ: **bảng số chuẩn** để mọi cách tính so vào, **bản mô tả cấu trúc dữ liệu** để Power Query, Python và DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) dùng chung tên cột và tên khoản, và **biết chắc cách dựng file Excel và Power BI nào chạy được trên máy này**.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Tạo các thư mục làm việc `excel/`, `checks/`, `powerbi/`, `report/`.
  - Lưu bảng số chuẩn thành `checks/numbers_of_record.csv`.
  - Viết `docs/cau_truc_du_lieu.md`:
    - Mỗi nguồn: 1 dòng là gì, khóa, ngày, loại tiền, dấu.
    - Quy tắc ghi nhận của từng bên.
    - Các loại bút toán của sổ cái.
    - Cột của bảng giao dịch chung `q_Transactions` và bảng cầu nối dạng dài `BR_Long`.
    - Danh mục khoản cầu nối.
  - Cài Power BI Desktop.
  - Chạy thử nhanh 2 công cụ: Excel tự động (dựng truy vấn Power Query bằng script) và Power BI tự động (mở dự án dạng file chữ, làm mới, hỏi số bằng DAX, chụp màn hình).
  - Lập danh sách câu hỏi xin mentor (người hướng dẫn) xác nhận.
- **Không làm (để cho plan khác):**
  - 8 truy vấn nạp dữ liệu thật → `load-clean-data`.
  - Tính các khoản cầu nối theo tháng → `python-check`.
  - Mô hình Power BI đầy đủ → `powerbi-totals`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Quy ước tính và số chuẩn | `docs/quy_uoc_va_so_chuan.md` | Nguồn chính của bảng số chuẩn |
| Slide đề bài | `docs/other_resources/[Slide_v2]-Project1-Sales-Domain.pdf` | Slide 16, 17 (cấu trúc nguồn, quy tắc ghi nhận); slide 22, 25, 26, 32, 36, 44 (số) |
| Bảng tổng kiểm soát | `data/Nexa_Home_Master_Data.xlsx`, sheet QC_Summary | 13 chỉ tiêu |
| Từ điển dữ liệu | `data/Nexa_Home_Master_Data.xlsx` và `data/Nexa_Home_Recon_Dataset.xlsx`, sheet Data_Dictionary | Tên và ý nghĩa cột |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash; khoản làm Flash cao hơn sổ cái ghi số âm.
- Thứ tự các bước của bảng cầu nối (14 bước).
- ADJ-0925 luôn ở dòng "Chưa giải thích được".

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Bảng số chuẩn | `checks/numbers_of_record.csv` | Mọi plan có con số phải khớp |
| Mô tả cấu trúc dữ liệu | `docs/cau_truc_du_lieu.md` | Power Query, Python, DAX, báo cáo phần II |
| Power BI Desktop đã cài | máy này | `powerbi-totals`, `dax-bridge`, `dashboard` |
| Kết luận 2 lần chạy thử | mục 9 của plan này | `load-clean-data`, `powerbi-totals` |
| Câu hỏi xin mentor | `plans/backlog.md` | Buổi kiểm tra tiến độ |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| 13 chỉ tiêu tổng kiểm soát có trong bảng số chuẩn (tách thành 16 số vì khoảng ngày và số đơn theo trạng thái có nhiều giá trị) | 16 số | sheet QC_Summary | 16 số | `checks/numbers_of_record.csv`, các dòng `qc_*` | Đạt |
| Các khoản cầu nối cả năm cộng lại bằng chênh lệch | −2.425.904,77 | `docs/quy_uoc_va_so_chuan.md` | −2.425.904,77 | `checks/numbers_of_record.csv` | Đạt |
| Cầu nối tháng 12 cộng lại bằng chênh lệch tháng 12 | −258.492,59 | slide 36 | −258.492,60 | `checks/numbers_of_record.csv` | Đạt (lệch 0,01 do slide làm tròn từng dòng) |
| Lần chạy thử Excel: truy vấn đọc file Flash qua ô đường dẫn | 156 dòng, tổng 31.124.401 | sheet QC_Summary | 156 dòng, 31.124.401 | file Excel chạy thử (thư mục nháp) | Đạt |
| Lần chạy thử Power BI: công thức Flash trả về | 31.124.401 | sheet QC_Summary | 31.124.401 | truy vấn DAX vào Power BI đang mở | Đạt |

**Việc phải có (không phải con số):**
- [x] Mỗi số trong bảng số chuẩn có cột ghi nguồn (slide nào, sheet nào).
- [x] Bản mô tả cấu trúc dữ liệu có đủ 4 nguồn, 5 loại bút toán sổ cái, cột của `q_Transactions`, cột của `BR_Long`, danh mục khoản.
- [x] Biết cách nạp truy vấn vào Excel bằng script, và cách đọc ô đường dẫn mà không bị Excel chặn.
- [x] Biết mở dự án Power BI dạng file chữ, làm mới dữ liệu, hỏi số bằng DAX và chụp màn hình được; hoặc đã ghi rõ phần nào không làm được vào backlog.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Chép nhầm số khi lập bảng số chuẩn | Các plan sau "khớp" với một số sai | Kiểm tra cộng: các khoản cầu nối phải cộng ra đúng chênh lệch, cả năm và tháng 12 |
| Lẫn dấu: slide 25–26 ghi chênh lệch là Flash − Sổ cái (số dương), ngược quy ước của nhóm | Bảng số chuẩn có số trái dấu | Mọi chênh lệch trong file đều theo Sổ cái − Flash; ghi chú rõ ở cột nguồn |
| Excel chạy bằng script bị treo, hoặc tắt nhầm Excel người dùng đang mở | Máy đứng, mất việc của người dùng | Chạy trong tiến trình riêng có giới hạn thời gian; chỉ tắt đúng tiến trình Excel do script mở |
| Excel chặn truy vấn đọc ô đường dẫn rồi đọc file (lỗi Formula.Firewall) | Làm mới báo lỗi | Đọc ô đường dẫn ngay trong truy vấn đọc file; thử bật "bỏ qua mức riêng tư" (FastCombine) |
| Cài Power BI cần quyền quản trị hoặc cần bấm đồng ý | Cài không xong | Dùng bản Microsoft Store qua winget; nếu vẫn lỗi thì ghi backlog |

---

## 7. Các bước

- [x] **Bước 1: Tạo thư mục làm việc và bảng số chuẩn**
  - Làm: tạo `excel/`, `checks/`, `powerbi/`, `report/`. Chép mọi số chuẩn của `docs/quy_uoc_va_so_chuan.md` và slide 36, 44 vào `checks/numbers_of_record.csv`, mỗi số một dòng, có cột nguồn.
  - Kiểm tra: đọc file bằng Python, cộng các khoản cầu nối cả năm và tháng 12 → kết quả mong đợi: −2.425.904,77 và −258.492,59.
- [x] **Bước 2: Viết bản mô tả cấu trúc dữ liệu**
  - Làm: viết `docs/cau_truc_du_lieu.md` theo slide 16, 17 và từ điển dữ liệu.
  - Kiểm tra: tên cột trong file khớp tên cột thật của dữ liệu (so bằng Python) → kết quả mong đợi: không có tên cột nào không tồn tại.
- [x] **Bước 3: Cài Power BI Desktop**
  - Làm: `winget install --id 9NTXR16HNW1T --source msstore`.
  - Kiểm tra: tìm thấy gói Power BI đã cài → kết quả mong đợi: có số phiên bản.
- [x] **Bước 4: Chạy thử Excel tự động**
  - Làm: script tạo file Excel mới, ghi đường dẫn vào ô `FolderPath`, thêm 1 truy vấn đọc file Flash, nạp vào sheet, làm mới, lưu. Chạy lại khi đổi sang thư mục khác.
  - Kiểm tra: đọc file đã lưu bằng Python → kết quả mong đợi: 156 dòng chi tiết, tổng 31.124.401; không có hộp thoại nào chặn.
- [x] **Bước 5: Chạy thử Power BI tự động**
  - Làm: dự án Power BI tối thiểu gồm bảng ngày, bảng Flash, 1 quan hệ bị động, 1 công thức, 1 trang có ô số, biểu đồ thác nước và bộ lọc. Mở bằng Power BI Desktop, làm mới, hỏi số bằng DAX, chụp màn hình.
  - Kiểm tra: công thức trả về 31.124.401; ảnh chụp thấy trang báo cáo → kết quả mong đợi: biết cách nào chạy được.
- [x] **Bước 6: Lập câu hỏi xin mentor**
  - Làm: ghi vào `plans/backlog.md`.
  - Kiểm tra: có đủ các câu trong `docs/ghi_chu_ky_thuat.md` và các điểm mới phát hiện (số làm tròn, file nộp Power BI).
- [x] **Bước cuối: lưu lên GitHub**
  - Làm: plan này không có phần báo cáo riêng; bản mô tả cấu trúc dữ liệu sẽ được dùng ở phần II khi dựng khung báo cáo.
  - Kiểm tra: lời nhắn khi lưu ghi tên plan.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Lập `checks/numbers_of_record.csv` | <ul><li>140 số, mỗi số có cột nguồn</li><li>Các khoản cầu nối cả năm cộng ra −2.425.904,77, đúng bằng Sổ cái − Flash</li><li>Tháng 12 cộng ra −258.492,60, lệch 0,01 so với −258.492,59</li><li>12 tháng cộng lại đúng tổng năm</li></ul> | Phần lệch 0,01 của tháng 12 là do slide 36 làm tròn từng dòng đến 2 chữ số. Nằm trong mức chấp nhận ≤ 1 USD |
| 18/10 | Viết `docs/cau_truc_du_lieu.md` | Đủ 4 nguồn, 4 bảng danh mục, 5 loại bút toán, tên truy vấn, cột `q_Transactions`, cột `BR_Long`, 15 dòng danh mục khoản | Đã so tên cột với dữ liệu thật bằng Python: không có tên nào sai |
| 18/10 | Chạy thử Excel tự động (3 lần) | <ul><li>Lần 1: 1 truy vấn đọc file Flash qua ô đường dẫn → 156 dòng, tổng 31.124.401, không có hộp thoại nào</li><li>Lần 2: 1 truy vấn ghép file POS với bảng cửa hàng ở file khác → chạy được, cả khi bật và tắt "bỏ qua mức riêng tư"</li><li>Lần 3: chép dữ liệu sang thư mục có dấu cách trong tên, chỉ đổi ô đường dẫn → vẫn 156 dòng</li></ul> | Lần 3 lúc đầu lỗi vì script chạy thử truyền đường dẫn có dấu cách bị cắt đôi; đã sửa cách truyền tham số. Excel không có lỗi |
| 18/10 | Ghi 8 câu hỏi xin mentor vào `plans/backlog.md` | Đủ 3 câu của `docs/ghi_chu_ky_thuat.md` và 5 câu mới | |
| 18/10 | Cài Power BI Desktop bản Microsoft Store bằng winget | Phiên bản 2.159.883.0, không cần quyền quản trị | Tải mất khoảng 15 phút |
| 18/10 | Chạy thử Power BI tự động | <ul><li>Dự án viết bằng file chữ (3 bảng, 3 quan hệ trong đó 1 quan hệ bị động, 2 công thức, 1 trang có ô số, bộ lọc, biểu đồ thác nước) mở được trong Power BI Desktop</li><li>Làm mới dữ liệu bằng lệnh gửi từ script: chạy được</li><li>Hỏi số bằng DAX: Flash = 31.124.401; đơn online đặt năm 2025 tính sau giảm giá = 16.062.746,09</li><li>Chụp riêng cửa sổ Power BI: thấy đủ 3 hình có dữ liệu</li></ul> | <ul><li>Lần mở đầu tiên Power BI tự tắt; mở lại thì chạy bình thường (có thể do lần chạy đầu tiên sau khi cài)</li><li>Lần chụp đầu tiên chụp cả màn hình, dính cửa sổ khác của người dùng → đã xóa ảnh, đổi sang chỉ chụp cửa sổ Power BI</li><li>Thư viện hỏi số đi kèm Power BI phải nạp bằng `Reflection.Assembly.LoadFrom`, nạp kiểu khác bị lỗi</li><li>Bấm Ctrl+S bằng script không lưu được bản dữ liệu đệm, vì Power BI coi như không có gì thay đổi</li></ul> |
| 18/10 | Thư mục `excel/`, `powerbi/`, `report/` | Chưa tạo | Git không lưu thư mục rỗng; các plan sau tạo thư mục khi có file đầu tiên |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Cột mô tả trong `numbers_of_record.csv` viết tiếng Việt không dấu | File chữ CSV (Comma-Separated Values) mở bằng Excel hay Python đều không lỗi font | Không |
| 18/10 | Mỗi truy vấn nạp dữ liệu tự đọc ô `FolderPath` ở bước đầu, rồi tìm file trong thư mục bằng `Folder.Files` theo phần đầu tên file | <ul><li>Đã chạy thử: không bị Excel chặn khi ghép nhiều file</li><li>Không cần bật "bỏ qua mức riêng tư", nên mở trên máy khác không phải chỉnh gì</li><li>Tên file đổi phần đuôi (ví dụ năm) vẫn đọc được</li></ul> | Không |
| 18/10 | Mã khoản cầu nối (`item_code`) viết tiếng Anh, ví dụ `discount`, `fx`; tên hiển thị tiếng Việt | Slide 7 yêu cầu tên cột, tên file giữ tiếng Anh; mã tiếng Anh dùng được trong công thức Excel và DAX mà không lỗi dấu | Không |
| 18/10 | Dự án Power BI viết dưới dạng file chữ (`.pbip`: mô hình viết bằng TMDL – Tabular Model Definition Language, báo cáo dạng PBIR – Power BI enhanced report format). Kiểm tra số bằng cách mở trong Power BI Desktop, làm mới, rồi hỏi bằng DAX từ script | <ul><li>Đã chạy thử được đủ chuỗi việc này</li><li>File chữ đọc và so sánh được trên GitHub</li></ul> | Không |
| 18/10 | Không lưu bản dữ liệu đệm (`cache.abf`) vào kho. Ai mở dự án Power BI thì bấm "Refresh now" một lần | Không tự lưu được bằng script; dữ liệu đệm là file nhị phân lớn | Không. Ghi vào hướng dẫn mở file ở plan `powerbi-totals` |
| 18/10 | Lỗi chuyển dữ liệu tính tại từng ô cửa hàng × ngày ghi sổ, đổi ra USD theo tỷ giá ngày của ngày ghi sổ | Cần một cách đổi tiền cố định để dòng tỷ giá và dòng kiểm tra khớp nhau. Năm 2025 chỉ có NX057 (cửa hàng ở Mỹ, tiền USD) nên không ảnh hưởng số | Không (bổ sung vào `docs/cau_truc_du_lieu.md`) |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Chép số chuẩn từ tài liệu và slide vào file CSV | Toàn bộ `checks/numbers_of_record.csv` | <ul><li>Cộng các khoản cầu nối cả năm và tháng 12, so với Sổ cái − Flash</li><li>Cộng 12 tháng, so với tổng năm</li><li>Nên dò lại bằng mắt 10 số bất kỳ với slide</li></ul> |
| 18/10 | Viết bản mô tả cấu trúc dữ liệu và danh mục khoản | Toàn bộ `docs/cau_truc_du_lieu.md` | So tên cột, số dòng, số bút toán từng loại với dữ liệu thật bằng Python |
| 18/10 | Viết script chạy thử Excel tự động và Power BI tự động | Các script trong thư mục nháp (không đưa vào kho) | Đọc lại file Excel đã lưu bằng Python, so số dòng và tổng với bảng tổng kiểm soát |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Một dòng của sổ cái đại diện cho cái gì? Khác gì một dòng của file POS?
   **Trả lời:** Một dòng POS là một món hàng trên một hóa đơn. Một dòng sổ cái là một bút toán. Bút toán tự động gộp nhiều giao dịch: cửa hàng thì gộp theo cửa hàng × ngày ghi sổ, online thì gộp theo ngày giao × loại tiền. Vì vậy không thể ghép từng dòng POS với từng dòng sổ cái, mà phải cộng POS lên cùng mức cửa hàng × ngày ghi sổ rồi mới so (xem `docs/cau_truc_du_lieu.md`, mục 1 và 3).
2. **Hỏi:** Vì sao nhóm lấy sổ cái làm chuẩn?
   **Trả lời:** Sổ cái đã khóa sổ từng tháng, ghi theo chuẩn mực kế toán VAS 14 (Chuẩn mực kế toán Việt Nam số 14 về doanh thu) và có giấy tờ làm căn cứ. Flash chỉ là báo cáo nhanh của phòng Kinh doanh, tính theo giá trước giảm giá và gồm cả đơn hủy.
3. **Hỏi:** Ngưỡng 200 USD và 1% được chọn lúc nào?
   **Trả lời:** Chọn trước khi tính số, ghi trong `docs/quy_uoc_va_so_chuan.md` và lưu lên GitHub ngày 15/10, theo nguyên tắc "đặt ngưỡng trước khi nhìn số" của slide 39.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 5 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** chưa; `docs/cau_truc_du_lieu.md` mục 1–3 sẽ thành phần II của báo cáo ở plan `report-skeleton`.
- **Việc còn lại:**
  - Hỏi mentor 8 câu → `plans/backlog.md` mục 1.
  - Chốt số làm tròn → plan `python-check`.
  - Tạo thư mục `excel/`, `powerbi/`, `report/` → các plan dùng tới.
- **Các lần lưu lên GitHub:** `5fc134b` (tạo plan), `46c0200` (bảng số chuẩn), `680a24c` (mô tả cấu trúc dữ liệu), `ab3293e` (câu hỏi mentor), `3d5f727` (nhật ký chạy thử Excel), và lần lưu đóng plan.
