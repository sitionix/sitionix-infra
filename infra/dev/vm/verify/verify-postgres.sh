#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${1:-${ROOT_DIR}/env/infra-compose.env}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  exit 1
fi

set -a
. "${ENV_FILE}"
set +a

echo "Checking postgres container state..."
docker inspect --format '{{.State.Status}}' sitionix-postgres | grep -qx "running"

echo "Checking postgres readiness..."
docker exec sitionix-postgres pg_isready -U postgres -d postgres

echo "Checking VM loopback reachability to 127.0.0.1:5432..."
bash -lc 'exec 3<>/dev/tcp/127.0.0.1/5432'

echo "Checking databases..."
for database_name in auths_sox atms_sox sites_sox wags_sox; do
  docker exec sitionix-postgres psql -U postgres -d postgres -tAc \
    "SELECT 1 FROM pg_database WHERE datname='${database_name}'" | grep -qx "1"
  echo "  - ${database_name} exists"
done

echo "Checking service user logins..."
docker exec -e PGPASSWORD="${AUTHS_SOX_DB_PASSWORD}" sitionix-postgres \
  psql -h localhost -U authssox_app -d auths_sox -tAc \
  "SELECT current_database() || ':' || current_user;" | grep -qx "auths_sox:authssox_app"

docker exec -e PGPASSWORD="${ATMS_SOX_DB_PASSWORD}" sitionix-postgres \
  psql -h localhost -U atmssox_app -d atms_sox -tAc \
  "SELECT current_database() || ':' || current_user;" | grep -qx "atms_sox:atmssox_app"

docker exec -e PGPASSWORD="${SITES_SOX_DB_PASSWORD}" sitionix-postgres \
  psql -h localhost -U stsssox_app -d sites_sox -tAc \
  "SELECT current_database() || ':' || current_user;" | grep -qx "sites_sox:stsssox_app"

docker exec -e PGPASSWORD="${WAGS_SOX_DB_PASSWORD}" sitionix-postgres \
  psql -h localhost -U wagssox_app -d wags_sox -tAc \
  "SELECT current_database() || ':' || current_user;" | grep -qx "wags_sox:wagssox_app"

echo "Postgres verification passed."
