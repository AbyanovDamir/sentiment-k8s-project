#!/usr/bin/env bash
set -euo pipefail
profile=${PROFILE:-sentiment-lab}
minikube start -p "$profile" --driver=docker --container-runtime=containerd \
  --kubernetes-version="${KUBERNETES_VERSION:-v1.37.0}" \
  --cpus="${MINIKUBE_CPUS:-2}" --memory="${MINIKUBE_MEMORY:-2200}" --nodes=2
minikube -p "$profile" addons enable metrics-server
minikube -p "$profile" addons enable ingress
kubectl --context "$profile" get nodes
