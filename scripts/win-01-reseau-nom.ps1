<#
 WIN-DC01 etape 1 : IP statique + renommage (redemarre la machine).
 PowerShell ADMINISTRATEUR. Verifier avant : Get-NetAdapter, plan IP, absence de conflit.
#>
param(
  [Parameter(Mandatory)][string]$InterfaceAlias,   # ex: Ethernet0 (voir Get-NetAdapter)
  [string]$IPAddress = "192.168.50.10",
  [int]$PrefixLength = 24,
  [string]$Gateway = "",                           # vide = pas de passerelle
  [string]$NewName = "WIN-DC01"
)
$ErrorActionPreference = "Stop"

if (-not (Get-NetAdapter -Name $InterfaceAlias -ErrorAction SilentlyContinue)) {
  throw "Interface '$InterfaceAlias' introuvable. Lancez Get-NetAdapter."
}
$existing = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.PrefixOrigin -ne "WellKnown" }
if ($existing) {
  Write-Warning "Adresse(s) deja presente(s) : $($existing.IPAddress -join ', ')"
  if ((Read-Host "Les supprimer ? (o/N)") -ne "o") { throw "Abandon." }
  $existing | Remove-NetIPAddress -Confirm:$false
}
Set-NetIPInterface -InterfaceAlias $InterfaceAlias -Dhcp Disabled

$p = @{ InterfaceAlias=$InterfaceAlias; IPAddress=$IPAddress; PrefixLength=$PrefixLength }
if ($Gateway) { $p.DefaultGateway = $Gateway }
New-NetIPAddress @p | Out-Null

# DNS : le serveur lui-meme (futur DNS du domaine)
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses 127.0.0.1

Get-NetIPConfiguration -InterfaceAlias $InterfaceAlias
if ($env:COMPUTERNAME -ne $NewName) { Rename-Computer -NewName $NewName -Restart }
