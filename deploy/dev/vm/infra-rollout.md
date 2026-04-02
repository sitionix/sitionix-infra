# Dev VM Infra Rollout

This document defines the automated shared-infra rollout for the dev VM.

## Trigger model

- source branch: `develop`
- trigger: GitHub Actions `push`
- GitHub Environment: `dev`
- deploy style: push-based from GitHub Actions over SSH
- VM role: runtime target only
- forbidden on VM: `git clone`, `git pull`, manual editing as the primary rollout path

## Scope

This rollout deploys only the shared environment infra layer:
- Postgres
- Kafka
- shared runtime secret file contract
- infra verification

This rollout does not deploy backend services yet.

## Repo artifacts used by the deploy

- workflow: `.github/workflows/dev-infra-deploy-on-push.yml`
- composite action: `.github/actions/dev-infra-deploy-run/action.yml`
- remote apply script: `deploy/dev/vm/apply-infra.sh`
- infra bundle: `infra/dev/vm/`

## GitHub Environment contract

### Secrets

- `DEPLOY_VM_HOST`
- `DEPLOY_VM_USER`
- `DEPLOY_VM_SSH_PRIVATE_KEY_DEV_ONLY`
- `POSTGRES_PASSWORD`
- `AUTHS_SOX_DB_PASSWORD`
- `SITES_SOX_DB_PASSWORD`
- `WAGS_SOX_DB_PASSWORD`
- `FORGE_SECURITY_DEV_JWT_SECRET`

### Vars

- `DEPLOY_VM_PORT`
- `KAFKA_CLUSTER_ID`

`KAFKA_CLUSTER_ID` is non-secret but required.

## VM paths materialized by the rollout

- current infra bundle: `/opt/sitionix/runtime/infra/current`
- real infra env file: `/opt/sitionix/runtime/infra/current/env/infra-compose.env`
- shared internal auth secret file: `/opt/sitionix/runtime/shared/dev-internal-auth.env`
- Postgres data: `/opt/sitionix/data/postgres`
- Kafka data: `/opt/sitionix/data/kafka`
- infra backup snapshot: `/opt/sitionix/backups/infra/<release-id>`

## Remote apply flow

1. GitHub Actions checks out the current `develop` commit.
2. The workflow packages:
   - `deploy/dev/vm/apply-infra.sh`
   - `infra/dev/vm/**`
   - a generated non-secret `release.env`
3. GitHub Actions uploads the tarball and a temporary secret env file to `/tmp` on the VM.
4. The VM runs `deploy/dev/vm/apply-infra.sh` from the unpacked bundle.
5. The script:
   - asserts all target paths stay under `/opt/sitionix`
   - creates runtime, data, and backup directories if missing
   - backs up the previous `current` bundle snapshot
   - rewrites `/opt/sitionix/runtime/infra/current`
   - materializes the real env files from GitHub Environment values
   - creates `sitionix-dev` if missing
   - runs `docker compose` for Postgres and Kafka
   - reruns Postgres DB or role bootstrap idempotently
   - verifies Postgres
   - verifies Kafka reachability through `kafka:9092` on `sitionix-dev`
6. The workflow fails immediately if any remote step or verification fails.

## Verification contract

The rollout is only successful when both scripts pass on the VM:
- `infra/dev/vm/verify/verify-postgres.sh`
- `infra/dev/vm/verify/verify-kafka.sh`

Postgres verification proves:
- `sitionix-postgres` is running
- `AUTHS_SOX`, `SITES_SOX`, and `WAGS_SOX` exist
- `authssox_app`, `stsssox_app`, and `wagssox_app` can authenticate

Kafka verification proves:
- `sitionix-kafka` is running
- `sitionix-dev` exists
- a separate temporary container on `sitionix-dev` can reach `kafka:9092`
- broker metadata and topic operations succeed through the shared network
