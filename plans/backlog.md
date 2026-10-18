# Backlog: việc cần người dùng quyết định

> Những việc trong lúc làm các plan mà AI (trí tuệ nhân tạo) không tự quyết được, hoặc cần người thật làm (ví dụ bấm trên giao diện, hỏi mentor).
> Mỗi việc ghi: plan phát hiện, vấn đề, các lựa chọn, phương án đang tạm dùng, và việc gì đang chờ quyết định này.

| # | Ngày | Plan phát hiện | Vấn đề | Các lựa chọn | Đang tạm dùng | Chờ quyết định này |
|---|---|---|---|---|---|---|
| 1 | 18/10 | `setup-baseline` | Cần mentor (người hướng dẫn) xác nhận một số quy ước trước khi chốt số nộp | Hỏi 8 câu ở mục "Câu hỏi xin mentor" bên dưới, ở buổi kiểm tra tiến độ 19/10 | Làm theo quy ước đã chốt trong `docs/quy_uoc_va_so_chuan.md` | Nếu mentor trả lời khác: sửa file quy ước (ghi lý do, ngày) rồi chạy lại các bảng |
| 2 | 18/10 | `setup-baseline` | <ul><li>Mới cài Power BI Desktop trên 1 máy (bản Microsoft Store 2.159.883.0)</li><li>Ghi chú kỹ thuật yêu cầu cả nhóm dùng **cùng một phiên bản**; bản Microsoft Store tự cập nhật nên phiên bản dễ lệch nhau</li><li>Chưa kiểm tra máy 2 bạn còn lại có đủ Excel 365, Power BI, TeX Live hoặc MiKTeX, Git không</li></ul> | <ul><li>Cả nhóm cài bản Microsoft Store và cập nhật cùng ngày, trước mỗi lần mở file của nhau thì so số phiên bản</li><li>Hoặc cả nhóm cài bản tải về (file cài đặt .exe) cùng một số phiên bản và tắt tự cập nhật</li></ul> | Bản Microsoft Store trên máy này | <ul><li>Mở dự án Power BI trên máy khác (`powerbi-totals`, `dashboard`)</li><li>Chạy thử làm mới trên máy khác (`refresh-test`)</li></ul> |
| 3 | 18/10 | `load-clean-data` | <ul><li>Mỗi truy vấn nạp đọc **đúng 1 file** có tên bắt đầu đúng chữ (ví dụ `POS_Sales_Export`) trong thư mục dữ liệu (không tìm thư mục con)</li><li>Nếu dữ liệu tháng mới đến dưới dạng **file riêng** nằm cạnh file cũ (ví dụ thêm `POS_Sales_Export_2026_01.csv`), truy vấn sẽ báo lỗi "phải có đúng 1 file" (đã sửa ngày 18/10, trước đó lấy bừa file đầu tiên)</li><li>Chưa biết dữ liệu tháng mới sẽ được đưa theo cách nào</li></ul> | <ul><li>Thay file cũ bằng file mới cùng phần đầu tên (rubric Band 5 ghi "chạy lại được cho tháng mới chỉ bằng thay file rồi refresh"): giữ cách đọc 1 file, thêm bước báo lỗi rõ ràng khi thư mục có hơn 1 file khớp tên</li><li>Mỗi tháng một file, nằm chung thư mục: sửa các truy vấn nạp để đọc và ghép mọi file khớp tên</li></ul> | Thay file: đọc đúng 1 file, báo lỗi rõ ràng nếu thư mục có 0 hoặc hơn 1 file khớp tên | <ul><li>Cách tạo dữ liệu giả của tháng mới ở plan `refresh-test`</li><li>Có thể hỏi mentor ở buổi kiểm tra tiến độ 19/10</li></ul> |
| 4 | 18/10 | `powerbi-totals` | <ul><li>Trang báo cáo Power BI đang sinh từ script `powerbi/build_report.py`; mỗi lần chạy, script xóa cả thư mục `powerbi/NexaRecon.Report/definition` rồi tạo lại</li><li>Nếu một bạn làm hình bằng giao diện Power BI Desktop rồi bấm lưu, lần chạy script sau sẽ xóa mất phần đó</li><li>Khi lưu, Power BI Desktop cũng viết lại các file `.tmdl` của mô hình (thêm mã nhận dạng, ghi chú), làm thay đổi rất nhiều dòng trên Git</li><li>Dashboard 4 trang có nhiều hình; làm bằng script thì cả nhóm phải đọc được Python</li></ul> | <ul><li>Giữ script là bản gốc: mọi trang dashboard viết trong `build_report.py`, không bấm lưu trong Power BI Desktop</li><li>Làm dashboard bằng giao diện Power BI Desktop: thôi chạy `build_report.py` từ plan `dashboard`, coi các file Power BI lưu ra là bản gốc, lưu lên Git sau mỗi lần sửa</li><li>Kết hợp: script sinh trang "Số tổng", các trang dashboard làm bằng giao diện; phải sửa script để chỉ xóa trang của nó</li></ul> | Script là bản gốc (quyết định ở plan `powerbi-totals`); chưa ai sửa trang bằng giao diện | <ul><li>Cách làm 4 trang ở plan `dashboard`</li><li>Thêm công thức ở plan `dax-bridge` (sửa file `.tmdl` hay sửa trong Power BI Desktop rồi lưu)</li></ul> |
| 5 | 18/10 | `report-skeleton` | Trang bìa báo cáo đang để chỗ trống: tên 2 thành viên còn lại và tên mentor (người hướng dẫn) | Điền vào `report/main.tex` (khối `\author` và dòng Mentor) | Ghi "(Thành viên 2)", "(Thành viên 3)", "(tên mentor)" | Bản PDF nộp ở plan `review-submit` |

---

## Câu hỏi xin mentor

1. **% chênh lệch chia cho số nào?**
   - Nhóm đang dùng: thẻ KPI (Key Performance Indicator, ô số liệu chính) trên dashboard chia cho Flash, theo slide 12.
   - Cờ ⚠ vượt ngưỡng của cửa hàng × tháng chia cho |sổ cái| (giá trị tuyệt đối, tức bỏ dấu âm), theo slide 28.
   - Như vậy có đúng không?
2. **Bút toán ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh; 1.250 USD (đô la Mỹ), không có giấy tờ):** nhóm để ở dòng "Chưa giải thích được", không gộp với phí vận chuyển như slide 32. Có đúng không?
3. **Nộp những file gì?**
   - Excel Power Query và `Mau_nop_Bang_cau_noi.xlsx`.
   - Power BI: nộp dự án dạng thư mục `.pbip` (dự án Power BI lưu thành nhiều file chữ, nén zip), hay bắt buộc file `.pbix` (một file Power BI gói cả dữ liệu)?
   - Báo cáo PDF (Portable Document Format).
   - Có cần nộp kèm các file `.m` (file code của Power Query) không?
4. **Số làm tròn chuẩn là bao nhiêu?**
   - Nhóm tính từ nội tệ ÷ tỷ giá, không làm tròn từng dòng, theo định nghĩa slide 34. Ra làm tròn **+1,01 USD** (Flash +0,95, sổ cái +0,05) và tỷ giá −57.598,01: **khớp slide 32 và 34**.
   - Dashboard mẫu dạng trang web HTML (HyperText Markup Language) lại ghi làm tròn 2,33 USD, chiết khấu −1.834.298,38, tỷ giá −57.598,50, vì nó cộng các cột USD đã làm tròn sẵn từng dòng trong file Recon_Dataset.
   - Mentor có chấp nhận số của nhóm (theo slide) không, và có chấp nhận chênh vài USD so với dashboard mẫu không?
5. **Thứ tự các bước cầu nối:** slide 12, 32 và 38 xếp thứ tự khác nhau. Nhóm theo slide 32 và 36 (chiết khấu → dòng trùng → đơn hủy → lệch thời điểm → … → tỷ giá → làm tròn). Có được không?
6. **File mẫu nộp chỉ có 1 bảng cầu nối toàn công ty.** Nhóm thêm 2 sheet cùng bố cục cho cửa hàng và online (có dòng chuyển kênh MJ-RCL – MJ = Manual Journal, bút toán tay; RCL = Reclassification, phân loại lại). Có được không?
7. **"guide_report_template" ở slide 45** có phải là file `main.tex` (bài mẫu Steel Plates) mentor đã gửi không? Nhóm giữ khung trình bày của file đó nhưng chia nội dung theo 8 phần của slide 45.
8. **Hàng trả lại** tính theo tỷ giá ngày đặt (−349.148,23). Phần chênh so với sổ cái (tỷ giá cuối tháng) đưa vào dòng tỷ giá. Có đúng ý mentor không?
