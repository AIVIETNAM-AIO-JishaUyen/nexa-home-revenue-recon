# Tạo bản Word (.docx) từ các file .md

- **File `.md` là bản gốc.** File `.docx` trong thư mục `docs/word/` được tạo tự động để người đọc dễ xem. **Không sửa tay file `.docx`**: muốn đổi nội dung thì sửa file `.md` rồi tạo lại.
- Các file được chuyển: `roadmap.md`, `tu_dien_roadmap.md` và 4 file trong `docs/` (danh sách ở đầu file `build.js`).

## Cách chạy (từ thư mục gốc project)

1. Lần đầu: cài thư viện.
   ```
   cd tools/build_docx
   npm install
   cd ../..
   ```
2. Tạo file Word:
   ```
   node tools/build_docx/build.js
   ```
   - Muốn tạo một file thôi: `node tools/build_docx/build.js roadmap`
   - Sơ đồ Mermaid được vẽ thành ảnh qua `npx @mermaid-js/mermaid-cli`. Ảnh lưu tạm ở `tools/build_docx/.cache/`, có thể xóa thư mục này.
3. (Tùy chọn) Xuất PDF để xem trước, cần máy có Microsoft Word:
   ```
   powershell -ExecutionPolicy Bypass -File tools\build_docx\export_pdf.ps1 -PdfDir <thư mục PDF>
   ```
