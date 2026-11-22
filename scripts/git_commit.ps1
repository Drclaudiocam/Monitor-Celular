param(
    [string]$Message = ""
)

$ErrorActionPreference = "Continue"
$projectRoot = "C:\Antigravity\Monitor Celular"
Set-Location $projectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       PHONEBOX - GIT COMMIT & SYNC       " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($Message)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "update: mobile monitor - $timestamp"
}

Write-Host "`n[1/3] Verificando arquivos alterados..." -ForegroundColor Yellow
git status -s

Write-Host "`n[2/3] Executando git add e git commit..." -ForegroundColor Yellow
git add -A
git commit -m "$Message"

Write-Host "`n[3/3] Sincronizando com o repositorio remoto (git push)..." -ForegroundColor Yellow
git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[AVISO] O git push no upstream nao foi concluido." -ForegroundColor Yellow
    Write-Host "Dica: Para enviar ao seu GitHub pessoal, crie um Fork e configure com:" -ForegroundColor DarkGray
    Write-Host "git remote set-url origin https://github.com/SEU_USUARIO/phonebox.git" -ForegroundColor DarkGray
} else {
    Write-Host "`n[OK] Git push executado com sucesso!" -ForegroundColor Green
}

Write-Host "`nProcesso concluido com sucesso!" -ForegroundColor Green

if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    Write-Host "Pressione qualquer tecla para fechar..."
    try { $null = [Console]::ReadKey($true) } catch { Start-Sleep -Seconds 4 }
} else {
    Start-Sleep -Seconds 4
}
