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
    - Cột tính tỷ giá cuối **tháng bán** cho dòng POS (dùng cho chênh lệch cửa hàng × tháng "trước xử lý", bước thêm).
    - Cột tính `dim_date[trong_ky_doi_soat]`: tháng có trong Flash (không ghi cứng năm).
    - Bảng danh mục khoản `dim_bridge_item` và bảng `pq_br_long` đọc từ file Power Query (`excel/Nexa_Home_Recon_PQ.xlsx`, bảng `q_BridgeItems`, `q_BR_Long`), qua tham số đường dẫn mới `PQFile`.
  - Công thức DAX từng khoản (thư mục "2. Cầu nối (DAX)"), công thức gom `Cầu nối (DAX)`, `Cầu nối (Power Query)`, `Lệch DAX − Power Query` (thư mục "3. So với Power Query").
  - Mẫu DAX của slide 30: chênh lệch cửa hàng × tháng trước / sau xử lý và cờ vượt ngưỡng (thư mục "4. Đối soát cửa hàng × tháng (slide 30)").
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
| Truy vấn so và kết quả | <ul><li>`powerbi/checks/bridge_compare.dax`, `bridge_compare.csv`</li><li>`powerbi/checks/store_month_compare.dax`, `store_month_compare.csv`</li><li>`powerbi/checks/store_month_flags.dax`, `store_month_flags.csv`</li></ul> | Báo cáo IV.5, `review-submit` |
| Toàn bộ công thức DAX | `powerbi/dax_measures.dax` | Bộ file nộp |
| Phần IV.5 | `report/sections/04_phan_tich_chinh.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Lệch lớn nhất DAX − Power Query, mọi kênh (toàn công ty, cửa hàng, online, chưa gắn kênh) × 12 tháng × khoản | ≤ 0,01 | Điều kiện của plan tổng | <ul><li>0,000000007 (709 ô, 0 ô quá 0,01)</li><li>709 ô = 708 dòng của `q_BR_Long` + 1 ô chuyển kênh toàn công ty tháng 6 (DAX ra 0; Power Query không có dòng chuyển kênh ở bảng toàn công ty)</li></ul> | `powerbi/checks/bridge_compare.csv` | Đạt |
| Chiết khấu cả năm bằng DAX | −1.834.297,47 | `checks/numbers_of_record.csv` (`br_y_discount`) | −1.834.297,47 | như trên | Đạt |
| Tỷ giá / làm tròn cả năm bằng DAX | −57.598,01 / +1,01 | `checks/numbers_of_record.csv` (`br_y_fx`, `br_y_rounding`) | −57.598,01 / +1,01 | như trên | Đạt |
| Dòng kiểm tra bằng DAX, mọi kênh × tháng | 0 (≤ 0,01) | Điều kiện của plan tổng | 0 (48/48 ô) | như trên | Đạt |
| Cửa hàng × tháng (mẫu DAX slide 30): chênh lệch trước / sau và 2 cờ | Khớp 679 ô của `Doi_soat_CH_thang` | Plan `store-recon` | 679/679 ô khớp tuyệt đối | `powerbi/checks/store_month_compare.csv` | Đạt |
| Số ô vượt ngưỡng trước → sau xử lý; tháng 11 | 137 → 2; 21 → 1 | Plan `store-recon` | 137 → 2; 21 → 1 | `powerbi/checks/store_month_flags.csv` | Đạt |

**Việc phải có (không phải con số):**
- [x] Mỗi công thức có ghi chú `///` nói khoản đó tính thế nào, dùng ngày nào, tỷ giá nào.
- [x] Không công thức nào dùng cột `*_usd_*` đã làm tròn của bảng POS và online (trừ Flash và `revenue_usd` của sổ cái, là số hai hệ thống thật sự ghi).
- [x] Không ghi cứng năm trong công thức.
- [x] `powerbi/README.md` có mục công thức cầu nối và cách chạy truy vấn so.

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

- [x] **Bước 1: Thêm cột tính, bảng danh mục khoản, bảng `pq_br_long` vào mô hình (file `.tmdl`)**
  - Kiểm tra: mở dự án, làm mới không lỗi; 12 dòng trùng; `pq_br_long` 708 dòng.
- [x] **Bước 2: Viết công thức từng khoản và công thức gom**
  - Kiểm tra: truy vấn so ra lệch ≤ 0,01 ở mọi ô.
- [x] **Bước 3: Xuất `dax_measures.dax`, cập nhật `powerbi/README.md`**
- [x] **Bước thêm: viết lại mẫu DAX của slide 30 (cửa hàng × tháng, cờ vượt ngưỡng) và so với `q_RC_Store_Month`**
- [x] **Bước 4: Viết phần IV.5, lưu vào Git (commit)**
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc mô hình hiện có và dữ liệu mentor | <ul><li>12 dòng POS có `export_seq` = 2, cùng khóa với 12 dòng `export_seq` = 1, ở cửa hàng mã 74</li><li>Sổ cái online gắn cửa hàng 999999 (kênh WEB), bút toán ADJ gắn −1 (chưa gắn kênh): lọc kênh qua bảng cửa hàng là đủ</li><li>Sổ cái ghi `amount_local` âm (bên Có), `revenue_usd` đã đổi dấu</li></ul> | |
| 18/10 | Kiểm tra dữ liệu trước khi viết cột tính | <ul><li>Tỷ giá ngày có đủ 5 loại tiền (kể cả USD) và đủ mọi ngày ghi sổ của POS và sổ cái</li><li>`revenue_usd` của sổ cái = −nội tệ ÷ tỷ giá cuối tháng, làm tròn 2 chữ số (lệch 0 ở mọi dòng)</li></ul> | |
| 18/10 | Thêm vào mô hình: tham số `PQFile`, bảng `dim_bridge_item`, `pq_br_long`, 5 cột tính, 23 công thức cầu nối; mở Power BI, làm mới, chạy `bridge_compare.dax` | 709 ô, lệch lớn nhất 0,000000007 USD; `pq_br_long` khớp 708 dòng của `q_BR_Long` | Khớp ngay lần chạy đầu |
| 18/10 | Viết lại mẫu DAX slide 30: 9 công thức cửa hàng × tháng | 679/679 ô khớp; 137 → 2 ô vượt ngưỡng; tháng 11: 21 → 1 | Truy vấn `ROW` truyền qua tham số `-Query` bị mất dấu nháy; chuyển sang file `store_month_flags.dax` |
| 18/10 | Xuất 37 công thức ra `dax_measures.dax`, cập nhật `powerbi/README.md`, viết IV.5 | Bảng 16 (cả năm theo hai cách tính) | Tên lệnh LaTeX không được có chữ số (`\SoDaxCoSauT11` làm hỏng bản dịch); đổi thành `ThangMuoiMot` |
| 18/10 | Rà soát: đọc lại 3 file CSV bằng Python, so với sheet `BR_Long`, `Doi_soat_CH_thang` và `checks/numbers_of_record.csv`; đối chiếu từng công thức với `q_BR_Long.m`, `q_RC_Store_Month.m`; kiểm từng ô cửa hàng × ngày ghi sổ trên dữ liệu mentor | <ul><li>Đạt cả 6 dòng số ở mục 5</li><li>5.120 ô cửa hàng × ngày ghi sổ: 5.118 ô khớp có hiệu bằng 0, 2 ô lệch (NX057, 21/11 và 02/12)</li><li>Không công thức nào dùng cột `*_usd_*` của POS / online, không ghi cứng năm</li></ul> | Sửa chữ: lý do của quyết định về lỗi chuyển dữ liệu (mục 9), giải thích 709 ô, thêm thư mục 4 và các file kết quả vào mục 2, 4 |
| 18/10 | Sửa theo rà soát: 2 công thức đếm ô vượt ngưỡng đếm theo mã cửa hàng của sổ cái (`finance_store_code`) thay vì mã POS, giống Power Query; mở lại Power BI, chạy lại 3 truy vấn so | Kết quả không đổi: 709 ô khớp; 679/679 ô; 137 → 2, tháng 11: 21 → 1 | Năm 2025 mỗi mã sổ cái chỉ có 1 mã POS còn bán nên hai cách đếm ra như nhau; sửa để tháng mới có cửa hàng 2 mã POS cùng lúc không bị đếm dư |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Danh mục khoản và bảng cầu nối Power Query đọc thẳng từ file Power Query vào mô hình (tham số `PQFile`) | <ul><li>Hai cách tính dùng chung một danh mục khoản, không gõ lại</li><li>So được ngay trong Power BI, dashboard trang 2 hiện được ô đối chiếu</li><li>Đổi lại: mô hình phụ thuộc file Power Query; phải làm mới file Excel trước rồi mới làm mới Power BI</li></ul> | Không |
| 18/10 | Dòng trùng xác định bằng khóa (số hóa đơn + số dòng, lần xuất sau), không chỉ dựa vào `export_seq` = 2 | Cùng cách Power Query làm; nếu sau này một dòng chỉ xuất ở lần 2 thì không bị đếm nhầm là trùng | Không |
| 18/10 | Khoản lỗi chuyển dữ liệu tính bằng hiệu tổng (bút toán POS trên sổ cái − dòng POS bỏ trùng, cùng tỷ giá ngày ghi sổ) thay vì duyệt từng ô | <ul><li>Hai bên của cùng một ô (cửa hàng × ngày ghi sổ × loại tiền) đổi theo cùng một tỷ giá, nên cộng hiệu từng ô bằng đúng hiệu hai tổng; công thức đơn giản, chạy nhanh</li><li>Khác duy nhất: Power Query làm tròn hiệu nội tệ của từng ô đến 2 chữ số trước khi đổi. Với dữ liệu mentor, 5.118 ô khớp có hiệu bằng 0 (chỉ còn sai số máy, dưới 0,000000000004 nội tệ), nên việc làm tròn này không đổi kết quả</li><li>Kết quả khớp Power Query đến 0,000000007 USD</li><li>Giới hạn: 2 ô lệch (NX057) đều bằng USD, nên phép so này không phân biệt được tỷ giá ngày ghi sổ với tỷ giá ngày bán</li></ul> | Không |
| 18/10 | Mọi công thức cầu nối lọc `dim_date[trong_ky_doi_soat]` (tháng có trong Flash) | Bảng ngày có tháng 12 năm trước và tháng 1 năm sau; không lọc thì lệch thời điểm online cả năm sai | Không |
| 18/10 | Thêm mẫu DAX slide 30 (cửa hàng × tháng, cờ vượt ngưỡng) vào plan này | Ghi chú của công thức `% chênh lệch so với sổ cái` (plan `powerbi-totals`) đã hẹn làm ở đây; dashboard trang 3 cần | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết lại các khoản cầu nối bằng DAX, truy vấn so, phần IV.5 | Cột tính và công thức trong `_Measures.tmdl`, `dim_bridge_item.tmdl`, `pq_br_long.tmdl`; `powerbi/checks/*.dax`; `dax_measures.dax`; mục IV.5 | <ul><li>So 709 ô với `q_BR_Long` và 679 ô với `q_RC_Store_Month`</li><li>So cả năm với số chuẩn trong `checks/numbers_of_record.csv`</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Power Query và Power BI có ra cùng số không?
   **Trả lời:** Có. 709 ô (toàn công ty và 3 kênh × 12 tháng × khoản) lệch lớn nhất 0,000000007 USD, chỉ là sai số tính toán của máy. Cách thứ hai dùng dữ liệu khác (file mentor chuẩn bị cho Power BI) và ngôn ngữ khác (DAX), nên khớp nghĩa là định nghĩa từng khoản đúng chứ không phải chép số.
2. **Hỏi:** Sao không dùng các cột USD có sẵn trong file của mentor?
   **Trả lời:** Các cột đó đã làm tròn 2 chữ số từng dòng. Cộng lại thì chiết khấu ra −1.834.298,38, lệch 0,91 USD so với số chuẩn −1.834.297,47; dòng làm tròn khi đó cũng sai. Nhóm tính lại từ nội tệ ÷ tỷ giá từng dòng.
3. **Hỏi:** Mỗi khoản lấy ngày nào?
   **Trả lời:** Quan hệ đang dùng là ngày ghi sổ (POS), ngày giao (online). Khoản cần ngày khác thì bật quan hệ bị động bằng `USERELATIONSHIP`: chiết khấu, dòng trùng theo ngày bán; đơn hủy theo ngày đặt; hàng trả theo ngày trả. Lệch thời điểm = cùng một số đo tính theo ngày giao trừ theo ngày đặt.
4. **Hỏi:** Cờ vượt ngưỡng trên Power BI có giống bảng Power Query không?
   **Trả lời:** Giống từng ô: 679/679 ô cửa hàng × tháng. Trước xử lý có 137 ô vượt ngưỡng, sau khi đưa về cùng cách tính (bỏ dòng trùng, theo tháng ghi sổ, tỷ giá cuối tháng ghi sổ) còn 2 ô, đều của NX057 (tháng 11 thiếu 7.227,56, tháng 12 ghi bù).

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 6 dòng số và 4 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục IV.5 (Bảng 16: cả năm theo hai cách tính).
- **Việc còn lại:**
  - Ô đối chiếu DAX – Power Query và cờ vượt ngưỡng trên trang dashboard → `dashboard`.
  - Làm mới Power BI với dữ liệu tháng mới (file mentor chỉ có năm 2025) → `refresh-test`.
- **Các lần lưu vào Git (commit):** `d0b648f` (tạo plan), `b72ce46` (mô hình, công thức, truy vấn so, `dax_measures.dax`), `41f0f6b` (`powerbi/README.md`), `f80733a` (báo cáo IV.5), và các lần lưu ghi kết quả, rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
