# InfraReady – Administration Linux et Windows

Projet fil rouge Bachelor 3 – Cybersécurité, Informatique Infrastructure et Réseau.
Laboratoire de 3 machines virtuelles administrées et automatisées avec Ansible, supervisées avec Prometheus/Grafana, validées par GitHub Actions.

> **État du dépôt** : les fichiers fournis sont une base prête à adapter. Les sections `[À COMPLÉTER]`
> (captures, sorties de commandes, résultats réels) doivent être remplies **après** exécution dans votre labo.

## Architecture

| VM | Rôle | OS | IP |
|---|---|---|---|
| dc01 | Contrôleur de domaine AD DS + DNS, cible Ansible Windows | Windows Server 2022 | 192.168.56.10 |
| lin01 | Serveur Linux : Web (nginx), stockage, cible Ansible | Debian 12 / Ubuntu 22.04+ | 192.168.56.20 |
| mon01 | Nœud de contrôle Ansible + Prometheus + Grafana | Debian 12 / Ubuntu 22.04+ | 192.168.56.30 |

Domaine : `infraready.lab` – Réseau : host-only `192.168.56.0/24`. Voir `docs/architecture.md` et `docs/adressage-ip.md`.

## Prérequis

- Hyperviseur (VirtualBox/VMware/Hyper-V) avec un réseau host-only 192.168.56.0/24 (+ une carte NAT si accès Internet nécessaire).
- Sur mon01 : `python3`, `pip`, `ansible-core`, `pywinrm`, `git`.
- Un disque virtuel **de test** vide de 2 Go ajouté à lin01 (`/dev/sdb`, à vérifier avec `lsblk`).
- Accès SSH par clé de mon01 vers lin01 et mon01 (utilisateur `ansible`).
- WinRM HTTPS activé sur dc01 (`scripts/Enable-WinRM.ps1`).

## Installation (ordre recommandé)

```bash
# 1. Cloner et installer les dépendances (sur mon01)
git clone <url-du-depot> infraready && cd infraready
pip install ansible-core ansible-lint yamllint pywinrm
ansible-galaxy collection install -r requirements.yml

# 2. Préparer les secrets (jamais en clair dans Git)
cp group_vars/windows/vault.yml.example group_vars/windows/vault.yml
# éditer les valeurs, puis :
ansible-vault encrypt group_vars/windows/vault.yml

# 3. Vérifier les connexions
ansible all -m ping --ask-vault-pass            # Linux
ansible windows -m ansible.windows.win_ping --ask-vault-pass

# 4. Configuration (test à blanc puis réel)
ansible-playbook playbooks/windows.yml --ask-vault-pass
ansible-playbook playbooks/linux.yml --check --diff
ansible-playbook playbooks/linux.yml -e storage_confirm=yes   # après vérification de lsblk
ansible-playbook playbooks/monitoring.yml

# 5. Contrôles après exécution + 2e exécution (idempotence : changed=0 attendu)
ansible-playbook playbooks/linux.yml -e storage_confirm=yes
ansible-playbook playbooks/verification.yml --ask-vault-pass

# 6. Maintenance (redémarrage désactivé par défaut)
ansible-playbook playbooks/maintenance.yml --check
ansible-playbook playbooks/maintenance.yml --ask-vault-pass
```

Supervision : sur mon01, `cp monitoring/.env.example /opt/monitoring/.env`, définir le mot de passe Grafana, puis relancer `playbooks/monitoring.yml`.
Prometheus : `http://192.168.56.30:9090` – Grafana : `http://192.168.56.30:3000`.

## Organisation du dépôt

```
docs/         architecture, adressage, sécurité, maintenance, incident, traçabilité, dossier technique
inventory/    hosts.yml
group_vars/   variables communes, Linux, Windows (Vault)
playbooks/    linux, windows, maintenance, verification, monitoring
monitoring/   prometheus.yml, alerts.yml, docker-compose.yml, dashboards Grafana
scripts/      Enable-WinRM.ps1, prepare_linux.sh, check_disk.sh, incident_fill_disk.sh
evidence/     preuves (captures, sorties) – sans aucun secret
.github/workflows/validation.yml   CI : lint, syntaxe, JSON, règles Prometheus, anti-secrets
```

## Sécurité (résumé)

Moindre privilège, clés SSH, secrets dans Ansible Vault / GitHub Secrets, WinRM HTTPS, ports limités au réseau du labo,
opérations sur disque bloquées sans confirmation explicite (`storage_confirm=yes`). Détails : `docs/securite.md`.

## Limites connues

- Certificat WinRM auto-signé (validation désactivée en labo).
- Pas de WSUS : mises à jour Windows via mécanisme natif.
- Une seule alerte démontrée par Grafana/Prometheus, sans Alertmanager (notification non configurée).
- Version de `windows_exporter` à vérifier avant usage.
- Les playbooks n'ont pas été exécutés sur le labo de l'étudiant : tests et preuves à produire.
