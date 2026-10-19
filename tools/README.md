# Công cụ phụ

| Công cụ | Làm gì | Chạy |
|---|---|---|
| `make_submission.py` | Gom bộ file nộp vào `submission/`: chép báo cáo PDF và file Power Query; điền số vào bản sao file mẫu nộp của đề rồi tự kiểm dòng kiểm tra; nén dự án Power BI và code Power Query; viết `submission/README.md` | `D:/Anaconda/python.exe -I tools/make_submission.py` |
| `build_docx/` | Tạo bản Word (`docs/word/*.docx`) từ các file `.md` | Xem [`build_docx/README.md`](build_docx/README.md) |

**Thứ tự khi muốn nộp lại sau khi sửa:**
1. Sửa truy vấn thì dựng lại file Power Query (`excel/README.md`).
2. Sửa mô hình Power BI thì mở, làm mới và chạy lại truy vấn kiểm tra (`powerbi/README.md`).
3. Sinh lại số, hình và chuyển báo cáo ra PDF (`report/README.md`).
4. Chạy `make_submission.py`.
