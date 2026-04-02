# Dev VM Deploy

This directory owns the dev VM deployment flow for shared environment infrastructure.

Current scope:
- push-based deploy of shared Postgres and Kafka from `develop` to the `dev` GitHub Environment
- remote apply for the infra bundle under `/opt/sitionix/runtime/infra/current`
- runtime materialization of real env files on the VM
- Postgres and Kafka verification on the VM after apply

Key rules:
- GitHub Actions is the deploy orchestrator
- the VM is a runtime target only
- no `git` commands run on the VM
- real secrets come from GitHub Environment secrets or vars, never from git

Primary artifacts:
- `.github/workflows/dev-infra-deploy-on-push.yml`
- `.github/actions/dev-infra-deploy-run/action.yml`
- `deploy/dev/vm/apply-infra.sh`
- `infra/dev/vm/**`
