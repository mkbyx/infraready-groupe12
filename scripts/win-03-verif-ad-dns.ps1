<# WIN-DC01 etape 3 : verifications apres promotion + redirecteur DNS optionnel. #>
param([string]$Forwarder = "")   # ex: IP du resolveur autorise par le labo. Vide = aucun.
Get-ADDomain | Select-Object DNSRoot,NetBIOSName,DomainMode
Get-ADForest | Select-Object Name,ForestMode
Get-Service DNS,NTDS | Format-Table Name,Status
Get-DnsServerZone
Resolve-DnsName "WIN-DC01.infraready.test"
if ($Forwarder) { Add-DnsServerForwarder -IPAddress $Forwarder }
