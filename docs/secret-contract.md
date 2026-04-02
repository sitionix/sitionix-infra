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

Examples:
- VM SSH keys
- registry pull tokens
- deployment credentials

## File model

Infra repo keeps only templates such as:
- `*.env.example`

Real environment files are created on the VM or injected by CI/CD.
