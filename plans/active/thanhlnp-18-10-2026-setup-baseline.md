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
| Số chỉ tiêu tổng kiểm soát trong bảng số chuẩn | 13 | sheet QC_Summary | | `checks/numbers_of_record.csv` | |
| Các khoản cầu nối cả năm cộng lại bằng chênh lệch | −2.425.904,77 | `docs/quy_uoc_va_so_chuan.md` | | `checks/numbers_of_record.csv` | |
| Cầu nối tháng 12 cộng lại bằng chênh lệch tháng 12 | −258.492,59 | slide 36 | | `checks/numbers_of_record.csv` | |
| Lần chạy thử Excel: truy vấn đọc file Flash qua ô đường dẫn | 156 dòng, tổng 31.124.401 | sheet QC_Summary | | file Excel chạy thử | |
| Lần chạy thử Power BI: công thức Flash trả về | 31.124.401 | sheet QC_Summary | | truy vấn DAX | |

**Việc phải có (không phải con số):**
- [ ] Mỗi số trong bảng số chuẩn có cột ghi nguồn (slide nào, sheet nào).
- [ ] Bản mô tả cấu trúc dữ liệu có đủ 4 nguồn, 5 loại bút toán sổ cái, cột của `q_Transactions`, cột của `BR_Long`, danh mục khoản.
- [ ] Biết cách nạp truy vấn vào Excel bằng script, và cách đọc ô đường dẫn mà không bị Excel chặn.
- [ ] Biết mở dự án Power BI dạng file chữ, làm mới dữ liệu, hỏi số bằng DAX và chụp màn hình được; hoặc đã ghi rõ phần nào không làm được vào backlog.

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

- [ ] **Bước 1: Tạo thư mục làm việc và bảng số chuẩn**
  - Làm: tạo `excel/`, `checks/`, `powerbi/`, `report/`. Chép mọi số chuẩn của `docs/quy_uoc_va_so_chuan.md` và slide 36, 44 vào `checks/numbers_of_record.csv`, mỗi số một dòng, có cột nguồn.
  - Kiểm tra: đọc file bằng Python, cộng các khoản cầu nối cả năm và tháng 12 → kết quả mong đợi: −2.425.904,77 và −258.492,59.
- [ ] **Bước 2: Viết bản mô tả cấu trúc dữ liệu**
  - Làm: viết `docs/cau_truc_du_lieu.md` theo slide 16, 17 và từ điển dữ liệu.
  - Kiểm tra: tên cột trong file khớp tên cột thật của dữ liệu (so bằng Python) → kết quả mong đợi: không có tên cột nào không tồn tại.
- [ ] **Bước 3: Cài Power BI Desktop**
  - Làm: `winget install --id 9NTXR16HNW1T --source msstore`.
  - Kiểm tra: tìm thấy gói Power BI đã cài → kết quả mong đợi: có số phiên bản.
- [ ] **Bước 4: Chạy thử Excel tự động**
  - Làm: script tạo file Excel mới, ghi đường dẫn vào ô `FolderPath`, thêm 1 truy vấn đọc file Flash, nạp vào sheet, làm mới, lưu. Chạy lại khi đổi sang thư mục khác.
  - Kiểm tra: đọc file đã lưu bằng Python → kết quả mong đợi: 156 dòng chi tiết, tổng 31.124.401; không có hộp thoại nào chặn.
- [ ] **Bước 5: Chạy thử Power BI tự động**
  - Làm: dự án Power BI tối thiểu gồm bảng ngày, bảng Flash, 1 quan hệ bị động, 1 công thức, 1 trang có ô số, biểu đồ thác nước và bộ lọc. Mở bằng Power BI Desktop, làm mới, hỏi số bằng DAX, chụp màn hình.
  - Kiểm tra: công thức trả về 31.124.401; ảnh chụp thấy trang báo cáo → kết quả mong đợi: biết cách nào chạy được.
- [ ] **Bước 6: Lập câu hỏi xin mentor**
  - Làm: ghi vào `plans/backlog.md`.
  - Kiểm tra: có đủ các câu trong `docs/ghi_chu_ky_thuat.md` và các điểm mới phát hiện (số làm tròn, file nộp Power BI).
- [ ] **Bước cuối: lưu lên GitHub**
  - Làm: plan này không có phần báo cáo riêng; bản mô tả cấu trúc dữ liệu sẽ được dùng ở phần II khi dựng khung báo cáo.
  - Kiểm tra: lời nhắn khi lưu ghi tên plan.

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
