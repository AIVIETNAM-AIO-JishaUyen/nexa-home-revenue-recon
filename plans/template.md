# <Tên plan: một câu ngắn nói plan này làm gì>

> **Cách dùng file mẫu (xóa khối này khi bắt đầu):**
> - Chép file này vào `plans/active/`, đặt tên `<tên người làm>-<dd-mm-yyyy>-<việc>.md` theo [hướng dẫn](README.md).
> - Thay mọi chỗ trong dấu `< >`. Mục nào không dùng thì ghi "Không có", đừng xóa mục.
> - Các link trong file đã viết sẵn cho vị trí `plans/active/` (và `plans/completed/` khi chuyển sang), nên mở từ `plans/template.md` sẽ không bấm được.
> - Từ viết tắt ghi tên đầy đủ trong ngoặc ở lần đầu xuất hiện, ví dụ "PQ (Power Query)".

---

## Thông tin chung

| Mục | Nội dung |
|---|---|
| Người làm | <họ tên> |
| Ngày bắt đầu | <dd/mm/yyyy> |
| Ngày xong | <dd/mm/yyyy, để trống khi chưa xong> |
| Nhánh (branch) | <ví dụ `baseline`> |
| Thuộc việc nào trong roadmap | <ví dụ: Việc 2 – Nạp và làm sạch dữ liệu> |
| Mốc phải đạt | <ví dụ: Mốc 2 (19/10)> |
| Phần báo cáo liên quan | <phần nào trong 8 phần của báo cáo (slide 45)> |
| Trạng thái | <Đang làm / Tạm dừng / Xong / Hủy> |
| Plan liên quan | <ul><li>Làm sau plan: <tên file></li><li>Plan tiếp theo dùng kết quả này: <tên file></li></ul> |

---

## 1. Mục tiêu

<1–2 câu: làm xong plan này thì nhóm có thêm gì mà trước đó chưa có.>

---

## 2. Phạm vi

- **Làm trong plan này:**
  - <…>
- **Không làm (để cho plan khác):**
  - <… → plan nào>

---

## 3. Đầu vào

| Dùng gì | Đường dẫn | Ghi chú |
|---|---|---|
| <file dữ liệu, bảng, truy vấn của plan trước> | <`data/...`> | <…> |

**Quy ước áp dụng** (chỉ ghi điều nào áp dụng, không chép lại, xem [quy ước tính và số chuẩn](../../docs/quy_uoc_va_so_chuan.md)):
- <ví dụ: Chênh lệch = Sổ cái − Flash>

---

## 4. Đầu ra

| Tạo ra gì | Đường dẫn | Plan / phần nào dùng tiếp |
|---|---|---|
| <file, sheet, truy vấn, hình> | <…> | <…> |

---

## 5. Điều kiện xong

Plan chỉ được đóng khi mọi dòng dưới đây đạt.

**Con số phải khớp:**

| Kiểm tra | Số đúng | Lấy số đúng ở đâu | Số nhóm ra | Nhóm ra số ở đâu | Đạt? |
|---|---:|---|---:|---|---|
| <ví dụ: số dòng POS (Point of Sale, bán tại cửa hàng) sau khi nạp> | <17.124> | <sheet QC_Summary> | <…> | <sheet / truy vấn> | <Đạt / Chưa> |

**Việc phải có (không phải con số):**
- [ ] <ví dụ: mỗi bẫy có 1 ví dụ trước và sau khi xử lý>

---

## 6. Chỗ dễ sai

Những chỗ dễ làm sai mà bảng kiểm tra ở mục 5 chưa chắc phát hiện ra, kèm cách phòng.

| Chỗ dễ sai | Nếu sai thì thấy gì | Cách phòng / cách kiểm tra |
|---|---|---|
| <…> | <…> | <…> |

---

## 7. Các bước

Mỗi bước là một việc làm xong thì kiểm tra được ngay.

- [ ] **Bước 1: <làm gì>**
  - Làm: <…>
  - Kiểm tra: <làm gì để biết bước này đúng> → kết quả mong đợi: <…>
- [ ] **Bước 2: <làm gì>**
  - Làm: <…>
  - Kiểm tra: <…> → kết quả mong đợi: <…>
- [ ] **Bước cuối: viết phần báo cáo liên quan và lưu lên GitHub**
  - Làm: <đưa kết quả vào phần … của báo cáo>
  - Kiểm tra: báo cáo vẫn chuyển ra PDF (Portable Document Format) được; lời nhắn khi lưu ghi tên plan.

---

## 8. Nhật ký làm việc

Mỗi buổi ghi một dòng. Không xóa dòng cũ; nếu ghi sai thì thêm dòng mới để sửa.

| Ngày | Đã làm | Kết quả / số ra được | Vướng mắc, cách xử lý |
|---|---|---|---|
| <dd/mm> | <…> | <…> | <…> |

---

## 9. Quyết định đã chốt trong plan

| Ngày | Quyết định | Lý do | Có phải sửa file quy ước không |
|---|---|---|---|
| <dd/mm> | <…> | <…> | <Không / Có: đã sửa mục …> |

---

## 10. Dùng AI (trí tuệ nhân tạo)

Phần này được gom vào phụ lục khai báo dùng AI của báo cáo.

| Ngày | Nhờ AI làm gì | Phần nào do AI viết ra | Nhóm tự kiểm tra lại bằng cách nào |
|---|---|---|---|
| <dd/mm> | <…> | <file / bước / đoạn nào> | <so với số nào, chạy lại thế nào> |

---

## 11. Chuẩn bị vấn đáp

2–3 câu mentor (người hướng dẫn) có thể hỏi về phần này. Trả lời bằng lời của mình, có dẫn con số.

1. **Hỏi:** <…>
   **Trả lời:** <…>
2. **Hỏi:** <…>
   **Trả lời:** <…>

---

## 12. Kết quả khi đóng plan

- **Điều kiện xong:** <đạt hết / dòng nào chưa đạt và vì sao>
- **Đã đưa vào báo cáo:** <phần nào, đoạn nào>
- **Việc còn lại:** <… → chuyển sang plan nào>
- **Các lần lưu lên GitHub:** <mã lần lưu (commit) và nội dung chính>

**Tự soát trước khi đóng plan:**
- [ ] Không còn chỗ `< >` chưa điền.
- [ ] Mọi con số trong plan đều ghi rõ lấy từ đâu.
- [ ] Đã ghi mục "Dùng AI", hoặc ghi "Không có".
- [ ] Đã cập nhật bảng danh sách plan trong [plans/README.md](../README.md).
- [ ] Đã chuyển file sang `plans/completed/` bằng `git mv`.
