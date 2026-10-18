# Bảng giao dịch chung và sheet chất lượng dữ liệu

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 2 – Nạp và làm sạch dữ liệu (phần sau: nối mã cửa hàng, gộp bảng giao dịch chung, sheet kiểm tra chất lượng) |
| Mốc phải đạt | Trước Mốc 3 (23/10) |
| Phần báo cáo liên quan | <ul><li>Phần II (Dữ liệu và chuẩn bị): bảng giao dịch chung, kiểm tra chất lượng dữ liệu</li><li>Dashboard trang 4 (chất lượng dữ liệu)</li></ul> |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [report-skeleton](../completed/thanhlnp-18-10-2026-report-skeleton.md)</li><li>Plan tiếp theo dùng kết quả này: `store-recon`, `web-return-recon`, `bridge-monthly`</li></ul> |

---

## 1. Mục tiêu

Có **một bảng giao dịch chung** `q_Transactions` gộp mọi dòng POS (Point of Sale, bán tại cửa hàng) và mọi đơn online về cùng một dạng: mã cửa hàng bên kế toán, ngày bán / ngày đặt, ngày sổ cái ghi nhận, tiền trước giảm giá, chiết khấu, sau giảm giá, **USD theo 2 tỷ giá** (tỷ giá ngày và tỷ giá cuối tháng), cờ dòng trùng kèm lý do. Các bảng đối soát và bảng cầu nối về sau chỉ đọc từ bảng này. Kèm theo là **sheet chất lượng dữ liệu** tự đếm các lỗi dữ liệu mỗi lần làm mới.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Truy vấn `q_Transactions`, nạp ra sheet `Giao_dich_chung`.
  - Truy vấn `q_DataQuality`, nạp ra sheet `Chat_luong_du_lieu`: dòng trùng, ngày có bán mà thiếu bút toán, bút toán không gắn cửa hàng, đơn hủy mà có ngày giao, đơn giao trước ngày đặt, hàng trả trước ngày giao, dòng bán ở cửa hàng đã đóng cửa, dòng thiếu tỷ giá, mã cửa hàng POS không có trong danh mục, bút toán tay không có giấy tờ.
  - Sửa dòng bẫy 5 (nhiều loại tiền) ở `q_Traps` để trỏ vào bước đổi tiền của `q_Transactions`.
  - Viết phần báo cáo: bảng giao dịch chung, bảng kiểm tra chất lượng.
- **Không làm (để cho plan khác):**
  - So POS với sổ cái theo cửa hàng × ngày → `store-recon`.
  - So đơn online với sổ cái → `web-return-recon`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Các truy vấn nạp | `excel/queries/q_POS.m`, `q_WEB.m`, `q_GL.m`, `q_Store.m`, `q_Calendar.m`, `q_FX_Daily.m`, `q_FX_MonthEnd.m` | Plan `load-clean-data` |
| Cột của bảng giao dịch chung | `docs/cau_truc_du_lieu.md` mục 5 | |
| Số đúng để so | `checks/python_bridge.csv` | Plan `python-check` |
| 7 phép kiểm tra của dashboard mẫu | `docs/template/Nexa_Home_Recon_Dashboard.html` (dữ liệu nhúng, mục `checks`) | 12 dòng trùng, 1 ô thiếu bút toán, 1 bút toán không gắn cửa hàng, 4 phép còn lại bằng 0 |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Đổi nội tệ ra USD bằng cách **chia** cho tỷ giá, không làm tròn từng dòng.
- Tỷ giá ngày: ngày bán (POS) hoặc ngày đặt (online). Tỷ giá cuối tháng: tháng sổ cái ghi nhận (ngày ghi sổ, ngày giao, ngày nhận hàng trả).

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Truy vấn bảng giao dịch chung | `excel/queries/q_Transactions.m` → sheet `Giao_dich_chung` | Đối soát, cầu nối |
| Truy vấn kiểm tra chất lượng | `excel/queries/q_DataQuality.m` → sheet `Chat_luong_du_lieu` | Báo cáo phần II, dashboard trang 4 |
| File Excel dựng lại | `excel/Nexa_Home_Recon_PQ.xlsx` | |
| Phần báo cáo | `report/sections/02_du_lieu_chuan_bi.tex`, bảng sinh tự động | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Số dòng bảng giao dịch chung | 17.124 POS + 9.441 online = 26.565 | QC_Summary | | sheet `Giao_dich_chung` | |
| Tiền trước giảm giá theo tỷ giá ngày, theo tháng bán/đặt, từng kênh (cơ sở của Flash chưa làm tròn) | Flash + phần Flash làm tròn, từng tháng | `checks/python_bridge.csv` | | sheet `Giao_dich_chung` (cộng bằng Python) | |
| Chiết khấu, dòng trùng, đơn hủy theo tháng | khoản `discount`, `pos_duplicate`, `cancelled` | `checks/python_bridge.csv` | | như trên | |
| Dòng thiếu tỷ giá, mã cửa hàng không ghép được | 0 / 0 | dữ liệu | | sheet `Chat_luong_du_lieu` | |
| Dòng POS trùng / ô ngày có bán mà thiếu bút toán / bút toán không gắn cửa hàng | 12 / 1 / 1 | dashboard mẫu, slide 26, 35 | | sheet `Chat_luong_du_lieu` | |
| Đơn hủy có ngày giao / giao trước ngày đặt / trả trước ngày giao / bán ở cửa hàng đã đóng | 0 / 0 / 0 / 0 | dashboard mẫu | | sheet `Chat_luong_du_lieu` | |

**Việc phải có (không phải con số):**
- [ ] Bảng giao dịch chung có đủ cột ở `docs/cau_truc_du_lieu.md` mục 5.
- [ ] Nối mã cửa hàng POS → mã NX qua `store_master` (không ghi cứng mã nào).
- [ ] Sheet chất lượng dữ liệu có cột trạng thái tự đổi màu chữ "Đạt" / "Cần xem".
- [ ] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Ghép tỷ giá cuối tháng cho đơn hủy (không có ngày giao) | Lỗi hoặc tỷ giá rỗng | Ghép kiểu giữ dòng bên trái; đơn hủy để trống tỷ giá cuối tháng |
| Ghép bảng làm nhân đôi dòng (khóa ghép không duy nhất) | Số dòng lớn hơn 26.565 | Kiểm tra khóa của bảng tỷ giá, lịch, danh mục là duy nhất; so số dòng |
| Bảng lớn làm Excel chậm | Dựng file quá giờ | `Table.Buffer` các bảng nhỏ trước khi ghép; dùng `Table.Join` |
| Đếm "ngày có bán mà thiếu bút toán" theo ngày bán thay vì ngày ghi sổ | Ra hàng trăm ô | So theo ngày ghi sổ, mã NX |

---

## 7. Các bước

- [ ] **Bước 1: Viết `q_Transactions`**
  - Làm: phần POS (ghép mã NX, ngày ghi sổ, tỷ giá ngày, tỷ giá cuối tháng), phần online (ghép tỷ giá ngày đặt, tỷ giá cuối tháng của tháng giao và tháng trả), gộp 2 phần.
  - Kiểm tra: 26.565 dòng; không dòng nào thiếu tỷ giá ngày.
- [ ] **Bước 2: Viết `q_DataQuality`, sửa dòng bẫy 5 của `q_Traps`**
  - Kiểm tra: 12 / 1 / 1 và các phép còn lại bằng 0.
- [ ] **Bước 3: Dựng lại file, so với `python_bridge.csv`**
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [ ] **Bước 4: Viết phần báo cáo, lưu vào Git (commit)**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|

---

## 11. Chuẩn bị vấn đáp

---

## 12. Kết quả khi đóng plan
