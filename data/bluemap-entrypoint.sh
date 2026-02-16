#!/usr/bin/env bash
set -euo pipefail

seed_dir() {
  local src="$1"
  local dst="$2"

  mkdir -p "$dst"

  # if folder empty
  if [ -z "$(ls -A "$dst" 2>/dev/null || true)" ]; then
    echo "Seeding $dst from $src"
    cp -rT "$src" "$dst"
  else
    echo "$dst already initialized"
  fi
}

seed_dir /init/config /app/config
seed_dir /init/data   /app/data
seed_dir /init/web    /app/web

exec "$@"
