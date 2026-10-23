# Procédure de maintenance et de mise à jour

## Avant toute intervention
1. Prévenir (fenêtre de maintenance), identifier les VM concernées.
2. **Snapshot** de chaque VM.
3. Vérifier l'espace disque (seuil 80 %) : `scripts/check_disk.sh`, ou le contrôle intégré à `maintenance.yml`.
4. Vérifier l'état des services : ssh, nginx (lin01) ; NTDS, DNS, Netlogon (dc01).
5. Simulation : `ansible-playbook playbooks/maintenance.yml --check`.

## Exécution
- **Linux** : `apt update` puis `upgrade: safe` + `autoremove` via `playbooks/maintenance.yml`.
- **Windows** : Windows Update natif (SecurityUpdates, CriticalUpdates) via `ansible.windows.win_updates`. Pas de WSUS (non obligatoire).
- Redémarrage **désactivé par défaut**. Pour l'autoriser : `-e maintenance_allow_reboot=true`.

## Précautions avant redémarrage / modification majeure
- Redémarrer dc01 **en dernier** (les autres hôtes dépendent de son DNS) ; attendre le retour de NTDS et DNS.
- Ne jamais redémarrer simultanément dc01 et mon01 (perte de supervision et d'administration).
- Vérifier `/var/run/reboot-required` (Linux) et l'état de mise à jour (Windows).
- Conserver le snapshot jusqu'à validation.

## Après intervention
`ansible-playbook playbooks/verification.yml`, contrôle des dashboards Grafana, suppression des snapshots devenus inutiles.

Résultats de la maintenance (sorties, dates) : `[À COMPLÉTER]`
