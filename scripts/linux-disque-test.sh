#!/usr/bin/env bash
# Usage : sudo ./linux-disque-test.sh                -> inventaire seul
#         sudo ./linux-disque-test.sh /dev/sdb       -> formate CE disque apres confirmation
set -euo pipefail
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
[ $# -eq 1 ] || { echo "Inventaire seul. Relancer avec le disque cible pour le preparer."; exit 0; }
DEV=$1
[ -b "$DEV" ] || { echo "$DEV n'est pas un peripherique bloc"; exit 1; }
if lsblk -no MOUNTPOINTS "$DEV" | grep -q . || lsblk -no TYPE "$DEV" | grep -q part; then
  echo "$DEV contient deja des partitions ou est monte : ARRET."; exit 1
fi
echo "Cible : $DEV ($(lsblk -dno SIZE,MODEL "$DEV"))"
read -rp "Tapez le nom du peripherique pour confirmer ($DEV) : " C
[ "$C" = "$DEV" ] || { echo "Abandon."; exit 1; }
parted -s "$DEV" mklabel gpt mkpart labdata ext4 1MiB 100%
sleep 1
PART="${DEV}1"; [[ "$DEV" == *nvme* ]] && PART="${DEV}p1"
mkfs.ext4 -L labdata "$PART"
mkdir -p /mnt/labdata
UUID=$(blkid -s UUID -o value "$PART")
echo "UUID=$UUID /mnt/labdata ext4 defaults,nofail 0 2" >> /etc/fstab
mount -a
findmnt /mnt/labdata
echo "UUID a documenter : $UUID"
