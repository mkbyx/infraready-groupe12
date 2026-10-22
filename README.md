# InfraReady — plan de réalisation

**[MANUEL]** = vous le faites à la main (compte, décision, interface graphique).
**[AUTO]** = un script ou un playbook de ce dépôt s'en charge.
Les adresses (192.168.50.0/24) sont des exemples : à vérifier avant tout.

## Phase 0 — Préparation de l'hôte
1. **[MANUEL]** Vérifier VT-x/AMD-V, 16 Go RAM minimum, espace disque libre.
2. **[MANUEL]** Choisir le sous-réseau du labo, vérifier qu'il ne chevauche ni LAN, ni VPN, ni réseaux VMware. Si conflit, changer partout (inventory, prometheus.yml, scripts).
3. **[MANUEL]** Compte Broadcom, téléchargement et installation de VMware Workstation Pro.
4. **[MANUEL]** Dans VMware : créer un réseau Host-only ou Custom (désactiver le DHCP VMware si IP statiques).
5. **[MANUEL]** Télécharger l'ISO Ubuntu Server 24.04 LTS (vérifier SHA256) et l'ISO Windows Server 2025 Evaluation (formulaire Microsoft).
6. **[MANUEL]** Créer un compte GitHub (MFA), un dépôt privé `infraready-groupeXX`.

## Phase 1 — Création des VM
7. **[MANUEL]** Créer WIN-DC01 (2 vCPU, 4-6 Go, 50 Go), LINUX01 (2 vCPU, 2-4 Go, 30 Go), OPS01 (2-4 vCPU, 4-8 Go, 50 Go), toutes sur le réseau privé.
8. **[MANUEL]** Installer Ubuntu (LINUX01, OPS01) : utilisateur nominatif `adminlab` avec sudo, OpenSSH Server coché.
9. **[MANUEL]** Installer Windows Server 2025 Standard Evaluation, Desktop Experience, mot de passe Administrateur fort (gestionnaire de mots de passe).
10. **[MANUEL]** Pendant l'installation, garder un accès Internet (NAT) pour les mises à jour.

## Phase 2 — Réseau et noms
11. **[AUTO]** Linux : `sudo ./scripts/linux-netplan.sh <iface> 192.168.50.20/24 none 192.168.50.10` (LINUX01) puis `... 192.168.50.30/24 ...` (OPS01). Confirmer le `netplan try`. Avant que le DNS du DC existe, garder temporairement un DNS qui permet les mises à jour.
12. **[AUTO]** Windows : `Get-NetAdapter` puis `.\scripts\win-01-reseau-nom.ps1 -InterfaceAlias "Ethernet0"` (redémarre).
13. **[MANUEL]** Windows Update jusqu'à ne plus avoir de redémarrage en attente.
14. **[MANUEL]** Snapshot VMware `00-installation-propre` sur chaque VM.

## Phase 3 — Active Directory + DNS (WIN-DC01)
15. **[AUTO]** `.\scripts\win-02-promotion-addc.ps1` (le mot de passe DSRM est demandé au clavier).
16. **[MANUEL]** Noter le mot de passe DSRM dans le gestionnaire autorisé.
17. **[AUTO]** Après redémarrage : `.\scripts\win-03-verif-ad-dns.ps1` (option `-Forwarder <IP>` si le labo l'autorise).
18. **[AUTO]** Repasser LINUX01/OPS01 sur le DNS 192.168.50.10 (relancer `linux-netplan.sh`), puis `getent hosts WIN-DC01.infraready.test`.

## Phase 4 — Ansible depuis OPS01
19. **[AUTO]** Sur OPS01 : `sudo apt update && sudo apt install -y ansible git openssh-client python3`.
20. **[MANUEL]** Cloner ce dépôt sur OPS01, générer une clé SSH dédiée : `ssh-keygen -t ed25519 -f ~/.ssh/id_lab`, puis `ssh-copy-id -i ~/.ssh/id_lab.pub adminlab@192.168.50.20` (ajouter `ansible_ssh_private_key_file=~/.ssh/id_lab` dans l'inventaire).
21. **[AUTO]** `ansible linux -m ping` (test connexion + Python, pas ICMP).
22. **[AUTO]** `ansible-playbook playbooks/01-base-linux.yml --ask-become-pass`
23. **[MANUEL]** Redémarrer si le playbook l'indique, vérifier les services.

## Phase 5 — Supervision
24. **[AUTO]** `ansible-playbook playbooks/02-node-exporter.yml --ask-become-pass` (LINUX01, port 9100).
25. **[AUTO]** `ansible-playbook playbooks/03-ops-monitoring.yml --ask-become-pass` (Prometheus + Grafana + source de données).
26. **[AUTO]** WIN-DC01 : `.\scripts\win-04-windows-exporter.ps1` (MSI silencieux + pare-feu limité à OPS01).
27. **[MANUEL]** Vérifier Status > Targets dans Prometheus (http://192.168.50.30:9090) : 3 cibles UP. Si DOWN : `curl http://192.168.50.20:9100/metrics`, pare-feu, routes, journaux.
28. **[MANUEL]** Grafana (http://192.168.50.30:3000) : changer le mot de passe admin initial, créer le tableau de bord (CPU, mémoire, disque, état des cibles), noter les requêtes PromQL, faire les captures.

## Phase 6 — Stockage
29. **[MANUEL]** Ajouter un nouveau disque virtuel à une VM de test dans VMware.
30. **[AUTO]** Inventaire : `sudo ./scripts/linux-disque-test.sh` ou `.\scripts\win-06-disque-inventaire.ps1`.
31. **[MANUEL]** Identifier le disque (taille/modèle), faire valider par le formateur.
32. **[AUTO]** Linux : `sudo ./scripts/linux-disque-test.sh /dev/sdX` (confirmation demandée). Windows : les commandes sont en commentaire dans le script, à lancer après validation.

## Phase 7 — Dépôt Git et CI
33. **[MANUEL]** Configurer `git config user.name/email`, vérifier que `.gitignore` est en place, aucun secret commité.
34. **[AUTO]** `git add . && git commit -m "Infra initiale" && git push` : le workflow `validate.yml` se lance seul.
35. **[MANUEL]** Vérifier l'exécution sur un push ET sur une pull request.

## Phase 8 — Preuves et documentation
36. **[AUTO]** `./scripts/verify-linux.sh` (LINUX01, OPS01) et `.\scripts\win-05-verif.ps1` (WIN-DC01) : sorties dans `evidence/`.
37. **[MANUEL]** Remplir `docs/gabarits.md` : inventaire par VM, fiches de test T-01 à T-05, journal de changement. Interpréter les résultats (un ping qui échoue ne prouve rien seul).
38. **[MANUEL]** Mises à jour approuvées, snapshots nommés et datés, suppression des snapshots inutiles. Un snapshot n'est pas une sauvegarde.
39. **[MANUEL]** Cocher la checklist de fin du kit (chapitre 20).

## Points de vigilance
- Ne jamais mettre de mot de passe en clair dans un script, l'inventaire ou Git (Ansible Vault si besoin).
- Pas de règle « autoriser tout » : diagnostiquer le flux précis.
- Vérifier les versions de node_exporter et windows_exporter avant de lancer les scripts.
- Ansible vers Windows (WinRM) n'est pas couvert ici : non activé par défaut dans le kit.
