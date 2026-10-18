# Chạy thử làm mới ở thư mục khác với dữ liệu giả của tháng 01/2026 và một cửa hàng mới

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 2 – Nạp và làm sạch dữ liệu (chạy thử làm mới) |
| Mốc phải đạt | Mốc 4 (25/10): chạy thử làm mới đạt, trên máy khác và với dữ liệu giả của một tháng mới |
| Phần báo cáo liên quan | <ul><li>Phần II (dữ liệu và chuẩn bị: chạy lại cho tháng mới)</li><li>Phần VII (giới hạn: chưa thử trên máy thật thứ hai)</li></ul> |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [dax-bridge](../completed/thanhlnp-18-10-2026-dax-bridge.md)</li><li>Plan tiếp theo dùng kết quả này: `review-submit` (hướng dẫn chạy lại trong bộ file nộp)</li></ul> |

---

## 1. Mục tiêu

Chứng minh file Power Query **chạy lại được cho tháng mới chỉ bằng thay file dữ liệu rồi làm mới** (rubric – bảng tiêu chí chấm, mức Band 5), ở một thư mục khác, **không sửa truy vấn nào**: tháng 01/2026 và cửa hàng mới tự vào mọi bảng, các phép kiểm tra vẫn đạt.

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
| Sheet `Kiem_tra` (13 chỉ tiêu, so với QC_Summary mới) | 13/13 đạt | QC_Summary do script sinh dữ liệu ghi | 13/13 đạt | file đã làm mới | Đạt |
| Sheet `Chat_luong_du_lieu` | Chỉ phép 1 (dòng trùng) đổi, thêm đúng 1 dòng giả | Script sinh dữ liệu | Phép 1: 12 → 13; 12 phép còn lại giữ nguyên | như trên | Đạt |
| Bảng cầu nối: số tháng, dòng kiểm tra | 13 tháng; mọi bảng × tháng ≤ 1 USD (đô la Mỹ) | Điều kiện của plan tổng | 13 tháng (767 dòng); 52 bảng × tháng, lớn nhất 0,000000 USD | sheet `BR_Long`, `Canh_bao_cau_noi` | Đạt |
| 12 tháng năm 2025 của `BR_Long` | Giống hệt file gốc | `excel/Nexa_Home_Recon_PQ.xlsx` | 708/708 dòng (so cả hai chiều), lệch 0 | như trên | Đạt |
| Tháng 01/2026: <ul><li>Flash, sổ cái, chiết khấu, dòng trùng, đơn hủy, lệch thời điểm online, hàng trả, phí vận chuyển</li><li>3 khoản phải bằng 0: lệch ngày ghi sổ, lỗi chuyển dữ liệu, chưa giải thích được</li></ul> | Số mong đợi | `checks/refresh_test/expected_2026_01.csv` | 11/11 khoản, lệch 0,00 | như trên | Đạt |
| Đối soát cửa hàng × ngày, online × ngày × loại tiền của tháng 01/2026 (kể cả NX068) | Mọi ô khớp | Dữ liệu giả sinh sổ cái đúng bằng POS (Point of Sale, bán tại cửa hàng) và đơn online | <ul><li>Cửa hàng: 59/59 ô (NX068: 19 ô)</li><li>Online: 88/88 ô</li><li>Hàng trả: 9/9 ô</li></ul> | sheet `Doi_soat_CH_ngay`, `Doi_soat_online`, `Doi_soat_hang_tra` | Đạt |

**Việc phải có (không phải con số):**
- [x] Không sửa file truy vấn nào; chỉ thay file dữ liệu và sửa ô `FolderPath`.
- [x] Bản sao nằm ở đường dẫn khác hẳn thư mục dự án.
- [x] Ghi lại thời gian làm mới.

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

- [x] **Bước 1: Viết `make_fake_month.py`, sinh bản sao dữ liệu và số mong đợi**
  - Kiểm tra: đọc lại các file giả bằng pandas, đúng số dòng thêm vào.
- [x] **Bước 2: Viết `refresh_workbook.ps1`, chép file Excel sang bản sao, làm mới**
  - Kiểm tra: làm mới xong không lỗi, ghi thời gian.
- [x] **Bước 3: Viết `check_refresh.py`, so kết quả**
- [x] **Bước 4: Viết kết quả vào báo cáo phần II, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc file danh mục, 4 file dữ liệu | <ul><li>Lịch, tỷ giá ngày, tỷ giá cuối tháng có đến 31/01/2026</li><li>File online đã có 105 đơn giao và 7 đơn trả trong tháng 01/2026; sổ cái năm 2025 chưa có bút toán nào của tháng này</li><li>Mã cửa hàng lớn nhất NX067 (mã POS 670); NX068 còn trống</li></ul> | |
| 18/10 | Viết `make_fake_month.py`, sinh bản sao dữ liệu ở thư mục tạm của phiên làm việc | <ul><li>POS thêm 259 dòng (1 hóa đơn trùng), online thêm 96 đơn (3 hủy, 2 trả), sổ cái thêm 157 bút toán, Flash thêm 8 dòng</li><li>Số mong đợi tháng 01/2026 (USD): Flash 468.890, sổ cái 567.717,89, lệch thời điểm online +174.705,79 (đúng bằng 105 đơn đặt 12/2025 giao 01/2026)</li></ul> | Dòng trùng của file thật là cả hóa đơn xuất lại sáng hôm sau; dữ liệu giả làm giống vậy |
| 18/10 | Viết `refresh_workbook.ps1`, làm mới bản sao (sửa ô `FolderPath`, Refresh All) | Làm mới toàn bộ chỉ mất 174 giây (script này có bật bỏ qua mức riêng tư) | Bất ngờ: dựng file từ đầu mất khoảng 55 phút |
| 18/10 | Viết `check_refresh.py`, so kết quả | 11/11 phép so đạt, ghi ở `checks/refresh_test/ket_qua_2026_01.txt` | |
| 18/10 | Tìm vì sao dựng chậm mà làm mới nhanh; sửa `build_workbook.ps1` | <ul><li>Lần dựng đầu sau khi đổi sang một lần Refresh All (chưa bật bỏ qua mức riêng tư) vẫn quá giờ 30 phút</li><li>Thêm bật bỏ qua mức riêng tư (FastCombine): dựng từ đầu còn 325 giây, bước làm mới trong 2 lần dựng mất 270 và 172 giây</li><li>Vậy nguyên nhân chính là phần kiểm tra mức riêng tư. Chưa đo riêng cách làm mới từng bảng khi đã bật bỏ qua mức riêng tư, nên chưa biết làm mới một lần giúp thêm bao nhiêu</li><li>24 sheet bảng giống hệt file cũ; sheet `Nhat_ky_ngoai_le` chỉ khác ở chỗ 2 dòng ghi chú cuối dời xuống 1 dòng (lần dựng trước nhật ký có 17 dòng, nay 18 dòng)</li></ul> | Plan tổng có ghi bật FastCombine nhưng script dựng chưa bao giờ bật; `refresh_workbook.ps1` có bật nên làm mới nhanh. Backlog mục 8 đã xử lý |
| 18/10 | Viết mục II.8, sửa sheet hướng dẫn (thời gian làm mới, cách thay file tháng mới) | | |
| 18/10 | Rà soát plan (AI làm) | <ul><li>Tính lại độc lập 11 khoản tháng 01/2026 và cả tỷ giá (−16.640,78), làm tròn (−0,23) từ các file giả: khớp</li><li>Đếm lại ô đối soát (59 / 88 / 9), 24 sheet bảng so với bản trước khi dựng lại: khớp</li></ul> | <ul><li>`check_refresh.py`: phép 12 tháng năm 2025 so thêm chiều ngược (file mới không thừa dòng); phép file mẫu đếm số cột tháng thay vì ghi cứng; kết quả vẫn đạt</li><li>Sửa ghi chú thời gian trong 2 script `.ps1` (trước ghi "khoảng 1 giờ", và gán việc nhanh lên cho làm mới một lần, chưa đo)</li><li>Thêm giới hạn Power BI vào II.8</li></ul> |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Dữ liệu tháng mới đưa vào bằng cách **thay file** (file mới chứa cả dữ liệu cũ, giữ phần đầu tên), không đặt thêm file thứ hai cạnh file cũ | Đúng cách rubric mô tả ("thay file rồi refresh"); truy vấn hiện đọc đúng 1 file mỗi loại. Chạy thử với 4 tên file mới đều đọc đúng | Không (backlog mục 3 vẫn để người dùng chốt) |
| 18/10 | Sổ cái giả được sinh để khớp đúng POS và đơn online | Mục đích là thử cách nạp và các phép tính chạy đúng cho tháng mới; lỗi dữ liệu cố ý chỉ có 1 hóa đơn trùng để xem phép kiểm tra có bắt được không | Không |
| 18/10 | Bật bỏ qua mức riêng tư (FastCombine) trong file Power Query; làm mới một lần cho mọi bảng khi dựng | Mọi nguồn là file trên máy nên bỏ qua an toàn; thời gian dựng giảm từ khoảng 55 phút xuống khoảng 5 phút | Không |
| 18/10 | Không thử làm mới Power BI với tháng mới | Power BI đọc file dữ liệu mentor chuẩn bị (chỉ năm 2025), không có bản tháng mới để thay; ghi ở giới hạn | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Sinh dữ liệu giả, viết script làm mới và script so, tìm nguyên nhân dựng chậm, viết mục II.8 | `checks/refresh_test/*.py`, `excel/refresh_workbook.ps1`, phần sửa trong `build_workbook.ps1`, mục II.8 | <ul><li>Số mong đợi tính thẳng từ dữ liệu giả bằng pandas, không qua Power Query</li><li>So 24 sheet bảng của file dựng lại với file cũ: giống hệt</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Tháng sau chạy lại thế nào?
   **Trả lời:** Thay 4 file trong thư mục dữ liệu bằng bản mới (giữ phần đầu tên, mỗi loại 1 file). File danh mục cũng phải là bản mới: có lịch và tỷ giá của tháng mới, có cửa hàng mới (nếu có), và bảng QC_Summary của tháng mới để sheet `Kiem_tra` so. Mở file Excel, chọn Data > Refresh All, chờ khoảng 3–5 phút, xem sheet `Kiem_tra`, `Chat_luong_du_lieu` và `Canh_bao_cau_noi`. Kỳ đối soát lấy theo các tháng có trong Flash nên tự dài ra. Nhóm đã chạy thử với tháng 01/2026 giả và một cửa hàng mới: không sửa truy vấn nào, mọi phép kiểm tra đạt.
2. **Hỏi:** Đổi máy thì sao?
   **Trả lời:** Chỉ sửa ô `Cai_dat!B2` (đường dẫn thư mục dữ liệu). Đã thử với một thư mục khác hẳn; chưa thử trên một máy thật thứ hai.
3. **Hỏi:** Có điều gì bất ngờ?
   **Trả lời:** Làm mới chỉ mất 3 phút, trong khi script dựng file từ đầu mất 55 phút. Script dựng chưa bật bỏ qua mức riêng tư và làm mới từng bảng riêng. Chỉ đổi sang làm mới một lần thì vẫn quá 30 phút; bật thêm bỏ qua mức riêng tư thì dựng từ đầu còn khoảng 5 phút. Vậy nguyên nhân chính là phần kiểm tra mức riêng tư; nhóm chưa đo riêng phần do làm mới từng bảng.
4. **Hỏi:** Dữ liệu tháng mới có thể làm hỏng file ở đâu?
   **Trả lời:** Ba chỗ: lịch phải có đến ngày làm việc đầu tiên của tháng sau (phép kiểm tra 12 sẽ báo nếu thiếu); bảng tỷ giá phải có tỷ giá cuối tháng mới (phép 11); sheet `Cau_noi` của file mẫu chỉ có 12 cột tháng 2025.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 6 dòng số và 3 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục II.8 (chạy thử với một tháng mới, bốn giới hạn).
- **Việc còn lại:**
  - Chạy trên máy thật thứ hai → backlog mục 2 (cần người dùng).
  - Phần VII (giới hạn) chưa viết: khi viết, nhắc lại hai giới hạn chưa thử trên máy thứ hai và chưa làm mới Power BI với tháng mới → `conclusions` (plan viết phần V–VII).
  - Sheet hướng dẫn (`excel/huong_dan.txt`): danh sách sheet chưa có các sheet thêm từ plan 7 trở đi → `review-submit`. Bước 2 (file danh mục cũng phải là bản mới) đã sửa sau rà soát và dựng lại file Excel.
  - Quy ước "kỳ đối soát = các tháng có trong Flash" đã ghi vào file quy ước (trước đây chỉ có trong ghi chú truy vấn).
- **Các lần lưu vào Git (commit):** `3751a3f` (tạo plan), `3ffcf1c` (sinh dữ liệu giả, số mong đợi), `f393615` (dựng nhanh, sheet hướng dẫn, file Excel), `653b74f` (script làm mới, script so, kết quả), `18e2471` (báo cáo II.8), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
