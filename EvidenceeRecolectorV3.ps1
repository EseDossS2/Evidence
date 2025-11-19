<#
.SYNOPSIS
  Evidence Collector V3 - Recolecta evidencia forense del sistema local.
.DESCRIPTION
  Recolecta procesos, puertos, servicios, tareas, registro, programas instalados,
  configuraciones de red, eventos y archivos recientes. Todo se guarda en un ZIP
  para posterior análisis.
#>

# ================= CONFIGURACIÓN =================
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$basePath = "C:\Users\User\Documents\Scripts-Seguridad\Security--\evidence"
$outFolder = Join-Path $basePath "SecurityScan_$timestamp"
$zipPath = "$basePath\SecurityScan_$timestamp.zip"

# ================= FUNCIONES =====================

function Safe-Export {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        $Data,
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        $Data | Out-File -FilePath $Path -Encoding UTF8 -Force
    }
    catch {
        Write-Host "[!] Error exportando `${Name}: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ================= INICIO ========================
try {
    Write-Host "[*] Iniciando recoleccion de evidencias: $timestamp" -ForegroundColor Cyan

    if (-not (Test-Path $basePath)) {
        New-Item -Path $basePath -ItemType Directory | Out-Null
    }

    if (-not (Test-Path $outFolder)) {
        New-Item -Path $outFolder -ItemType Directory | Out-Null
    }

    # --- 1. Procesos ---
    Write-Host "[1/12] Recolectando procesos..."
    Get-WmiObject Win32_Process | Select-Object Name, ProcessId, ExecutablePath, CommandLine |
        Export-Csv -Path "$outFolder\procesos.csv" -NoTypeInformation -Encoding UTF8

    # --- 2. Puertos ---
    Write-Host "[2/12] Recolectando puertos en escucha..."
    netstat -ano | Out-File "$outFolder\puertos.txt" -Encoding UTF8

    # --- 3. Servicios ---
    Write-Host "[3/12] Recolectando servicios..."
    Get-Service | Select-Object Name, DisplayName, Status, StartType |
        Export-Csv -Path "$outFolder\servicios.csv" -NoTypeInformation -Encoding UTF8

    # --- 4. Tareas programadas ---
    Write-Host "[4/12] Recolectando tareas programadas..."
    schtasks /query /fo LIST /v | Out-File "$outFolder\tareas.txt" -Encoding UTF8

    # --- 5. Claves Run del registro ---
    Write-Host "[5/12] Recolectando claves Run..."
    $runKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    )
    foreach ($key in $runKeys) {
        Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
            Out-File "$outFolder\RunKeys.txt" -Append -Encoding UTF8
    }

    # --- 6. Programas instalados ---
    Write-Host "[6/12] Recolectando programas instalados..."
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
        Export-Csv -Path "$outFolder\programas.csv" -NoTypeInformation -Encoding UTF8

    # --- 7. Adaptadores de red ---
    Write-Host "[7/12] Recolectando adaptadores e IPs..."
    Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed |
        Export-Csv -Path "$outFolder\net_adapters.csv" -NoTypeInformation -Encoding UTF8
    ipconfig /all | Out-File "$outFolder\ipconfig.txt" -Encoding UTF8

    # --- 8. Firewall ---
    Write-Host "[8/12] Recolectando reglas de firewall..."
    Get-NetFirewallRule | Select DisplayName, Direction, Action, Enabled |
        Export-Csv -Path "$outFolder\firewall.csv" -NoTypeInformation -Encoding UTF8

    # --- 9. Eventos ---
    Write-Host "[9/12] Exportando eventos 4624/4625..."
    Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4625} -MaxEvents 100 |
        Export-Csv -Path "$outFolder\eventos_logon.csv" -NoTypeInformation -Encoding UTF8

    # --- 10. Archivos recientes ---
    Write-Host "[10/12] Listando archivos recientes..."
    Get-ChildItem "$env:TEMP" -Recurse -ErrorAction SilentlyContinue |
        Select-Object FullName, LastWriteTime |
        Export-Csv -Path "$outFolder\archivos_temp.csv" -NoTypeInformation -Encoding UTF8
    Get-ChildItem "$env:USERPROFILE\Downloads" -ErrorAction SilentlyContinue |
        Select-Object FullName, LastWriteTime |
        Export-Csv -Path "$outFolder\descargas.csv" -NoTypeInformation -Encoding UTF8

    # --- 11. Compactar ZIP ---
    Write-Host "[11/12] Creando archivo ZIP..."
    try {
        Compress-Archive -Path "$outFolder\*" -DestinationPath $zipPath -Force
        Write-Host ("[ok] ZIP creado en: {0}" -f $zipPath) -ForegroundColor Green
    }
    catch {
        Write-Host ("[x] Error creando ZIP: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }

    # --- 12. Final ---
    Write-Host "[ok] Recolección finalizada correctamente." -ForegroundColor Green
}
catch {
    Write-Host ("[x] Error crítico: {0}" -f $_.Exception.Message) -ForegroundColor Red
}