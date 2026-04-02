#!/usr/bin/env bash
set -euo pipefail

SMOKE_TOPIC="${1:-sitionix.infra.smoke.v1}"
KAFKA_IMAGE="${KAFKA_IMAGE:-confluentinc/cp-kafka:7.6.0}"
KAFKA_NETWORK="${KAFKA_NETWORK:-sitionix-dev}"

run_in_network() {
  local command="$1"
  docker run --rm --network "${KAFKA_NETWORK}" "${KAFKA_IMAGE}" bash -lc "${command}"
}

echo "Checking kafka container state..."
docker inspect --format '{{.State.Status}}' sitionix-kafka | grep -qx "running"

echo "Checking shared-network reachability to kafka:9092..."
docker network inspect "${KAFKA_NETWORK}" >/dev/null

run_in_network "kafka-broker-api-versions --bootstrap-server kafka:9092 >/dev/null"

echo "Checking topic operations through the shared network..."
run_in_network "kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic '${SMOKE_TOPIC}' --partitions 1 --replication-factor 1 >/dev/null && kafka-topics --bootstrap-server kafka:9092 --describe --topic '${SMOKE_TOPIC}'"

echo "Kafka verification passed through ${KAFKA_NETWORK} to kafka:9092."
