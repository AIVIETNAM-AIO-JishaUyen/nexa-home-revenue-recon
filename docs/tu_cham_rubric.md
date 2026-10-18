# Tự chấm theo rubric

> Nhóm tự chấm bản nộp trên nhánh `baseline` theo rubric của đề (`docs/other_resources/Rubric_danh_gia_Project_1.xlsx`, sheet `Rubric`). Mỗi tiêu chí của Band 4 và Band 5 có: đạt hay chưa, và **bằng chứng** (chỗ mở ra xem được).
> Ngày tự chấm: 19/10/2026. "Báo cáo" là `report/main.pdf`; "file Power Query" là `excel/Nexa_Home_Recon_PQ.xlsx`.

---

## Tóm tắt

| Năng lực | Band tự chấm | Lý do chính | Điểm còn thiếu |
|---|---|---|---|
| 1. Phân tích đề bài | 5 | Đủ 5 trục khác biệt có kiểm chứng; ngưỡng chốt trước; 3 câu hỏi riêng đo được; 3 rủi ro đề không nói | Đặt vấn đề vẫn theo khung 8 phần của slide 45 |
| 2. Truy vấn và xử lý số liệu | 5 | 5 bẫy, 3 tầng đối soát, cầu nối khớp đến 0,00; chạy lại tháng mới chỉ bằng thay file; tự cảnh báo; kiểm chứng bằng Python và DAX | Chưa chạy trên máy thật thứ hai |
| 3. Kết luận và đề xuất | 5 | 4 nhóm, ADJ-0925 nêu rõ hỏi ai, đề xuất xếp ưu tiên có bộ phận / thời điểm / chỉ số, giả thuyết bị bác bỏ | Chưa có câu trả lời của mentor cho 8 quy ước |
| 4. Trình bày output | 4–4,5 | Tóm tắt 1 phút, tiêu đề là nhận định kèm số, dashboard 4 trang cho 2 kiểu người đọc, nhật ký đủ cột | Báo cáo 45 trang (dài); dashboard thiếu nút "Đặt lại"; ảnh dashboard chữ nhỏ khi in |

---

## 1. Phân tích đề bài

| Tiêu chí | Đạt? | Bằng chứng |
|---|---|---|
| **Band 4.** Nêu đủ 5 trục khác biệt (thời điểm, giá trị, phạm vi, tiền tệ, mức chi tiết), trục nào cũng kiểm chứng trên dữ liệu | Đạt | Báo cáo mục II.2 (bảng quy tắc ghi nhận) và IV.3 (Bảng "năm lý do lệch, chứng minh bằng số"); sheet `Nam_ly_do` |
| Chọn sổ cái làm chuẩn và nói được vì sao | Đạt | Phần I, bảng quy ước: đã khóa sổ, theo VAS 14, có giấy tờ |
| Đặt ngưỡng chấp nhận trước khi làm | Đạt | Quy ước chốt ngày 15/10/2026, trước khi dựng file (`docs/quy_uoc_va_so_chuan.md`, lịch sử Git) |
| Có 2–4 câu hỏi phân tích cụ thể, đo được | Đạt | Phần I.3: 3 câu hỏi riêng, mỗi câu có thước đo và nơi lấy số; trả lời ở bảng mục V.2 |
| **Band 5.** Thấy rủi ro đề không nói | Đạt | Mục VII.2: hàng trả sau ngày lấy dữ liệu (7 đơn tháng 01/2026, nhật ký EX-13); sổ cái tháng 11 đã khóa mà thiếu doanh thu; mã cửa hàng khác nhau giữa POS và sổ cái |
| Hiểu bối cảnh vận hành: ai sở hữu nguồn nào, chu kỳ chốt sổ | Đạt | Danh sách việc trước khi khóa sổ theo 5 ngày của tuần chốt sổ (mục VI.2); đề xuất ghi rõ bộ phận Kinh doanh / Tài chính / IT |
| Cách đặt vấn đề có dấu ấn riêng | Phần lớn | Câu hỏi riêng 1 (bước so ô trước khi khóa sổ bắt được gì) và tiêu đề báo cáo là của nhóm; khung 8 phần theo slide 45 |

## 2. Truy vấn và xử lý số liệu

| Tiêu chí | Đạt? | Bằng chứng |
|---|---|---|
| **Band 4.** Xử lý đủ 5 bẫy khi nạp | Đạt | Sheet `Bay_du_lieu`: mỗi bẫy có số trước / sau và "nếu bỏ bước này" |
| Đối soát đủ 3 tầng: tháng, kênh, cửa hàng × ngày ghi sổ | Đạt | Sheet `Chenh_lech_thang`, `Chenh_lech_kenh`, `Doi_soat_CH_ngay` (5.118/5.120 ô khớp), `Doi_soat_online` (1.647/1.647), `Doi_soat_hang_tra` (159/159) |
| Bỏ dòng trùng có ghi lý do; tách riêng chênh lệch tỷ giá | Đạt | `q_POS` cột `is_duplicate`, `duplicate_reason`; dòng tỷ giá −57.598,01 USD theo định nghĩa slide 34 |
| Cầu nối 12 tháng khớp đến 1 USD | Đạt | Sheet `BR_Long`: dòng kiểm tra lớn nhất 0,00 USD ở mọi bảng × tháng |
| Power Query làm mới được, có tham số thư mục | Đạt | Ô `Cai_dat!B2` (tên `FolderPath`); Data > Refresh All khoảng 3 phút |
| **Band 5.** Chạy lại cho tháng mới chỉ bằng thay file rồi làm mới | Đạt | Mục II.8; `checks/refresh_test/ket_qua_2026_01.txt`: tháng 01/2026 giả + cửa hàng mới, 11/11 phép so đạt, không sửa truy vấn |
| Kiểm tra tự động: cảnh báo phần chưa giải thích vượt ngưỡng, đếm dòng trùng, đếm ngày thiếu | Đạt | Sheet `Canh_bao_cau_noi`; sheet `Chat_luong_du_lieu` (13 phép, gồm dòng trùng và ô cửa hàng × ngày thiếu bút toán) |
| Tự kiểm chứng bằng cách tính thứ hai | Đạt | Bảng tính Python (`checks/python_check.py`) và DAX trên dữ liệu mentor: 709 ô lệch dưới 0,000001 USD (mục IV.5) |
| Query gọn, đặt tên rõ, mỗi bước có ghi chú | Đạt | `excel/queries/*.m`: tên bước tiếng Việt, ghi chú `//`; phụ lục A |

## 3. Kết luận và đề xuất

| Tiêu chí | Đạt? | Bằng chứng |
|---|---|---|
| **Band 4.** Phân loại đủ 4 nhóm | Đạt | Bảng 4 nhóm ở mục V.1; nhật ký ngoại lệ cột "Phân loại" |
| Để ADJ-0925 ở nhóm chưa giải thích và nêu rõ cần hỏi ai | Đạt | Nhật ký EX-18: phòng Tài chính gửi chứng từ, trạng thái "Chờ phản hồi" |
| Chứng minh lệch thời điểm tự triệt tiêu ở kỳ sau | Đạt | Sheet `Lech_ngay_ghi_so` (3 cặp tháng, cả năm bằng 0); `Lech_thoi_diem_online` (chỉ còn phần vắt qua năm) |
| Đề xuất kiểm soát cụ thể: ai làm, khi nào, chỉ số | Đạt | Bảng đề xuất mục VI.1: cột bộ phận, khi nào, chỉ số theo dõi (mục tiêu) |
| Có nêu giới hạn | Đạt | Mục VII.1 |
| **Band 5.** Xếp ưu tiên đề xuất theo tác động và chi phí | Đạt | Bảng đề xuất xếp theo lợi ích so với công sức |
| Gắn kết luận với quy trình khóa sổ và định nghĩa báo cáo (ví dụ thêm cột doanh thu thuần) | Đạt | Đề xuất 1 (so ô trước khi khóa sổ), đề xuất 4 (Flash báo thêm doanh số thuần: chênh lệch cả năm còn −0,09%) |
| Tách điều dữ liệu cho thấy với giả thuyết | Đạt | Mục VII.1 "Chỉ kết luận điều dữ liệu cho thấy" (nguyên nhân NX057, nội dung ADJ-0925 ghi là phải hỏi) |
| Nêu giả thuyết đã kiểm tra mà dữ liệu không ủng hộ | Đạt | Mục V.3: 4 giả thuyết bị bác bỏ, mỗi giả thuyết có cách kiểm và nhãn nguồn |

## 4. Trình bày output

| Tiêu chí | Đạt? | Bằng chứng |
|---|---|---|
| **Band 4.** Mỗi mục trả lời một câu hỏi; tiêu đề là nhận định kèm số | Đạt | Mục lục: tiêu đề mục con phần II–V là nhận định (ví dụ "Sổ cái thấp hơn Flash ở 11/12 tháng; riêng tháng 3 cao hơn"); tiêu đề biểu đồ dashboard là công thức có số |
| Bảng cầu nối hoặc thác nước dễ đọc; dấu nhất quán | Đạt | Hình thác nước mục IV.4; quy ước Sổ cái − Flash ở mọi trang |
| Nhật ký ngoại lệ đủ cột | Đạt | Sheet `Nhat_ky_ngoai_le` (10 cột của file mẫu), phụ lục B |
| Báo cáo ngắn gọn, theo mạch Câu hỏi → Bằng chứng → Kết luận | Phần lớn | Mạch đúng; nhưng 45 trang (thân bài khoảng 29 trang) |
| **Band 5.** Người ngoài đọc 1 phút nắm được lệch bao nhiêu, vì sao, ai cần làm gì | Đạt | Hộp tóm tắt trang 1 |
| Thiết kế hợp người đọc; xem được chi tiết từng ô lệch | Đạt | Dashboard trang 1 cho Giám đốc Tài chính, trang 3 cho kế toán (bảng ô cửa hàng × ngày còn lệch, bấm để lọc) |
| Văn tự nhiên, nói rõ đã cân nhắc gì, kết quả nào bất ngờ | Đạt | Mục V.4 "Điều bất ngờ"; các đoạn "nhóm phải cân nhắc" ở IV.5, IV.6, VI.3 |

---

## Rủi ro bị xem là lạm dụng AI (sheet `Lam_dung_AI`) và cách nhóm phòng

| Dấu hiệu | Tình trạng |
|---|---|
| Số không khớp dữ liệu | Mọi số trong báo cáo là macro sinh từ file Power Query; ba cách tính độc lập ra cùng số |
| Mã dùng hàm hay cột không có trong dữ liệu | Mọi truy vấn và công thức DAX đã chạy ra kết quả nộp (dựng lại file từ đầu, mở Power BI và làm mới) |
| Nguyên nhân lệch không có trong dữ liệu | Không nêu; nguyên nhân NX057 và ADJ-0925 ghi là "phải hỏi" |
| Văn chung chung, không truy được về bảng | Mỗi kết luận có nhãn nguồn số (phụ lục C) |
| Phân tích mâu thuẫn với số | Lần rà soát cuối đã sửa các chỗ đếm lệch (ví dụ "3 lỗi" thành "2 lỗi + 1 khoản chưa giải thích") |
| Chuẩn bị vấn đáp | `docs/chuan_bi_van_dap.md`: 6 câu gợi ý của rubric, mỗi câu có chỗ mở ra để chỉ |
