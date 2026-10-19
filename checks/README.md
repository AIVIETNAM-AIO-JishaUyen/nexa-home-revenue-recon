# Kiểm tra số

> Thư mục này không phải sản phẩm nộp. Nó dùng để chắc số của file Power Query là đúng: so với số chuẩn của đề, và tính lại bằng một cách độc lập.

## 1. Các file

| File | Là gì |
|---|---|
| `numbers_of_record.csv` | **Số chuẩn**: số lấy từ đề, slide, bảng tổng kiểm soát QC_Summary (QC – Quality Control). Cột: mã số, nhóm, tên chỉ tiêu, kỳ, kênh, giá trị, đơn vị, nguồn |
| `python_check.py` | Bảng tính kiểm tra viết bằng Python: tính lại từng khoản của bảng cầu nối từ 4 file dữ liệu, không dùng Power Query |
| `python_bridge.csv` | Kết quả của `python_check.py`, cùng dạng bảng cầu nối dạng dài của Power Query |
| `python_check_result.txt` | Kết quả so với số chuẩn: mỗi dòng "ĐẠT" hoặc "SAI"; dòng cuối là tổng kết |
| `refresh_test/` | Chạy thử làm mới với dữ liệu giả của một tháng mới (mục 3) |

## 2. Chạy bảng tính kiểm tra

```
D:/Anaconda/python.exe -I checks/python_check.py
```

Lần chạy gần nhất (19/10/2026): 102/102 phép so đạt, 0 sai.

## 3. Chạy thử với tháng mới (`refresh_test/`)

Mục đích: chứng minh file Power Query chạy lại được cho tháng mới chỉ bằng thay file rồi làm mới, không sửa truy vấn.

1. `make_fake_month.py <thư mục data gốc> <thư mục data mới>`: chép dữ liệu sang thư mục khác, thêm dữ liệu **giả** tháng 01/2026 và cửa hàng mới NX068, tự tính số mong đợi (`expected_2026_01.csv`).
2. Chép file Power Query sang cạnh thư mục mới, làm mới bằng `excel/refresh_workbook.ps1 -File <file> -DataFolder <thư mục data mới>`.
3. `check_refresh.py <file Excel đã làm mới>`: so kết quả, ghi ra `ket_qua_2026_01.txt`.

Kết quả lần chạy thử: mọi phép so đạt (chi tiết trong `ket_qua_2026_01.txt` và mục II.8 của báo cáo).
