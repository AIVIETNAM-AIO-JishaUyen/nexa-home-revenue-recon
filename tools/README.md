# Công cụ phụ

| Công cụ | Làm gì | Chạy |
|---|---|---|
| `make_submission.py` | Gom bộ file nộp vào `submission/` (xóa thư mục cũ rồi tạo lại):<ul><li>Chép báo cáo PDF và file Power Query</li><li>Điền số vào bản sao file mẫu nộp của đề, rồi tự kiểm dòng kiểm tra bằng 0</li><li>Nén dự án Power BI và code Power Query thành file `.zip`</li><li>Viết `submission/README.md`</li></ul> | `D:/Anaconda/python.exe -I tools/make_submission.py` |
| `build_docx/` | Tạo bản Word (`docs/word/*.docx`) từ các file `.md` | Xem [`build_docx/README.md`](build_docx/README.md) |

**Thứ tự khi muốn nộp lại sau khi sửa:**
1. Sửa truy vấn thì dựng lại file Power Query (`excel/README.md`).
2. Sửa mô hình Power BI thì mở, làm mới và chạy lại truy vấn kiểm tra (`powerbi/README.md`).
3. Sinh lại số, hình và chuyển báo cáo ra PDF (`report/README.md`).
4. Chạy `make_submission.py`.
