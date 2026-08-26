# instalar.ps1 — elegí modo (testing/release) y dispositivo con las flechas,
# y lanza `flutter run` con lo elegido. ponytail: menu de flechas hecho a mano
# con RawUI.ReadKey (sin dependencias nuevas) en vez de un modulo de consola.

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

$modo = Select-Menu -Title "Modo de instalación:" -Options @("Testing (debug, rápido)", "Release")
$esRelease = $modo -eq 1

Write-Host "`nBuscando dispositivos..." -ForegroundColor Yellow
$devicesJson = flutter devices --machine | Out-String
$devices = $devicesJson | ConvertFrom-Json

if (-not $devices -or $devices.Count -eq 0) {
    Write-Host "No se encontró ningún dispositivo. Conectá uno y reintentá." -ForegroundColor Red
    exit 1
}

$labels = $devices | ForEach-Object { "$($_.name) [$($_.id)] — $($_.targetPlatform)" }
$choice = Select-Menu -Title "Elegí el dispositivo:" -Options $labels
$device = $devices[$choice]

Clear-Host
$modoTexto = if ($esRelease) { "RELEASE" } else { "TESTING (debug)" }
Write-Host "Instalando en $($device.name) — modo $modoTexto`n" -ForegroundColor Green

if ($esRelease) {
    flutter run -d $device.id --release
} else {
    flutter run -d $device.id
}
