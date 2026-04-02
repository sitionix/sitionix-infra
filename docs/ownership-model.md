# Ownership Model

## Infra repo owns

- shared environment infrastructure
- network and runtime naming contracts
- environment rollout sequencing
- environment-level smoke tests
- operator runbooks
- environment-level secret contracts and templates

## Service repos own

- service code
- service packaging
- service runtime config and Spring profiles
- service DB migrations and schema evolution
- service unit, integration and contract tests
- service-specific deploy details that do not affect other services

## Why this split exists

Without a dedicated infra repo, shared environment concerns drift into arbitrary service repos.
That leads to duplicated runtime contracts, conflicting docs and no clear control-plane owner.

`Sitionix Infra` exists to centralize environment truth without turning into a dump for application code.
