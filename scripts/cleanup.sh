#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
profile=${PROFILE:-sentiment-lab}
k() { kubectl --context "$profile" -n sentiment "$@"; }

if [[ -z "$(k get namespace sentiment --ignore-not-found -o name)" ]]; then
  exit 0
fi
if [[ -n "$(k get crd servicemonitors.monitoring.coreos.com --ignore-not-found -o name)" ]]; then
  k delete -f monitoring/servicemonitor.yaml --ignore-not-found
fi
k delete configmap sentiment-dashboard --ignore-not-found
helm uninstall sentiment-monitor --kube-context "$profile" -n sentiment --ignore-not-found
k delete secret sentiment-grafana-admin --ignore-not-found
k delete -f k8s/hpa.yaml -f k8s/ingress.yaml -f k8s/service.yaml -f k8s/deployment.yaml --ignore-not-found
