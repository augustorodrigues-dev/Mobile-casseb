#Requires -Version 5.1
# Executa os mesmos testes puros de test-core.sh, sem Python ou download de pacotes.
$ErrorActionPreference = 'Stop'
$circuitoRoot = Split-Path -Parent $PSScriptRoot
$circuitoMobile = Join-Path $circuitoRoot 'mobile'
$circuitoDart = if ($env:DART_BIN) { $env:DART_BIN } else { 'dart' }
if (-not (Get-Command $circuitoDart -ErrorAction SilentlyContinue)) {
    throw 'Dart nao encontrado. Instale Flutter e adicione a pasta flutter\bin ao PATH.'
}
$circuitoTemp = Join-Path ([IO.Path]::GetTempPath()) ('circuito-core-' + [Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($circuitoTemp) | Out-Null
try {
    $circuitoMobileUri = [Uri]::new($circuitoMobile + [IO.Path]::DirectorySeparatorChar).AbsoluteUri
    $circuitoConfig = @{
        configVersion = 2
        packages = @(@{
            name = 'circuito_descobertas'
            rootUri = $circuitoMobileUri
            packageUri = 'lib/'
            languageVersion = '3.9'
        })
    }
    $circuitoConfigPath = Join-Path $circuitoTemp 'package_config.json'
    $circuitoJson = $circuitoConfig | ConvertTo-Json -Depth 6
    [IO.File]::WriteAllText($circuitoConfigPath, $circuitoJson, [Text.UTF8Encoding]::new($false))
    & $circuitoDart "--packages=$circuitoConfigPath" (Join-Path $circuitoMobile 'tool\test_core.dart')
    $circuitoResult = $LASTEXITCODE
} finally {
    Remove-Item -LiteralPath $circuitoTemp -Recurse -Force
}
exit $circuitoResult
