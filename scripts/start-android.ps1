#Requires -Version 5.1
# Abre o AVD sem apagar dados e com camera VirtualScene para ler QR Codes.
param(
    [string]$AvdName = 'Small_Phone',
    [string]$SdkPath
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'android-env.ps1') -SdkPath $SdkPath
$circuitoAdb = Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'
$circuitoEmulator = Join-Path $env:ANDROID_HOME 'emulator\emulator.exe'
if (-not (Test-Path -LiteralPath $circuitoEmulator -PathType Leaf)) {
    throw 'Android Emulator nao encontrado. Instale-o em Android Studio > SDK Manager > SDK Tools.'
}

& $circuitoAdb start-server
if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel iniciar o ADB.' }
$circuitoDevices = @(& $circuitoAdb devices)
if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel consultar os dispositivos no ADB.' }
foreach ($circuitoLine in $circuitoDevices) {
    if ($circuitoLine -match '^(emulator-\d+)\s+device(?:\s|$)') {
        $circuitoSerial = $Matches[1]
        $circuitoNameOutput = @(& $circuitoAdb -s $circuitoSerial emu avd name)
        if ($LASTEXITCODE -eq 0 -and $circuitoNameOutput.Count -gt 0 -and $circuitoNameOutput[0].Trim() -eq $AvdName) {
            Write-Host "AVD $AvdName ja esta disponivel em $circuitoSerial."
            if (Get-Command flutter -ErrorAction SilentlyContinue) {
                & flutter devices
                exit $LASTEXITCODE
            }
            exit 0
        }
    }
}
if ($circuitoDevices -match '^emulator-\d+\s+offline(?:\s|$)') {
    throw 'Existe um emulador offline ou iniciando. Aguarde o boot; se persistir, feche-o pelo Device Manager e execute novamente.'
}

$circuitoAvds = @(& $circuitoEmulator -list-avds)
if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel listar os AVDs.' }
$circuitoAvds = @($circuitoAvds | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($circuitoAvds -notcontains $AvdName) {
    Write-Host 'AVDs disponiveis neste computador:'
    $circuitoAvds | ForEach-Object { Write-Host "  $_" }
    throw "AVD '$AvdName' nao encontrado. Crie-o pelo Device Manager ou informe -AvdName com um nome listado acima."
}

Write-Host "Iniciando $AvdName com camera VirtualScene. Aguarde a tela inicial do Android."
Write-Host 'Mantenha este terminal aberto e execute flutter run em outro terminal.'
& $circuitoEmulator -avd $AvdName -no-snapshot-load -camera-back virtualscene
exit $LASTEXITCODE
