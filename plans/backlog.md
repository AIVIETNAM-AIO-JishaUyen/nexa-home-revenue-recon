# Backlog: việc cần người dùng quyết định

> Những việc trong lúc làm các plan mà AI (trí tuệ nhân tạo) không tự quyết được, hoặc cần người thật làm (ví dụ bấm trên giao diện, hỏi mentor).
> Mỗi việc ghi: plan phát hiện, vấn đề, các lựa chọn, phương án đang tạm dùng, và việc gì đang chờ quyết định này.

| # | Ngày | Plan phát hiện | Vấn đề | Các lựa chọn | Đang tạm dùng | Chờ quyết định này |
|---|---|---|---|---|---|---|
| 1 | 18/10 | `setup-baseline` | Cần mentor (người hướng dẫn) xác nhận một số quy ước trước khi chốt số nộp | Hỏi 8 câu ở mục "Câu hỏi xin mentor" bên dưới, ở buổi kiểm tra tiến độ 19/10 | Làm theo quy ước đã chốt trong `docs/quy_uoc_va_so_chuan.md` | Nếu mentor trả lời khác: sửa file quy ước (ghi lý do, ngày) rồi chạy lại các bảng |

---

## Câu hỏi xin mentor

1. **% chênh lệch chia cho số nào?**
   - Nhóm đang dùng: thẻ KPI (Key Performance Indicator, ô số liệu chính) trên dashboard chia cho Flash, theo slide 12.
   - Cờ ⚠ vượt ngưỡng của cửa hàng × tháng chia cho |sổ cái|, theo slide 28.
   - Như vậy có đúng không?
2. **Bút toán ADJ-0925 (1.250 USD, không có giấy tờ):** nhóm để ở dòng "Chưa giải thích được", không gộp với phí vận chuyển như slide 32. Có đúng không?
3. **Nộp những file gì?**
   - Excel Power Query và `Mau_nop_Bang_cau_noi.xlsx`.
   - Power BI: nộp dự án dạng thư mục `.pbip` (nén zip), hay bắt buộc file `.pbix`?
   - Báo cáo PDF.
   - Có cần nộp kèm các file `.m` (file code của Power Query) không?
4. **Số làm tròn chuẩn là bao nhiêu?**
   - Slide 32 và 34 ghi 1,01 USD; dashboard mẫu HTML ghi 2,33 USD.
   - Nhóm tính từ nội tệ ÷ tỷ giá, không làm tròn từng dòng, theo định nghĩa slide 34.
   - Mentor có chấp nhận chênh vài USD ở khoản chiết khấu, tỷ giá, làm tròn do cách làm tròn không?
5. **Thứ tự các bước cầu nối:** slide 12, 32 và 38 xếp thứ tự khác nhau. Nhóm theo slide 32 và 36 (chiết khấu → dòng trùng → đơn hủy → lệch thời điểm → … → tỷ giá → làm tròn). Có được không?
6. **File mẫu nộp chỉ có 1 bảng cầu nối toàn công ty.** Nhóm thêm 2 sheet cùng bố cục cho cửa hàng và online (có dòng chuyển kênh MJ-RCL). Có được không?
7. **"guide_report_template" ở slide 45** có phải là file `main.tex` (bài mẫu Steel Plates) mentor đã gửi không? Nhóm giữ khung trình bày của file đó nhưng chia nội dung theo 8 phần của slide 45.
8. **Hàng trả lại** tính theo tỷ giá ngày đặt (−349.148,23). Phần chênh so với sổ cái (tỷ giá cuối tháng) đưa vào dòng tỷ giá. Có đúng ý mentor không?
