# Báo cáo

> Báo cáo viết bằng LaTeX, chuyển ra PDF. Bản đọc: `main.pdf` (45 trang). Mọi con số và hình được sinh tự động từ file Power Query và kết quả Power BI, không gõ tay vào lời văn.

## 1. Các file

| File / thư mục | Là gì |
|---|---|
| `main.tex` | Khung báo cáo: trang bìa, kiểu chữ, các hộp, các lệnh LaTeX dùng chung; gọi các file trong `sections/` |
| `sections/` | Nội dung, mỗi phần một file: `00_tom_tat` (hộp tóm tắt), `01`–`08` là 8 phần theo slide 45, `09_phu_luc` là phụ lục |
| `figures_src/make_figures.py` | Đọc file Power Query (`excel/Nexa_Home_Recon_PQ.xlsx`) và kết quả Power BI (`powerbi/checks/`), sinh bảng, hình, con số vào `generated/` |
| `generated/` | Do `make_figures.py` sinh ra. **Không sửa tay.** `so_lieu.tex` chứa các con số dạng lệnh LaTeX, ví dụ `\SoChenhLechNam` |
| `references.bib` | Tài liệu tham khảo |
| `build_pdf.ps1` | Chuyển ra PDF |
| `Figures/` | Logo của mẫu báo cáo |

## 2. Dựng lại PDF

```
D:/Anaconda/python.exe -I report/figures_src/make_figures.py
powershell -ExecutionPolicy Bypass -File report\build_pdf.ps1
```

Cần TeX Live (hoặc MiKTeX). Cảnh báo "There were undefined references" có sẵn từ mẫu báo cáo, không ảnh hưởng.

## 3. Sửa báo cáo

- **Sửa lời văn:** sửa file trong `sections/`.
- **Cần một con số mới trong lời văn:** trong `make_figures.py`, thêm số đó vào một khối `macros.update({...})` đặt gần chỗ tính số, chạy lại, rồi dùng lệnh `\TenSo{}` trong lời văn (ví dụ `\SoChenhLechNam{}`). Không gõ số tay.
- **Nhãn nguồn** như `[QC]`, `[BR-Tổng]` (lệnh `\nguon{...}`) cho biết số lấy từ bảng nào; bảng tra ở phụ lục C.
- Sau khi sửa: dựng lại PDF, rồi gom lại bộ file nộp (`tools/README.md`).
