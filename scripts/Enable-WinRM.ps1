<#
.SYNOPSIS
  Active WinRM en HTTPS (certificat auto-signe) pour permettre a Ansible de gerer dc01.
  A executer UNE FOIS, en administrateur, sur la VM Windows du laboratoire.
.NOTES
  Limite connue : certificat auto-signe, usage laboratoire uniquement.
#>
$ErrorActionPreference = "Stop"
$hostName = $env:COMPUTERNAME
Enable-PSRemoting -Force -SkipNetworkProfileCheck

$existing = Get-ChildItem WSMan:\localhost\Listener | Where-Object { $_.Keys -contains "Transport=HTTPS" }
if (-not $existing) {
    $cert = New-SelfSignedCertificate -DnsName $hostName -CertStoreLocation Cert:\LocalMachine\My
    New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force | Out-Null
}
# Pare-feu : 5986 uniquement depuis le reseau du labo
if (-not (Get-NetFirewallRule -DisplayName "WinRM HTTPS Lab" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "WinRM HTTPS Lab" -Direction Inbound -Protocol TCP `
        -LocalPort 5986 -RemoteAddress 192.168.56.0/24 -Action Allow | Out-Null
}
# Pas d'authentification basique ni de trafic non chiffre
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $false
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $false
Write-Host "WinRM HTTPS actif sur le port 5986."
