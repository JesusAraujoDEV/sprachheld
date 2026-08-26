# instalar.ps1 - elegi modo (testing/release) y dispositivo con las flechas,
# y lanza `flutter run` con lo elegido. ponytail: menu de flechas hecho a mano
# con RawUI.ReadKey (sin dependencias nuevas) en vez de un modulo de consola.
# Solo ASCII en los strings: PowerShell 5.1 lee .ps1 sin BOM como ANSI y
# corrompe tildes/rayas largas, rompiendo el parser.

function Select-Menu {
    param([string]$Title, [string[]]$Options)
    $index = 0
    while ($true) {
        Clear-Host
        Write-Host "$Title`n" -ForegroundColor Yellow
        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $index) { Write-Host "  > $($Options[$i])" -ForegroundColor Cyan }
            else { Write-Host "    $($Options[$i])" }
        }
        Write-Host "`n(Flechas para moverte, Enter para elegir)"
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.VirtualKeyCode) {
            38 { if ($index -gt 0) { $index-- } }              # arriba
            40 { if ($index -lt $Options.Count - 1) { $index++ } } # abajo
            13 { return $index }                                # enter
        }
    }
}

$modo = Select-Menu -Title "Modo de instalacion:" -Options @("Testing (debug, rapido)", "Release")
$esRelease = $modo -eq 1

Write-Host "`nBuscando dispositivos..." -ForegroundColor Yellow
$devicesJson = flutter devices --machine | Out-String
$devices = $devicesJson | ConvertFrom-Json

if (-not $devices -or $devices.Count -eq 0) {
    Write-Host "No se encontro ningun dispositivo. Conecta uno y reintenta." -ForegroundColor Red
    exit 1
}

$labels = $devices | ForEach-Object { "$($_.name) [$($_.id)] - $($_.targetPlatform)" }
$choice = Select-Menu -Title "Elegi el dispositivo:" -Options $labels
$device = $devices[$choice]

Clear-Host
$modoTexto = if ($esRelease) { "RELEASE" } else { "TESTING (debug)" }
Write-Host "Instalando en $($device.name) - modo $modoTexto`n" -ForegroundColor Green

if ($esRelease) {
    flutter run -d $device.id --release
} else {
    flutter run -d $device.id
}
