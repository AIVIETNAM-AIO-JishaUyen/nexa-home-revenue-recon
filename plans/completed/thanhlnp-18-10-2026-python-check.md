# Bảng kiểm tra bằng Python: từng khoản cầu nối theo tháng và kênh

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | 18/10/2026 |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 4 – Bảng cầu nối (phần bảng tính kiểm tra viết bằng Python, chỉ dùng nội bộ) |
| Mốc phải đạt | Trước Mốc 3 (23/10) |
| Phần báo cáo liên quan | Phụ lục: so 3 phiên bản số làm tròn; giải thích cách kiểm chứng |
| Trạng thái | Xong |
| Plan liên quan | <ul><li>Làm sau plan: [load-clean-data](../completed/thanhlnp-18-10-2026-load-clean-data.md)</li><li>Plan tiếp theo dùng kết quả này: `transactions-quality`, `store-recon`, `web-return-recon`, `bridge-monthly`, `dax-bridge`</li></ul> |

---

## 1. Mục tiêu

Có **số đúng của từng khoản cầu nối theo từng tháng và từng kênh** (cửa hàng, online, chưa gắn kênh, toàn công ty), để các plan làm bằng Power Query và DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) có số cụ thể mà so. Slide chỉ cho số cả năm, tháng 11 và tháng 12, nên 10 tháng còn lại chưa có số chuẩn theo từng khoản.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Một script duy nhất `checks/python_check.py` đọc thẳng 4 file dữ liệu gốc và file danh mục, tính bảng cầu nối theo đúng định nghĩa ở `docs/cau_truc_du_lieu.md` mục 7.
  - Ghi kết quả ra `checks/python_bridge.csv`, cùng dạng với bảng cầu nối dạng dài `BR_Long`.
  - Tự so với `checks/numbers_of_record.csv` và với số nhúng trong dashboard mẫu của mentor (người hướng dẫn) (`docs/template/Nexa_Home_Recon_Dashboard.html`), in kết quả so ra `checks/python_check_result.txt`.
- **Không làm (để cho plan khác):**
  - Đối soát chi tiết cửa hàng × ngày, online × ngày → `store-recon`, `web-return-recon` (Python ở đây chỉ tính các ô cần cho khoản lỗi chuyển dữ liệu).
  - Bảng cầu nối nộp bài (phải làm bằng Power Query) → `bridge-monthly`.
  - **Không lấy số từ file này để nộp.** Số nộp phải ra từ Power Query; file này chỉ để so.

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| 4 file dữ liệu, file danh mục | `data/` | Đọc thẳng, không qua Power Query, để là một cách tính độc lập |
| Định nghĩa từng khoản | `docs/cau_truc_du_lieu.md` mục 6, 7 | Danh mục khoản, dạng bảng `BR_Long` |
| Bảng số chuẩn | `checks/numbers_of_record.csv` | Cả năm, tháng 12, tháng 11, các cặp tháng |
| Dashboard mẫu của mentor | `docs/template/Nexa_Home_Recon_Dashboard.html` | Số theo tháng × cửa hàng × khoản; tính từ USD (đô la Mỹ) đã làm tròn từng dòng nên lệch vài USD |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash; khoản làm Flash cao hơn sổ cái ghi số âm.
- Mọi khoản trước dòng tỷ giá dùng tỷ giá ngày bán / ngày đặt; tỷ giá và làm tròn theo định nghĩa slide 34 (sửa ngày 18/10).
- Lỗi chuyển dữ liệu đổi theo tỷ giá ngày của ngày ghi sổ.
- Bút toán ADJ-0925 (ADJ = Adjustment, bút toán điều chỉnh) ở dòng "Chưa giải thích được"; chuyển kênh MJ-RCL (MJ = Manual Journal, bút toán tay; RCL = Reclassification, phân loại lại) chỉ có ở bảng theo kênh.

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| Script tính cầu nối | `checks/python_check.py` | Chạy lại khi cần |
| Bảng cầu nối dạng dài | `checks/python_bridge.csv` | So với Power Query (`bridge-monthly`) và DAX (`dax-bridge`) |
| Kết quả tự so | `checks/python_check_result.txt` | Bằng chứng, phụ lục báo cáo |

---

## 5. Điều kiện xong

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| 13 khoản cầu nối cả năm, toàn công ty | dòng `br_y_*` | `numbers_of_record.csv` | 13/13 khớp (lệch ≤ 0,005) | `python_check_result.txt` mục 1 | Đạt |
| 13 khoản cầu nối tháng 12 | dòng `br_m12_*` (sai ≤ 0,01 do slide làm tròn) | slide 36 | 13/13 khớp, kể cả tỷ giá −27.080,93 và làm tròn 0,67 | `python_check_result.txt` mục 2 | Đạt |
| Lỗi chuyển dữ liệu tháng 11, dòng trùng tháng 3, lệch thời điểm online tháng 3, ADJ-0925 tháng 9 | −7.227,56 / −12.622,20 / +281.787,98 / +1.250 | `numbers_of_record.csv` | Khớp cả 4 | `python_check_result.txt` mục 3 | Đạt |
| 3 cặp tháng tự bù trừ của khoản lệch ngày ghi sổ | 41.464,78 / 75.240,30 / 80.588,85 | `numbers_of_record.csv` | Khớp cả 6 tháng (tháng trước âm, tháng sau dương) | `python_check_result.txt` mục 4 | Đạt |
| Dòng kiểm tra của cả 4 bảng, mọi tháng | ≤ 1 USD | quy ước | 0,00 ở mọi tháng, mọi bảng | `python_check_result.txt` mục 9 | Đạt |
| Dòng làm tròn mọi tháng, mọi bảng | ≤ 5 USD | quy ước | <ul><li>Toàn công ty: lớn nhất 1,83 (tháng 9)</li><li>Cửa hàng: 1,73 (tháng 3)</li><li>Online: 1,01 (tháng 11)</li></ul> | `python_check_result.txt` mục 9 | Đạt |
| So với dashboard mẫu, toàn công ty, từng tháng × từng khoản | lệch ≤ 5 USD (do cách làm tròn) | file HTML (HyperText Markup Language, trang web) của mentor | <ul><li>Lệch lớn nhất trong 1 tháng: 0,25 (tỷ giá tháng 10)</li><li>Cả năm (nhóm − mẫu): chiết khấu +0,91, tỷ giá +0,49, làm tròn −1,32 (nhóm 1,01, dashboard hiện 2,33)</li><li>So thêm ở mức kênh: cửa hàng và online lệch không quá 0,31 USD ở mọi tháng × khoản</li></ul> | `python_check_result.txt` mục 10 | Đạt |

**Việc phải có (không phải con số):**
- [x] Dòng tỷ giá được **tính trực tiếp**, không lấy phần dư; dòng kiểm tra là phần dư.
- [x] Mỗi khoản trong script có ghi chú nói rõ cách tính, khớp `docs/cau_truc_du_lieu.md`.
- [x] Script chạy lại ra đúng file kết quả cũ.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Lấy tỷ giá là phần dư để cầu nối về 0 | Dòng kiểm tra luôn bằng 0, không phát hiện được sai sót nào | Tính tỷ giá trực tiếp; nếu dòng kiểm tra khác 0 thì tìm nguyên nhân |
| Tin rằng dòng kiểm tra bằng 0 là đủ để biết các khoản đúng | <ul><li>Dòng tỷ giá trừ đi đúng các số đã dùng ở khoản lệch thời điểm online, lệch ngày ghi sổ, hàng trả và lỗi chuyển dữ liệu</li><li>Nên nếu xếp sai tháng một trong các khoản đó, dòng tỷ giá tự bù đúng phần sai và dòng kiểm tra vẫn bằng 0 (đã thử khi rà soát)</li><li>Dòng kiểm tra chỉ bắt được: bút toán sổ cái không thuộc khoản nào, khoản bị tính hai lần, khoản bị ngược dấu</li></ul> | So từng khoản, từng tháng với số chuẩn và dashboard mẫu (các dòng khác ở mục 5); dòng tỷ giá phải khớp slide 32 và 36 |
| Dùng cột USD đã làm tròn sẵn từng dòng | Chiết khấu lệch 0,91 USD, tỷ giá lệch 0,49 USD so với số chuẩn | Đổi tiền từ nội tệ ÷ tỷ giá, không làm tròn từng dòng |
| Đơn đặt tháng 12/2024 lọt vào Flash 2025 | Chiết khấu, đơn hủy tháng 1 sai | Chỉ tính các tháng có trong Flash |
| Nhân với tỷ giá thay vì chia | Số USD sai hoàn toàn | Tỷ giá là số ngoại tệ đổi được 1 USD → chia |
| Ghép mã cửa hàng POS (Point of Sale, bán tại cửa hàng) với mã NX (mã cửa hàng bên kế toán, dạng NX001) sai (1 mã NX có nhiều mã POS) | Ô cửa hàng × ngày lệch giả | Ghép qua `store_master`, kiểm tra không còn mã POS nào không ghép được |

---

## 7. Các bước

- [x] **Bước 1: Đọc dữ liệu và chuẩn bị**
  - Làm: đọc 4 file, ghép tỷ giá ngày, ngày ghi sổ, mã NX; đánh dấu dòng trùng giữ lần xuất đầu.
  - Kiểm tra: 17.124 / 9.441 / 6.940 / 156 dòng; 12 dòng trùng; không có dòng thiếu tỷ giá.
- [x] **Bước 2: Tính từng khoản cho cửa hàng, online, chưa gắn kênh; cộng ra toàn công ty**
  - Làm: theo `docs/cau_truc_du_lieu.md` mục 7; ghi `checks/python_bridge.csv`.
  - Kiểm tra: dòng kiểm tra ≤ 1 USD mọi tháng, mọi bảng.
- [x] **Bước 3: Tự so với số chuẩn và dashboard mẫu**
  - Làm: in bảng so ra `checks/python_check_result.txt`.
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [x] **Bước 4: Ghi phần cho báo cáo và lưu vào Git (commit)**
  - Làm: ghi nội dung cho phụ lục vào mục 12.
  - Kiểm tra: lời nhắn khi lưu bắt đầu bằng `python-check:`.

---

## 8. Nhật ký làm việc

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| 18/10 | Viết `checks/python_check.py` theo đúng 15 dòng danh mục khoản ở `docs/cau_truc_du_lieu.md` mục 7 | <ul><li>708 dòng kết quả (4 bảng × 12 tháng × 15 khoản, bảng toàn công ty không có dòng chuyển kênh)</li><li>Dữ liệu: 0 dòng thiếu tỷ giá, 0 mã POS không ghép được mã NX</li></ul> | |
| 18/10 | Chạy tự so | <ul><li>0 dòng sai trên toàn bộ 9 nhóm kiểm tra</li><li>5.120 ô cửa hàng × ngày ghi sổ, 2 ô lệch: NX057 ngày 21/11 (−7.227,56) và 02/12 (+7.227,56)</li><li>Dòng kiểm tra bằng 0,00 ở mọi tháng của cả 4 bảng</li></ul> | Đạt ngay lần chạy đầu, vì định nghĩa từng khoản đã được thử và rà soát ở plan `setup-baseline` |
| 18/10 | Chạy lại lần 2 | File `python_bridge.csv` giống hệt lần 1 | |
| 18/10 | Rà soát bằng một trợ lý AI khác (không chạy Excel, Power BI) | <ul><li>Tính lại độc lập cả 4 bảng × 12 tháng × mọi khoản, không dùng lại script: khớp `python_bridge.csv` ở mọi ô (lệch dưới 0,0001 vì file chỉ ghi 4 chữ số lẻ)</li><li>Tính lại tỷ giá từ chính các dòng POS và đơn online (nội tệ ÷ tỷ giá cuối tháng trong sheet `fx_month_end`): ra đúng như dòng tỷ giá ở mọi tháng, cả cửa hàng lẫn online</li><li>1.647 ô giao hàng và 159 ô hàng trả online khớp nội tệ 100% với sổ cái</li><li>So dashboard mẫu theo từng kênh: cửa hàng và online lệch không quá 0,31 USD ở mọi tháng × khoản</li><li>Chạy lại script: 2 file kết quả không đổi</li></ul> | <ul><li>Mục 9 của script so dòng làm tròn với mã khoản "10" (làm tròn) trong số liệu nhúng của dashboard. Nhưng dashboard hiện dòng làm tròn = mã "10" + (mã "g" − Flash), trong đó "g" là doanh số Flash dashboard tự tính lại từ giao dịch; cả năm 1,50 + 0,83 = 2,33. Cần sửa script; số đúng đã ghi ở mục 5</li><li>Ở bảng theo kênh, mã "08" (bút toán tay) của dashboard gồm cả phí vận chuyển lẫn chuyển kênh MJ-RCL (tháng 6: cửa hàng −3.480, online +3.480). Plan sau so theo kênh phải cộng 2 khoản này</li><li>Thử cố ý xếp sai tháng giao hàng, tháng ghi sổ, tháng nhận hàng trả: dòng kiểm tra vẫn bằng 0 vì dòng tỷ giá nhận hết phần sai; phần tự so với số chuẩn bắt được cả 3 lần (7, 10, 6 dòng sai). Đã ghi vào mục 6</li></ul> |
| 18/10 | Sửa script theo rà soát rồi chạy lại | <ul><li>So dashboard: dòng làm tròn lấy mã "10" + (mã "g" − Flash); mã "08" ở mức kênh = phí vận chuyển + chuyển kênh; thêm so theo kênh cửa hàng và online (mục 10 của file kết quả)</li><li>Thêm mục 7: 1.647 ô giao hàng và 159 ô hàng trả online so nội tệ với sổ cái, 0 ô lệch</li><li>Thêm mục 8: tỷ giá tính theo cách thứ hai từ từng giao dịch, lệch 0,00 so với dòng tỷ giá ở mọi tháng</li><li>Thêm mục 0: thiếu tỷ giá, mã POS không ghép được biến thành phép kiểm tra có đạt/sai</li><li>File kết quả viết số kiểu Việt Nam; `python_bridge.csv` không đổi</li></ul> | 0 dòng sai |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| 18/10 | Bảng `BR_Long` ghi **đủ mọi khoản cho mọi bảng**, khoản không áp dụng thì bằng 0; riêng bảng toàn công ty không có dòng chuyển kênh | <ul><li>Bảng cùng một hình dạng thì so Power Query, Python, DAX chỉ cần ghép theo bảng + tháng + mã khoản</li><li>File mẫu nộp lấy số bằng công thức tìm theo mã khoản, khoản bằng 0 vẫn tìm được</li></ul> | Không (bổ sung vào `docs/cau_truc_du_lieu.md` mục 6) |
| 18/10 | Ô cửa hàng × ngày ghi sổ ghép theo **mã NX + ngày ghi sổ + loại tiền** | Sổ cái ghi bút toán theo mã NX; một mã NX có thể có nhiều mã POS nên phải cộng các mã POS lại trước khi so | Không |

---

## 10. Dùng AI (trí tuệ nhân tạo)

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| 18/10 | Viết script Python tính cầu nối và tự so | Toàn bộ `checks/python_check.py` | <ul><li>So với 3 nguồn độc lập: bảng số chuẩn lấy từ slide, slide 36 (tháng 12), dashboard mẫu của mentor</li><li>Trợ lý rà soát đã tính lại độc lập cả 4 bảng × 12 tháng × mọi khoản (khớp mọi ô), so dashboard mẫu theo kênh, và thử cố ý xếp sai tháng 3 khoản để xem phần tự so có bắt được không (mục 8)</li><li>Nhóm nên đọc từng khối "Bảng cửa hàng", "Bảng online" trong script và đối chiếu với định nghĩa ở `docs/cau_truc_du_lieu.md` mục 7</li></ul> |

---

## 11. Chuẩn bị vấn đáp

1. **Hỏi (rubric – bảng tiêu chí chấm, sheet `Lam_dung_AI`, câu hỏi vấn đáp gợi ý):** Vì sao không gán khoản 1.250 USD vào làm tròn cho bảng cầu nối về 0?
   **Trả lời:** Làm tròn có định nghĩa riêng: phần Flash làm tròn từng dòng đến USD (+0,95) cộng phần sổ cái làm tròn từng bút toán (+0,05), cả năm +1,01, mỗi tháng không quá 1,83 USD (ngưỡng 5 USD/tháng). Khoản 1.250 USD là bút toán tay ADJ-0925 tháng 9, không gắn kênh, không có giấy tờ. Bảng cầu nối vẫn về 0 khi để nó ở dòng riêng "Chưa giải thích được". Nếu nhét vào làm tròn thì dòng làm tròn tháng 9 thành khoảng 1.248 USD (−1,83 + 1.250), vượt ngưỡng, và che mất một khoản cần hỏi phòng Tài chính. Slide 35 và 38 dặn "không ép cho khớp"; phiếu chấm mẫu trong rubric cho nhóm "gán ADJ-0925 vào làm tròn" chỉ được Band 3 ở năng lực phân loại chênh lệch.
2. **Hỏi (slide 47 và rubric, sheet `Lam_dung_AI`):** Vì sao tháng 3 sổ cái lại cao hơn báo cáo nhanh?
   **Trả lời:** Vì khoản lệch thời điểm online tháng 3 là +281.787,98 USD: nhiều đơn đặt cuối tháng 2 (Flash tính vào tháng 2) nhưng giao trong tháng 3 (sổ cái tính vào tháng 3). Tháng 2 có khoản ngược lại −160.258,71. Các khoản khác của tháng 3 đều kéo sổ cái xuống: chiết khấu −129.142,95, dòng trùng −12.622,20, đơn hủy −20.144,45, hàng trả −37.119,63. Cộng cả phí vận chuyển +8.002,48, tỷ giá +8.254,85 và làm tròn +1,45 thì ra chênh lệch +99.017,53 (`checks/python_bridge.csv`, bảng toàn công ty `COMPANY`, tháng 3).
3. **Hỏi:** Vì sao dòng tỷ giá phải tính trực tiếp, không lấy phần còn thiếu cho cầu nối về 0? Dòng kiểm tra bằng 0 thì chứng minh được gì?
   **Trả lời:** Nếu lấy phần dư thì dòng tỷ giá nhận hết mọi sai sót và không còn gì để kiểm tra. Nhóm tính tỷ giá trực tiếp theo slide 34 (nội tệ trên bút toán sổ cái ÷ tỷ giá cuối tháng − cùng các giao dịch đó ÷ tỷ giá ngày) rồi so với slide: cả năm −57.598,01 (slide 32 ghi −57.598), tháng 12 −27.080,93 (đúng slide 36). Khi rà soát, tỷ giá tính lại từ chính các dòng POS và đơn online cũng ra đúng số đó ở mọi tháng. Phải nói rõ giới hạn của dòng kiểm tra: nó bằng 0 cho thấy mọi bút toán sổ cái đều thuộc một khoản, không khoản nào bị tính hai lần hay ngược dấu. Nó **không** chứng minh từng khoản nằm đúng tháng: nếu xếp sai tháng giao hàng thì dòng tỷ giá tự bù đúng phần đó và dòng kiểm tra vẫn bằng 0 (đã thử khi rà soát). Vì vậy nhóm còn so từng khoản, từng tháng với số chuẩn và dashboard mẫu (mục 5).

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** đạt hết 7 dòng số và 3 việc phải có (mục 5).
- **Nội dung cho báo cáo** (plan `report-skeleton`, `report-draft` đưa vào):
  - Phụ lục, mục kiểm chứng: nhóm tính bảng cầu nối bằng 3 cách độc lập. Power Query là số nộp; Python và DAX dùng để so. Bảng Python khớp slide 32, 34, 36 và dashboard mẫu.
  - Phụ lục, bảng so 3 phiên bản số làm tròn:

    | Nguồn | Chiết khấu | Tỷ giá | Làm tròn |
    |---|---:|---:|---:|
    | Nhóm (tính từ nội tệ, không làm tròn từng dòng; slide 34) | −1.834.297,47 | −57.598,01 | +1,01 |
    | Slide 32 | −1.834.297 | −57.598 | +1,01 |
    | Dashboard mẫu của mentor (cộng cột USD đã làm tròn từng dòng) | −1.834.298,38 | −57.598,50 | +2,33 |

  - Phần IV: cầu nối 12 tháng toàn công ty (bảng cuối của `checks/python_check_result.txt`) chỉ dùng để so; số trong báo cáo lấy từ Power Query (plan `bridge-monthly`).
- **Việc còn lại:**
  - Power Query phải ra đúng `checks/python_bridge.csv` từng bảng × tháng × khoản → `bridge-monthly`.
  - DAX phải ra đúng như vậy → `dax-bridge`.
  - Khi so với dashboard mẫu ở mức kênh: mã "08" gồm cả chuyển kênh MJ-RCL, làm tròn = mã "10" + (mã "g" − Flash) → `bridge-monthly`, `dax-bridge`, `dashboard`.
- **Các lần lưu vào Git (commit):** `226f43b` (tạo plan), `4be8a45` (script), `f40aa63` (kết quả), `48c98ed` (ghi kết quả, quyết định, chuẩn bị vấn đáp), và các lần lưu sửa script theo rà soát, đóng plan.

**Tự soát trước khi đóng plan:**
- [x] Không còn chỗ `< >` chưa điền.
- [x] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [x] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [x] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [x] Đã chuyển file sang `plans/completed/` bằng `git mv`.
