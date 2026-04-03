# Secret Contract

## Never commit

- real passwords
- real JWT secrets
- private keys
- TLS material
- cloud credentials

## May be committed

- `.env.example` templates
- secret names
- secret file locations
- provisioning instructions
- environment variable contracts

## Secret categories

### Shared environment secrets

Shared by multiple services inside one environment.

Current dev example:
- `FORGE_SECURITY_DEV_JWT_SECRET`

Expected VM location:
- `/opt/sitionix/runtime/shared/dev-internal-auth.env`

### Service-owned secrets

Owned by one service even if provisioned by the environment.

Examples:
- auth JWT signing key material
- email verification HMAC secret
- per-service DB passwords

### GitHub Environment secrets

Used by CI/CD and never committed.

Current dev infra deploy secrets:
- `DEPLOY_VM_HOST`
- `DEPLOY_VM_USER`
- `DEPLOY_VM_SSH_PRIVATE_KEY`
- `POSTGRES_PASSWORD`
- `AUTHS_SOX_DB_PASSWORD`
- `SITES_SOX_DB_PASSWORD`
- `WAGS_SOX_DB_PASSWORD`
- `FORGE_SECURITY_DEV_JWT_SECRET`

### GitHub Environment vars

Non-secret environment values used by CI/CD.

Current dev infra deploy vars:
- `DEPLOY_VM_PORT`
- `KAFKA_CLUSTER_ID`

## File model

Infra repo keeps only templates such as:
- `*.env.example`

Real environment files are created on the VM by CI/CD and not committed.

Current dev infra deploy materializes:
- `/opt/sitionix/runtime/infra/current/env/infra-compose.env`
- `/opt/sitionix/runtime/shared/dev-internal-auth.env`

## Shared build credentials

`sitionix-infra` owns shared templates for private-artifact resolution, but not the real credentials.

Current shared Maven contract:
- template path: `contracts/shared/maven/settings.xml.template`
- service repo variable: `MAVEN_REPOSITORY_USERNAME`
- service repo secret: `SITIONIX_INFRA_READ_TOKEN`
- service repo secret: `GITHUB_FORGE_IT_MAVEN_TOKEN`
- service repo secret: `GITHUB_APP_AFESOX_MAVEN_TOKEN`
- service repo secret: `GITHUB_FORGE_SECURITY_MAVEN_TOKEN`
- service repo secret: `GITHUB_FORGE_COMMON_MAVEN_TOKEN`

These credentials are not environment-specific for the current model and should not be duplicated as full `settings.xml` blob secrets in each service repo.
