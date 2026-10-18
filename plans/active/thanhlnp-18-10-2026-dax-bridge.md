# Tính lại từng khoản cầu nối bằng DAX và so với Power Query

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 5 – Kiểm tra lại bằng cách tính thứ hai |
| Mốc phải đạt | Mốc 4 (25/10): Power Query và Power BI ra cùng một số |
| Phần báo cáo liên quan | Phần IV.5 (kiểm chứng bằng cách tính thứ hai) |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [bridge-template-log](../completed/thanhlnp-18-10-2026-bridge-template-log.md), [powerbi-totals](../completed/thanhlnp-18-10-2026-powerbi-totals.md)</li><li>Plan tiếp theo dùng kết quả này: `refresh-test`, `dashboard` (trang 2 có ô đối chiếu DAX – Power Query)</li></ul> |

---

## 1. Mục tiêu

Tính lại **từng khoản** của bảng cầu nối bằng công thức DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) trên dữ liệu mentor (người hướng dẫn) chuẩn bị cho Power BI, rồi so với bảng cầu nối của Power Query (`BR_Long`) ở từng tháng × khoản × kênh. Hai cách tính độc lập ra cùng số thì kết luận của bảng cầu nối đáng tin hơn.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Thêm vào mô hình Power BI:
    - Cột tính `fact_pos_line[is_duplicate]` (dòng xuất lặp: cùng số hóa đơn + số dòng, lần xuất sau).
    - Cột tính tỷ giá ngày của **ngày ghi sổ** cho dòng POS (Point of Sale, bán tại cửa hàng) và bút toán sổ cái (dùng cho khoản lỗi chuyển dữ liệu).
    - Cột tính `dim_date[trong_ky_doi_soat]`: tháng có trong Flash (không ghi cứng năm).
    - Bảng danh mục khoản `dim_bridge_item` và bảng `pq_br_long` đọc từ file Power Query (`excel/Nexa_Home_Recon_PQ.xlsx`, bảng `q_BridgeItems`, `q_BR_Long`), qua tham số đường dẫn mới `PQFile`.
  - Công thức DAX từng khoản (thư mục "2. Cầu nối (DAX)"), công thức gom `Cầu nối (DAX)`, `Cầu nối (Power Query)`, `Lệch DAX − Power Query`.
  - Truy vấn DAX so 2 cách tính, lưu CSV (Comma-Separated Values, file bảng dạng chữ) vào `powerbi/checks/`; xuất toàn bộ công thức ra `powerbi/dax_measures.dax` bằng `INFO.VIEW.MEASURES()`.
  - Viết phần IV.5 của báo cáo.
- **Không làm (để cho plan khác):**
  - Hình ảnh trên trang dashboard → `dashboard`.
  - Chạy thử làm mới với tháng mới → `refresh-test`.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Dự án Power BI | `powerbi/NexaRecon.pbip`, `powerbi/NexaRecon.SemanticModel/definition/` | 12 bảng, quan hệ theo slide 19, 5 công thức số tổng (plan `powerbi-totals`) |
| Dữ liệu mentor cho Power BI | `data/Nexa_Home_Recon_Dataset.xlsx` | Cột `*_local` (nội tệ) và tỷ giá từng dòng; cột `*_usd_*` đã làm tròn sẵn, **không dùng** |
| Bảng cầu nối Power Query | `excel/Nexa_Home_Recon_PQ.xlsx`, bảng `q_BR_Long` (708 dòng), `q_BridgeItems` | Số để so |
| Cách tính từng khoản | `excel/queries/q_BR_Long.m` | Cùng định nghĩa, viết lại bằng DAX |
| Công cụ chạy truy vấn | `powerbi/dax_query.ps1` | Mở dự án, làm mới, chạy DAX ra CSV |
| DAX mẫu | Slide 29–30 | `USERELATIONSHIP`, cờ vượt ngưỡng |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash; thứ tự và tỷ giá của từng khoản như mục 1 file quy ước.
- Tính từ nội tệ ÷ tỷ giá từng dòng, không cộng cột USD đã làm tròn (nếu không sẽ lệch vài USD, ví dụ chiết khấu −1.834.298,38 thay vì −1.834.297,47).
- Không ép khớp: chỗ nào lệch thì tìm nguyên nhân, ghi lại.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Mô hình có thêm cột tính, 2 bảng, công thức cầu nối | `powerbi/NexaRecon.SemanticModel/definition/` | `dashboard` |
| Truy vấn so và kết quả | `powerbi/checks/bridge_compare.dax`, `bridge_compare.csv` | Báo cáo IV.5, `review-submit` |
| Toàn bộ công thức DAX | `powerbi/dax_measures.dax` | Bộ file nộp |
| Phần IV.5 | `report/sections/04_phan_tich_chinh.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Lệch lớn nhất DAX − Power Query, mọi kênh (toàn công ty, cửa hàng, online, chưa gắn kênh) × 12 tháng × khoản | ≤ 0,01 | Điều kiện của plan tổng | | `powerbi/checks/bridge_compare.csv` | |
| Chiết khấu cả năm bằng DAX | −1.834.297,47 | `checks/numbers_of_record.csv` (`br_y_discount`) | | như trên | |
| Tỷ giá / làm tròn cả năm bằng DAX | −57.598,01 / +1,01 | `br_y_fx`, `br_y_rounding` | | như trên | |
| Dòng kiểm tra bằng DAX, mọi kênh × tháng | 0 (≤ 0,01) | | | như trên | |

**Việc phải có (không phải con số):**
- [ ] Mỗi công thức có ghi chú `///` nói khoản đó tính thế nào, dùng ngày nào, tỷ giá nào.
- [ ] Không công thức nào dùng cột `*_usd_*` đã làm tròn của bảng POS và online (trừ Flash và `revenue_usd` của sổ cái, là số hai hệ thống thật sự ghi).
- [ ] Không ghi cứng năm trong công thức.
- [ ] `powerbi/README.md` có mục công thức cầu nối và cách chạy truy vấn so.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Quên `USERELATIONSHIP` khi tính theo ngày bán / ngày đặt / ngày trả | Khoản lệch thời điểm hoặc lệch ngày ghi sổ ra 0; chiết khấu xếp sai tháng | So từng tháng, không chỉ cả năm |
| Đơn hủy không có ngày giao | Lọc theo tháng giao thì đơn hủy rơi vào dòng trống | Chỉ tính đơn hủy theo ngày đặt |
| Lỗi chuyển dữ liệu tính theo tỷ giá ngày bán thay vì ngày ghi sổ | Ô NX057 vẫn đúng (tiền USD) nên không phát hiện | Viết đúng định nghĩa: tỷ giá ngày của ngày ghi sổ, cho cả 2 phía |
| Dữ liệu mentor khác file nguồn (ví dụ cách đánh dấu dòng trùng) | Lệch ở 1 khoản | Tìm nguyên nhân, ghi lại, không sửa số |
| Bảng ngày có tháng 12 năm trước và tháng 1 năm sau | Cả năm của lệch thời điểm online sai | Mọi công thức lọc `dim_date[trong_ky_doi_soat]` |

---

## 7. Các bước

- [ ] **Bước 1: Thêm cột tính, bảng danh mục khoản, bảng `pq_br_long` vào mô hình (file `.tmdl`)**
  - Kiểm tra: mở dự án, làm mới không lỗi; 12 dòng trùng; `pq_br_long` 708 dòng.
- [ ] **Bước 2: Viết công thức từng khoản và công thức gom**
  - Kiểm tra: truy vấn so ra lệch ≤ 0,01 ở mọi ô.
- [ ] **Bước 3: Xuất `dax_measures.dax`, cập nhật `powerbi/README.md`**
- [ ] **Bước 4: Viết phần IV.5, lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc mô hình hiện có và dữ liệu mentor | <ul><li>12 dòng POS có `export_seq` = 2, cùng khóa với 12 dòng `export_seq` = 1, ở cửa hàng mã 74</li><li>Sổ cái online gắn cửa hàng 999999 (kênh WEB), bút toán ADJ gắn −1 (chưa gắn kênh): lọc kênh qua bảng cửa hàng là đủ</li><li>Sổ cái ghi `amount_local` âm (bên Có), `revenue_usd` đã đổi dấu</li></ul> | |

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

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
