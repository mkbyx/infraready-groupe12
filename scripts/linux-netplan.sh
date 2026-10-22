#!/usr/bin/env bash
# Usage : sudo ./linux-netplan.sh <interface> <ip/cidr> <passerelle|none> <dns>
# Ex    : sudo ./linux-netplan.sh ens33 192.168.50.20/24 none 192.168.50.10
# Utilise "netplan try" : retour automatique si vous ne confirmez pas.
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Lancer avec sudo"; exit 1; }
[ $# -eq 4 ] || { echo "Usage: $0 <iface> <ip/cidr> <gw|none> <dns>"; exit 1; }
IFACE=$1; ADDR=$2; GW=$3; DNS=$4
ip link show "$IFACE" >/dev/null 2>&1 || { echo "Interface $IFACE introuvable (ip -br link)"; exit 1; }

cp -a /etc/netplan "/etc/netplan.backup-$(date +%F-%H%M%S)"
{
  echo "network:"
  echo "  version: 2"
  echo "  ethernets:"
  echo "    $IFACE:"
  echo "      dhcp4: false"
  echo "      addresses: [$ADDR]"
  if [ "$GW" != "none" ]; then
    echo "      routes:"
    echo "        - to: default"
    echo "          via: $GW"
  fi
  echo "      nameservers:"
  echo "        addresses: [$DNS]"
} > /etc/netplan/01-lab.yaml
chmod 600 /etc/netplan/01-lab.yaml
echo "Fichier genere : /etc/netplan/01-lab.yaml"
echo "ATTENTION : d'autres fichiers de /etc/netplan peuvent entrer en conflit (ex: 50-cloud-init.yaml)."
netplan try
