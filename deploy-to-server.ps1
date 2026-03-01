# Развёртывание stocks_products на сервере 79.174.82.60
# Запуск: .\deploy-to-server.ps1
# При запросе пароля введите: 8AorNvpYAOP7qM3u

$Server = "root@79.174.82.60"
$LocalPath = Join-Path $PSScriptRoot "stocks_products"
$RemotePath = "/opt/stocks_products"

Write-Host "Копирование проекта на сервер..."
Write-Host "Используйте WSL: wsl scp -r $($LocalPath -replace '\\','/') ${Server}:${RemotePath}"
Write-Host "Затем: wsl ssh $Server 'cd $RemotePath && chmod +x deploy/deploy.sh && ./deploy/deploy.sh'"
Write-Host ""
Write-Host "Или из WSL (bash):"
Write-Host "  scp -r stocks_products root@79.174.82.60:/opt/"
Write-Host "  ssh root@79.174.82.60 'cd /opt/stocks_products && chmod +x deploy/deploy.sh && ./deploy/deploy.sh'"
