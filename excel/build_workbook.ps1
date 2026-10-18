# build_workbook.ps1 – Dựng file excel/Nexa_Home_Recon_PQ.xlsx từ các file .m trong excel/queries (Power Query), bằng Excel tự động (COM).
# Cách chạy (PowerShell):  powershell -ExecutionPolicy Bypass -File excel\build_workbook.ps1 [-DataFolder <thư mục dữ liệu>] [-OutFile <file Excel>]
# - excel/queries/manifest.csv: danh sách truy vấn; cột sheet để trống = chỉ tạo kết nối, không nạp ra sheet.
# - Script tự giới hạn thời gian (mặc định 15 phút) và chỉ tắt đúng tiến trình Excel do nó mở.
param(
    [string]$DataFolder = '',
    [string]$OutFile = '',
    [int]$TimeoutSec = 900,
    [switch]$Worker,
    [string]$PidFile = ''
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if ($DataFolder -eq '') { $DataFolder = Join-Path $root 'data' }
if ($OutFile -eq '') { $OutFile = Join-Path $PSScriptRoot 'Nexa_Home_Recon_PQ.xlsx' }
$DataFolder = (Resolve-Path $DataFolder).Path.TrimEnd('\')
$OutFile = [IO.Path]::GetFullPath($OutFile)

# Phần chạy ngoài: mở chính script này ở tiến trình con, chờ có giới hạn thời gian
if (-not $Worker) {
    $PidFile = [IO.Path]::GetTempFileName()
    $log = [IO.Path]::GetTempFileName()
    $argLine = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Worker -DataFolder `"$DataFolder`" -OutFile `"$OutFile`" -PidFile `"$PidFile`""
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

# Phần chạy trong tiến trình con: dựng file bằng Excel
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public static class W { [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint p); }'
$queriesDir = Join-Path $PSScriptRoot 'queries'
$manifest = Import-Csv (Join-Path $queriesDir 'manifest.csv') -Encoding UTF8
$errors = 0
$xl = New-Object -ComObject Excel.Application
$xlPid = [uint32]0
[void][W]::GetWindowThreadProcessId([IntPtr]$xl.Hwnd, [ref]$xlPid)
Set-Content -Path $PidFile -Value $xlPid
try {
    $xl.Visible = $false; $xl.DisplayAlerts = $false; $xl.AskToUpdateLinks = $false; $xl.EnableEvents = $false; $xl.ScreenUpdating = $false
    $wb = $xl.Workbooks.Add()
    while ($wb.Worksheets.Count -gt 1) { $wb.Worksheets.Item($wb.Worksheets.Count).Delete() }

    # Sheet hướng dẫn
    $wsH = $wb.Worksheets.Item(1); $wsH.Name = 'Huong_dan'
    $lines = Get-Content (Join-Path $PSScriptRoot 'huong_dan.txt') -Encoding UTF8
    for ($i = 0; $i -lt $lines.Count; $i++) { $wsH.Cells.Item($i + 1, 1).Value2 = $lines[$i] }
    $wsH.Range('A1').Font.Bold = $true; $wsH.Range('A1').Font.Size = 14
    $wsH.Columns.Item(1).ColumnWidth = 140

    # Sheet cài đặt: ô FolderPath
    $wsC = $wb.Worksheets.Add([Type]::Missing, $wsH); $wsC.Name = 'Cai_dat'
    $wsC.Range('A1').Value2 = 'Cài đặt'
    $wsC.Range('A1').Font.Bold = $true; $wsC.Range('A1').Font.Size = 14
    $wsC.Range('A2').Value2 = 'FolderPath'
    $wsC.Range('B2').Value2 = $DataFolder + '\'
    $wsC.Range('B2').Interior.Color = 13431551   # nền vàng nhạt: ô người dùng được sửa
    $wsC.Range('A3').Value2 = 'Đường dẫn thư mục chứa 4 file dữ liệu và file danh mục. Đổi máy hoặc đổi thư mục thì chỉ sửa ô B2 rồi chọn Data > Refresh All.'
    $wsC.Columns.Item(1).ColumnWidth = 14; $wsC.Columns.Item(2).ColumnWidth = 90
    [void]$wb.Names.Add('FolderPath', '=Cai_dat!$B$2')

    # Thêm mọi truy vấn
    foreach ($m in $manifest) {
        $code = Get-Content (Join-Path $queriesDir ($m.query + '.m')) -Raw -Encoding UTF8
        [void]$wb.Queries.Add($m.query, $code)
    }

    # Nạp các truy vấn có tên sheet ra sheet, theo thứ tự trong manifest
    foreach ($m in ($manifest | Where-Object { $_.sheet -ne '' })) {
        $ws = $wb.Worksheets.Add([Type]::Missing, $wb.Worksheets.Item($wb.Worksheets.Count)); $ws.Name = $m.sheet
        $ws.Range('A1').Value2 = $m.title; $ws.Range('A1').Font.Bold = $true; $ws.Range('A1').Font.Size = 13
        $cs = 'OLEDB;Provider=Microsoft.Mashup.OleDb.1;Data Source=$Workbook$;Location=' + $m.query + ';Extended Properties=""'
        $lo = $ws.ListObjects.Add(0, $cs, [Type]::Missing, 1, $ws.Range('A3'))
        $lo.DisplayName = $m.query
        $qt = $lo.QueryTable; $qt.CommandType = 2; $qt.CommandText = 'SELECT * FROM [' + $m.query + ']'; $qt.BackgroundQuery = $false
        try {
            $t0 = Get-Date; [void]$qt.Refresh($false)
            'OK   ' + $m.query + ' -> sheet ' + $m.sheet + ': ' + $lo.ListRows.Count + ' dòng, ' + [int]((Get-Date) - $t0).TotalSeconds + ' giây'
        } catch {
            'LỖI  ' + $m.query + ': ' + $_.Exception.Message
            $errors++
            continue
        }
        foreach ($c in $lo.ListColumns) {
            if ($null -eq $c.DataBodyRange) { continue }
            if ($c.Name -match 'pct') { $c.DataBodyRange.NumberFormat = '0.00%' }
            elseif ($c.Name -match 'usd') { $c.DataBodyRange.NumberFormat = '#,##0.00' }
        }
        # Tô chữ đỏ, đậm cho dòng chưa đạt: trang_thai khác "Đạt", dat = FALSE, match_status khác "Khớp" và "Ngoài kỳ đối soát", flag_norm = TRUE (vượt ngưỡng)
        foreach ($c in $lo.ListColumns) {
            if ($null -eq $c.DataBodyRange) { continue }
            $first = $c.DataBodyRange.Cells.Item(1).Address(0, 0)
            $fc = $null
            if ($c.Name -eq 'trang_thai') { $fc = $c.DataBodyRange.FormatConditions.Add(2, [Type]::Missing, ('=' + $first + '<>"Đạt"')) }
            elseif ($c.Name -eq 'dat') { $fc = $c.DataBodyRange.FormatConditions.Add(2, [Type]::Missing, ('=' + $first + '=FALSE')) }
            elseif ($c.Name -eq 'match_status') { $fc = $c.DataBodyRange.FormatConditions.Add(2, [Type]::Missing, ('=AND(' + $first + '<>"Khớp",' + $first + '<>"Ngoài kỳ đối soát")')) }
            elseif ($c.Name -eq 'flag_norm') { $fc = $c.DataBodyRange.FormatConditions.Add(2, [Type]::Missing, ('=' + $first + '=TRUE')) }
            if ($fc) { $fc.Font.Color = 255; $fc.Font.Bold = $true }
        }
        # Giãn cột theo bảng (không theo dòng tiêu đề dài ở ô A1)
        [void]$lo.Range.Columns.AutoFit()
    }

    # File mẫu nộp của đề: chép sheet Cau_noi và Nhat_ky_ngoai_le, điền bằng công thức (SUMIFS, INDEX), không gõ tay số nào
    $tplPath = Join-Path $DataFolder 'Mau_nop_Bang_cau_noi.xlsx'
    if (-not (Test-Path $tplPath)) {
        'LỖI  không thấy file mẫu nộp ' + $tplPath
        $errors++
    } else {
        try {
            # Tên khoản lấy từ bảng danh mục khoản đã nạp (sheet Danh_muc_khoan)
            $names = @{}
            $loI = $wb.Worksheets.Item('Danh_muc_khoan').ListObjects.Item(1)
            $cCode = $loI.ListColumns.Item('item_code').Index; $cName = $loI.ListColumns.Item('item_name').Index
            foreach ($r in $loI.ListRows) { $names[[string]$r.Range.Cells.Item(1, $cCode).Value2] = [string]$r.Range.Cells.Item(1, $cName).Value2 }
            $tpl = $xl.Workbooks.Open($tplPath, 0, $true)
            # Bảng toàn công ty: đúng 10 dòng khoản của file mẫu; bảng theo kênh thêm 1 dòng chuyển kênh (MJ-RCL)
            $base = @('discount', 'pos_duplicate', 'cancelled', 'online_timing', 'store_posting', 'transfer_error', 'returns', 'shipping')
            $specs = @(
                @{ sheet = 'Cau_noi'; bridge = 'COMPANY'; label = 'toàn công ty'; items = $base + @('fx', 'rounding') },
                @{ sheet = 'Cau_noi_cua_hang'; bridge = 'STORE'; label = 'cửa hàng'; items = $base + @('channel_reclass', 'fx', 'rounding') },
                @{ sheet = 'Cau_noi_online'; bridge = 'WEB'; label = 'online'; items = $base + @('channel_reclass', 'fx', 'rounding') }
            )
            foreach ($s in $specs) {
                $tpl.Worksheets.Item('Cau_noi').Copy([Type]::Missing, $wb.Worksheets.Item($wb.Worksheets.Count))
                $ws = $wb.Worksheets.Item($wb.Worksheets.Count); $ws.Name = $s.sheet
                $n = $s.items.Count
                # Thêm dòng khoản nếu bảng có hơn 10 khoản (chèn trong vùng cộng nên công thức tổng tự giãn)
                for ($k = 10; $k -lt $n; $k++) { [void]$ws.Rows.Item(12).Insert() }
                $codes = @('flash') + $s.items + @('unexplained')
                $glRow = 5 + $n
                $ws.Cells.Item(1, 16).Value2 = 'Mã khoản (cột phụ cho công thức)'
                for ($i = 0; $i -lt $codes.Count; $i++) {
                    $row = 2 + $i
                    if ($i -ge 1 -and $i -le $n) { $ws.Cells.Item($row, 1).Value2 = 'Khoản giải thích ' + $i + ': ' + $names[$s.items[$i - 1]] }
                    $ws.Cells.Item($row, 16).Value2 = $codes[$i]
                    $ws.Cells.Item($row, 14).Formula = '=SUM(B' + $row + ':M' + $row + ')'
                }
                $ws.Cells.Item($glRow, 16).Value2 = 'gl'
                # Ô vàng: SUMIFS trên bảng cầu nối dạng dài, theo bảng (bridge), tháng (dòng 1) và mã khoản (cột P)
                foreach ($row in @(2..(3 + $n)) + @($glRow)) {
                    $ws.Range('B' + $row + ':M' + $row).Formula = '=SUMIFS(q_BR_Long[usd],q_BR_Long[bridge],"' + $s.bridge + '",q_BR_Long[period],B$1,q_BR_Long[item_code],$P' + $row + ')'
                }
                $ws.Range('B2:N' + ($glRow + 1)).NumberFormat = '#,##0.00'
                $ws.Columns.Item(16).Font.Color = 8421504
                $ws.Cells.Item($glRow + 3, 1).Value2 = 'Bảng ' + $s.label + '. Ô vàng lấy số bằng SUMIFS từ bảng q_BR_Long (sheet BR_Long), không ô nào gõ tay; làm mới dữ liệu là số tự cập nhật.'
                if ($s.bridge -ne 'COMPANY') { $ws.Cells.Item($glRow + 4, 1).Value2 = 'Cửa hàng + online + chưa gắn kênh (bút toán ADJ-0925, xem BR_Long với bridge = UNALLOCATED) = toàn công ty.' }
                [void]$ws.Columns.Item(1).AutoFit()
                'OK   file mẫu -> sheet ' + $s.sheet + ' (' + $n + ' khoản)'
            }
            # Nhật ký ngoại lệ: giữ đúng tiêu đề của file mẫu, bỏ dòng ví dụ EX-00, mỗi ô đọc bảng q_ExceptionLog bằng INDEX
            $tpl.Worksheets.Item('Nhat_ky_ngoai_le').Copy([Type]::Missing, $wb.Worksheets.Item($wb.Worksheets.Count))
            $wsL = $wb.Worksheets.Item($wb.Worksheets.Count)
            $note = [string]$wsL.Range('A4').Value2
            [void]$wsL.Range('A2:J4').ClearContents()
            $nLog = $wb.Worksheets.Item('Nhat_ky_du_lieu').ListObjects.Item(1).ListRows.Count
            $last = $nLog + 11   # chừa 10 dòng trống cho khoản mới khi nạp tháng mới
            $wsL.Range('A2:J' + $last).Formula = '=IFERROR(INDEX(q_ExceptionLog,ROW()-1,COLUMN())&"","")'
            $wsL.Range('E2:E' + $last).Formula = '=IFERROR(INDEX(q_ExceptionLog,ROW()-1,5),"")'
            $wsL.Range('E2:E' + $last).NumberFormat = '#,##0.00'
            $wsL.Cells.Item($last + 2, 1).Value2 = $note
            $wsL.Cells.Item($last + 3, 1).Value2 = 'Mỗi ô đọc bảng q_ExceptionLog (sheet Nhat_ky_du_lieu) bằng INDEX; không ô nào gõ tay.'
            $wsL.Columns.Item(4).ColumnWidth = 80; $wsL.Columns.Item(8).ColumnWidth = 45
            'OK   file mẫu -> sheet Nhat_ky_ngoai_le (' + $nLog + ' dòng)'
            $tpl.Close($false)
            $xl.CalculateFull()
        } catch {
            'LỖI  file mẫu nộp: ' + $_.Exception.Message
            $errors++
        }
    }

    $wsH.Activate()
    if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
    $wb.SaveAs($OutFile, 51)
    $wb.Close($false)
    'Đã lưu ' + $OutFile
} catch {
    'LỖI: ' + $_.Exception.Message
    $errors++
} finally {
    $xl.Quit()
    [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($xl)
    Start-Sleep -Milliseconds 500
    Stop-Process -Id $xlPid -Force -ErrorAction SilentlyContinue
}
if ($errors -gt 0) { exit 1 } else { exit 0 }
