# Sécurité

| Règle | Mise en œuvre |
|---|---|
| Moindre privilège | Compte de service `ansible` (sudo ciblé), comptes de test sans droits d'admin, groupes AD GG_Admins_Lab / GG_Users_Lab |
| Accès d'administration | SSH par clé uniquement, WinRM HTTPS (Basic et non chiffré désactivés) |
| Secrets | Ansible Vault (`group_vars/windows/vault.yml` chiffré), `.env` Grafana non versionné, `no_log` sur les tâches de mots de passe |
| Scripts / playbooks | `set -euo pipefail`, `assert` avant opérations dangereuses, `--check` possible |
| Traçabilité | Commits Git explicites, PR, journaux d'exécution CI |
| Sauvegardes | Snapshot de chaque VM avant : promotion AD, mise à jour majeure, opération sur disque |
| Vérification des cibles | `lsblk -f` et `assert` (pas le disque racine) ; confirmation `storage_confirm=yes` |
| Ports ouverts | 22, 80 (lin01), 5986/9182 (dc01, restreints à 192.168.56.0/24), 9100, 9090, 3000 |
| Secrets en clair | Interdit – contrôle automatique dans le workflow |
| Modifications perturbatrices | Documentées dans `docs/maintenance.md` et `docs/incident.md` |

## Contrôles à réaliser (preuves)
```bash
sudo ss -tlnp                 # ports à l'écoute sur Linux
sudo ufw status               # si pare-feu activé (autoriser 22, 80, 9100 depuis le réseau du labo)
ansible-vault view group_vars/windows/vault.yml   # doit demander le mot de passe
git log --oneline | head
```
Limites connues : certificat WinRM auto-signé ; pas d'authentification multifacteur ; pas de durcissement CIS complet.
