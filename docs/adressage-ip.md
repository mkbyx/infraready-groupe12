# Plan d'adressage IP

| Hôte | FQDN | IP | Masque | Passerelle | DNS |
|---|---|---|---|---|---|
| dc01 | dc01.infraready.lab | 192.168.56.10 | /24 | — | 127.0.0.1 (puis 192.168.56.10) |
| lin01 | lin01.infraready.lab | 192.168.56.20 | /24 | — | 192.168.56.10 |
| mon01 | mon01.infraready.lab | 192.168.56.30 | /24 | — | 192.168.56.10 |

Prérequis réseau avant `playbooks/windows.yml` : IP statique de dc01 configurée, nom d'hôte `dc01`, DNS pointant sur lui-même.
Les enregistrements A de lin01 et mon01 sont créés dans la zone `infraready.lab` (DNS Manager ou `Add-DnsServerResourceRecordA`).

## Tests de connectivité et DNS à consigner dans `evidence/`
```bash
ping -c 2 192.168.56.10 ; ping -c 2 192.168.56.20 ; ping -c 2 192.168.56.30
getent hosts dc01.infraready.lab        # depuis Linux
resolvectl status | grep -A2 "DNS Servers"
```
```powershell
Resolve-DnsName lin01.infraready.lab ; Test-NetConnection 192.168.56.20 -Port 22
```
Résultats : `[À COMPLÉTER]`
