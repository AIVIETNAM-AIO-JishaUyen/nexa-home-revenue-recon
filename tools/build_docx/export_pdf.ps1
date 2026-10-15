# Xuat cac file .docx trong thu muc docs/word/ sang PDF bang Microsoft Word, de xem truoc / kiem tra.
# Moi file chay trong mot job rieng (mot tien trinh Word rieng), toi da 60 giay; qua thoi gian thi dung Word do.
# File .docx duoc mo roi dong khong luu (Close(0)), nen khong bi sua.
# Chay tu thu muc goc project:
#   powershell -ExecutionPolicy Bypass -File tools\build_docx\export_pdf.ps1 -PdfDir <thu muc PDF>
# Ghi chu: tren may nay, mo nhieu file lien tiep trong cung mot tien trinh Word, mo che do chi doc,
# Fields.Update() hay ExportAsFixedFormat deu tung lam Word treo, nen script tranh cac cach do.
param([string]$PdfDir = (Join-Path $env:TEMP 'build_docx_pdf'))

$wordDir = (Resolve-Path (Join-Path (Get-Location) 'docs\word')).Path
New-Item -ItemType Directory -Force -Path $PdfDir | Out-Null
$PdfDir = (Resolve-Path $PdfDir).Path

foreach ($f in Get-ChildItem -Path $wordDir -Filter *.docx | Where-Object { $_.Name -notlike '~$*' }) {
  $docxPath = $f.FullName
  $pdfPath = Join-Path $PdfDir ($f.BaseName + '.pdf')
  $job = Start-Job -ScriptBlock {
    param($docxPath, $pdfPath)
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $doc = $word.Documents.Open($docxPath, $false, $false, $false)
    $doc.SaveAs2($pdfPath, 17)
    $doc.Close(0)
    $word.Quit()
  } -ArgumentList $docxPath, $pdfPath
  $null = Wait-Job $job -Timeout 60
  if ($job.State -ne 'Completed') {
    Stop-Job $job
    Get-Process WINWORD -ErrorAction SilentlyContinue |
      Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-2) } | Stop-Process -Force
    Write-Output ('LOI (qua thoi gian): ' + $f.Name)
  } else {
    Write-Output ('Xong: ' + $f.Name)
  }
  Remove-Job $job -Force
}
