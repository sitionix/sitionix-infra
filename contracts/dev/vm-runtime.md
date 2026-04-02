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
  - `auths_sox`
  - `sites_sox`
  - `wags_sox`
- Kafka broker: `kafka:9092`

## Scope

This file documents the environment-owned runtime topology.
Service repos must not reassemble this topology through workflow env injection.

## Deploy model

For dev, `develop` in `sitionix-infra` is the source of truth for the shared VM infra state.
GitHub Actions pushes the bundle to the VM and materializes runtime env files there.
The VM is not allowed to become the source of truth through local edits or `git` operations.
