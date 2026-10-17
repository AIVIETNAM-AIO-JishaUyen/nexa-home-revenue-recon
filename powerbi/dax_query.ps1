# dax_query.ps1 – Mở dự án Power BI, làm mới dữ liệu, chạy truy vấn DAX và lưu kết quả ra CSV, để so số với Power Query và Python.
# Cần Power BI Desktop bản Microsoft Store. Truy vấn gửi vào bộ máy tính cục bộ (Analysis Services) của Power BI Desktop đang mở.
# Ví dụ:
#   powershell -ExecutionPolicy Bypass -File powerbi\dax_query.ps1 -Open powerbi\NexaRecon.pbip -Refresh
#   powershell -ExecutionPolicy Bypass -File powerbi\dax_query.ps1 -QueryFile powerbi\checks\totals_by_month.dax -OutCsv powerbi\checks\totals_by_month.csv
#   powershell -ExecutionPolicy Bypass -File powerbi\dax_query.ps1 -Close
param(
    [string]$Open = '',
    [switch]$Refresh,
    [string]$Query = '',
    [string]$QueryFile = '',
    [string]$OutCsv = '',
    [switch]$Close,
    [int]$WaitSec = 240
)
$ErrorActionPreference = 'Stop'
# Viết số theo kiểu quốc tế (dấu chấm thập phân) dù máy cài vùng Việt Nam, để file CSV đọc đúng
[Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::InvariantCulture
$base = Join-Path $env:USERPROFILE 'Microsoft\Power BI Desktop Store App\AnalysisServicesWorkspaces'

if ($Close) {
    # Chỉ tắt cửa sổ Power BI đang mở dự án NexaRecon
    Get-Process PBIDesktop -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like 'NexaRecon*' } | Stop-Process -Force
    'Đã tắt Power BI Desktop (NexaRecon)'
    exit 0
}

if ($Open -ne '') {
    $start = Get-Date
    $file = (Resolve-Path $Open).Path
    Start-Process (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\PBIDesktopStore.exe') -ArgumentList ('"' + $file + '"')
    # Chờ Power BI mở xong: có cửa sổ tên NexaRecon và có tệp cổng của bộ máy tính mới tạo sau lúc mở
    $deadline = $start.AddSeconds($WaitSec)
    do {
        Start-Sleep -Seconds 5
        $win = Get-Process PBIDesktop -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like 'NexaRecon*' }
        $portFile = Get-ChildItem $base -Recurse -Filter msmdsrv.port.txt -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $start }
    } until (($win -and $portFile) -or (Get-Date) -gt $deadline)
    if (-not ($win -and $portFile)) { 'QUÁ GIỜ: Power BI chưa mở xong dự án'; exit 2 }
    Start-Sleep -Seconds 15
    'Đã mở ' + $file
}

if (-not $Refresh -and $Query -eq '' -and $QueryFile -eq '') { exit 0 }

# Nạp thư viện ADOMD.NET đi kèm Power BI Desktop
$dll = Join-Path (Get-AppxPackage *PowerBIDesktop*).InstallLocation 'bin\Microsoft.PowerBI.AdomdClient.dll'
[void][Reflection.Assembly]::LoadFrom($dll)
# Tìm cổng của bộ máy tính cục bộ mới nhất
$ws = Get-ChildItem $base -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'Data\msmdsrv.port.txt') } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$port = (Get-Content (Join-Path $ws.FullName 'Data\msmdsrv.port.txt') -Encoding Unicode -Raw).Trim()
$conn = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection("Data Source=localhost:$port")
$conn.Open()
$db = $conn.GetSchemaDataSet('DBSCHEMA_CATALOGS', $null).Tables[0].Rows[0]['CATALOG_NAME']
try {
    if ($Refresh) {
        # Làm mới toàn bộ dữ liệu bằng lệnh TMSL (Tabular Model Scripting Language)
        $c = $conn.CreateCommand(); $c.CommandText = '{"refresh":{"type":"full","objects":[{"database":"' + $db + '"}]}}'
        [void]$c.ExecuteNonQuery()
        'Đã làm mới dữ liệu'
    }
    if ($QueryFile -ne '') { $Query = Get-Content $QueryFile -Raw -Encoding UTF8 }
    if ($Query -ne '') {
        $conn.ChangeDatabase($db)
        $cmd = $conn.CreateCommand(); $cmd.CommandText = $Query
        $da = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        [void]$da.Fill($dt)
        # Bỏ dấu ngoặc vuông và tên bảng ở tên cột kết quả, ví dụ "dim_date[period]" -> "period", "[Flash]" -> "Flash"
        foreach ($c in $dt.Columns) { $c.ColumnName = ($c.ColumnName -replace '^.*\[', '' -replace '\]$', '') }
        if ($OutCsv -ne '') {
            $dir = Split-Path $OutCsv -Parent; if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory $dir | Out-Null }
            $dt | Export-Csv $OutCsv -NoTypeInformation -Encoding UTF8
            'Đã lưu ' + $dt.Rows.Count + ' dòng vào ' + $OutCsv
        } else {
            $dt | Format-Table -AutoSize | Out-String -Width 250
        }
    }
} finally {
    $conn.Close()
}
