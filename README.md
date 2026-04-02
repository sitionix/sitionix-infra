# Sitionix Infra

`Sitionix Infra` is the environment and orchestration control-plane repository for Sitionix.

It owns:
- environment infrastructure definitions
- environment-level deployment orchestration
- shared runtime contracts between services inside an environment
- operator runbooks
- environment-level smoke and end-to-end verification

It does not own:
- service business code
- service-specific Spring config
- service DB migrations
- service unit or service-internal integration tests
- real secrets

## Ownership model

Infra repo owns environment concerns.
Service repos own service concerns.

Examples of infra-owned artifacts:
- VM infrastructure compose for shared Postgres and Kafka
- environment secret contracts and env templates
- operator runbooks for infra and environment rollout
- environment smoke checks that verify service-to-service integration
- GitHub Actions that push shared infra state to the runtime VM

Examples of service-owned artifacts:
- application code
- service-specific `application.yml` and profile files
- service database schema evolution and migrations
- service-local tests
- service build and packaging logic

## Initial structure

```text
sitionix-infra/
├── .github/
│   ├── actions/
│   └── workflows/
├── contracts/
│   └── dev/
├── deploy/
│   └── dev/
│       └── vm/
├── docs/
├── infra/
│   └── dev/
│       └── vm/
├── scripts/
└── tests/
    └── smoke/
        └── dev/
```

## Initial bootstrap content

The first artifacts moved here are the dev VM shared-infra bundle and the environment-level contracts it relies on:
- VM infra compose for Postgres and Kafka
- VM infra env templates
- Postgres DB/user bootstrap script
- infra verification scripts
- VM infra rollout runbook
- shared internal service-auth contract
- dev VM runtime contract summary
- GitHub Actions workflow and remote apply script for `develop -> dev` infra rollout

## Current recommendation

For the current VM-based dev stage:
- shared infra and operator runbooks should live here
- service repos may temporarily keep service-specific deploy logic
- `develop` in this repo is the source of truth for the shared dev VM infra state
- the VM is a runtime target only: no repo clone and no `git pull` on the VM
- production orchestration should later converge here as the environment source of truth
