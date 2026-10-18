# Bảng quy ước sổ cái Finance GL – Nexa Home

> Nguồn: `quy uoc.xlsx`. Nội dung được chuyển từ hai sheet trong file Excel.

## 1. Quy ước các cột dữ liệu (`Quy_uoc_cot`)

| STT | Tên cột | Ý nghĩa | Quy ước chuẩn hóa / kiểm tra | Ứng dụng đối soát Q1 |
| --- | --- | --- | --- | --- |
| 1 | journal_id | Mã bút toán | Giữ nguyên dạng text; kiểm tra rỗng/trùng mã | Khóa truy vết GL |
| 2 | posting_date | Ngày hạch toán | Định dạng Date; đây là ngày ghi nhận GL | Đối soát cửa hàng × ngày, online × ngày |
| 3 | period | Kỳ kế toán YYYY-MM | Giữ dạng tháng; đối chiếu với posting_date | Group By 12 tháng |
| 4 | account | Tài khoản kế toán | Giữ dạng text; file có 5111 (doanh thu), 5213 (hàng trả) | Không loại 5213 khi tính doanh thu thuần |
| 5 | journal_type | Loại bút toán | 5 nhóm: POS_DAILY, WEB_DELIVERY, WEB_RETURN, MANUAL, POS_CATCHUP | Phân biệt giao dịch và điều chỉnh |
| 6 | store_code | Mã cửa hàng Finance | Mã NX... cho STORE; WEB cho online; có dòng null | Merge với Store Master; nhận diện chưa phân bổ |
| 7 | channel | Kênh doanh thu | STORE / WEB / UNALLOCATED; không bỏ UNALLOCATED | Tổng kênh phải bằng tổng GL |
| 8 | currency | Đơn vị nguyên tệ | AUD / CAD / EUR / GBP / USD | Không cộng nguyên tệ khác nhau để phân tích doanh thu |
| 9 | amount_local | Số tiền theo nguyên tệ | Giữ số thập phân và dấu GL gốc | Đối chiếu POS/WEB theo cùng currency |
| 10 | fx_rate_month_end | Tỷ giá cuối tháng | Trong bộ dữ liệu: số đơn vị tiền bản địa cho 1 USD | USD xấp xỉ amount_local / fx_rate_month_end |
| 11 | amount_usd | Số tiền sổ cái theo USD | Gốc ghi doanh thu âm, hàng trả dương; revenue_usd = -amount_usd | SUM(revenue_usd) là Finance 2025 |
| 12 | description | Diễn giải nội dung | Giữ nguyên; đọc để nhận diện điều chỉnh bất thường | Truy vết POS_CATCHUP, MANUAL |
| 13 | source_ref | Mã chứng từ tham chiếu | Rỗng ở bút toán hệ thống là bình thường; cần xem MANUAL | Kiểm chứng nguyên nhân bút toán tay |

**Công thức cần nhớ:** `revenue_usd = -amount_usd` (đổi dấu toàn bộ, gồm cả hàng trả).

**Kiểm tra tổng:** `SUM(amount_usd) = -28.698.496,23 USD` → `SUM(revenue_usd) = +28.698.496,23 USD`.

## 2. Phân loại bút toán (`Loai_but_toan`)

### 2.1. Theo `journal_type`

| journal_type | Ý nghĩa / cách xử lý | Số dòng | Finance sau đổi dấu (USD) | Ghi chú đối soát |
| --- | --- | --- | --- | --- |
| POS_DAILY | Doanh thu cửa hàng ghi nhận thường ngày | 5118 | 13,178,150.69 | So POS chuẩn hóa theo store × posting_date × currency |
| WEB_DELIVERY | Doanh thu online của đơn đã giao | 1647 | 15,766,167.26 | So WEB theo delivery_date × currency |
| WEB_RETURN | Hàng online trả lại; sau đổi dấu là số âm | 159 | -349,066.23 | So WEB theo return_date × currency; không bỏ khỏi net |
| MANUAL | Bút toán nhập tay (vận chuyển, phân loại lại, chưa phân bổ...) | 15 | 96,016.95 | Đọc description/source_ref; không coi tất cả là doanh thu bán hàng |
| POS_CATCHUP | Ghi bổ sung doanh thu POS bị thiếu | 1 | 7,227.56 | NX057: doanh thu 21/11 hạch toán bổ sung trong tháng 12 |
| TOTAL | Tổng Finance GL sau đổi dấu | 6940 | 28,698,496.23 |  |

### 2.2. Theo `channel`

| channel | Ý nghĩa | Số dòng | Finance USD | Lưu ý |
| --- | --- | --- | --- | --- |
| STORE | Bút toán gắn kênh cửa hàng | 5120 | 13,181,898.25 | Gồm các journal_type liên quan STORE, kể cả điều chỉnh |
| WEB | Bút toán gắn kênh website | 1819 | 15,515,347.98 | Gồm cả WEB_RETURN và các bút toán MANUAL thuộc WEB |
| UNALLOCATED | Không gắn kênh/cửa hàng | 1 | 1,250.00 | Phải giữ lại để tổng kênh khớp GL |
| TOTAL | Tổng các kênh | 6940 | 28,698,496.23 |  |

**Lưu ý quan trọng:** Không cộng `amount_local` từ nhiều đồng tiền để diễn giải doanh thu; sử dụng `revenue_usd` hoặc nhóm theo `currency`.
