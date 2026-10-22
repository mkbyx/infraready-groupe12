# Fiche d'inventaire (une par VM)
| Champ | Valeur |
|---|---|
| Nom VM / hostname | |
| OS / version / édition | |
| CPU / RAM / disque | |
| Réseau virtuel / IP / masque / passerelle | |
| DNS / domaine | |
| Rôle et services attendus | |
| Ports entrants autorisés et justification | |
| Mises à jour et snapshot de référence | |
| Tests effectués / résultat / date | |
| Écarts et décisions validées | |

# Fiche de test
| ID | Objectif | Commande | Résultat attendu / preuve |
|---|---|---|---|
| T-01 | Adresse IP | `ip -br a` / `ipconfig /all` | Conforme au plan |
| T-02 | Connectivité | `ping` / `Test-NetConnection` | Interpréter ICMP et port |
| T-03 | DNS | `getent hosts` / `Resolve-DnsName` | Nom résolu vers l'IP attendue |
| T-04 | Service | `systemctl` / `Get-Service` | Actif + port en écoute |
| T-05 | Supervision | Prometheus > Status > Targets | Cible UP |

# Journal de changement
Date/heure | opérateur | système | état initial | changement | risque | validation préalable | résultat | contrôle après | retour arrière | preuve
