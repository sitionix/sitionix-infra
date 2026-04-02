# Dev Internal Service Auth Contract

Shared internal service-to-service auth in dev uses one shared secret and committed non-secret metadata.

## Shared secret

- env var: `FORGE_SECURITY_DEV_JWT_SECRET`
- VM file: `/opt/sitionix/runtime/shared/dev-internal-auth.env`

## Shared non-secret values

- issuer: `sitionix-internal`
- ttl seconds: `300`

## Participating services

- `backendforfrontendservice-sox`
- `authorisationservice-sox`
- `siteservice-sox`
- `workspaceaggregationservice-sox`

## Ownership rule

This shared contract is environment-owned and belongs in `Sitionix Infra`.
Each service repo still owns how its service binds and consumes the contract.
