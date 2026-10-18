# Đối soát cửa hàng theo ngày ghi sổ, cờ vượt ngưỡng, lệch ngày ghi sổ tự bù trừ

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 3 – Đối soát chi tiết (phần cửa hàng) |
| Mốc phải đạt | Mốc 3 (23/10) |
| Phần báo cáo liên quan | Phần IV.1 (đối soát cửa hàng theo ngày ghi sổ); câu hỏi riêng 1 và 3 |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [transactions-quality](../completed/thanhlnp-18-10-2026-transactions-quality.md)</li><li>Plan tiếp theo dùng kết quả này: `web-return-recon`, `bridge-monthly`, `dashboard` (trang 3)</li></ul> |

---

## 1. Mục tiêu

Đối soát POS (Point of Sale, bán tại cửa hàng) với sổ cái ở **mức chi tiết nhất có thể: cửa hàng × ngày ghi sổ × loại tiền, so bằng nội tệ**, chia mỗi ô vào 4 trường hợp (khớp, chỉ có ở POS, chỉ có ở sổ cái, có cả hai nhưng lệch tiền). Sau đó cộng lên cửa hàng × tháng để đánh dấu ⚠ vượt ngưỡng, so **trước** và **sau** khi đưa hai bên về cùng cách tính, và chứng minh khoản lệch ngày ghi sổ tự bù trừ theo cặp tháng.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - `q_RC_Store`: ô cửa hàng × ngày ghi sổ × loại tiền, 4 trường hợp, số tiền lệch theo nội tệ và USD (đô la Mỹ).
  - `q_RC_Store_Raw`: cùng cách so nhưng POS lấy theo **ngày bán, chưa bỏ dòng trùng** (cách so "chưa xử lý"), để thấy vì sao phải đưa về cùng cách tính.
  - `q_RC_Store_Month`: cửa hàng × tháng, chênh lệch trước và sau khi đưa về cùng cách tính, % so với |sổ cái|, cờ ⚠ theo ngưỡng 200 USD và 1%.
  - `q_RC_Store_Timing`: lệch ngày ghi sổ theo tháng, chỉ ra các cặp tháng tự bù trừ.
  - Viết phần IV.1 của báo cáo.
- **Không làm (để cho plan khác):** online và hàng trả (`web-return-recon`); bảng cầu nối (`bridge-monthly`).

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| Bảng giao dịch chung | `excel/queries/q_Transactions.m` | Cột `store_code`, `recognition_date`, `net_local`, `net_usd_month_end`, `is_duplicate` |
| Sổ cái | `excel/queries/q_GL.m` | Bút toán `POS_DAILY`, `POS_CATCHUP` |
| Số đúng | `checks/numbers_of_record.csv` | `det_store_*`, `nov_*`, `tim_store_pair_*` |
| Dashboard mẫu của mentor | `docs/template/Nexa_Home_Recon_Dashboard.html` | Dữ liệu `det` (cửa hàng × tháng: chưa xử lý, sổ cái, sau khi đưa về cùng cách tính), `ncells`, `wrong` (số ô, số ô lệch theo ngày bán) |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − POS; % chênh lệch cho cờ ⚠ chia cho |sổ cái|.
- Ngưỡng: |chênh lệch| > 200 USD **và** |%| > 1%, tính cho một cửa hàng trong một tháng.
- So mức cửa hàng × tháng bằng USD theo tỷ giá cuối tháng (cách sổ cái quy đổi, giống công thức mẫu slide 30), để chênh lệch không lẫn phần tỷ giá.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| 4 truy vấn đối soát cửa hàng | `excel/queries/q_RC_Store*.m` | Cầu nối, dashboard trang 3 |
| Sheet `Doi_soat_CH_ngay`, `Doi_soat_CH_thang`, `Lech_ngay_ghi_so` | `excel/Nexa_Home_Recon_PQ.xlsx` | Báo cáo, dashboard |
| Phần IV.1 | `report/sections/04_phan_tich_chinh.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Ô cửa hàng × ngày ghi sổ: tổng / khớp / lệch | 5.120 / 5.118 / 2 | `det_store_cells*` | | sheet `Doi_soat_CH_ngay` | |
| 2 ô lệch | NX057 21/11 (chỉ có ở POS, 7.227,56), NX057 02/12 (chỉ có ở sổ cái, 7.227,56) | slide 26 | | như trên | |
| Tháng 11 so theo ngày bán: ô lệch / tổng ô | 347 / 453 | slide 44 | | sheet tạm từ `q_RC_Store_Raw` | |
| Cả năm so theo ngày bán: số ô lệch | 2.929 | dashboard mẫu | | như trên | |
| Tháng 11: cửa hàng vượt ngưỡng trước / sau khi đưa về cùng cách tính | 21 cửa hàng (+ kênh online = 22 dòng như slide 44) / 1 (NX057, −7.227,56, −74,6%) | slide 28, 44; dashboard mẫu | | sheet `Doi_soat_CH_thang` | |
| NX008 tháng 11 trước / sau | −716,19 / ≈ 0 | slide 28 | | như trên | |
| 3 cặp tháng tự bù trừ | 41.464,78 / 75.240,30 / 80.588,85 | `tim_store_pair_*` | | sheet `Lech_ngay_ghi_so` | |

**Việc phải có (không phải con số):**
- [ ] Ghép đủ 2 bên (kiểu ghép giữ mọi dòng của cả hai bảng – full outer join), chia 4 trường hợp.
- [ ] Cờ ⚠ tính tự động từ ngưỡng, không gõ tay.
- [ ] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| So theo ngày bán thay vì ngày ghi sổ | Hàng nghìn ô lệch giả vào cuối tuần, ngày lễ | Bảng chính so theo ngày ghi sổ; cách so theo ngày bán chỉ để minh họa |
| Quên bỏ dòng trùng ở bảng "sau khi đưa về cùng cách tính" | NX007 tháng 3 vượt ngưỡng | Bỏ dòng có `is_duplicate` |
| Ghép theo mã POS thay vì mã NX | Cửa hàng có nhiều mã POS bị tách đôi | Ghép theo `store_code` (mã NX) |
| Chia % cho sổ cái = 0 | Lỗi chia cho 0 | Để trống % khi sổ cái bằng 0, ô đó vẫn bị cờ nếu chênh lệch > 200 |

---

## 7. Các bước

- [ ] **Bước 1: Viết `q_RC_Store` và `q_RC_Store_Raw`**; kiểm tra 5.120 / 2 ô, 347 / 453 tháng 11.
- [ ] **Bước 2: Viết `q_RC_Store_Month`**; kiểm tra số cửa hàng vượt ngưỡng tháng 11, NX008, NX057.
- [ ] **Bước 3: Viết `q_RC_Store_Timing`**; kiểm tra 3 cặp tháng.
- [ ] **Bước 4: Dựng lại file, so với dashboard mẫu, viết phần IV.1, lưu vào Git (commit).**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc dữ liệu `det` của dashboard mẫu để tìm cách slide tính các số "chưa xử lý" | <ul><li>Tháng 11 có 22 dòng vượt ngưỡng khi chưa xử lý, trong đó có dòng kênh online (mã 999999): 21 cửa hàng + 1 online</li><li>NX008 tháng 11: chưa xử lý −716,19, sau khi đưa về cùng cách tính +0,02</li><li>Online tháng 11: −12.064,26 khi so theo ngày đặt</li><li>"Chưa xử lý" = POS theo tháng bán, chưa bỏ dòng trùng, quy đổi theo tỷ giá cuối tháng; sổ cái theo tháng ghi sổ</li></ul> | Giải được 3 số mà plan `setup-baseline` đánh dấu "chỉ tham khảo" |

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
