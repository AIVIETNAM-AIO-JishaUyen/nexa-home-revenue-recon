# Nạp và làm sạch dữ liệu bằng Power Query, khớp bảng tổng kiểm soát

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 2 – Nạp và làm sạch dữ liệu (phần nạp, kiểm tra tổng) |
| Mốc phải đạt | Mốc 2 (19/10) |
| Phần báo cáo liên quan | <ul><li>Phần II (Dữ liệu và chuẩn bị): 5 bẫy, bảng tổng kiểm soát</li><li>Phần III (Khám phá): chênh lệch theo tháng và kênh</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [setup-baseline](../completed/thanhlnp-18-10-2026-setup-baseline.md)</li><li>Plan tiếp theo dùng kết quả này: `python-check`, `transactions-quality`, `refresh-test`</li></ul> |

---

## 1. Mục tiêu

Có file Excel làm bằng Power Query (công cụ nạp và xử lý dữ liệu trong Excel) nạp đủ 4 file dữ liệu và 4 bảng danh mục qua **một ô đường dẫn thư mục**, xử lý đủ 5 bẫy, tự so với bảng tổng kiểm soát QC_Summary của đề, và cho ra chênh lệch theo năm, tháng, kênh khớp slide.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Sheet `Cai_dat` có ô `FolderPath` (đường dẫn thư mục dữ liệu).
  - 8 truy vấn nạp: `q_POS`, `q_WEB`, `q_GL`, `q_FLASH`, `q_Store`, `q_Calendar`, `q_FX_Daily`, `q_FX_MonthEnd`; thêm 2 truy vấn đọc thô `q_WEB_Raw`, `q_FLASH_Raw` để làm ví dụ "trước khi xử lý".
  - Sheet `Kiem_tra` (truy vấn `q_Check`): so 13 chỉ tiêu với QC_Summary.
  - Sheet `Bay_du_lieu` (truy vấn `q_Traps`): mỗi bẫy 1 dòng, có số trước và sau khi xử lý, chỉ rõ truy vấn và bước xử lý.
  - Sheet `Chenh_lech_thang`, `Chenh_lech_kenh` (truy vấn `q_Delta_Month`, `q_Delta_Channel`).
  - Sheet `Huong_dan`: cách đổi đường dẫn, cách làm mới, ý nghĩa từng sheet.
  - Mỗi truy vấn lưu thành file `.m` (file code của Power Query) trong `excel/queries/`, và một script dựng lại cả file Excel từ các file `.m`.
- **Không làm (để cho plan khác):**
  - Bảng giao dịch chung `q_Transactions`, sheet chất lượng dữ liệu → `transactions-quality`.
  - Đổi tiền ra USD cho từng giao dịch → `transactions-quality` (ở đây chỉ đổi để làm ví dụ bẫy 5).
  - Chạy thử làm mới với dữ liệu tháng mới → `refresh-test`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| 4 file dữ liệu, 1 file danh mục | `data/` | Không sửa |
| Bản mô tả cấu trúc dữ liệu | `docs/cau_truc_du_lieu.md` | Tên truy vấn, tên cột |
| Bảng số chuẩn | `checks/numbers_of_record.csv` | Số tháng, kênh để so |
| Kết quả chạy thử Excel tự động | [plan setup-baseline](../completed/thanhlnp-18-10-2026-setup-baseline.md), mục 8 và 9 | Cách dựng file bằng script |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash. % chênh lệch trên bảng tháng chia cho Flash.
- Sổ cái là nguồn chuẩn; doanh thu sổ cái đổi dấu thành số dương.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| File Excel Power Query | `excel/Nexa_Home_Recon_PQ.xlsx` | Mọi plan Power Query sau; file nộp |
| Code các truy vấn | `excel/queries/*.m` | Đọc, kiểm tra, phụ lục báo cáo |
| Danh sách truy vấn và sheet nạp | `excel/queries/manifest.csv` | Script dựng file |
| Script dựng file | `excel/build_workbook.ps1` | Dựng lại file sau mỗi lần sửa `.m` |
| Chữ cho sheet hướng dẫn | `excel/huong_dan.txt` | Script dựng file |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| 13 chỉ tiêu của QC_Summary, cột chênh lệch | 0 cả 13 dòng | sheet QC_Summary | | sheet `Kiem_tra` | |
| Chênh lệch cả năm | −2.425.904,77 | `numbers_of_record.csv` (`tot_delta`) | | sheet `Chenh_lech_thang` | |
| Chênh lệch 12 tháng | 12 số `m01_delta`…`m12_delta` | `numbers_of_record.csv` | | sheet `Chenh_lech_thang` | |
| Sổ cái theo 3 kênh | 13.181.898,25 / 15.515.347,98 / 1.250 | `numbers_of_record.csv` (`ch_gl_*`) | | sheet `Chenh_lech_kenh` | |
| Tổng các kênh của sổ cái = tổng sổ cái | 28.698.496,23 | `numbers_of_record.csv` | | sheet `Chenh_lech_kenh` | |
| Dòng POS trùng | 12 dòng | slide 35 | | `q_POS`, cột `is_duplicate` | |

**Việc phải có (không phải con số):**
- [ ] Mọi truy vấn nạp đọc file qua ô `FolderPath`, tìm file theo phần đầu tên, không ghi cứng đường dẫn hay năm.
- [ ] Đổi kiểu số và ngày luôn ghi rõ vùng en-US (English – United States), để máy cài tiếng Việt vẫn đọc đúng.
- [ ] Mỗi bước trong truy vấn có tên tiếng Việt dễ hiểu và có ghi chú.
- [ ] Mỗi bẫy có 1 dòng ví dụ trước/sau ở sheet `Bay_du_lieu`, chỉ rõ truy vấn và tên bước.
- [ ] Dựng lại file từ đầu bằng script, mở bằng Excel không có hộp thoại lỗi.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Ô ngày trống trong file WEB (đơn hủy không có ngày giao) | Đổi kiểu ngày báo lỗi ở 139 đơn hủy và các đơn không bị trả | Thay ô trống bằng null trước khi đổi kiểu; đếm số ô lỗi phải bằng 0 |
| Đọc ngày WEB theo vùng của máy | Máy để vùng Việt Nam đọc `12/13/2024` thành lỗi, `03/05/2025` thành 03/05 thay vì 05/03 | Luôn đổi kiểu với vùng en-US; bảng bẫy đếm số dòng bị ảnh hưởng |
| Bỏ dòng tiêu đề Flash bằng số dòng cố định | Nếu file Flash tháng sau thêm 1 dòng tiêu đề thì đọc sai | Bỏ các dòng đầu cho đến khi gặp ô "Tháng" |
| Lọc dòng trùng làm mất 12 dòng trước khi so QC | Số dòng POS ra 17.112, lệch QC_Summary (17.124) | Giữ đủ 17.124 dòng, chỉ thêm cột cờ `is_duplicate`; bước sau mới lọc |
| Tổng QC_Summary của POS và WEB cộng thẳng nhiều loại tiền | Tưởng là doanh thu | Ghi rõ trên sheet `Kiem_tra` là chỉ để kiểm tra nạp đủ |
| Excel tự động bị treo | Script không kết thúc | Script tự giới hạn thời gian, chỉ tắt đúng Excel do nó mở |

---

## 7. Các bước

- [ ] **Bước 1: Viết 4 truy vấn danh mục và 2 truy vấn đọc thô**
  - Làm: `q_Store`, `q_Calendar` (thêm cột `posting_date` = ngày làm việc gần nhất kể từ ngày đó), `q_FX_Daily`, `q_FX_MonthEnd`, `q_WEB_Raw`, `q_FLASH_Raw`.
  - Kiểm tra: số dòng 74 / 427 / 2.135 / 70; ngày 29/11/2025 (thứ bảy) có `posting_date` = 01/12/2025.
- [ ] **Bước 2: Viết 4 truy vấn nạp dữ liệu, xử lý 5 bẫy**
  - Làm: `q_POS` (cờ dòng trùng, giữ đủ dòng), `q_WEB` (ngày kiểu Mỹ), `q_GL` (đổi dấu), `q_FLASH` (bỏ tiêu đề và dòng tổng, đổi tên cột sang tiếng Anh).
  - Kiểm tra: 17.124 / 9.441 / 6.940 / 156 dòng.
- [ ] **Bước 3: Viết `q_Check`, `q_Traps`, `q_Delta_Month`, `q_Delta_Channel`**
  - Làm: so với QC_Summary; bảng 5 bẫy; chênh lệch tháng, kênh.
  - Kiểm tra: đọc file bằng Python, so với `numbers_of_record.csv`.
- [ ] **Bước 4: Script dựng file và sheet hướng dẫn**
  - Làm: `excel/build_workbook.ps1` đọc `manifest.csv`, thêm truy vấn, nạp vào sheet, làm mới, lưu; tự giới hạn thời gian.
  - Kiểm tra: chạy script 2 lần liên tiếp đều ra file giống nhau, không treo.
- [ ] **Bước 5: Kiểm tra theo điều kiện xong, ghi phần cho báo cáo**
  - Làm: điền mục 5; ghi nội dung cho phần II, III vào mục 12 để plan `report-skeleton` đưa vào báo cáo.
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [ ] **Bước cuối: lưu vào Git (commit)**
  - Kiểm tra: lời nhắn khi lưu bắt đầu bằng `load-clean-data:`.

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
