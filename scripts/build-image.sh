#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../app"
profile=${PROFILE:-sentiment-lab}
case "${1:-}" in
  "") dockerfile=Dockerfile ;;
  --with-jar) dockerfile=Dockerfile.vm ;;
  *) printf 'Usage: %s [--with-jar]\n' "$0" >&2; exit 2 ;;
esac
image=sentiment-app:1.0.0
docker build -f "$dockerfile" -t "$image" .
bytes=$(docker image inspect "$image" --format '{{.Size}}')
printf 'Image size: %s bytes\n' "$bytes"
if (( bytes >= 150000000 )); then
  printf 'Image must be smaller than 150 MB\n' >&2
  exit 1
fi
minikube -p "$profile" image load "$image" --overwrite=true
