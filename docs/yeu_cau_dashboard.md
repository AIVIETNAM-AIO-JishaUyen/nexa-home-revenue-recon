# Yêu cầu dashboard (slide 11–14)

> Tài liệu tham khảo cho [roadmap](../roadmap.md). Từ khó xem ở [từ điển](../tu_dien_roadmap.md).
> Dashboard (màn hình gồm các con số chính và biểu đồ) làm bằng Power BI (phần mềm của Microsoft), gồm 4 trang. Số tiền tính bằng USD (đô la Mỹ).

**Bộ lọc dùng chung cho cả 4 trang** (chọn ở một trang thì các trang khác đổi theo):
- Tháng: chọn 1 tháng hoặc cả năm, **mặc định tháng 12/2025**.
- Kênh: Tất cả · Cửa hàng (POS – Point of Sale) · Online.
- Quốc gia: Tất cả hoặc 1 trong 8 nước. **Khi chọn một nước thì bỏ kênh online**, vì Flash chia online theo 5 thị trường (Australia, Canada, Eurozone, United Kingdom, United States), trong đó Eurozone (khu vực dùng đồng Euro) gộp nhiều nước, nên không khớp với 8 nước của cửa hàng.
- Nút **Đặt lại**: đưa mọi bộ lọc về mặc định.

**Quy tắc chung cho mọi trang:**
- Mở đầu mỗi trang bằng một câu **"Điểm chính"** tóm tắt kết luận.
- Ô số liệu chính (thẻ KPI – Key Performance Indicator) ghi giá trị và **mức thay đổi so với tháng trước**.
- **Tiêu đề biểu đồ nói luôn kết luận kèm con số**, ví dụ "Chiết khấu kéo sổ cái xuống 202,8 nghìn USD".
- Dùng màu xám cho phần nền, chỉ một màu nổi bật cho điều cần chú ý, màu đỏ chỉ dành cho ô vượt ngưỡng ⚠.
- Không dùng biểu đồ tròn, biểu đồ vành khuyên (hình tròn rỗng ở giữa), biểu đồ 3D. Ghi nhãn số ngay trên biểu đồ.
- Cuối trang ghi **nguồn dữ liệu và ngày lấy dữ liệu**.
- Dấu của chênh lệch thống nhất ở mọi trang.

| Trang | Ô số liệu chính (KPI) | Biểu đồ / bảng bắt buộc |
|---|---|---|
| 1 · Tổng quan | <ul><li>Flash</li><li>Sổ cái (nghìn USD)</li><li>Chênh lệch (USD và % so với Flash)</li><li>Phần do lỗi dữ liệu</li><li>Phần chưa giải thích</li></ul> | <ul><li>Biểu đồ đường Flash (xám) và sổ cái (xanh) 12 tháng, tháng đang chọn có nhãn</li><li>Biểu đồ thác nước (đi từ Flash, cộng trừ từng nhóm, đến sổ cái): Flash → quy tắc ghi nhận → lỗi dữ liệu → chưa giải thích → sổ cái</li><li>Biểu đồ cột % chênh lệch theo tháng</li><li>Cột "chênh lệch còn lại sau khi trừ phần do quy tắc", **tô đỏ khi độ lớn (bỏ dấu âm) > 200 USD**</li></ul> |
| 2 · Cầu nối | <ul><li>Flash</li><li>Quy tắc ghi nhận</li><li>Lỗi dữ liệu</li><li>Chưa giải thích</li><li>Sổ cái</li></ul> | <ul><li>Biểu đồ thác nước từng khoản, đúng tên và thứ tự như bảng cầu nối (chiết khấu, dòng POS trùng, đơn hủy, lệch thời điểm online, lệch ngày ghi sổ của cửa hàng, lỗi chuyển dữ liệu, hàng trả, phí vận chuyển, chuyển kênh khi lọc theo kênh, tỷ giá, làm tròn, chưa giải thích)</li><li>Biểu đồ cột ngang xếp các khoản từ lớn đến nhỏ, **nhãn ghi % trên độ lớn tổng chênh lệch (bỏ dấu âm)**</li><li>Bảng cầu nối 12 tháng, **cột tháng đang chọn được tô màu**, dòng kiểm tra về 0</li></ul> |
| 3 · Đối soát chi tiết | <ul><li>Số ô (cửa hàng × ngày)</li><li>Số ô lệch nếu so theo ngày bán</li><li>Số cửa hàng vượt ngưỡng (dữ liệu chưa xử lý / sau khi đưa về cùng cách tính)</li><li>Chênh lệch online sau khi đổi sang ngày giao</li></ul> | <ul><li>Đường chênh lệch cửa hàng: dữ liệu chưa xử lý so với sau khi đưa về cùng cách tính</li><li>Đường chênh lệch online: theo ngày đặt so với theo ngày giao</li><li>Bảng cửa hàng xếp theo độ lớn chênh lệch, có cột ⚠</li><li>Bảng các ô cửa hàng × ngày còn lệch (**bấm vào xem được từng ô**)</li></ul> |
| 4 · Hoàn trả, hủy và chất lượng dữ liệu | <ul><li>Giá trị và tỷ lệ hàng trả (**tính bằng điểm phần trăm**, ví dụ từ 1,5% lên 2,0% là tăng 0,5 điểm; tăng là xấu)</li><li>Số đơn hủy</li><li>Số dòng POS trùng</li><li>Số bút toán tay</li></ul> | <ul><li>Đường tỷ lệ hàng trả 12 tháng</li><li>Cột số đơn hủy theo tháng đặt</li><li>Bảng bút toán tay, **tô đỏ bút toán không có giấy tờ làm căn cứ**</li><li>Bảng các phép kiểm tra dữ liệu (trùng dòng, ngày thiếu, bút toán không gắn cửa hàng…)</li></ul> |
| (thêm) Đối chiếu — đặt ngay trên trang 2, không phải trang thứ 5 | — | <ul><li>Ô hoặc bảng nhỏ so tổng bảng cầu nối tính bằng DAX (ngôn ngữ công thức của Power BI) với tổng tính bằng Power Query theo từng tháng</li><li>Mục đích: chứng minh 2 cách tính ra cùng số</li></ul> |
