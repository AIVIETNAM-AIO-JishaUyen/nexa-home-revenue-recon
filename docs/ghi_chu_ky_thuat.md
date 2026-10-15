# Ghi chú kỹ thuật cho các đầu việc

---

## Việc 1 — Hiểu đề và chốt quy ước tính

**Phần mềm mỗi máy cần có:**
- Windows (Power BI chỉ chạy trên Windows; máy Mac không dùng được Power BI).
- Excel 365 có Power Query.
- **Cùng một phiên bản Power BI Desktop** cho cả nhóm.
- Phần mềm soạn LaTeX (TeX Live hoặc MiKTeX).
- Git (phần mềm lưu lịch sử thay đổi của file).

**Nơi lưu chung:** kho lưu trữ trên GitHub hoặc GitLab (để chế độ riêng tư) và thư mục chung trên Google Drive hoặc OneDrive.

**Câu hỏi nên xin mentor (người hướng dẫn) xác nhận ở buổi kiểm tra tiến độ:**
- % chênh lệch chia cho số nào.
- Xử lý bút toán ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh 1.250 USD không có giấy tờ) ra sao.
- Nộp những file gì.

Nếu mentor trả lời khác quy ước đã chốt: lưu bản quy ước mới lên GitHub, ghi lý do và ngày đổi. Như vậy vẫn giữ được bằng chứng "chốt trước khi tính".

---

## Việc 2 — Nạp và làm sạch dữ liệu

**Bản mô tả cấu trúc bảng** (thống nhất trước khi làm): tên cột, kiểu dữ liệu, dấu (âm hay dương), cột khóa (cột giúp phân biệt từng dòng) của bảng giao dịch chung `q_Transactions` và 3 bảng đối soát. Khi bảng thật chưa xong, có thể dùng bảng giả (dữ liệu tạm, đúng tên cột) để làm trước các việc sau.

**Bảng giao dịch chung `q_Transactions` phải có:**
- Kênh.
- Mã cửa hàng (cả mã POS và mã NX bên kế toán).
- Ngày bán/đặt, ngày tính doanh thu.
- Loại tiền.
- Tiền trước giảm giá / chiết khấu / sau giảm giá theo nội tệ (tiền của nước có cửa hàng).
- **Số USD theo 2 tỷ giá** (tỷ giá ngày và tỷ giá cuối tháng).
- Cột đánh dấu dòng trùng kèm lý do.

**8 truy vấn nạp dữ liệu.** Mỗi bước đặt tên rõ và có ghi chú (tiêu chí Band 5):
- `q_POS`: đổi kiểu dữ liệu; bỏ dòng trùng theo cặp `receipt_no + line_no`, giữ lần xuất đầu tiên, có cột ghi lý do.
- `q_WEB`: đọc ngày theo kiểu Mỹ (chọn vùng English – United States, ký hiệu en-US).
- `q_GL`: đổi dấu doanh thu thành số dương.
- `q_FLASH`: bỏ 4 dòng đầu, bỏ dòng TỔNG CỘNG.
- `q_Store` (danh mục cửa hàng), `q_Calendar` (lịch, thêm cột ngày ghi sổ `posting_date`), `q_FX_Daily` (tỷ giá ngày), `q_FX_MonthEnd` (tỷ giá cuối tháng).

**Thêm:**
- Ô cài đặt **đường dẫn thư mục (FolderPath)**.
- **Sheet kiểm tra tổng** tự so với QC_Summary (cột chênh lệch = 0).
- Mỗi bẫy chuẩn bị 1 ví dụ trước và sau khi xử lý, chỉ ra được bước xử lý nằm ở đâu trong truy vấn.
- Nối mã cửa hàng bên POS với mã NX bên kế toán qua bảng `store_master`. Một cửa hàng có thể có nhiều mã POS nhưng chỉ một mã NX. Thêm cửa hàng mới thì chỉ cần cập nhật `store_master`.
- Sheet kiểm tra chất lượng dữ liệu: đếm dòng trùng, ngày thiếu bút toán, bút toán không gắn cửa hàng, cảnh báo phần chưa giải thích.

**Chạy thử làm mới dữ liệu (Refresh) 2 lần**, xong trước Mốc 4:
- Lần 1: chép file sang một thư mục mới trên máy khác, chỉ đổi đường dẫn thư mục rồi bấm Refresh.
- Lần 2: làm trên **bản sao** của thư mục `data/`: thêm dữ liệu giả của "một tháng mới" và một cửa hàng mới vào danh mục cửa hàng `store_master`, bấm Refresh, không phải sửa truy vấn nào.

---

## Việc 3 — Đối soát chi tiết

- Đi từ tổng xuống chi tiết (slide 24 và 37):
  - So tổng cả năm và từng tháng.
  - So theo kênh; kiểm tra tổng các kênh của sổ cái bằng tổng sổ cái (phát hiện 1.250 USD chưa gắn kênh).
  - Rồi mới xuống cửa hàng × ngày, online × ngày × loại tiền.
- Đối soát **cửa hàng theo ngày ghi sổ** (so bằng nội tệ):
  - Ghép bảng POS với sổ cái, giữ đủ dòng của cả hai bên (kiểu ghép Full Outer Join).
  - Chia 4 trường hợp: khớp · chỉ có ở POS · chỉ có ở sổ cái · có ở cả hai nhưng lệch tiền.
- Đối soát **online theo ngày giao và loại tiền** và **hàng trả theo ngày trả và loại tiền**, chia 4 trường hợp tương tự (chỉ có ở WEB · chỉ có ở sổ cái…).
- Đánh dấu ⚠ cho cửa hàng vượt ngưỡng theo tháng.
- So chênh lệch khi chưa xử lý (theo ngày bán, chưa bỏ dòng trùng) với chênh lệch sau khi đưa về cùng cách tính.
- Lập bảng chứng minh phần lệch thời điểm tự bù trừ theo cặp tháng.
- Xếp mỗi khoản lệch vào 1 trong 4 nhóm (quy tắc ghi nhận, lỗi dữ liệu, chưa giải thích được, sai số chấp nhận được) để dùng cho nhật ký ngoại lệ và dashboard.

---

## Việc 4 — Bảng cầu nối và nhật ký ngoại lệ

- Bảng cầu nối **12 tháng cho cả 3 bảng (toàn công ty, cửa hàng, online)** làm trong Power Query, gồm:
  - Dòng chuyển kênh MJ-RCL (MJ = Manual Journal, bút toán tay; RCL = Reclassification, phân loại lại), chỉ có ở bảng theo kênh.
  - Bút toán ADJ ở dòng chưa giải thích.
  - Dòng tỷ giá, dòng làm tròn, dòng kiểm tra.
- **Tự hiện cảnh báo** khi phần chưa giải thích vượt ngưỡng.
- **Ô vàng của file mẫu nộp `Mau_nop` lấy số trực tiếp từ kết quả Power Query, không gõ tay.**
- Viết bảng cầu nối bằng ngôn ngữ M của Power Query; lưu mỗi truy vấn thành file `.m` (file code của Power Query) để cả nhóm đọc và kiểm tra.
- Bổ sung bảng tính kiểm tra bằng Python cho phần slide không cho (từng tháng, từng khoản, từng kênh), làm không quá 1 ngày. Các số cả năm đã có sẵn trong [quy_uoc_va_so_chuan.md](quy_uoc_va_so_chuan.md).
- Bảng so sánh khi đổi thứ tự các bước (3 dòng, đặt ở phụ lục).

**Khi Power Query và DAX ra số khác nhau:**
- So cả hai với bảng số chuẩn.
- Cách tính bị sai phải được sửa trong 24 giờ.
- Không được ép cho khớp (nhét phần dư vào một khoản khác).

---

## Việc 5 — Kiểm tra lại bằng cách tính thứ hai

- Nạp file Recon_Dataset (dữ liệu mentor đã nối sẵn cho Power BI) vào Power BI.
- Nối các bảng như slide 19: mỗi cặp bảng có 1 đường nối chính; các đường nối theo ngày khác đặt làm đường nối phụ, chỉ bật khi công thức cần.
- Đánh dấu bảng ngày (nút Mark as Date Table).
- Viết công thức DAX cho Flash, sổ cái, chênh lệch, % chênh lệch, rồi cho từng khoản của bảng cầu nối (theo mẫu slide 29–30, dùng hàm USERELATIONSHIP để tính theo một ngày khác ngày mặc định). **Riêng khoản tỷ giá nên dành 2 ngày.**
- Sau khi cầu nối đã khớp: không thêm/bớt bảng hay đổi cách nối bảng nữa, chỉ thêm công thức.
- Mỗi lần lưu bản mới, xuất toàn bộ công thức ra file `powerbi/dax_measures.dax`.

---

## Việc 6 — Dashboard 4 trang

- Yêu cầu từng trang: xem [yeu_cau_dashboard.md](yeu_cau_dashboard.md).
- Phác bố cục 4 trang trên giấy trước khi làm.
- Chốt số liệu trước khi chụp hình; đặt tên hình cố định để khi cập nhật chỉ cần lưu đè.

---

## Việc 7 — Kết luận và đề xuất

- Đề xuất cải tiến quy trình theo 4 bước **Phát hiện → Ý nghĩa → Đề xuất → Giới hạn**:
  - Ghi rõ bộ phận nào của công ty làm, khi nào, theo dõi bằng chỉ số nào.
  - **Xếp thứ tự ưu tiên theo lợi ích so với công sức.**
- Danh sách việc cần kiểm trước khi khóa sổ (1 trang).
- Mô tả ai giữ nguồn dữ liệu nào, mỗi tháng khóa sổ ra sao.
- Các phỏng đoán đã kiểm tra và thấy sai.
- Nêu rõ giới hạn của kết luận (ví dụ: chỉ có dữ liệu 1 năm; hàng trả sau ngày lấy dữ liệu chưa có).
- Nếu còn thời gian: so sánh hai cách xử lý tỷ giá (mục "Sáng tạo" của slide 10).
