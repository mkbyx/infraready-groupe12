<# Collecte des preuves Windows -> evidence\<host>-<date>.txt #>
New-Item -ItemType Directory -Force evidence | Out-Null
$out = "evidence\$env:COMPUTERNAME-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"
& {
  "### hostname";         hostname
  "### ipconfig";         ipconfig /all
  "### route";            route print
  "### DNS";              Resolve-DnsName "WIN-DC01.infraready.test"
  "### Prometheus 9090";  Test-NetConnection 192.168.50.30 -Port 9090
  "### Services";         Get-Service DNS,NTDS,windows_exporter -ErrorAction SilentlyContinue | Format-Table Name,Status
  "### Ecoute 9182";      Get-NetTCPConnection -LocalPort 9182 -State Listen -ErrorAction SilentlyContinue
  "### Services arretes"; Get-Service | Where-Object Status -eq 'Stopped' | Select-Object -First 30
  "### Journal System";   Get-WinEvent -LogName System -MaxEvents 30 | Format-Table TimeCreated,Id,LevelDisplayName,Message -Wrap
} *>&1 | Tee-Object -FilePath $out
Write-Host "Preuves : $out"
