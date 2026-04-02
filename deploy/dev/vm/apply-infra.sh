#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
payload_dir="$(cd "${script_dir}/.." && pwd)"

# shellcheck source=/dev/null
source "${payload_dir}/release.env"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

assert_absolute_path() {
  local path_value="$1"
  local allowed_prefix="$2"

  if [[ "${path_value}" != "${allowed_prefix}"* ]]; then
    echo "Path ${path_value} must stay under ${allowed_prefix}" >&2
    exit 1
  fi
}

wait_for() {
  local description="$1"
  local command="$2"
  local attempts="${3:-30}"
  local sleep_seconds="${4:-2}"
  local command_timeout_seconds="${5:-10}"

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if timeout "${command_timeout_seconds}" bash -lc "${command}" >/dev/null 2>&1; then
      return 0
    fi
    sleep "${sleep_seconds}"
  done

  echo "Timed out waiting for ${description}" >&2
  return 1
}

for name in \
  SITIONIX_RELEASE_ID \
  SITIONIX_INFRA_RUNTIME_ROOT \
  SITIONIX_SHARED_RUNTIME_ROOT \
  SITIONIX_INFRA_BACKUP_ROOT \
  SITIONIX_POSTGRES_DATA_ROOT \
  SITIONIX_KAFKA_DATA_ROOT \
  SITIONIX_DOCKER_NETWORK \
  SITIONIX_SHARED_INTERNAL_AUTH_ENV_PATH \
  POSTGRES_PASSWORD \
  AUTHS_SOX_DB_PASSWORD \
  SITES_SOX_DB_PASSWORD \
  WAGS_SOX_DB_PASSWORD \
  KAFKA_CLUSTER_ID \
  FORGE_SECURITY_DEV_JWT_SECRET; do
  require_env "${name}"
done

assert_absolute_path "${SITIONIX_INFRA_RUNTIME_ROOT}" "/opt/sitionix/"
assert_absolute_path "${SITIONIX_SHARED_RUNTIME_ROOT}" "/opt/sitionix/"
assert_absolute_path "${SITIONIX_INFRA_BACKUP_ROOT}" "/opt/sitionix/"
assert_absolute_path "${SITIONIX_POSTGRES_DATA_ROOT}" "/opt/sitionix/"
assert_absolute_path "${SITIONIX_KAFKA_DATA_ROOT}" "/opt/sitionix/"
assert_absolute_path "${SITIONIX_SHARED_INTERNAL_AUTH_ENV_PATH}" "/opt/sitionix/"

staged_source_dir="${payload_dir}/infra"
current_root="${SITIONIX_INFRA_RUNTIME_ROOT}/current"
backup_root="${SITIONIX_INFRA_BACKUP_ROOT}/${SITIONIX_RELEASE_ID}"
shared_secret_path="${SITIONIX_SHARED_INTERNAL_AUTH_ENV_PATH}"

mkdir -p \
  "${SITIONIX_INFRA_RUNTIME_ROOT}" \
  "${SITIONIX_SHARED_RUNTIME_ROOT}" \
  "${SITIONIX_INFRA_BACKUP_ROOT}" \
  "${SITIONIX_POSTGRES_DATA_ROOT}" \
  "${SITIONIX_KAFKA_DATA_ROOT}" \
  "${backup_root}" \
  "${current_root}"

if find "${current_root}" -mindepth 1 -maxdepth 1 | read -r _; then
  mkdir -p "${backup_root}/previous-current"
  cp -R "${current_root}/." "${backup_root}/previous-current/"
fi

find "${current_root}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -R "${staged_source_dir}/." "${current_root}/"
cp "${payload_dir}/release.env" "${backup_root}/release.env"

install -d -m 0755 "${current_root}/env"
umask 077
cat > "${current_root}/env/infra-compose.env" <<ENVEOF
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
AUTHS_SOX_DB_PASSWORD=${AUTHS_SOX_DB_PASSWORD}
SITES_SOX_DB_PASSWORD=${SITES_SOX_DB_PASSWORD}
WAGS_SOX_DB_PASSWORD=${WAGS_SOX_DB_PASSWORD}
KAFKA_CLUSTER_ID=${KAFKA_CLUSTER_ID}
ENVEOF

cat > "${shared_secret_path}" <<ENVEOF
FORGE_SECURITY_DEV_JWT_SECRET=${FORGE_SECURITY_DEV_JWT_SECRET}
ENVEOF
umask 022

if ! docker network inspect "${SITIONIX_DOCKER_NETWORK}" >/dev/null 2>&1; then
  docker network create "${SITIONIX_DOCKER_NETWORK}" >/dev/null
fi

(
  cd "${current_root}"
  docker compose --env-file env/infra-compose.env -f docker-compose.infra.yml up -d
)

wait_for "Postgres readiness" "docker exec sitionix-postgres pg_isready -U postgres -d postgres"
docker exec -i \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=postgres \
  -e AUTHS_SOX_DB_PASSWORD="${AUTHS_SOX_DB_PASSWORD}" \
  -e SITES_SOX_DB_PASSWORD="${SITES_SOX_DB_PASSWORD}" \
  -e WAGS_SOX_DB_PASSWORD="${WAGS_SOX_DB_PASSWORD}" \
  sitionix-postgres bash -s < "${current_root}/postgres/init/00-create-app-databases.sh"
wait_for "Kafka readiness" "docker exec sitionix-kafka kafka-topics --bootstrap-server localhost:9092 --list"

(
  cd "${current_root}"
  bash verify/verify-postgres.sh
  bash verify/verify-kafka.sh
)

echo "Dev infra apply completed for ${SITIONIX_RELEASE_ID}."
