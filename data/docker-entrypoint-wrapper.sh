#!/usr/bin/env bash
set -euo pipefail

# original entrypoint
docker-entrypoint.sh postgres &

# db health check
until pg_isready -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  sleep 1
done

# multi database script
init-multiple-databases.sh

# foreground
wait -n
