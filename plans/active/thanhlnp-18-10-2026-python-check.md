# Bảng kiểm tra bằng Python: từng khoản cầu nối theo tháng và kênh

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | Lê Nguyễn Phước Thành (thanhlnp), làm cùng AI (trí tuệ nhân tạo) Claude |
| Ngày bắt đầu | 18/10/2026 |
| Ngày xong | |
| Nhánh (branch) | `baseline` |
| Thuộc việc nào trong roadmap | Việc 4 – Bảng cầu nối (phần bảng tính kiểm tra viết bằng Python, chỉ dùng nội bộ) |
| Mốc phải đạt | Trước Mốc 3 (23/10) |
| Phần báo cáo liên quan | Phụ lục: so 3 phiên bản số làm tròn; giải thích cách kiểm chứng |
| Trạng thái | Đang làm |
| Plan liên quan | <ul><li>Làm sau plan: [load-clean-data](../completed/thanhlnp-18-10-2026-load-clean-data.md)</li><li>Plan tiếp theo dùng kết quả này: `transactions-quality`, `store-recon`, `web-return-recon`, `bridge-monthly`, `dax-bridge`</li></ul> |

---

## 1. Mục tiêu

Có **số đúng của từng khoản cầu nối theo từng tháng và từng kênh** (cửa hàng, online, chưa gắn kênh, toàn công ty), để các plan làm bằng Power Query và DAX (Data Analysis Expressions, ngôn ngữ công thức của Power BI) có số cụ thể mà so. Slide chỉ cho số cả năm, tháng 11 và tháng 12, nên 10 tháng còn lại chưa có số chuẩn theo từng khoản.

---

## 2. Phạm vi

- **Làm trong plan này:**
  - Một script duy nhất `checks/python_check.py` đọc thẳng 4 file dữ liệu gốc và file danh mục, tính bảng cầu nối theo đúng định nghĩa ở `docs/cau_truc_du_lieu.md` mục 7.
  - Ghi kết quả ra `checks/python_bridge.csv`, cùng dạng với bảng cầu nối dạng dài `BR_Long`.
  - Tự so với `checks/numbers_of_record.csv` và với số nhúng trong dashboard mẫu của mentor (`docs/template/Nexa_Home_Recon_Dashboard.html`), in kết quả so ra `checks/python_check_result.txt`.
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
| Dashboard mẫu của mentor | `docs/template/Nexa_Home_Recon_Dashboard.html` | Số theo tháng × cửa hàng × khoản; tính từ USD đã làm tròn từng dòng nên lệch vài USD |

**Quy ước áp dụng** (xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- Chênh lệch = Sổ cái − Flash; khoản làm Flash cao hơn sổ cái ghi số âm.
- Mọi khoản trước dòng tỷ giá dùng tỷ giá ngày bán / ngày đặt; tỷ giá và làm tròn theo định nghĩa slide 34 (sửa ngày 18/10).
- Lỗi chuyển dữ liệu đổi theo tỷ giá ngày của ngày ghi sổ.
- ADJ-0925 ở dòng "Chưa giải thích được"; chuyển kênh MJ-RCL chỉ có ở bảng theo kênh.

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
| 13 khoản cầu nối cả năm, toàn công ty | dòng `br_y_*` | `numbers_of_record.csv` | | `python_check_result.txt` | |
| 13 khoản cầu nối tháng 12 | dòng `br_m12_*` (sai ≤ 0,01 do slide làm tròn) | slide 36 | | `python_check_result.txt` | |
| Lỗi chuyển dữ liệu tháng 11, dòng trùng tháng 3, lệch thời điểm online tháng 3, ADJ-0925 tháng 9 | −7.227,56 / −12.622,20 / +281.787,98 / +1.250 | `numbers_of_record.csv` | | `python_check_result.txt` | |
| 3 cặp tháng tự bù trừ của khoản lệch ngày ghi sổ | 41.464,78 / 75.240,30 / 80.588,85 | `numbers_of_record.csv` | | `python_check_result.txt` | |
| Dòng kiểm tra của cả 4 bảng, mọi tháng | ≤ 1 USD | quy ước | | `python_check_result.txt` | |
| Dòng làm tròn mọi tháng, mọi bảng | ≤ 5 USD | quy ước | | `python_check_result.txt` | |
| So với dashboard mẫu, toàn công ty, từng tháng × từng khoản | lệch ≤ 5 USD (do cách làm tròn) | file HTML của mentor | | `python_check_result.txt` | |

**Việc phải có (không phải con số):**
- [ ] Dòng tỷ giá được **tính trực tiếp**, không lấy phần dư; dòng kiểm tra là phần dư.
- [ ] Mỗi khoản trong script có ghi chú nói rõ cách tính, khớp `docs/cau_truc_du_lieu.md`.
- [ ] Script chạy lại ra đúng file kết quả cũ.

---

## 6. Chỗ dễ sai

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| Lấy tỷ giá là phần dư để cầu nối về 0 | Dòng kiểm tra luôn bằng 0, không phát hiện được sai sót nào | Tính tỷ giá trực tiếp; nếu dòng kiểm tra khác 0 thì tìm nguyên nhân |
| Dùng cột USD đã làm tròn sẵn từng dòng | Chiết khấu lệch 0,91 USD, tỷ giá lệch 0,5 USD so với slide | Đổi tiền từ nội tệ ÷ tỷ giá, không làm tròn từng dòng |
| Đơn đặt tháng 12/2024 lọt vào Flash 2025 | Chiết khấu, đơn hủy tháng 1 sai | Chỉ tính các tháng có trong Flash |
| Nhân với tỷ giá thay vì chia | Số USD sai hoàn toàn | Tỷ giá là số ngoại tệ đổi được 1 USD → chia |
| Ghép mã cửa hàng POS với mã NX sai (1 mã NX có nhiều mã POS) | Ô cửa hàng × ngày lệch giả | Ghép qua `store_master`, kiểm tra không còn mã POS nào không ghép được |

---

## 7. Các bước

- [ ] **Bước 1: Đọc dữ liệu và chuẩn bị**
  - Làm: đọc 4 file, ghép tỷ giá ngày, ngày ghi sổ, mã NX; đánh dấu dòng trùng giữ lần xuất đầu.
  - Kiểm tra: 17.124 / 9.441 / 6.940 / 156 dòng; 12 dòng trùng; không có dòng thiếu tỷ giá.
- [ ] **Bước 2: Tính từng khoản cho cửa hàng, online, chưa gắn kênh; cộng ra toàn công ty**
  - Làm: theo `docs/cau_truc_du_lieu.md` mục 7; ghi `checks/python_bridge.csv`.
  - Kiểm tra: dòng kiểm tra ≤ 1 USD mọi tháng, mọi bảng.
- [ ] **Bước 3: Tự so với số chuẩn và dashboard mẫu**
  - Làm: in bảng so ra `checks/python_check_result.txt`.
  - Kiểm tra: mọi dòng ở mục 5 đạt.
- [ ] **Bước 4: Ghi phần cho báo cáo và lưu vào Git (commit)**
  - Làm: ghi nội dung cho phụ lục vào mục 12.
  - Kiểm tra: lời nhắn khi lưu bắt đầu bằng `python-check:`.

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
