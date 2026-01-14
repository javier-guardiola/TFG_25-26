<#
============================================================
Title           : Set-NTPSync
Description     : Automatiza la sincronización horaria con servidores NTP.
Author          : Javier Guardiola
Date            : 20251011
Version         : 1.0
Dependencies    : Windows Time Service (w32time)
============================================================
#>

# --- Comprobación de Privilegios (Requisito para servicios) ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Se requieren privilegios de Administrador."
    exit 1
}

Write-Host "--- Verificando dependencias del sistema ---" -ForegroundColor Cyan

# --- Gestión Automática de la Dependencia (w32time) ---
$timeService = Get-Service -Name w32time
if ($timeService.StartType -eq 'Disabled') {
    Write-Host "[!] El servicio de tiempo estaba deshabilitado. Activando..." -ForegroundColor Yellow
    Set-Service -Name w32time -StartupType Automatic
}

# --- Ejecución de Sincronización ---
try {
    Write-Host "[1/3] Reiniciando servicio..."
    Restart-Service -Name w32time -Force

    Write-Host "[2/3] Configurando servidores externos (pool.ntp.org)..."
    w32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org" /syncfromflags:manual /reliable:YES /update

    Write-Host "[3/3] Forzando resincronización..." -NoNewline
    w32tm /resync | Out-Null
    Write-Host " [OK]" -ForegroundColor Green

    Write-Host "`nSincronización completada exitosamente." -ForegroundColor Cyan
} catch {
    Write-Error "Error en la sincronización: $($_.Exception.Message)"
}