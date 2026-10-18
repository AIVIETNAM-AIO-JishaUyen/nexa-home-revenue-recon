# Chuẩn bị vấn đáp

> Tài liệu tập vấn đáp cho cả nhóm. Mentor (người hướng dẫn) hỏi 5 phút, ít nhất 2 thành viên, chọn 2 trong 6 câu gợi ý của rubric (sheet `Lam_dung_AI` trong `docs/other_resources/Rubric_danh_gia_Project_1.xlsx`). Mỗi câu dưới đây có: câu trả lời ngắn, số liệu, và **chỗ mở ra để chỉ** khi mentor hỏi tiếp.
> Mọi số lấy từ file Power Query (`excel/Nexa_Home_Recon_PQ.xlsx`) và báo cáo; không học thuộc số lẻ, chỉ cần nhớ số chính và biết mở đâu ra xem.
> Tiền tính bằng USD (đô la Mỹ). Flash là báo cáo nhanh doanh số của phòng Kinh doanh; sổ cái là sổ kế toán của phòng Tài chính.

---

## Câu 1. Một dòng của sổ cái đại diện cho cái gì? Khác gì một dòng của file POS?

- **Một dòng sổ cái** (GL – General Ledger) là **một bút toán**:
  - Bút toán ghi tự động `POS_DAILY`: doanh thu của **một cửa hàng trong một ngày ghi sổ**, một loại tiền. Riêng `POS_CATCHUP` (1 bút toán) là bút toán ghi bù doanh thu POS của một ngày bị thiếu (NX057, ngày 21/11 ghi bù ngày 02/12).
  - `WEB_DELIVERY`: doanh thu online của **các đơn giao trong một ngày**, theo từng loại tiền; `WEB_RETURN`: hàng trả nhận trong một ngày.
  - `MANUAL`: bút toán tay (MJ – Manual Journal): phí vận chuyển MJ-SHIP, chuyển kênh MJ-RCL, điều chỉnh MJ-ADJ.
  - Ghi theo dấu kế toán: doanh thu là số âm (bên Có), nên phải đổi dấu.
- **Một dòng POS** (Point of Sale, bán tại cửa hàng) là **một món hàng trên một hóa đơn** (khóa `receipt_no` + `line_no`), giá **trước** giảm giá, nội tệ, theo **ngày bán**.
- Vì hai bên khác mức chi tiết (grain), nhóm so ở mức **cửa hàng × ngày ghi sổ**: cộng dòng POS theo ngày ghi sổ rồi so với bút toán `POS_DAILY`. Kết quả: 5.118/5.120 ô khớp đến từng xu.
- **Mở ra chỉ:** sheet `Doi_soat_CH_ngay`; truy vấn `q_RC_Store`.

## Câu 2. Dòng trùng nằm ở cửa hàng nào, ngày nào? Nhóm phát hiện ở bước nào trong query?

- **12 dòng** của **2 hóa đơn** (`R3376006`, `R3376008`, mỗi hóa đơn 6 dòng hàng) bán ngày **29/03/2025** ở cửa hàng **NX007** (mã POS 74). Lần xuất đầu lúc 23:15 ngày 29/03; cả 2 hóa đơn được xuất lại lúc **08:42 ngày 30/03/2025**.
- Ảnh hưởng: **−12.622,20 USD** (tiền sau giảm giá, tỷ giá ngày bán). Flash đếm cả bản trùng, sổ cái không.
- Phát hiện ở truy vấn **`q_POS`**:
  1. Bước `Sắp theo giờ xuất` sắp các dòng theo `exported_at`.
  2. Bước `Đánh số thứ tự dòng` đánh số theo thứ tự giờ xuất; bước `Lần xuất đầu tiên của mỗi khóa` nhóm theo `receipt_no` + `line_no`, lấy số thứ tự nhỏ nhất (lần xuất sớm nhất).
  3. Bước `Cờ dòng trùng`: dòng nào không phải lần xuất đầu thì `is_duplicate = TRUE`; bước `Lý do trùng` ghi lý do.
- Nhóm **giữ** dòng trùng (để số dòng khớp bảng tổng kiểm soát 17.124) và chỉ đánh dấu.
- Sheet `Chat_luong_du_lieu` phép số 1 đếm lại mỗi lần làm mới; nhật ký ngoại lệ dòng EX-02.
- **Mở ra chỉ:** Data > Queries & Connections > `q_POS`; sheet `Bay_du_lieu` bẫy số 4 (cột `stt` = 4).

## Câu 3. Vì sao tháng 3 sổ cái lại cao hơn báo cáo nhanh?

- Tháng 3 sổ cái cao hơn Flash **+99.017,53 USD**, trái chiều với 11 tháng còn lại.
- Nguyên nhân: **lệch thời điểm online**. Flash ghi đơn theo **ngày đặt**, sổ cái theo **ngày giao**.
  - Tháng 3 nhận vào **315.819,08 USD** từ **140 đơn đặt từ 22/02 đến 28/02**, giao trong tháng 3.
  - Khoản lệch thời điểm online của tháng 3 là **+281.787,98 USD**, đủ lớn để lật dấu chênh lệch của tháng.
  - Tháng 3 còn có 12 dòng POS trùng (−12.622,20), nhưng nhỏ hơn nhiều.
- Đây **không** phải sổ cái ghi thừa: cả năm, lệch thời điểm online tự bù trừ giữa các tháng, chỉ còn −52.597,90 USD vắt qua năm.
- **Mở ra chỉ:** sheet `Lech_thoi_diem_online`; Hình 3 của báo cáo (mục IV.2).

## Câu 4. Mở query và chỉ chỗ xử lý ngày MM/DD/YYYY. Nếu bỏ bước đó thì số nào sẽ đổi?

- Truy vấn **`q_WEB`**, bước **`Đổi kiểu dữ liệu (ngày kiểu Mỹ, en-US)`**: đổi kiểu ngày theo vùng English – United States, vì file đơn online ghi ngày kiểu Mỹ (tháng/ngày/năm).
- Nếu bỏ vùng en-US ở bước này (máy cài tiếng Việt sẽ đọc ngày theo kiểu ngày/tháng), xét cột ngày đặt hàng:
  - **5.950 đơn báo lỗi** (phần "ngày" lớn hơn 12 bị hiểu là tháng).
  - **3.215 đơn bị đảo ngày với tháng mà không báo lỗi**: nguy hiểm hơn, vì không ai thấy.
  - Số đổi: tháng đặt và tháng giao của hàng nghìn đơn sai, nên **chênh lệch theo tháng** và **khoản lệch thời điểm online** sai; các ô đối soát online × ngày giao không còn khớp.
- **Mở ra chỉ:** `q_WEB`; sheet `Bay_du_lieu` bẫy số 1 (có sẵn số trước và sau khi xử lý).

## Câu 5. Vì sao không gán khoản 1.250 USD vào làm tròn cho bảng cầu nối về 0?

- 1.250 USD là **bút toán ADJ-0925** (mã MJ-ADJ-2509, bút toán JE20250904892, tháng 9): không gắn kênh, **không có giấy tờ làm căn cứ**.
- Bảng cầu nối của nhóm **đã về 0 mà không cần gán**: mọi khoản tính thẳng từ dữ liệu, ADJ-0925 nằm ở dòng riêng "Chưa giải thích được".
- Gán vào làm tròn là **ép khớp**: làm tròn của cả năm chỉ +1,01 USD, mỗi tháng dưới 5 USD (ngưỡng chấp nhận). Một khoản 1.250 USD nằm ở dòng làm tròn sẽ che mất một khoản cần hỏi.
- Đúng quy ước đã chốt trước khi tính; nhật ký ngoại lệ EX-18, trạng thái "Chờ phản hồi", người phụ trách: phòng Tài chính phải gửi chứng từ.
- File tự cảnh báo: sheet `Canh_bao_cau_noi` báo "Cần xem" ở tháng 9 vì phần chưa giải thích vượt 200 USD.
- **Mở ra chỉ:** sheet `Cau_noi` dòng "Chưa giải thích được"; sheet `Nhat_ky_ngoai_le` dòng EX-18.

## Câu 6. Nếu tháng sau có thêm một cửa hàng mới, file của nhóm phải sửa ở đâu?

- **Không sửa truy vấn nào.** Chỉ cần:
  1. Bảng danh mục cửa hàng (`store_master` trong file danh mục `Nexa_Home_Master_Data.xlsx`) có dòng của cửa hàng mới: mã POS, mã sổ cái, nước, loại tiền, ngày mở cửa. File danh mục bản mới cũng phải có lịch và tỷ giá của tháng mới, như mọi tháng.
  2. Thay 4 file dữ liệu bản mới (giữ phần đầu tên file), rồi Data > Refresh All (khoảng 3–5 phút).
- Nhóm **đã chạy thử**: dữ liệu giả tháng 01/2026 + cửa hàng mới NX068, ở một thư mục khác. Cửa hàng mới tự vào bảng đối soát (19 ô, đều khớp), kỳ đối soát tự dài ra 13 tháng, 11/11 phép so đạt.
- Nếu quên thêm cửa hàng vào danh mục: phép kiểm tra số 9 ("Dòng POS có mã cửa hàng không có trong danh mục") báo "Cần xem".
- **Mở ra chỉ:** mục II.8 của báo cáo; `checks/refresh_test/ket_qua_2026_01.txt`.

---

## Câu dễ bị hỏi thêm

| Câu hỏi | Trả lời ngắn | Mở ra chỉ |
|---|---|---|
| Vì sao chọn sổ cái làm chuẩn? | <ul><li>Sổ cái đã khóa sổ từng tháng, ghi theo chuẩn mực kế toán (VAS 14 – chuẩn mực kế toán Việt Nam số 14 về doanh thu), có giấy tờ làm căn cứ</li><li>Flash chỉ là báo cáo nhanh của phòng Kinh doanh</li></ul> | Mục I.4, bảng quy ước |
| Làm sao biết số đúng? | <ul><li>Ba cách tính độc lập ra cùng số: Power Query, bảng tính Python, DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) trên file dữ liệu khác</li><li>DAX lệch Power Query dưới 0,000001 USD ở cả 709 ô; Python lệch không quá 0,01 USD</li></ul> | Mục IV.4, IV.5; `powerbi/checks/bridge_compare.csv`; `checks/python_check_result.txt` |
| Ngày 21/11 NX057 bị gì? | <ul><li>POS có 7.227,56 USD nhưng sổ cái không có bút toán</li><li>Ngày 02/12 sổ cái ghi bù (bút toán `POS_CATCHUP`)</li><li>Sổ cái tháng 11 đã khóa mà thiếu khoản này</li></ul> | Sheet `Doi_soat_CH_ngay`; nhật ký EX-10, EX-11 |
| AI (trí tuệ nhân tạo) đã làm gì? | <ul><li>Viết nháp code và lời văn</li><li>Mọi số ra từ file; mỗi plan có lần rà soát độc lập</li></ul> | Phụ lục G (Khai báo dùng AI) |
