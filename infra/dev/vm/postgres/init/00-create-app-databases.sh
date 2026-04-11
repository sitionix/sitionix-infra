#!/usr/bin/env bash
set -euo pipefail

psql_base=(psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}")

create_role() {
  local role_name="$1"
  local role_password="$2"

  if ! "${psql_base[@]}" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${role_name}'" | grep -qx "1"; then
    "${psql_base[@]}" -c "CREATE ROLE ${role_name} LOGIN PASSWORD '${role_password}';"
  else
    "${psql_base[@]}" -c "ALTER ROLE ${role_name} WITH LOGIN PASSWORD '${role_password}';"
  fi
}

create_database() {
  local database_name="$1"
  local owner_name="$2"

  if ! "${psql_base[@]}" -tAc "SELECT 1 FROM pg_database WHERE datname='${database_name}'" | grep -qx "1"; then
    "${psql_base[@]}" -c "CREATE DATABASE ${database_name} OWNER ${owner_name};"
  fi

  "${psql_base[@]}" -c "GRANT ALL PRIVILEGES ON DATABASE ${database_name} TO ${owner_name};"
}

grant_schema_access() {
  local database_name="$1"
  local owner_name="$2"

  psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${database_name}" <<SQL
ALTER SCHEMA public OWNER TO ${owner_name};
GRANT ALL ON SCHEMA public TO ${owner_name};
SQL
}

create_role "authssox_app" "${AUTHS_SOX_DB_PASSWORD}"
create_role "atmssox_app" "${ATMS_SOX_DB_PASSWORD}"
create_role "stsssox_app" "${SITES_SOX_DB_PASSWORD}"
create_role "wagssox_app" "${WAGS_SOX_DB_PASSWORD}"

create_database "auths_sox" "authssox_app"
create_database "atms_sox" "atmssox_app"
create_database "sites_sox" "stsssox_app"
create_database "wags_sox" "wagssox_app"

grant_schema_access "auths_sox" "authssox_app"
grant_schema_access "atms_sox" "atmssox_app"
grant_schema_access "sites_sox" "stsssox_app"
grant_schema_access "wags_sox" "wagssox_app"
