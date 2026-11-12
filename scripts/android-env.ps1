#Requires -Version 5.1
# Prepara o SDK apenas no terminal atual, sem alterar configuracoes do Windows.
param([string]$SdkPath)

$circuitoCandidates = @()
if ($SdkPath) {
    $circuitoCandidates = @($SdkPath)
} else {
    if ($env:ANDROID_HOME) { $circuitoCandidates += $env:ANDROID_HOME }
    if ($env:ANDROID_SDK_ROOT) { $circuitoCandidates += $env:ANDROID_SDK_ROOT }
    $circuitoLocalAppData = [Environment]::GetFolderPath('LocalApplicationData')
    if ($circuitoLocalAppData) {
        $circuitoCandidates += Join-Path $circuitoLocalAppData 'Android\Sdk'
    }
}

$circuitoSdk = $null
foreach ($circuitoCandidate in $circuitoCandidates) {
    if (Test-Path -LiteralPath (Join-Path $circuitoCandidate 'platform-tools\adb.exe') -PathType Leaf) {
        $circuitoSdk = (Resolve-Path -LiteralPath $circuitoCandidate).Path
        break
    }
}
if (-not $circuitoSdk) {
    throw 'SDK Android nao encontrado. Instale Android SDK Platform-Tools pelo Android Studio ou informe -SdkPath "D:\Android\Sdk".'
}

$env:ANDROID_HOME = $circuitoSdk
$env:ANDROID_SDK_ROOT = $circuitoSdk
$circuitoEntries = @(
    (Join-Path $circuitoSdk 'platform-tools'),
    (Join-Path $circuitoSdk 'emulator'),
    (Join-Path $circuitoSdk 'cmdline-tools\latest\bin')
)
$circuitoExistingPath = @($env:Path -split [IO.Path]::PathSeparator)
foreach ($circuitoEntry in $circuitoEntries) {
    if ($circuitoExistingPath -notcontains $circuitoEntry) {
        $circuitoExistingPath = @($circuitoEntry) + $circuitoExistingPath
    }
}
$env:Path = $circuitoExistingPath -join [IO.Path]::PathSeparator
Write-Host "SDK Android preparado neste terminal: $circuitoSdk"
