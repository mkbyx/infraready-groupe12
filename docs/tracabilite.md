# Traçabilité exigences → opérations → preuves

| Tâche | Exigence | Fichier / commande | Preuve (dans `evidence/`) |
|---|---|---|---|
| A | VM, IP, réseau, DNS, schéma | docs/architecture.md, docs/adressage-ip.md | `[À COMPLÉTER]` |
| B | AD DS, domaine, DNS, groupes, comptes, journaux | playbooks/windows.yml | `[À COMPLÉTER]` |
| C | Comptes, services, Web, stockage, journaux | playbooks/linux.yml | `[À COMPLÉTER]` |
| D | Inventaire, variables, playbooks Linux/Windows, idempotence | inventory/, group_vars/, playbooks/ | 1re et 2e exécution (changed=0) |
| E | Maintenance, MAJ Linux/Windows, précautions | playbooks/maintenance.yml, docs/maintenance.md | `[À COMPLÉTER]` |
| F | Prometheus, exporters, Grafana, seuil/alerte | monitoring/, playbooks/monitoring.yml | dashboard + alerte |
| G | Dépôt, commits, workflow CI | .github/workflows/validation.yml | run GitHub Actions vert |
| H | Diagnostic d'incident | docs/incident.md | rapport complété |
