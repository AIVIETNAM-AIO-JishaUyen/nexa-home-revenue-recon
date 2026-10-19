# Nạp và làm sạch dữ liệu bằng Power Query, khớp bảng tổng kiểm soát

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 2 – Nạp và làm sạch dữ liệu (phần nạp, kiểm tra tổng) |
| Mốc phải đạt | Mốc 2 (19/10) |
| Phần báo cáo liên quan | <ul><li>Phần II (Dữ liệu và chuẩn bị): 5 bẫy, bảng tổng kiểm soát</li><li>Phần III (Khám phá): chênh lệch theo tháng và kênh</li></ul> |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [setup-baseline](../completed/thanhlnp-18-10-2026-setup-baseline.md)</li><li>Plan tiếp theo dùng kết quả này: `python-check`, `transactions-quality`, `refresh-test`</li></ul> |

---

## 1. Mục tiêu

Có file Excel làm bằng Power Query (công cụ nạp và xử lý dữ liệu trong Excel) nạp đủ 4 file dữ liệu và 4 bảng danh mục qua **một ô đường dẫn thư mục**, xử lý đủ 5 bẫy, tự so với bảng tổng kiểm soát QC_Summary (QC = Quality Control, kiểm soát chất lượng) của đề, và cho ra chênh lệch theo năm, tháng, kênh khớp slide.

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
  - Nối mã cửa hàng bên POS (Point of Sale, bán tại cửa hàng) với mã NX bên kế toán qua bảng `store_master` → `transactions-quality` (ở đây chỉ nạp danh mục cửa hàng `q_Store`).
  - Đổi tiền ra USD (đô la Mỹ) cho từng giao dịch → `transactions-quality` (ở đây chỉ đổi để làm ví dụ bẫy 5).
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
| 13 chỉ tiêu của QC_Summary, cột chênh lệch | 0 cả 13 dòng | sheet QC_Summary | 0 cả 13 dòng, cột `dat` TRUE | sheet `Kiem_tra` | Đạt |
| Chênh lệch cả năm | −2.425.904,77 | `numbers_of_record.csv` (`tot_delta`) | −2.425.904,77 (−7,79% so với Flash) | sheet `Chenh_lech_thang`, dòng Cả năm | Đạt |
| Chênh lệch 12 tháng | 12 số `m01_delta`…`m12_delta` | `numbers_of_record.csv` | Khớp cả 12 tháng, cả Flash và sổ cái (lệch 0,00) | sheet `Chenh_lech_thang` | Đạt |
| Sổ cái theo 3 kênh | 13.181.898,25 / 15.515.347,98 / 1.250 | `numbers_of_record.csv` (`ch_gl_*`) | 13.181.898,25 / 15.515.347,98 / 1.250,00 | sheet `Chenh_lech_kenh` | Đạt |
| Chênh lệch theo 3 kênh (cửa hàng / online / chưa gắn kênh) | −878.601,75 / −1.548.553,02 / +1.250 | `numbers_of_record.csv` (`ch_delta_*`) | −878.601,75 / −1.548.553,02 / +1.250,00; Flash theo kênh 14.060.500 / 17.063.901 / 0 cũng khớp `ch_flash_*` | sheet `Chenh_lech_kenh` | Đạt |
| Tổng các kênh của sổ cái = tổng sổ cái | 28.698.496,23 | `numbers_of_record.csv` | 28.698.496,23; dòng kiểm tra = 0,00 | sheet `Chenh_lech_kenh`, dòng TOTAL và CHECK | Đạt |
| Dòng POS trùng | 12 dòng | slide 35 | 12 dòng, cửa hàng POS 74, ngày 29/03/2025, xuất lại 30/03/2025 08:42 | sheet `Bay_du_lieu`, dòng 4 | Đạt |

**Việc phải có (không phải con số):**
- [x] Mọi truy vấn nạp đọc file qua ô `FolderPath`, tìm file theo phần đầu tên, không ghi cứng đường dẫn hay năm.
- [x] Đổi kiểu số và ngày luôn ghi rõ vùng en-US (English – United States), để máy cài tiếng Việt vẫn đọc đúng.
- [x] Mỗi bước trong truy vấn có tên tiếng Việt dễ hiểu và có ghi chú.
- [x] Mỗi bẫy có 1 dòng ví dụ trước/sau ở sheet `Bay_du_lieu`, chỉ rõ truy vấn và tên bước.
- [x] Dựng lại file từ đầu bằng script, mở bằng Excel không có hộp thoại lỗi.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Ô ngày trống trong file WEB (đơn hủy không có ngày giao) | Đổi kiểu ngày báo lỗi ở 139 đơn hủy và các đơn không bị trả | <ul><li>Thay ô trống bằng null (ô rỗng, không có giá trị) trước khi đổi kiểu</li><li>Đếm số dòng lỗi sau khi đổi kiểu, phải bằng 0</li></ul> |
| Đọc ngày WEB theo vùng của máy | Máy để vùng Việt Nam đọc `12/13/2024` thành lỗi, `03/05/2025` thành 03/05 thay vì 05/03 | <ul><li>Luôn đổi kiểu với vùng en-US</li><li>Bảng bẫy đếm số đơn bị ảnh hưởng</li></ul> |
| Bỏ dòng tiêu đề Flash bằng số dòng cố định | Nếu file Flash tháng sau thêm 1 dòng tiêu đề thì đọc sai | Bỏ các dòng đầu cho đến khi gặp ô "Tháng" |
| Lọc dòng trùng làm mất 12 dòng trước khi so QC | Số dòng POS ra 17.112, lệch QC_Summary (17.124) | <ul><li>Giữ đủ 17.124 dòng, chỉ thêm cột cờ `is_duplicate`</li><li>Bước sau mới lọc</li></ul> |
| Tổng QC_Summary của POS và WEB cộng thẳng nhiều loại tiền | Tưởng là doanh thu | Ghi rõ trên sheet `Kiem_tra` là chỉ để kiểm tra nạp đủ |
| Excel tự động bị treo | Script không kết thúc | <ul><li>Script tự giới hạn thời gian</li><li>Chỉ tắt đúng Excel do nó mở</li></ul> |

---

## 7. Các bước

- [x] **Bước 1: Viết 4 truy vấn danh mục và 2 truy vấn đọc thô**
  - Làm: `q_Store`, `q_Calendar` (thêm cột `posting_date` = ngày làm việc gần nhất kể từ ngày đó), `q_FX_Daily`, `q_FX_MonthEnd`, `q_WEB_Raw`, `q_FLASH_Raw`.
  - Kiểm tra: số dòng 74 / 427 / 2.135 / 70; ngày 29/11/2025 (thứ bảy) có `posting_date` = 01/12/2025.
- [x] **Bước 2: Viết 4 truy vấn nạp dữ liệu, xử lý 5 bẫy**
  - Làm: `q_POS` (cờ dòng trùng, giữ đủ dòng), `q_WEB` (ngày kiểu Mỹ), `q_GL` (đổi dấu), `q_FLASH` (bỏ tiêu đề và dòng tổng, đổi tên cột sang tiếng Anh).
  - Kiểm tra: 17.124 / 9.441 / 6.940 / 156 dòng.
- [x] **Bước 3: Viết `q_Check`, `q_Traps`, `q_Delta_Month`, `q_Delta_Channel`**
  - Làm: so với QC_Summary; bảng 5 bẫy; chênh lệch tháng, kênh.
  - Kiểm tra: đọc file bằng Python, so với `numbers_of_record.csv`.
- [x] **Bước 4: Script dựng file và sheet hướng dẫn**
  - Làm: `excel/build_workbook.ps1` đọc `manifest.csv`, thêm truy vấn, nạp vào sheet, làm mới, lưu; tự giới hạn thời gian.
  - Kiểm tra: chạy script 2 lần liên tiếp đều ra file giống nhau, không treo.
- [x] **Bước 5: Kiểm tra theo điều kiện xong, ghi phần cho báo cáo**
  - Làm: điền mục 5; ghi nội dung cho phần II, III vào mục 12 để plan `report-skeleton` đưa vào báo cáo.
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [x] **Bước cuối: lưu vào Git (phần mềm lưu lịch sử sửa file) bằng lệnh commit**
  - Kiểm tra: lời nhắn khi lưu bắt đầu bằng `load-clean-data:`.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đo trước số liệu cho bảng 5 bẫy bằng Python | <ul><li>Đọc ngày đặt hàng online (cột `order_date`) theo kiểu ngày/tháng: 5.950 đơn lỗi, 3.215 đơn bị đảo ngày với tháng mà không báo lỗi</li><li>Flash thô 162 dòng, cộng thẳng cột doanh số ra 62.248.802</li></ul> | |
| 18/10 | Viết 14 truy vấn `.m`: 4 danh mục, 2 đọc thô, 4 nạp dữ liệu, 4 kiểm tra | <ul><li>`q_Calendar`: ngày 29/11/2025 và 30/11/2025 (thứ bảy, chủ nhật) có ngày ghi sổ 01/12/2025</li><li>Ngày 29/03/2025 (thứ bảy) ghi sổ 31/03/2025</li></ul> | Lệnh ghi nhiều file cùng lúc trong cửa sổ dòng lệnh bị lỗi, phải ghi từng file một |
| 18/10 | Viết script `excel/build_workbook.ps1` dựng file từ các file `.m` | Lần đầu: dựng được, nạp đúng sheet Flash (156 dòng) và Cua_hang (74 dòng) | |
| 18/10 | Thêm các truy vấn kiểm tra rồi dựng lại | Lần 2 (chạy với giới hạn 600 giây, tức 10 phút; mặc định của script là 900 giây): quá giờ, script tự dừng và tắt đúng Excel của nó | <ul><li>Nguyên nhân: bước đánh số lần xuất trong `q_POS` tạo 17 nghìn bảng nhỏ rồi ghép lại, và bị tính lại nhiều lần trong `q_Traps`</li><li>Sửa: đánh số thứ tự cả bảng một lần, gom nhóm theo khóa lấy số nhỏ nhất, ghép lại bằng `Table.Join`; giữ sẵn bảng trong bộ nhớ bằng `Table.Buffer` ở `q_Check`, `q_Traps`</li><li>Sau khi sửa: cả file dựng xong trong khoảng 110 giây</li></ul> |
| 18/10 | Kiểm tra kết quả bằng Python | <ul><li>13/13 chỉ tiêu QC_Summary lệch 0</li><li>12 tháng và cả năm khớp số chuẩn</li><li>3 kênh khớp, tổng các kênh = tổng sổ cái</li></ul> | |
| 18/10 | Dựng lại lần nữa, so 2 file | 9 sheet giống hệt nhau | |
| 18/10 | Trợ lý AI khác rà soát plan (chỉ đọc file đã lưu, không chạy Excel) | <ul><li>Tính lại từ `data/` bằng Python: 13 chỉ tiêu QC_Summary, 12 tháng, cả năm, 3 kênh, mọi số trên sheet `Bay_du_lieu`: khớp</li><li>Sheet `Lich`: 426/427 ngày có ngày ghi sổ giống cột `posting_date` của sheet dim_date trong `Nexa_Home_Recon_Dataset.xlsx`; riêng 31/01/2026 (thứ bảy, ngày cuối lịch) để trống vì lịch không còn ngày làm việc nào sau đó (dim_date ghi 02/02/2026). Không ảnh hưởng số năm 2025</li><li>Sửa nhỏ: thêm tên đầy đủ cho từ viết tắt, tách ô nhiều ý thành gạch đầu dòng, thêm dòng chênh lệch theo kênh vào mục 5; sửa `excel/huong_dan.txt` (tên cột `dat`, thêm sheet `Lich`)</li></ul> | Sheet `Huong_dan` trong file Excel chỉ đổi theo `excel/huong_dan.txt` sau khi chạy lại `excel/build_workbook.ps1` |
| 18/10 | Sửa theo rà soát: viết lại 14 truy vấn | <ul><li>Mọi bước (154 bước) có 1 dòng ghi chú `//` ngay phía trên; tên bước khó hiểu (`ThuMuc`, `WEBTho`, `FL`…) đổi thành tên tiếng Việt rõ nghĩa</li><li>Tìm file bằng `Folder.Contents` (chỉ trong thư mục, không tìm thư mục con) và báo lỗi rõ ràng nếu không có đúng 1 file khớp phần đầu tên</li><li>`q_Delta_Month`: ghép đủ tháng của cả hai bên, thêm dòng kiểm tra tổng các tháng − tổng cả file (= 0)</li><li>`q_Delta_Channel`: thêm dòng kiểm tra cửa hàng + online − tổng sổ cái = −1.250,00 (lộ ra bút toán không gắn kênh) và dòng tổng mọi kênh − tổng sổ cái = 0</li><li>`q_Traps`: bẫy 5 trỏ đúng bước đổi tiền; tách chữ ngày theo dấu "/"; số trống coi là 0; viết ngày theo vùng vi-VN</li></ul> | Dựng lại: mọi số không đổi, 13/13 chỉ tiêu QC vẫn đạt |
| 18/10 | Mở file bằng Excel (cửa sổ hiện ra) và chụp lại cửa sổ | <ul><li>Mở thẳng không có hộp thoại lỗi hay hỏi mức riêng tư</li><li>Sheet `Kiem_tra` và `Bay_du_lieu` hiện đủ số</li></ul> | Cột A từng bị giãn quá rộng theo dòng tiêu đề; sửa script chỉ giãn cột theo bảng |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Dòng POS trùng **không bị xóa** ở `q_POS`, chỉ thêm cột `is_duplicate` và `duplicate_reason` | <ul><li>Số dòng phải khớp QC_Summary (17.124)</li><li>Bảng cầu nối cần số tiền của dòng trùng (khoản "Dòng POS bị trùng")</li><li>Giữ dòng trùng làm bằng chứng khi vấn đáp</li></ul> | Không |
| 18/10 | Bỏ dòng tiêu đề Flash bằng cách bỏ các dòng đầu **cho đến khi gặp chữ "Tháng"**, không bỏ cố định 4 dòng | File tháng sau có thể thêm bớt dòng tiêu đề | Không |
| 18/10 | Thêm 2 truy vấn đọc thô `q_WEB_Raw`, `q_FLASH_Raw` (ngoài 8 truy vấn nạp) | <ul><li>Cần số "trước khi xử lý" cho bảng 5 bẫy</li><li>`q_WEB`, `q_FLASH` đọc tiếp từ 2 truy vấn này nên không đọc file 2 lần</li></ul> | Không |
| 18/10 | **File `.m` là bản gốc của truy vấn.** <ul><li>Muốn sửa truy vấn thì sửa file `.m` rồi chạy `excel/build_workbook.ps1`</li><li>Nếu lỡ sửa trong Excel thì chép code về file `.m`</li></ul> | Code nằm trong file chữ thì cả nhóm đọc, so sánh, kiểm tra được trên Git | Không |
| 18/10 | Chỉ nạp ra sheet các bảng kết quả nhỏ; bảng lớn (POS, WEB, sổ cái) để dạng chỉ kết nối | <ul><li>File nhẹ (khoảng 85 KB – kilobyte), mở nhanh</li><li>Bảng giao dịch chung sẽ được nạp ra sheet ở plan `transactions-quality`</li></ul> | Không |
| 18/10 | Mỗi truy vấn nạp chỉ tìm file trong đúng thư mục dữ liệu (không tìm thư mục con) và **bắt buộc có đúng 1 file** khớp phần đầu tên; sai thì báo lỗi ghi rõ có bao nhiêu file | <ul><li>Trước đây nếu thư mục có thêm file cũ hoặc file tháng mới, truy vấn lấy bừa file đầu tiên mà không báo</li><li>Báo lỗi rõ ràng thì người làm mới biết phải dọn thư mục</li><li>Cách giao dữ liệu tháng mới (thay file hay thêm file) chờ người dùng quyết: `plans/backlog.md` mục 3</li></ul> | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết code Power Query (ngôn ngữ M) cho 14 truy vấn | Toàn bộ `excel/queries/*.m` | <ul><li>Sheet `Kiem_tra` so tự động với QC_Summary: 13/13 đạt</li><li>Đọc file Excel bằng Python, so chênh lệch 12 tháng và 3 kênh với `numbers_of_record.csv`: khớp</li><li>Nhóm nên mở từng truy vấn trong Excel (Data > Queries &amp; Connections), bấm qua từng bước và đọc ghi chú</li></ul> |
| 18/10 | Viết script dựng file Excel | `excel/build_workbook.ps1` | Chạy 2 lần, 2 file kết quả giống hệt nhau |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi (slide 47):** Mở query và chỉ chỗ xử lý ngày MM/DD/YYYY. Nếu bỏ bước đó thì số nào sẽ đổi?
   **Trả lời:** Truy vấn `q_WEB`, bước "Đổi kiểu dữ liệu (ngày kiểu Mỹ, en-US)". Nếu bỏ và để Excel đọc theo kiểu Việt Nam (ngày/tháng) thì 5.950 đơn báo lỗi vì phần ngày lớn hơn 12, và 3.215 đơn bị đảo ngày với tháng mà không báo lỗi (sheet `Bay_du_lieu`, dòng 1; đếm trên ngày đặt `order_date`, ngày giao và ngày trả cũng bị sai theo cùng kiểu). Khi đó tháng đặt, tháng giao sai, nên chênh lệch theo tháng và khoản lệch thời điểm online sai.
2. **Hỏi (slide 47):** Dòng trùng nằm ở cửa hàng nào, ngày nào? Nhóm phát hiện ở bước nào trong query?
   **Trả lời:** 12 dòng ở cửa hàng có mã POS 74 (mã kế toán NX007), ngày bán 29/03/2025, bị xuất lại lúc 08:42 ngày 30/03/2025. Phát hiện ở truy vấn `q_POS`, bước "Lần xuất đầu tiên của mỗi khóa" và "Cờ dòng trùng": trong mỗi khóa receipt_no + line_no, dòng xuất sớm nhất được giữ, dòng xuất sau có cờ `is_duplicate` kèm lý do. Số tiền 12.622,20 USD (sau giảm giá, tỷ giá ngày bán).
3. **Hỏi (slide 47):** Nếu tháng sau có thêm một cửa hàng mới, file của nhóm phải sửa ở đâu?
   **Trả lời:** Chỉ thêm 1 dòng vào sheet `store_master` của file danh mục (mã POS, mã NX, nước, loại tiền). Không sửa truy vấn nào: các truy vấn tìm file theo phần đầu tên, còn việc nối mã cửa hàng POS với mã NX sẽ đi qua bảng `store_master` (làm trong `q_Transactions`, plan `transactions-quality`). Nếu cửa hàng mới dùng một loại tiền chưa có thì bảng tỷ giá cũng phải có loại tiền đó. Plan `refresh-test` sẽ chạy thử đúng tình huống này.
4. **Hỏi:** Vì sao trên sheet `Kiem_tra`, tổng line_amount 14.706.296,35 không phải doanh thu?
   **Trả lời:** Vì nó cộng thẳng 5 loại tiền (USD, EUR, GBP, CAD, AUD). Đề chỉ dùng số này để kiểm tra đã nạp đủ dòng. Đổi từng dòng ra USD theo tỷ giá ngày bán rồi mới cộng thì ra 14.060.501,00 USD (sheet `Bay_du_lieu`, dòng 5; tính cả 12 dòng trùng, vì Flash cũng tính cả dòng trùng), gần bằng Flash kênh cửa hàng 14.060.500 (Flash làm tròn từng dòng đến USD).

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 7 dòng số và 5 việc phải có (mục 5); việc "mỗi bước có ghi chú" đạt sau khi sửa theo rà soát (154/154 bước).
- **Nội dung cho báo cáo** (plan `report-skeleton` đưa vào):
  - **Phần II – Dữ liệu và chuẩn bị:**
    - Bảng 5 bẫy lấy từ sheet `Bay_du_lieu`: mỗi bẫy có truy vấn, tên bước, số trước và sau.
    - Kiểm tra tổng: 13/13 chỉ tiêu khớp QC_Summary `[QC]`.
    - Quyết định khi nạp: giữ dòng trùng có cờ, không xóa; đọc ô đường dẫn trong từng truy vấn; tìm file theo phần đầu tên.
  - **Phần III – Khám phá** (số lấy từ sheet `Chenh_lech_thang` và `Chenh_lech_kenh`):
    - Sổ cái thấp hơn Flash 2.425.904,77 USD, tức −7,79% so với Flash.
    - 11/12 tháng sổ cái thấp hơn Flash. Riêng tháng 3 sổ cái cao hơn 99.017,53 USD (+4,95%).
    - Lệch nặng nhất theo % là tháng 4 (−13,31%); theo số tiền là tháng 2 (−387.252,01).
    - Theo kênh: cửa hàng −878.601,75 (−6,25%), online −1.548.553,02 (−9,08%), chưa gắn kênh +1.250 (bút toán ADJ-0925, ADJ = Adjustment, bút toán điều chỉnh không có giấy tờ).
    - Tổng 3 kênh của sổ cái đúng bằng tổng sổ cái.
- **Việc còn lại:**
  - Bảng giao dịch chung (có nối mã cửa hàng POS với mã NX), đổi tiền từng dòng ra USD → `transactions-quality`.
  - Dòng bẫy 5 trên sheet `Bay_du_lieu` đã trỏ đúng bước đổi tiền trong `q_Traps`; khi có `q_Transactions` thì cân nhắc trỏ sang bước đổi tiền của bảng đó → `transactions-quality`.
  - Nếu khi chạy thử trên máy khác gặp lỗi "Formula.Firewall" ở `q_Check` (vừa đọc file vừa dùng truy vấn khác) thì tách phần đọc QC_Summary thành truy vấn riêng → `refresh-test`.
  - Chạy thử ở thư mục khác và với tháng mới → `refresh-test`.
- **Các lần lưu vào Git (commit):** `59abcf2` (tạo plan), `a211b40` (4 truy vấn danh mục), `aca7e37` (2 truy vấn đọc thô và 4 truy vấn nạp, xử lý 5 bẫy), `0182b23` (kiểm tra tổng, bảng bẫy, chênh lệch tháng và kênh), `52e42ca` (script dựng file, danh sách truy vấn, chữ sheet hướng dẫn), `c153ae8` (file Excel đã dựng), `01fd144` (ghi kết quả, quyết định, chuẩn bị vấn đáp), và các lần lưu sửa theo rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
