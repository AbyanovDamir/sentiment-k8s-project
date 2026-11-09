#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
profile=${PROFILE:-sentiment-lab}
k() { kubectl --context "$profile" -n sentiment "$@"; }

secret=$(k get secret sentiment-grafana-admin --ignore-not-found -o name)
if [[ -z "$secret" ]]; then
  k create secret generic sentiment-grafana-admin --from-literal=admin-user=admin \
    --from-literal=admin-password="$(openssl rand -hex 18)"
fi

helm upgrade --install sentiment-monitor oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --version 93.1.0 --kube-context "$profile" -n sentiment -f monitoring/helm-values.yaml --timeout 10m

k apply -f monitoring/servicemonitor.yaml
k create configmap sentiment-dashboard --from-file=sentiment.json=monitoring/grafana-dashboard.json \
  --dry-run=client -o yaml |
  k label --local -f - grafana_dashboard=1 -o yaml |
  k apply -f -
