# refresh_workbook.ps1 – Làm mới file Power Query đã dựng (giống bấm Data > Refresh All), không dựng lại từ đầu.
# Cách chạy (PowerShell):  powershell -ExecutionPolicy Bypass -File excel\refresh_workbook.ps1 [-File <file Excel>] [-DataFolder <thư mục dữ liệu>] [-TimeoutSec 5400]
# - Có -DataFolder thì ghi đường dẫn đó vào ô Cai_dat!B2 (tên FolderPath) trước khi làm mới; đây là ô duy nhất người dùng phải sửa khi đổi máy hoặc đổi thư mục.
# - Làm mới toàn bộ mất khoảng 1 giờ (mỗi bảng tự tính lại các truy vấn nó dùng). Script tự giới hạn thời gian và chỉ tắt đúng tiến trình Excel do nó mở.
param(
    [string]$File = '',
    [string]$DataFolder = '',
    [int]$TimeoutSec = 5400,
    [switch]$Worker,
    [string]$PidFile = ''
)
$ErrorActionPreference = 'Stop'
if ($File -eq '') { $File = Join-Path $PSScriptRoot 'Nexa_Home_Recon_PQ.xlsx' }
$File = (Resolve-Path $File).Path
if ($DataFolder -ne '') { $DataFolder = (Resolve-Path $DataFolder).Path.TrimEnd('\') + '\' }

# Phần chạy ngoài: mở chính script này ở tiến trình con, chờ có giới hạn thời gian
if (-not $Worker) {
    $PidFile = [IO.Path]::GetTempFileName()
    $log = [IO.Path]::GetTempFileName()
    $argLine = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Worker -File `"$File`" -PidFile `"$PidFile`""
    if ($DataFolder -ne '') { $argLine += " -DataFolder `"$($DataFolder.TrimEnd('\'))`"" }
    $proc = Start-Process powershell -ArgumentList $argLine -PassThru -WindowStyle Hidden -RedirectStandardOutput $log
    if (-not $proc.WaitForExit($TimeoutSec * 1000)) {
        "QUÁ GIỜ sau $TimeoutSec giây, tắt Excel do script mở"
        $proc.Kill()
        $x = Get-Content $PidFile -ErrorAction SilentlyContinue
        if ($x) { Stop-Process -Id $x -Force -ErrorAction SilentlyContinue }
        Get-Content $log -Encoding UTF8
        exit 2
    }
    $proc.WaitForExit()
    Get-Content $log -Encoding UTF8
    exit $proc.ExitCode
}

# Phần chạy trong tiến trình con: mở file, sửa ô FolderPath, làm mới, lưu
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class W { [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint p); }'
$xl = New-Object -ComObject Excel.Application
$xlPid = [uint32]0
[void][W]::GetWindowThreadProcessId([IntPtr]$xl.Hwnd, [ref]$xlPid)
Set-Content -Path $PidFile -Value $xlPid
$code = 0
try {
    $xl.Visible = $false; $xl.DisplayAlerts = $false; $xl.AskToUpdateLinks = $false; $xl.EnableEvents = $false; $xl.ScreenUpdating = $false
    $wb = $xl.Workbooks.Open($File)
    $wb.Queries.FastCombine = $true
    if ($DataFolder -ne '') {
        $wb.Worksheets.Item('Cai_dat').Range('B2').Value2 = $DataFolder
        'Ô FolderPath = ' + $DataFolder
    }
    $t0 = Get-Date
    $wb.RefreshAll()
    $xl.CalculateUntilAsyncQueriesDone()
    $xl.CalculateFull()
    'Làm mới xong sau ' + [int]((Get-Date) - $t0).TotalSeconds + ' giây'
    # Liệt kê số dòng của từng bảng để thấy bảng nào trống hoặc lỗi
    foreach ($ws in $wb.Worksheets) {
        foreach ($lo in $ws.ListObjects) { '  ' + $ws.Name + ': ' + $lo.ListRows.Count + ' dòng' }
    }
    $wb.Save()
    $wb.Close($false)
    'Đã lưu ' + $File
} catch {
    'LỖI  ' + $_.Exception.Message
    $code = 1
} finally {
    $xl.Quit()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
    Start-Sleep -Seconds 2
    Stop-Process -Id $xlPid -Force -ErrorAction SilentlyContinue
}
exit $code
