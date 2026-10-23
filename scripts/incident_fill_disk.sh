#!/usr/bin/env bash
# Tache H - Incident CONTROLE ET REVERSIBLE : remplit /data avec un fichier de test.
# Usage : sudo ./incident_fill_disk.sh create <taille_Mo>   |   sudo ./incident_fill_disk.sh clean
set -euo pipefail
TARGET=/data/incident_test.bin
case "${1:-}" in
  create)
    mountpoint -q /data || { echo "/data n'est pas monte : arret"; exit 1; }
    fallocate -l "${2:?taille en Mo}M" "$TARGET"; df -h /data ;;
  clean)
    rm -f "$TARGET"; df -h /data ;;
  *) echo "Usage: $0 create <Mo> | clean"; exit 1 ;;
esac
