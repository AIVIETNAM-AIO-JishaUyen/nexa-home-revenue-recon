# build_pdf.ps1 – Chuyển báo cáo LaTeX ra PDF: pdflatex -> bibtex -> pdflatex x2. Cần TeX Live (hoặc MiKTeX) có pdflatex, bibtex.
# Chạy: powershell -ExecutionPolicy Bypass -File report\build_pdf.ps1
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    $steps = @(@('pdflatex', '-interaction=nonstopmode', '-halt-on-error', 'main.tex'),
               @('bibtex', 'main'),
               @('pdflatex', '-interaction=nonstopmode', '-halt-on-error', 'main.tex'),
               @('pdflatex', '-interaction=nonstopmode', '-halt-on-error', 'main.tex'))
    foreach ($s in $steps) {
        & $s[0] $s[1..($s.Count - 1)] | Out-Null
        if ($LASTEXITCODE -ne 0 -and $s[0] -eq 'pdflatex') {
            'LỖI khi chạy ' + ($s -join ' ') + ' – xem report\main.log'
            Select-String -Path main.log -Pattern '^!' -Context 0, 3 | Select-Object -First 5 | ForEach-Object { $_.ToString() }
            exit 1
        }
    }
    $warn = (Select-String -Path main.log -Pattern 'Warning' | Measure-Object).Count
    $undef = Select-String -Path main.log -Pattern 'undefined' | Select-Object -First 5
    'Đã tạo report\main.pdf; số cảnh báo trong main.log: ' + $warn
    $undef | ForEach-Object { '  ' + $_.Line }
} finally {
    Pop-Location
}
