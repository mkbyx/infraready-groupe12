<#
 WIN-DC01 etape 4 : windows_exporter (MSI officiel, installation silencieuse) + pare-feu limite a OPS01.
 Verifier la version sur https://github.com/prometheus-community/windows_exporter/releases
#>
param(
  [string]$Version = "0.30.0",
  [int]$Port = 9182,
  [string]$OpsIP = "192.168.50.30"
)
$ErrorActionPreference = "Stop"
$msi = "$env:TEMP\windows_exporter-$Version-amd64.msi"
$url = "https://github.com/prometheus-community/windows_exporter/releases/download/v$Version/windows_exporter-$Version-amd64.msi"
Invoke-WebRequest -Uri $url -OutFile $msi
Get-FileHash $msi -Algorithm SHA256   # comparer avec la somme publiee sur la page de release

$collectors = "cpu,memory,logical_disk,net,os,service,system"
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$msi`" ENABLED_COLLECTORS=$collectors LISTEN_PORT=$Port /qn"

if (-not (Get-NetFirewallRule -DisplayName "windows_exporter (OPS01)" -ErrorAction SilentlyContinue)) {
  New-NetFirewallRule -DisplayName "windows_exporter (OPS01)" -Direction Inbound -Protocol TCP `
    -LocalPort $Port -RemoteAddress $OpsIP -Action Allow | Out-Null
}
Get-Service windows_exporter | Format-Table Name,Status
Get-NetTCPConnection -LocalPort $Port -State Listen
Write-Host "Version=$Version Collecteurs=$collectors Port=$Port Pare-feu=OPS01 ($OpsIP)"
