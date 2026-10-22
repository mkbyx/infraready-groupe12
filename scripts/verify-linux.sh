#!/usr/bin/env bash
# Collecte des preuves (chap. 15 + fiche de test). Sortie : evidence/<host>-<date>.txt
set -uo pipefail
OUT="evidence/$(hostname)-$(date +%F-%H%M).txt"
mkdir -p evidence
run() { echo -e "\n### $*" | tee -a "$OUT"; eval "$@" 2>&1 | tee -a "$OUT"; }

run hostnamectl
run ip -br address
run ip route
run resolvectl status
run getent hosts WIN-DC01.infraready.test
run ping -c 3 192.168.50.10
run "ss -lntup"
run systemctl --failed
run "journalctl -p warning -b --no-pager | tail -50"

if systemctl list-unit-files | grep -q '^node_exporter'; then
  run systemctl status node_exporter --no-pager
  run "curl -s http://localhost:9100/metrics | head -5"
fi
if systemctl list-unit-files | grep -q '^prometheus.service'; then
  run systemctl status prometheus --no-pager
  run "curl -s http://localhost:9090/api/v1/targets | python3 -c \"import sys,json; [print(t['scrapeUrl'], t['health']) for t in json.load(sys.stdin)['data']['activeTargets']]\""
fi
if systemctl list-unit-files | grep -q '^grafana-server'; then
  run systemctl status grafana-server --no-pager
  run "curl -s http://localhost:3000/api/health"
fi
echo -e "\nPreuves enregistrees dans $OUT"
