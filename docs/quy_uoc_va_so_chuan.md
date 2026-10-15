# Quy ước tính và bảng số chuẩn

---

## 1. Quy ước tính

| Nội dung | Thống nhất |
|---|---|
| Lấy nguồn nào làm chuẩn | <ul><li>**Sổ cái** (GL – General Ledger, sổ kế toán của phòng Tài chính).</li><li>Lý do 1: đã khóa sổ (đã chốt số của từng tháng, không sửa nữa).</li><li>Lý do 2: ghi theo chuẩn mực kế toán VAS 14 (Chuẩn mực kế toán Việt Nam số 14 về doanh thu).</li><li>Lý do 3: có giấy tờ làm căn cứ.</li></ul> |
| Cách tính chênh lệch | <ul><li>**Chênh lệch = Sổ cái − Flash** (Flash là báo cáo nhanh doanh số của phòng Kinh doanh).</li><li>Số âm nghĩa là sổ cái thấp hơn.</li><li>Trong bảng cầu nối, khoản nào làm Flash cao hơn sổ cái thì ghi **số âm**.</li></ul> |
| % chênh lệch hiển thị trên dashboard (ô số liệu chính, gọi là thẻ KPI – Key Performance Indicator) | <ul><li>**Chênh lệch ÷ Flash**, đúng yêu cầu slide 12 "% báo cáo nhanh".</li><li>Ví dụ: cả năm −7,8%, tháng 12 −7,4%.</li><li>% mang cùng dấu với chênh lệch (tháng 3 là số dương).</li></ul> |
| % chênh lệch dùng để đánh dấu cửa hàng – tháng vượt ngưỡng | <ul><li>**Chênh lệch ÷ \|Sổ cái\|** (slide 28–30; \|x\| là giá trị tuyệt đối, tức bỏ dấu âm).</li><li>Chỉ dùng ở mức một cửa hàng trong một tháng.</li><li>Tên chỉ số luôn ghi rõ là "% so với Flash" hay "% so với sổ cái".</li></ul> |
| Ngưỡng phải giải thích | <ul><li>Đánh dấu ⚠ khi **độ lớn chênh lệch (bỏ dấu âm) lớn hơn 200 USD (đô la Mỹ) VÀ độ lớn % chênh lệch lớn hơn 1%**.</li><li>Tính cho một cửa hàng trong một tháng.</li><li>Tính sau khi đã đưa hai bên về cùng cách tính.</li></ul> |
| Sai số làm tròn chấp nhận được | <ul><li>≤ **5 USD/tháng**.</li></ul> |
| Dòng kiểm tra của bảng cầu nối | <ul><li>Phải về 0.</li><li>Chấp nhận sai lệch ≤ 1 USD.</li></ul> |
| Thứ tự các bước trong bảng cầu nối | <ol><li>Flash</li><li>Chiết khấu</li><li>Dòng POS trùng (POS – Point of Sale, bán tại cửa hàng)</li><li>Đơn hủy</li><li>Lệch thời điểm online</li><li>Lệch ngày ghi sổ của cửa hàng</li><li>Lỗi chuyển dữ liệu</li><li>Hàng trả</li><li>Phí vận chuyển</li><li>Chuyển kênh MJ-RCL (chỉ có ở bảng cầu nối theo kênh)</li><li>Tỷ giá</li><li>Làm tròn</li><li>Chưa giải thích</li><li>Sổ cái</li></ol> |
| Tên các khoản so với slide 12 | <ul><li>"Trùng dòng" = dòng POS trùng.</li><li>"Ngày hạch toán" = lệch ngày ghi sổ của cửa hàng.</li><li>"Thiếu bút toán" = lỗi chuyển dữ liệu.</li><li>"Bút toán tay" = phí vận chuyển (và chuyển kênh, ở bảng theo kênh). Bút toán ADJ-0925 tách riêng, xem dòng dưới.</li></ul> |
| Vì sao theo thứ tự này | <ul><li>Flash tính theo giá trước giảm giá và đã gồm cả dòng trùng lẫn đơn hủy.</li><li>Trừ chiết khấu trước thì dòng trùng và đơn hủy được tính theo giá sau giảm giá, giống cách sổ cái ghi.</li></ul> |
| Tỷ giá dùng trong từng khoản | <ul><li>Mọi khoản đứng trước dòng tỷ giá đều đổi ra USD theo **tỷ giá của ngày đặt hàng / ngày bán**.</li><li>Hàng trả cũng tính theo tỷ giá **ngày đặt hàng**: ra −349.148,23.</li><li>Để so sánh:<ul><li>Nếu dùng tỷ giá ngày trả hàng: −349.652,76.</li><li>Sổ cái dùng tỷ giá cuối tháng: −349.066,23.</li></ul></li><li>Dòng tỷ giá = (số USD trên sổ cái, tính theo tỷ giá cuối tháng) − (cũng các giao dịch đó, tính theo tỷ giá ngày).</li></ul> |
| Bút toán ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh; 1.250 USD) | <ul><li>Luôn để ở dòng **"Chưa giải thích được"**.</li><li>Không gộp vào dòng phí vận chuyển hay dòng làm tròn.</li><li>Slide 32 gộp nó chung với phí vận chuyển dưới tên "bút toán tay", **không chép theo cách đó**.</li></ul> |
| Bút toán MJ-RCL-2506 (MJ = Manual Journal, bút toán tay; RCL = Reclassification, phân loại lại): bút toán tay chuyển 3.480 USD từ cửa hàng NX019 sang online, tháng 6 | <ul><li>Bảng cầu nối toàn công ty không cần dòng này (tổng = 0).</li><li>**Bảng cầu nối theo kênh bắt buộc có dòng riêng**.</li></ul> |
| Nhãn nguồn số liệu | <ul><li>Mọi kết luận trong báo cáo và dashboard ghi kèm nhãn cho biết số lấy từ bảng nào.</li><li>`[QC]`: bảng tổng kiểm soát (QC = Quality Control, kiểm soát chất lượng).</li><li>`[RC-CH]`, `[RC-WEB]`, `[RC-RET]`: bảng đối soát cửa hàng, online, hàng trả (RC = Reconciliation, đối soát; CH = cửa hàng; RET = Return, hàng trả).</li><li>`[BR-Tổng]`, `[BR-CH]`, `[BR-WEB]`: bảng cầu nối toàn công ty, cửa hàng, online (BR = Bridge, cầu nối).</li><li>`[EX-xx]`: dòng xx của nhật ký ngoại lệ (EX = Exception, ngoại lệ).</li><li>Phụ lục có bảng tra từ nhãn sang sheet hoặc truy vấn (truy vấn = một chuỗi bước xử lý trong Power Query, cho ra một bảng).</li></ul> |

---

## 2. Bảng số chuẩn để đối chiếu (sẽ lưu thành file `checks/numbers_of_record.csv` khi bắt đầu làm)

Đây là các con số **đúng** mà mọi cách tính của nhóm (Power Query, DAX – ngôn ngữ công thức của Power BI, bảng tính kiểm tra viết bằng Python – một ngôn ngữ lập trình) phải khớp. Số lấy từ slide đề bài; khi lập kế hoạch, các số cả năm đã được tính lại từ 4 file dữ liệu gốc bằng Python và khớp.

**Tổng kiểm soát (sheet QC_Summary của đề):**
- POS (bán hàng tại cửa hàng):
  - 17.124 dòng · 7.130 hóa đơn · tổng số lượng 53.872.
  - Ngày bán từ 01/01 đến 31/12/2025.
  - Tổng cột `line_amount` 14.706.296,35 · tổng cột `discount_amount` 872.455,82.
- WEB (đơn online): 9.441 đơn (9.121 đã giao / 139 bị hủy / 181 bị trả) · tổng cột `net_amount` 18.712.884,87.
- Sổ cái: 6.940 bút toán (dòng ghi sổ) · tổng cột `amount_usd` −28.698.496,23.
- Flash: 156 dòng chi tiết · tổng 31.124.401.

**Theo kênh bán (cả năm):**

| Kênh | Flash | Sổ cái |
|---|---|---|
| Cửa hàng | 14.060.500 | 13.181.898 |
| Online | 17.063.901 | 15.515.348 |
| Chưa gắn kênh | 0 | 1.250 |

**Bảng cầu nối cả năm (USD, dấu theo quy ước ở phần 1):**

| Khoản | USD | Nhóm |
|---|---:|---|
| Doanh số Flash | 31.124.401,00 | |
| Chiết khấu | −1.834.297,47 | Quy tắc ghi nhận |
| Dòng POS bị trùng<ul><li>Tính theo giá sau giảm giá</li><li>Nếu tính theo giá trước giảm giá là −13.695,13</li></ul> | −12.622,20 | Lỗi dữ liệu |
| Đơn online bị hủy<ul><li>124 đơn đặt năm 2025</li><li>15 đơn còn lại đặt tháng 12/2024</li></ul> | −215.658,92 | Quy tắc ghi nhận |
| Lệch thời điểm online<ul><li>Đặt hàng và giao hàng rơi vào hai tháng khác nhau</li></ul> | −52.597,90 | Quy tắc ghi nhận |
| Lệch ngày ghi sổ của cửa hàng | 0 cả năm (từng tháng khác 0) | Quy tắc ghi nhận |
| Lỗi chuyển dữ liệu từ POS sang sổ cái, cửa hàng NX057 | 0 cả năm<ul><li>Tháng 11: −7.227,56</li><li>Tháng 12: +7.227,56</li></ul> | Lỗi dữ liệu |
| Hàng trả lại (tỷ giá ngày đặt) | −349.148,23 | Quy tắc ghi nhận |
| Phí vận chuyển<ul><li>12 bút toán tay MJ-SHIP (SHIP = Shipping, vận chuyển)</li></ul> | +94.766,95 | Quy tắc ghi nhận |
| Tỷ giá | −57.597,96 | Quy tắc ghi nhận |
| Làm tròn | +0,96 | Sai số chấp nhận được |
| Chưa giải thích (bút toán ADJ-0925, tháng 9) | +1.250,00 | Chưa giải thích được |
| **Doanh thu theo sổ cái** | **28.698.496,23** | |

**Theo tháng và chi tiết:**
- **Chênh lệch theo tháng (sổ cái − Flash, nghìn USD):** tháng 1 −233 · tháng 2 −387 · **tháng 3 +99** · tháng 4 −138 · tháng 5 −324 · tháng 6 −94 · tháng 7 −159 · tháng 8 −296 · tháng 9 −83 · tháng 10 −250 · tháng 11 −302 · tháng 12 −258.
- Bảng cầu nối tháng 12 đầy đủ: xem slide 36.
- Tháng 11 (slide 44):
  - So theo ngày bán: 347 ô (một cửa hàng trong một ngày) bị lệch (slide 44 ghi là "347/453 ô").
  - So theo ngày ghi sổ: chỉ còn 1 ô lệch (NX057, ngày 21/11).
  - Với dữ liệu chưa xử lý có 22 cửa hàng vượt ngưỡng; sau khi đưa về cùng cách tính chỉ còn NX057 (−7.228 USD, −74,6%).
  - Online lệch −12.064 USD nếu so theo ngày đặt, về 0 nếu so theo ngày giao.
- Phần lệch thời điểm online của cả năm không về 0 vì có đơn đặt năm này nhưng giao năm sau:
  - Đầu năm: +122.107,89 (77 đơn đặt tháng 12/2024, giao năm 2025).
  - Cuối năm: −174.705,79 (105 đơn đặt năm 2025, giao năm 2026).
- Lệch ngày ghi sổ của cửa hàng tự bù trừ về 0 theo từng cặp tháng (tháng trước âm, tháng sau dương cùng số tiền): tháng 5 và tháng 6: 41.464,78 · tháng 8 và tháng 9: 75.240,30 · tháng 11 và tháng 12: 80.588,85.
- **Tháng 3 sổ cái cao hơn Flash** vì lệch thời điểm online +281.787,98: nhiều đơn đặt cuối tháng 2 nhưng giao trong tháng 3.
- Đối soát chi tiết:
  - Cửa hàng theo ngày ghi sổ: 5.120 ô, 5.118 ô khớp, 2 ô lệch (NX057 ngày 21/11 và 02/12).
  - Bút toán doanh thu online WEB_DELIVERY (1.647 ô) và bút toán hàng trả WEB_RETURN (159 ô): khớp 100%.

**Phần còn thiếu:** slide không cho số **theo từng tháng, từng khoản, từng kênh** của 10 tháng còn lại. Nhóm tự tính phần này bằng bảng tính kiểm tra viết bằng Python. Bảng này chỉ dùng nội bộ để so, không nộp; nhóm phải giải thích được từng dòng.

---

## 3. Nhật ký ngoại lệ: mỗi khoản lệch một dòng (slide 10 và 40)

Mỗi dòng có đủ các cột: Mã · Phát hiện ở bước nào · Nguồn · Mô tả · Số tiền USD · Kỳ (tháng) · Nhóm · Hướng xử lý · Người phụ trách (bộ phận của công ty, ví dụ bộ phận IT (công nghệ thông tin) hay phòng Tài chính) · Trạng thái.

| Nhóm | Các dòng phải có |
|---|---|
| Quy tắc ghi nhận | <ul><li>Chiết khấu</li><li>Đơn hủy</li><li>Lệch thời điểm online; tách riêng phần đơn đặt năm này nhưng giao năm sau: đầu năm +122 nghìn, cuối năm −175 nghìn</li><li>Lệch ngày ghi sổ của cửa hàng (3 cặp tháng)</li><li>Hàng trả</li><li>Phí vận chuyển</li><li>Tỷ giá</li><li>Bút toán chuyển kênh MJ-RCL (chỉ ở bảng theo kênh)</li></ul> |
| Lỗi dữ liệu | <ul><li>12 dòng POS bị trùng ở NX007 ngày 29/03</li><li>Lỗi chuyển dữ liệu ở NX057, gồm 2 vế: thiếu ngày 21/11 và được bổ sung ngày 02/12</li><li>Ghi chú: tháng 11 đã khóa sổ mà vẫn thiếu doanh thu</li></ul> |
| Chưa giải thích được | <ul><li>Bút toán ADJ-0925: 1.250 USD, tháng 9</li><li>Không gắn kênh nào (UNALLOCATED)</li><li>Không có giấy tờ làm căn cứ</li><li>Cần hỏi phòng Tài chính</li></ul> |
| Sai số chấp nhận được | <ul><li>Làm tròn: +0,96 cả năm, ≤ 5 USD/tháng</li></ul> |
| Rủi ro cần theo dõi (không phải khoản lệch của năm 2025) | <ul><li>7 đơn bị trả trong tháng 01/2026, thuộc các đơn đặt/giao năm 2025.</li><li>Khách trả hàng 5–25 ngày sau khi nhận.</li><li>Dữ liệu chỉ lấy đến ngày 15/01/2026, nên các đơn giao từ khoảng 21/12/2025 vẫn có thể bị trả sau ngày lấy dữ liệu.</li><li>Hàng trả được ghi giảm doanh thu vào ngày nhận hàng trả, nên không làm đổi số năm 2025, nhưng sẽ rơi vào tháng 01/2026.</li><li>5 đơn bị trả trong tháng 12/2024, nằm ngoài năm đối soát.</li></ul> |
