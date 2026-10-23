# Architecture

```
                 Réseau host-only 192.168.56.0/24  (domaine infraready.lab)

   +----------------------+     +----------------------+     +----------------------------+
   | dc01 (Windows 2022)  |     | lin01 (Linux)        |     | mon01 (Linux)              |
   | 192.168.56.10        |     | 192.168.56.20        |     | 192.168.56.30              |
   | AD DS, DNS           |     | nginx :80, /data     |     | Ansible, Prometheus :9090  |
   | WinRM :5986          |     | SSH :22              |     | Grafana :3000, SSH :22     |
   | windows_exporter     |     | node_exporter :9100  |     | node_exporter :9100        |
   |   :9182              |     |                      |     |                            |
   +----------+-----------+     +----------+-----------+     +-------------+--------------+
              ^   DNS (53) depuis lin01/mon01   ^   SSH (22) / WinRM (5986) depuis mon01
              +--------------------------------+-----------------------------+
```

## Rôles
- **dc01** : annuaire AD DS, DNS du domaine, cible Windows d'Ansible, exporté par windows_exporter.
- **lin01** : serveur applicatif (Web), stockage de test monté sur `/data`, cible d'Ansible.
- **mon01** : poste d'administration (Ansible), supervision (Prometheus/Grafana).

## Flux
| Source | Destination | Port | Usage |
|---|---|---|---|
| mon01 | lin01, mon01 | 22/TCP | Ansible (SSH) |
| mon01 | dc01 | 5986/TCP | Ansible (WinRM HTTPS) |
| mon01 (Prometheus) | lin01, mon01 | 9100/TCP | métriques Linux |
| mon01 (Prometheus) | dc01 | 9182/TCP | métriques Windows |
| lin01, mon01 | dc01 | 53/TCP+UDP | résolution DNS |
| Poste admin | mon01 | 3000, 9090 | Grafana, Prometheus |

Processus, services, comptes et permissions utiles : voir `docs/securite.md` et `docs/maintenance.md`.
