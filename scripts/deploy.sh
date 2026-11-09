#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
profile=${PROFILE:-sentiment-lab}
kubectl --context "$profile" apply -f k8s/namespace.yaml
kubectl --context "$profile" -n sentiment apply \
  -f k8s/deployment.yaml -f k8s/service.yaml -f k8s/ingress.yaml -f k8s/hpa.yaml
kubectl --context "$profile" -n sentiment rollout status deploy/sentiment --timeout=8m
