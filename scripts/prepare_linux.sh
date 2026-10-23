#!/usr/bin/env bash
# Prepare un serveur Linux Debian/Ubuntu pour Ansible (Tache C - preparation).
# Usage : sudo ./prepare_linux.sh "<cle publique ssh de l'utilisateur ansible>"
set -euo pipefail

PUBKEY="${1:?Usage: $0 '<cle publique ssh>'}"

id ansible &>/dev/null || useradd -m -s /bin/bash ansible
install -d -m 700 -o ansible -g ansible /home/ansible/.ssh
echo "$PUBKEY" > /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys

# Moindre privilege : sudo sans mot de passe pour ce compte de service uniquement
echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
visudo -cf /etc/sudoers.d/ansible

# Etat initial (a consigner dans les preuves)
hostnamectl; ip -br a; lsblk -f; df -h
