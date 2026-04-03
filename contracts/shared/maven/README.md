# Shared Maven Settings Contract

This directory is the canonical source of truth for Maven private-artifact settings used by Sitionix service repositories.

It owns:
- the settings template shape
- the exact GitHub Packages server ids used by service builds
- placeholder names for runtime credential injection

It does not own:
- real usernames
- real tokens
- per-service Maven build logic

## Template

- `settings.xml.template`

Service repos should:
1. fetch this template from `sitionix-infra`
2. inject only the runtime credentials
3. use the materialized file for Maven and Docker build secrets

## Runtime placeholders

- `${MAVEN_REPOSITORY_USERNAME}`
- `${GITHUB_FORGE_IT_MAVEN_TOKEN}`
- `${GITHUB_APP_AFESOX_MAVEN_TOKEN}`
- `${GITHUB_FORGE_SECURITY_MAVEN_TOKEN}`
- `${GITHUB_FORGE_COMMON_MAVEN_TOKEN}`

Recommended GitHub contract for service repos:
- repository variable `MAVEN_REPOSITORY_USERNAME`
- repository secret `SITIONIX_INFRA_READ_TOKEN`
- repository secret `GITHUB_FORGE_IT_MAVEN_TOKEN`
- repository secret `GITHUB_APP_AFESOX_MAVEN_TOKEN`
- repository secret `GITHUB_FORGE_SECURITY_MAVEN_TOKEN`
- repository secret `GITHUB_FORGE_COMMON_MAVEN_TOKEN`

The token must be able to:
- read private GitHub Packages Maven repositories used by the service

The infra read token must be able to:
- read this `sitionix-infra` repository if the service workflow checks out the template directly
