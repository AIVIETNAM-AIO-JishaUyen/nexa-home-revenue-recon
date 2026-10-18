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

Điền **file mẫu nộp của đề** (sheet `Cau_noi`, `Nhat_ky_ngoai_le`) mà **không gõ tay ô số nào**: ô vàng lấy số từ bảng cầu nối dạng dài bằng công thức SUMIFS (hàm Excel cộng các dòng thỏa nhiều điều kiện), nhật ký ngoại lệ sinh từ một truy vấn. Thêm bảng cho thấy số của từng khoản đổi thế nào nếu đổi thứ tự các bước, để giải thích vì sao nhóm chốt thứ tự hiện tại.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - `q_ExceptionLog`: nhật ký ngoại lệ, mỗi khoản lệch một dòng, đủ 10 cột của file mẫu; số tiền và mô tả lấy từ các bảng đã có; tổng cột tiền = tổng chênh lệch cả năm.
  - `q_OrderSwap`: 3 cách đổi thứ tự các bước, mỗi cách cho số cũ và số mới của hai khoản bị ảnh hưởng; tổng không đổi.
  - Sửa `excel/build_workbook.ps1`: chép sheet `Cau_noi` và `Nhat_ky_ngoai_le` của file mẫu vào file Power Query; ô vàng dùng SUMIFS đọc bảng `q_BR_Long`; thêm `Cau_noi_cua_hang`, `Cau_noi_online` cùng bố cục (thêm 1 dòng chuyển kênh); nhật ký dùng công thức INDEX (hàm Excel lấy giá trị theo số dòng, số cột) đọc bảng `q_ExceptionLog`, bỏ dòng ví dụ EX-00 (EX = Exception, ngoại lệ).
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
| `Cau_noi` dòng 16 (kiểm tra) 12 tháng và cả năm | 0 | file mẫu | 0 (13/13 ô) | sheet `Cau_noi` (đọc lại bằng Excel sau khi tính) | Đạt |
| `Cau_noi` cột cả năm: Flash / sổ cái / chưa giải thích | 31.124.401 / 28.698.496,23 / 1.250 | `numbers_of_record.csv` (`br_y_*`) | 31.124.401 / 28.698.496,23 / 1.250 | như trên | Đạt |
| `Cau_noi_cua_hang`, `Cau_noi_online` dòng kiểm tra | 0 | file mẫu | 0 (13/13 ô mỗi sheet) | 2 sheet đó | Đạt |
| Tổng cột tiền của nhật ký | −2.425.904,77 | `numbers_of_record.csv` (`tot_delta`) | −2.425.904,77 (18 dòng) | sheet `Nhat_ky_du_lieu` | Đạt |
| Đổi thứ tự: dòng trùng theo giá trước giảm giá | −13.695,13 | file quy ước | −13.695,13 | sheet `Doi_thu_tu` | Đạt |
| Đổi thứ tự: hàng trả tính sau tỷ giá (tỷ giá cuối tháng của sổ cái, chưa làm tròn) | −349.066,20 (sổ cái ghi −349.066,23 sau khi làm tròn từng bút toán; 0,03 nằm ở dòng làm tròn) | `numbers_of_record.csv` (`det_returns_gl`) | −349.066,20 | như trên | Đạt |

**Việc phải có (không phải con số):**
- [x] Không ô số nào trong `Cau_noi*` và `Nhat_ky_ngoai_le` gõ tay; dòng EX-00 đã xóa.
- [x] Nhật ký có đủ các dòng ở mục 3 file quy ước; mỗi dòng có người phụ trách và trạng thái theo slide 40.
- [x] Mọi bước có tên tiếng Việt và ghi chú `//`; không ghi cứng năm trong truy vấn.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| File mẫu có 10 dòng khoản, bảng theo kênh có 11 khoản | Thiếu dòng chuyển kênh, kiểm tra khác 0 ở tháng 6 | Chèn 1 dòng vào sheet theo kênh; kiểm tra dòng 16/17 bằng 0 |
| Công thức tham chiếu sai tên bảng | `#REF!` hoặc 0 khắp nơi | Đọc lại giá trị đã tính bằng pandas (thư viện Python đọc bảng) sau khi dựng |
| Nhật ký đếm trùng (ví dụ ghi cả lệch thời điểm cả năm lẫn hai phần vắt qua năm) | Tổng cột tiền khác tổng chênh lệch | Thiết kế để tổng nhật ký = tổng chênh lệch; kiểm tra bằng pandas |

---

## 7. Các bước

- [x] **Bước 1: Viết `q_ExceptionLog`, `q_OrderSwap`**
  - Kiểm tra: tổng nhật ký = −2.425.904,77; 3 dòng đổi thứ tự có tổng thay đổi = 0.
- [x] **Bước 2: Sửa `build_workbook.ps1` để chép và điền file mẫu**
  - Kiểm tra: dòng kiểm tra của 3 sheet cầu nối bằng 0; nhật ký hiện đủ dòng.
- [x] **Bước 3: Viết báo cáo (IV.4 đoạn cuối, phụ lục B, E), lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc file mẫu nộp bằng openpyxl (thư viện Python đọc file Excel), đọc slide 10, 31, 40 | <ul><li>`Cau_noi`: 10 dòng khoản + "Chưa giải thích được"; dòng 14 cộng, dòng 16 = ROUND(dòng 14 − dòng 15, 2)</li><li>Nhật ký 10 cột; slide 40 có 4 trạng thái và ví dụ EX-02, EX-06, EX-07, EX-10</li></ul> | |
| 18/10 | Viết `q_ExceptionLog`, `q_OrderSwap`; sửa `build_workbook.ps1` để chép 2 sheet của file mẫu và điền công thức | <ul><li>Nhật ký 17 dòng, tổng −2.425.904,77</li><li>Đổi thứ tự: dòng trùng −13.695,13; đơn hủy −230.286,39; hàng trả −349.652,76, tỷ giá thành −57.093,48</li></ul> | Lần dựng đầu quá giờ 40 phút. Thêm in số giây mỗi truy vấn rồi dựng lại với giới hạn 90 phút: xong sau khoảng 55 phút, chậm nhất là `q_RC_Store_DayCompare` (446 giây), `q_DataQuality` (394 giây), `q_BR_Long` (335 giây). Mỗi bảng nạp tự tính lại các truy vấn nó dùng từ đầu, nên thêm bảng là thêm thời gian. Ghi vào backlog, xem lại ở plan `refresh-test` |
| 18/10 | Đọc lại file đã dựng bằng openpyxl (giá trị đã tính) | <ul><li>Dòng kiểm tra của `Cau_noi`, `Cau_noi_cua_hang`, `Cau_noi_online` bằng 0 ở 12 tháng và cả năm</li><li>Cột cả năm `Cau_noi` khớp số chuẩn từng khoản</li><li>`Nhat_ky_ngoai_le` hiện đủ 17 dòng, không còn EX-00</li></ul> | Bảng đổi thứ tự làm tròn riêng hai số "khi đổi" nên dòng 1 hiện −1.072,93 và +1.072,92. Sửa: số mới của khoản thứ hai = số cũ − phần đã chuyển sang khoản thứ nhất, tính sau khi làm tròn; cột tổng thay đổi vẫn tính từ số chưa làm tròn để kiểm tra |
| 18/10 | Viết đoạn cuối IV.4, phụ lục B, E; chuyển ra PDF | Bảng nhật ký dài nhiều trang (bảng longtable), bảng đổi thứ tự 6 dòng | |
| 18/10 | Rà soát: đọc lại file đã dựng (giá trị và công thức), đối chiếu lời văn nhật ký với các sheet `Giao_dich_chung`, `Doi_soat_CH_ngay`, `Lech_ngay_ghi_so`, `Lech_thoi_diem_online`, `BR_Long` và file dữ liệu gốc | <ul><li>Cả 6 dòng số ở mục 5 đạt; không ô số nào gõ tay; không còn EX-00</li><li>Số đơn, số dòng, cửa hàng, ngày, mã bút toán trong nhật ký đều khớp dữ liệu</li></ul> | <ul><li>Sửa lời văn trong `q_ExceptionLog.m`: tháng viết dạng mm/yyyy; EX-10 thêm ghi chú sổ cái tháng 11 đã khóa mà vẫn thiếu (mục 3 file quy ước yêu cầu); EX-11, EX-17 thêm diễn giải của bút toán trên sổ cái (EX-17 nay hiện tên ADJ-0925); EX-16 thêm tháng làm tròn lớn nhất; EX-12 viết lại cho rõ</li><li>Phải dựng lại file Excel rồi chạy `make_figures.py` thì sheet và Phụ lục B mới có lời văn mới (số không đổi)</li><li>Hai việc cần người dùng quyết: backlog mục 10 (cách đổi thứ 3 của bảng đổi thứ tự), mục 11 (dòng rủi ro hàng trả tháng 01/2026)</li></ul> |
| 18/10 | Sửa theo rà soát: cách đổi thứ 3 của bảng đổi thứ tự, thêm dòng rủi ro hàng trả sau kỳ vào nhật ký; làm mới riêng 2 truy vấn trên file đã dựng | <ul><li>Cách 3: hàng trả −349.066,20, tỷ giá −57.680,04, tổng thay đổi 0</li><li>Nhật ký 18 dòng (thêm EX-13: 7 đơn trả tháng 01/2026, 22.136,44 USD, ghi 0), tổng vẫn −2.425.904,77; ADJ-0925 thành EX-18</li></ul> | Làm mới riêng 1 truy vấn vẫn mất 7–14 phút vì truy vấn tự tính lại `q_BR_Long` |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Sheet `Cau_noi` giữ đúng 10 dòng khoản của file mẫu; hai sheet theo kênh chèn thêm dòng "Chuyển kênh (MJ-RCL)" (MJ-RCL = Manual Journal – Reclassification, bút toán tay phân loại lại doanh thu giữa hai kênh) | Toàn công ty không có khoản chuyển kênh (cửa hàng −3.480, online +3.480 cộng lại bằng 0); theo kênh thì thiếu dòng này dòng kiểm tra tháng 6 sẽ khác 0 | Không |
| 18/10 | Cột P của sheet cầu nối ghi mã khoản, công thức SUMIFS đọc mã ở cột này | Tên khoản là chữ tiếng Việt dễ đổi; mã khoản cố định. Người đọc thấy ngay ô nào lấy khoản nào | Không |
| 18/10 | Nhật ký: lệch thời điểm online tách 3 dòng (tự bù trừ trong năm = 0, đầu kỳ +122.107,89, cuối kỳ −174.705,79); 3 cặp lệch ngày ghi sổ ghi 0 | Để cột "Ảnh hưởng (USD)" (USD = đô la Mỹ) cộng lại đúng chênh lệch cả năm; nếu ghi cả tổng lẫn chi tiết thì bị đếm hai lần | Không |
| 18/10 | Lỗi chuyển dữ liệu NX057 ghi 2 dòng (tháng 11 −7.227,56, tháng 12 +7.227,56), trạng thái "Đã sửa kỳ sau" | Mỗi tháng thấy được một dòng; hai dòng cộng lại bằng 0 đúng như số cả năm | Không |
| 18/10 | Dòng POS (Point of Sale, bán tại cửa hàng) trùng: "Cần sửa nguồn"; ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh): "Chờ phản hồi"; các khoản do quy tắc ghi nhận: "Đã giải thích" | Theo 4 trạng thái của slide 40. Dòng trùng là lỗi xuất dữ liệu của POS, phải chặn ở nguồn; ADJ-0925 chưa có chứng từ | Không |
| 18/10 | Khoản cả năm ghi kỳ "2025-01 đến 2025-12" (lấy tháng đầu, tháng cuối của Flash), không ghi một tháng | File mẫu chỉ có ví dụ một tháng; khoản cả năm không thuộc riêng tháng nào. Ghi vào backlog để người dùng quyết | Không |
| 18/10 | (Sau rà soát) Cách đổi thứ 3 của bảng đổi thứ tự: hàng trả tính sau tỷ giá thì đo theo tỷ giá cuối tháng của sổ cái (−349.066,20), dòng tỷ giá thành −57.680,04 | <ul><li>Bản đầu dùng tỷ giá ngày trả (−349.652,76): đó là đổi cách chọn tỷ giá, không phải đổi thứ tự</li><li>Khi dòng tỷ giá đứng trước, mọi giao dịch đã được đưa về tỷ giá cuối tháng của sổ cái, nên khoản đứng sau phải đo theo tỷ giá đó</li></ul> | Không (file quy ước đã có cả 3 số hàng trả) |
| 18/10 | (Sau rà soát) Thêm dòng nhật ký "rủi ro cần theo dõi": 7 đơn giao trong kỳ bị trả tháng 01/2026, ghi 0 USD, nhóm "Quy tắc ghi nhận", trạng thái "Đã giải thích", hướng xử lý "Theo dõi kỳ sau" | <ul><li>Mục 3 file quy ước yêu cầu nhật ký có dòng này</li><li>Ghi 0 USD vì không làm đổi số năm 2025; tổng nhật ký vẫn bằng chênh lệch cả năm</li><li>Hàng trả ghi giảm doanh thu vào ngày nhận hàng trả là quy tắc ghi nhận, nên dùng nhóm này thay vì đặt nhóm mới</li></ul> | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết 2 truy vấn, phần điền file mẫu trong script dựng, bảng và đoạn báo cáo | `q_ExceptionLog.m`, `q_OrderSwap.m`; khối "File mẫu nộp" trong `build_workbook.ps1`; `bang_nhat_ky.tex`, `bang_doi_thu_tu.tex` trong `make_figures.py`; đoạn cuối IV.4, phụ lục B, E | <ul><li>Đọc lại giá trị đã tính của file Excel bằng openpyxl: dòng kiểm tra bằng 0, cột cả năm khớp số chuẩn</li><li>Tổng nhật ký = tổng chênh lệch cả năm</li><li>Số đổi thứ tự khớp số chuẩn trong file quy ước</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Ô nào trong file mẫu do nhóm gõ tay?
   **Trả lời:** Không ô số nào. Ô vàng là công thức SUMIFS đọc bảng `q_BR_Long` theo bảng (toàn công ty, cửa hàng, online), tháng (dòng 1) và mã khoản (cột P). Nhật ký là công thức INDEX đọc bảng `q_ExceptionLog`. Nạp tháng mới rồi chọn Data > Refresh All là cả hai tự cập nhật.
2. **Hỏi:** Cộng cột "Ảnh hưởng (USD)" của nhật ký ra bao nhiêu?
   **Trả lời:** −2.425.904,77, đúng chênh lệch cả năm. Khoản nào có phần tự bù trừ (lệch thời điểm online, lệch ngày ghi sổ, lỗi chuyển dữ liệu NX057) được tách để không đếm hai lần.
3. **Hỏi:** Vì sao chốt thứ tự: chiết khấu trước, rồi mới đến dòng trùng, đơn hủy, hàng trả?
   **Trả lời:** Đổi thứ tự thì tổng không đổi nhưng số từng khoản đổi (phụ lục E): dòng trùng tính trước chiết khấu thành −13.695,13 thay vì −12.622,20; hàng trả tính sau tỷ giá thì đo theo tỷ giá cuối tháng của sổ cái, thành −349.066,20 thay vì −349.148,23, và dòng tỷ giá thành −57.680,04. Còn −349.652,76 (tỷ giá ngày trả) là đổi cách chọn tỷ giá, không phải đổi thứ tự. Nhóm tính chiết khấu trước để mọi khoản sau đều đo theo giá thực bán, khớp với số sổ cái ghi; đổi mọi khoản theo tỷ giá ngày đặt để toàn bộ phần do tỷ giá nằm ở một dòng.
4. **Hỏi:** Nhật ký giúp gì cho kỳ sau?
   **Trả lời:** Hai dòng còn treo: EX-18 (ADJ-0925, "Chờ phản hồi", Tài chính gửi chứng từ) và EX-02 (dòng POS trùng, "Cần sửa nguồn", bộ phận IT (công nghệ thông tin) chặn xuất lặp). Các dòng "Đã giải thích" là quy tắc ghi nhận, kỳ nào cũng có, chỉ cần xem số có bất thường không. Ngoài ra EX-13 nhắc theo dõi 7 đơn giao năm 2025 bị trả tháng 01/2026 (22.136,44 USD), sẽ ghi giảm doanh thu kỳ sau.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 6 dòng số và 3 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** đoạn "File mẫu nộp và nhật ký ngoại lệ" cuối mục IV.4; phụ lục B (nhật ký 18 dòng); phụ lục E (Bảng 18, so khi đổi thứ tự các bước).
- **Việc còn lại:**
  - Tạo bản sao file mẫu nộp riêng (chỉ giữ giá trị hoặc giữ công thức) trong bộ file nộp → `review-submit`.
  - Thời gian dựng file khoảng 55 phút → backlog mục 8, xem lại ở `refresh-test`.
  - Trang nhật ký trên dashboard đọc `q_ExceptionLog` → `dashboard`.
- **Các lần lưu vào Git (commit):** `0ec7a91` (tạo plan), `6b35c60` (2 truy vấn), `276db09` (điền file mẫu, nạp sheet, file Excel), `d954238` (báo cáo IV.4, phụ lục B, E), `aae875a` (ghi kết quả, quyết định, chuẩn bị vấn đáp, backlog), và các lần lưu rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
