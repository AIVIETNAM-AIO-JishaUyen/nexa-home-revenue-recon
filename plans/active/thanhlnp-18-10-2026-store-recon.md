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
  - `q_RC_Store_DayCompare`: đếm theo tháng số ô lệch khi so theo ngày ghi sổ và khi POS lấy theo **ngày bán, chưa bỏ dòng trùng** (cách so "chưa xử lý"), để thấy vì sao phải đưa về cùng cách tính.
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
| Sheet `Doi_soat_CH_ngay`, `So_ngay_ban_ngay_ghi_so`, `Doi_soat_CH_thang`, `Lech_ngay_ghi_so` | `excel/Nexa_Home_Recon_PQ.xlsx` | Báo cáo, dashboard |
| Phần IV.1 | `report/sections/04_phan_tich_chinh.tex` | |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| Ô cửa hàng × ngày ghi sổ: tổng / khớp / lệch | 5.120 / 5.118 / 2 | `det_store_cells*` | 5.120 / 5.118 / 2 | sheet `Doi_soat_CH_ngay` | Đạt |
| 2 ô lệch | NX057 21/11 (chỉ có ở POS, 7.227,56), NX057 02/12 (chỉ có ở sổ cái, 7.227,56) | slide 26 | Đúng 2 ô đó; ô 02/12 là bút toán `JE20251206231` loại `POS_CATCHUP` | như trên | Đạt |
| Tháng 11 so theo ngày bán: ô lệch / tổng ô | 347 / 453 | slide 44 | 347 / 453 | sheet `So_ngay_ban_ngay_ghi_so` | Đạt |
| Cả năm so theo ngày bán: số ô lệch | 2.929 | dashboard mẫu | 2.929 | như trên | Đạt |
| Tháng 11: cửa hàng vượt ngưỡng trước / sau khi đưa về cùng cách tính | 21 cửa hàng (+ kênh online = 22 dòng như slide 44) / 1 (NX057, −7.227,56, −74,6%) | slide 28, 44; dashboard mẫu | 21 / 1 (NX057, −7.227,56, −74,55%) | sheet `Doi_soat_CH_thang` | Đạt (slide ghi −74,6% vì chia hai số đã làm tròn 7.228 / 9.695) |
| NX008 tháng 11 trước / sau | −716,19 / ≈ 0 | slide 28 | −716,19 / −0,01 | như trên | Đạt |
| 3 cặp tháng tự bù trừ | 41.464,78 / 75.240,30 / 80.588,85 | `tim_store_pair_*` | 41.464,78 / 75.240,30 / 80.588,85; cả năm 0,00 | sheet `Lech_ngay_ghi_so` | Đạt |

**Việc phải có (không phải con số):**
- [x] Ghép đủ 2 bên (kiểu ghép giữ mọi dòng của cả hai bảng – full outer join), chia 4 trường hợp.
- [x] Cờ ⚠ tính tự động từ ngưỡng, không gõ tay.
- [x] Mọi bước có tên tiếng Việt và ghi chú `//` ngay phía trên.

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

- [x] **Bước 1: Viết `q_RC_Store` và `q_RC_Store_DayCompare`**; kiểm tra 5.120 / 2 ô, 347 / 453 tháng 11.
- [x] **Bước 2: Viết `q_RC_Store_Month`**; kiểm tra số cửa hàng vượt ngưỡng tháng 11, NX008, NX057.
- [x] **Bước 3: Viết `q_RC_Store_Timing`**; kiểm tra 3 cặp tháng.
- [x] **Bước 4: Dựng lại file, so với dashboard mẫu, viết phần IV.1, lưu vào Git (commit).**

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Đọc dữ liệu `det` của dashboard mẫu để tìm cách slide tính các số "chưa xử lý" | <ul><li>Tháng 11 có 22 dòng vượt ngưỡng khi chưa xử lý, trong đó có dòng kênh online (mã 999999): 21 cửa hàng + 1 online</li><li>NX008 tháng 11: chưa xử lý −716,19, sau khi đưa về cùng cách tính +0,02</li><li>Online tháng 11: −12.064,26 khi so theo ngày đặt</li><li>"Chưa xử lý" = POS theo tháng bán, chưa bỏ dòng trùng, quy đổi theo tỷ giá cuối tháng bán; sổ cái theo tháng ghi sổ</li></ul> | Giải được 3 số mà plan `setup-baseline` đánh dấu "chỉ tham khảo" |
| 18/10 | Viết 4 truy vấn đối soát cửa hàng, nạp vào 4 sheet, dựng lại file | <ul><li>5.120 ô: 5.118 khớp, 1 ô chỉ có ở POS (NX057 21/11), 1 ô chỉ có ở sổ cái (NX057 02/12, bút toán ghi bù có ghi chú "lỗi interface")</li><li>So theo ngày bán: 2.929 ô lệch cả năm, tháng 11 là 347/453</li><li>Cửa hàng × tháng vượt ngưỡng: trước xử lý 137 lượt (tháng 3, 5, 6, 8, 9, 11, 12), sau xử lý 2 lượt (NX057 tháng 11 và 12)</li><li>3 cặp tháng lệch ngày ghi sổ, 267 dòng, cả năm 0</li></ul> | <ul><li>Lần dựng file mất hơn 10 phút (trước là 4 phút) vì 4 truy vấn mới đều đọc lại bảng giao dịch chung; vẫn trong giới hạn 15 phút của script</li><li>Lệnh `sed` làm hỏng dấu `\` khi sửa phụ lục; sửa lại bằng script Python</li></ul> |
| 18/10 | Thử lại số −716 của NX008 | <ul><li>Dùng tỷ giá cuối tháng ghi nhận: −726,34</li><li>Dùng tỷ giá cuối **tháng bán**: −716,19, đúng bằng dashboard mẫu</li></ul> | Nhật ký trước ghi lý do là "dashboard làm tròn từng dòng" là sai; lý do đúng là tỷ giá cuối tháng bán |
| 18/10 | Tìm vì sao cờ "chưa xử lý" chỉ có ở 7 tháng | <ul><li>Ngày 31/05, 31/08, 29–30/11 là cuối tuần: doanh thu sang tháng sau ở hầu hết cửa hàng</li><li>Các tháng khác kết thúc vào ngày làm việc nên dời trong tháng tự triệt tiêu</li><li>Tháng 3: NX007 do 12 dòng trùng ngày 29/03</li></ul> | |
| 18/10 | Viết phần IV.1, thêm Bảng 10 và 21 số vào `so_lieu.tex`, sửa bảng tra nhãn nguồn ở phụ lục | PDF 17 trang, phần IV.1 ở trang 12–14 | |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Ô cửa hàng × ngày so bằng **nội tệ**; phần lệch đổi ra USD theo tỷ giá ngày của ngày ghi sổ | Không lẫn phần tỷ giá; đúng quy ước cho lỗi chuyển dữ liệu (mục 4 của file quy ước) | Không |
| 18/10 | Cấp cửa hàng × tháng so bằng USD theo tỷ giá cuối tháng; "chưa xử lý" đổi theo tỷ giá cuối **tháng bán**, "sau xử lý" theo tỷ giá cuối tháng ghi sổ | Đây là cách dashboard mẫu tính, tái lập đúng −716,19 của slide 28; sổ cái cũng quy đổi theo tỷ giá cuối tháng | Không |
| 18/10 | Sổ cái ở cấp cửa hàng chỉ lấy bút toán `POS_DAILY`, `POS_CATCHUP`, không lấy bút toán tay MJ-RCL | Bút toán chuyển kênh MJ-RCL là việc của bảng cầu nối theo kênh; nếu lấy vào thì một cửa hàng tháng 6 bị cờ vì một bút toán tay chứ không vì lệch POS | Không |
| 18/10 | Ngưỡng 200 USD và 1% đặt thành 2 bước có tên ở đầu `q_RC_Store_Month`; sổ cái = 0 thì chỉ xét ngưỡng tiền | Đổi ngưỡng chỉ sửa 1 chỗ; tránh chia cho 0 | Không |
| 18/10 | Thêm sheet thứ tư `So_ngay_ban_ngay_ghi_so` thay cho "sheet tạm" | Số 347/453 và 2.929 cần nằm trong file để người chấm tự kiểm tra | Không |
| 18/10 | Cả 4 truy vấn dùng chung nhãn nguồn `[RC-CH]` | Không đặt thêm ký hiệu mới; bảng tra nhãn ở phụ lục C liệt kê đủ 4 sheet | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Đọc dữ liệu nhúng của dashboard mẫu, viết 4 truy vấn, viết phần IV.1 | `excel/queries/q_RC_Store*.m`, phần sinh Bảng 10 trong `make_figures.py`, `report/sections/04_phan_tich_chinh.tex` (mục IV.1) | <ul><li>Chạy thử cùng phép tính bằng Python trên sheet giao dịch chung trước khi viết truy vấn</li><li>So từng số với slide 26, 28, 44, `numbers_of_record.csv` và dữ liệu `det` của dashboard mẫu (mục 5)</li><li>Tra lịch thứ trong tuần của các ngày cuối tháng để kiểm tra lời giải thích</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi:** Vì sao so cửa hàng theo ngày ghi sổ mà không theo ngày bán?
   **Trả lời:** Sổ cái ghi doanh thu cửa hàng theo ngày ghi sổ: bán thứ Bảy, Chủ nhật, ngày lễ thì ghi sang ngày làm việc kế tiếp. So theo ngày bán ra 2.929 ô lệch cả năm (tháng 11 là 347/453) dù tiền không mất đồng nào. So theo ngày ghi sổ thì 5.118/5.120 ô khớp đến từng xu, chỉ còn 2 ô lệch thật.
2. **Hỏi:** Hai ô lệch đó là gì, nhóm xếp vào nhóm nào?
   **Trả lời:** NX057 ngày 21/11 có 7.227,56 USD bên POS mà sổ cái không có; ngày 02/12 sổ cái có bút toán ghi bù `POS_CATCHUP` đúng số đó, ghi chú "lỗi interface". Đây là lỗi chuyển dữ liệu từ POS sang sổ cái, thuộc nhóm "Lỗi dữ liệu": cả năm không lệch nhưng tháng 11 báo thiếu và tháng 12 báo thừa.
3. **Hỏi:** Slide nói 22 cửa hàng vượt ngưỡng ở tháng 11, nhóm ra 21?
   **Trả lời:** Con số 22 của slide gồm 21 cửa hàng và 1 dòng của kênh online (trong dữ liệu dashboard mẫu dòng đó có mã 999999). Nhóm tái lập đúng cách tính "chưa xử lý": POS lấy mọi dòng kể cả dòng trùng, cộng theo tháng bán, đổi theo tỷ giá cuối tháng bán; ra đúng −716,19 của NX008. Phần online xét ở plan `web-return-recon`.
4. **Hỏi:** Vì sao trước khi xử lý chỉ có 7 tháng bị cờ?
   **Trả lời:** Chỉ những tháng có ngày cuối rơi vào cuối tuần (31/05, 31/08, 29–30/11) mới đẩy doanh thu sang tháng sau, nên tháng đó và tháng sau (6, 9, 12) bị cờ ở hầu hết cửa hàng. Các tháng khác doanh thu cuối tuần chỉ dời trong cùng tháng nên tự triệt tiêu. Tháng 3 là NX007 do 12 dòng POS xuất trùng.
5. **Hỏi:** Lệch ngày ghi sổ có tự bù trừ không? (câu hỏi riêng 3)
   **Trả lời:** Có. 3 cặp tháng: tháng 5 sang 6 là 41.464,78 USD, 8 sang 9 là 75.240,30, 11 sang 12 là 80.588,85, cộng 267 dòng; cả năm bằng 0. Ngày 31/12/2025 là thứ Tư nên không có doanh thu cửa hàng nào vắt sang năm 2026.
6. **Hỏi:** Bước so ô cửa hàng × ngày trước khóa sổ có đáng làm không? (câu hỏi riêng 1)
   **Trả lời:** Năm 2025 nó bắt được 1 lỗi, 7.227,56 USD, ngay trong tháng 11, tức là trước khi khóa sổ tháng 11. Công sức nhỏ vì 5.118/5.120 ô khớp tuyệt đối, kế toán chỉ cần xem vài ô còn lại.

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 7 dòng số và 3 việc phải có (mục 5).
- **Đã đưa vào báo cáo:** mục IV.1 "Đối soát cửa hàng theo ngày ghi sổ" (Bảng 10, sinh từ 3 sheet), trả lời câu hỏi riêng 1 và phần cửa hàng của câu hỏi riêng 3; bảng tra nhãn nguồn ở phụ lục C.
- **Đã cập nhật số chuẩn:** 2 trong 3 số "chỉ tham khảo" ở `checks/numbers_of_record.csv` nay đã tái lập được (22 cửa hàng = 21 + 1 online; NX008 −716,19); số online −12.064 để cho `web-return-recon`.
- **Việc còn lại:**
  - Dòng online của tháng 11 (−12.064,26 theo ngày đặt) → `web-return-recon`.
  - Khoản lệch ngày ghi sổ và lỗi chuyển dữ liệu trong bảng cầu nối Power Query → `bridge-monthly` (so với sheet `Lech_ngay_ghi_so` và `Doi_soat_CH_ngay`).
  - Trang 3 của dashboard (cửa hàng × tháng, bấm xem từng ô) → `dashboard`.
- **Các lần lưu vào Git (commit):** `d57ce19` (tạo plan), `3afa6d0` (đối soát theo ngày), `9d35dfb` (theo tháng, lệch ngày ghi sổ), `c2d1beb` (nạp sheet, file Excel, số chuẩn), `9faf0de` (báo cáo IV.1), và các lần lưu ghi kết quả, rà soát, đóng plan.
