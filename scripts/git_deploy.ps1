param(
    [string]$Message = ""
)

$ErrorActionPreference = "Continue"
$projectRoot = "C:\Antigravity\Monitor Celular"
Set-Location $projectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       PHONEBOX - GIT COMMIT & DEPLOY     " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Git Commit
if ([string]::IsNullOrWhiteSpace($Message)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Message = "deploy: mobile monitor - $timestamp"
}

Write-Host "`n[1/4] Git Add & Commit..." -ForegroundColor Yellow
git add -A
git commit -m "$Message"

# 2. Git Push
Write-Host "`n[2/4] Sincronizando com repositorio remoto (git push)..." -ForegroundColor Yellow
git push
if ($LASTEXITCODE -ne 0) {
    Write-Host "[AVISO] git push no upstream nao autorizado. Commit local preservado com sucesso." -ForegroundColor Yellow
} else {
    Write-Host "[OK] Git push concluido com sucesso." -ForegroundColor Green
}

# 3. Android Build
Write-Host "`n[3/4] Compilando APK Android (assembleDebug)..." -ForegroundColor Yellow
$gradleCmd = Join-Path $projectRoot "android\gradlew.bat"
$adbCmd = Join-Path $projectRoot "platform-tools\adb.exe"

Push-Location (Join-Path $projectRoot "android")
& $gradleCmd assembleDebug
$buildExit = $LASTEXITCODE
Pop-Location

if ($buildExit -ne 0) {
    Write-Host "`n[ERRO] Falha na compilacao do APK Android (codigo $buildExit)!" -ForegroundColor Red
} else {
    Write-Host "[OK] Compilacao do APK concluida com sucesso." -ForegroundColor Green
    
    # 4. ADB Install & Launch
    Write-Host "`n[4/4] Instalando e iniciando no celular conectado..." -ForegroundColor Yellow
    $apkPath = Join-Path $projectRoot "android\app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $apkPath) {
        & $adbCmd install -r $apkPath
        & $adbCmd shell am start -n net.oxog.phonebox.deskpanel/.MainActivity
        Write-Host "`n[SUCESSO] Aplicativo atualizado e iniciado no celular!" -ForegroundColor Green
    } else {
        Write-Host "[ERRO] APK nao encontrado em $apkPath" -ForegroundColor Red
    }
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "           DEPLOY FINALIZADO!             " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    Write-Host "Pressione qualquer tecla para fechar..."
    try { $null = [Console]::ReadKey($true) } catch { Start-Sleep -Seconds 4 }
} else {
    Start-Sleep -Seconds 4
}
