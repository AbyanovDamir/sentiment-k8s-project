#!/usr/bin/env bash
set -euo pipefail
version=${MINIKUBE_VERSION:-v1.39.0}
case "$(uname -m)" in
  x86_64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2; exit 1 ;;
esac
tmp=$(mktemp -d)
trap 'rm -f "$tmp/minikube" "$tmp/minikube.sha256"; rmdir "$tmp"' EXIT
url="https://storage.googleapis.com/minikube/releases/$version/minikube-linux-$arch"
curl -fsSL "$url" -o "$tmp/minikube"
curl -fsSL "$url.sha256" -o "$tmp/minikube.sha256"
read -r expected _ < <(cat "$tmp/minikube.sha256"; echo)
printf '%s  %s\n' "$expected" "$tmp/minikube" | sha256sum --check -
install -Dm755 "$tmp/minikube" "$HOME/.local/bin/minikube"
"$HOME/.local/bin/minikube" version
