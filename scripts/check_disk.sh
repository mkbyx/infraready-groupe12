#!/usr/bin/env bash
# Affiche les systemes de fichiers depassant un seuil (defaut 80 %).
# Usage : ./check_disk.sh [seuil]
set -euo pipefail
THRESHOLD="${1:-80}"
rc=0
while read -r use mount; do
  pct="${use%\%}"
  if [ "$pct" -ge "$THRESHOLD" ]; then
    echo "ALERTE: $mount a ${pct}% (seuil ${THRESHOLD}%)"; rc=1
  fi
done < <(df -P -x tmpfs -x devtmpfs | awk 'NR>1 {print $5, $6}')
[ "$rc" -eq 0 ] && echo "OK: aucun volume au-dessus de ${THRESHOLD}%"
exit "$rc"
