# Dev VM Runtime Contract

## Shared network

- docker network: `sitionix-dev`

## Shared infra aliases

- Postgres alias: `postgres`
- Kafka alias: `kafka`

## Expected service aliases

- `authorisationservice-sox`
- `siteservice-sox`
- `workspaceaggregationservice-sox`
- `bffssox-service` may exist as a container name, but shared contracts should prefer stable aliases where possible

## Current shared stores

- Postgres databases:
  - `AUTHS_SOX`
  - `SITES_SOX`
  - `WAGS_SOX`
- Kafka broker: `kafka:9092`

## Scope

This file documents the environment-owned runtime topology.
Service repos must not reassemble this topology through workflow env injection.
