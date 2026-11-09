#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
step=${1:?evidence step required}
profile=${PROFILE:-sentiment-lab}
k() { kubectl --context "$profile" -n sentiment --request-timeout=30s "$@"; }
capture() {
  echo "Sentiment API | $(hostname) | $(date -Is)"
  case "$step" in
    01-cluster)
      echo '$ minikube version; minikube status; kubectl get nodes'
      minikube version
      timeout 20 minikube -p "$profile" status || true
      kubectl --context "$profile" --request-timeout=35s get nodes
      ;;
    02-image)
      echo '$ cat app/Dockerfile.vm; docker image inspect sentiment-app:1.0.0'
      cat app/Dockerfile.vm
      docker image inspect sentiment-app:1.0.0 --format 'Tags: {{.RepoTags}} | Size: {{.Size}} bytes'
      ;;
    03-api)
      url=${API_URL:-http://$(minikube -p "$profile" ip)}
      printf '$ curl -H "Host: sentiment.local" %s/api/sentiment?text=hello\n' "$url"
      for text in hello terrible table; do
        printf '%-10s ' "$text"
        curl -fsS --max-time 10 -H 'Host: sentiment.local' "$url/api/sentiment?text=$text"
        echo
      done
      echo '$ kubectl get endpointslice -l kubernetes.io/service-name=sentiment'
      k get endpointslice -l kubernetes.io/service-name=sentiment
      ;;
    04-workloads)
      echo '$ kubectl -n sentiment get deploy,pods,svc,ingress,hpa'
      k get deploy/sentiment
      k get pods -l app=sentiment -o wide | cut -c 1-106
      k get svc,ingress,hpa | grep -E "NAME|sentiment[[:space:]]" | cut -c 1-106
      ;;
    05-monitoring)
      echo '$ helm list -n sentiment; kubectl -n sentiment get servicemonitor,pods'
      helm list -n sentiment --kube-context "$profile" | cut -c 1-106
      k get servicemonitor
      k get pods | grep -E 'NAME|grafana|prometheus|kube-state-metrics' | cut -c 1-106
      ;;
    06-hpa)
      echo '$ kubectl -n sentiment get hpa; kubectl -n sentiment top pods'
      k get hpa
      k top pods -l app=sentiment
      echo '$ kubectl -n sentiment events --for hpa/sentiment'
      k events --for hpa/sentiment | tail -6 | cut -c 1-106
      ;;
    07-load)
      printf '$ python3 scripts/load.py %s 180\n' "$(cat evidence/load-url.txt)"
      cat evidence/load.txt
      ;;
    *) return 1 ;;
  esac
}
capture > "evidence/$step.txt" 2>&1
sudo setfont -C /dev/tty1 /usr/share/consolefonts/CyrAsia-TerminusBold24x12.psf.gz
sudo sh -c 'printf "\033c" > /dev/tty1'
sudo tee /dev/tty1 < "evidence/$step.txt" > /dev/null
sudo chvt 1
