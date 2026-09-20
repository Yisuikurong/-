# ============================================================
# 一键生成手机版脚本
# 用法：在项目目录里右键"用 PowerShell 运行"，或：
#   powershell -ExecutionPolicy Bypass -File build_mobile.ps1
# 作用：读取主版本 智能花卉养殖系统.html
#       1) 把 img/ 下所有 jpg 内嵌为 base64
#       2) 追加手机屏幕适配样式
#       3) 输出 智能花卉养殖系统_手机版.html（单文件离线版）
# 注意：请始终修改"主版本"，不要直接改手机版（base64 不可读）
# ============================================================

$ErrorActionPreference = "Stop"
$proj = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path $proj "智能花卉养殖系统.html"
$dst  = Join-Path $proj "智能花卉养殖系统_手机版.html"

if (-not (Test-Path $src)) { Write-Host "找不到主版本文件: $src" -ForegroundColor Red; exit 1 }

Write-Host "读取主版本..." -ForegroundColor Cyan
$c = [System.IO.File]::ReadAllText($src)

Write-Host "内嵌图片 base64..." -ForegroundColor Cyan
$imgDir = Join-Path $proj "img"
$files = Get-ChildItem $imgDir -File
$ok = 0
foreach ($f in $files) {
    $bytes = [IO.File]::ReadAllBytes($f.FullName)
    $b64 = [Convert]::ToBase64String($bytes)
    $old = "img/" + $f.Name
    $new = "data:image/jpeg;base64," + $b64
    if ($c.Contains($old)) { $c = $c.Replace($old, $new); $ok++ }
}
Write-Host "  已内嵌 $ok / $($files.Count) 张图片" -ForegroundColor Green

Write-Host "追加手机适配样式..." -ForegroundColor Cyan
$mobileCss = @"
        /* ============ 手机版适配 ============ */
        @media (max-width: 640px) {
            .page { padding: 10px 10px 80px; }
            .top-bar { padding: 16px 50px 12px; margin-bottom: 14px; border-radius: 14px; top: 6px; }
            .top-bar h1 { font-size: 19px; }
            .top-bar p { font-size: 12px; margin-top: 4px; }
            .daily-flower, .card, .home-card, .album-card { padding: 16px; border-radius: 14px; margin-bottom: 14px; }
            .daily-flower h3, .card h4, .home-card h2 { font-size: 17px; }
            .search-area, .search-box { margin: 0 0 16px; }
            .search-area input, .search-box input { padding: 14px 16px; font-size: 16px; }
            .album-grid { grid-template-columns: repeat(2, 1fr) !important; gap: 10px; }
            .album-card img, .album-card .album-img-wrap img { height: 110px; object-fit: cover; }
            .modal { padding: 18px; border-radius: 14px; max-width: 100%; max-height: 94vh; }
            .appearance-img { max-height: 45vh; }
            .filter-bar { gap: 8px; }
            .filter-bar button { padding: 8px 12px; font-size: 13px; }
            .btn { padding: 11px 16px; font-size: 15px; }
            .knowledge-block { padding: 12px; margin: 10px 0; }
            .settings-btn { width: 36px; height: 36px; font-size: 18px; }
            .modal-close { font-size: 24px; }
            .plant-day-tag, .sick-tag, .category-tag { font-size: 12px; padding: 4px 9px; }
        }
"@
if ($c.Contains("@media (max-width: 640px)")) {
    Write-Host "  手机样式已存在，跳过追加" -ForegroundColor Yellow
} else {
    $c = $c.Replace("</style>", $mobileCss + "`r`n    </style>")
}

$utf8 = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($dst, $c, $utf8)

$sizeMB = [math]::Round((Get-Item $dst).Length / 1MB, 2)
Write-Host ""
Write-Host "完成！手机版已生成:" -ForegroundColor Green
Write-Host "  $dst  ($sizeMB MB)" -ForegroundColor Green
Write-Host "把这个文件发到手机用浏览器打开即可。" -ForegroundColor Cyan
