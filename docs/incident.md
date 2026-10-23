# Rapport d'incident (modèle – Tâche H)

Binôme : `[À COMPLÉTER]` – Date : `[À COMPLÉTER]`

## Incident choisi (simple, contrôlé, réversible)
Exemple proposé : **disque proche du seuil** sur lin01 (`/data`).

## 1. Symptôme
Alerte `DisqueLinuxPresquePlein` dans Prometheus / panneau « Stockage Linux » à plus de 80 %. `[capture]`

## 2. Tests et journaux consultés
```bash
df -h /data
sudo du -xh /data --max-depth=1 | sort -h | tail
journalctl -p warning --since "30 min ago"
bash scripts/check_disk.sh 80
```
Sorties : `[À COMPLÉTER]`

## 3. Cause identifiée / hypothèse
Un fichier volumineux (`/data/incident_test.bin`) occupe l'espace. `[À ADAPTER selon vos observations]`

## 4. Correction appliquée
```bash
sudo scripts/incident_fill_disk.sh clean
```

## 5. Vérification du retour à la normale
`df -h /data` sous le seuil, alerte résolue dans Prometheus, panneau Grafana redescendu. `[captures]`

## Provocation de l'incident (réversible)
```bash
sudo scripts/incident_fill_disk.sh create 1500     # adapter à la taille du disque de test
```
Autres incidents possibles : service Linux/Windows arrêté, DNS incorrect, métriques absentes, playbook en échec.
