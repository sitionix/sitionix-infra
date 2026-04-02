# Dev Smoke Tests

This directory is reserved for environment-level smoke and end-to-end checks.

These tests should verify:
- public edge to backend connectivity
- service-to-service integration across the environment
- shared runtime contracts
- health and functional smoke after rollout

These tests should not contain:
- service unit tests
- service-internal integration tests
- DB migration logic
