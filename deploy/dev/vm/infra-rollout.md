# Dev VM Infra Rollout

This runbook owns the manual rollout of shared dev VM infrastructure.

Current scope:
- create or update shared Postgres and Kafka on `sitionix-dev`
- verify DB bootstrap and Kafka shared-network reachability

The actual runtime artifacts live under:
- `infra/dev/vm/`
