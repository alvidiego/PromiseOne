# Deployment Workflow

## Purpose

PromiseOne separates local development, client review, and production. Publishing
must always use the exact timestamped build that was reviewed. Never rebuild during
promotion and never deploy `site_output/latest` as the authoritative artifact.

## Environments

### Local Preview

Use this for development on the computer or a phone on the same WiFi network.

- Source: an exact folder under `site_output/`
- URL: local file or local-network HTTP server
- Record required: build summary only
- Approval required: no
- Production impact: none

The current `Folder` provider also creates a duplicate under `deployments/`. That
behavior is retained for compatibility but should later be replaced by a clear
build-only/local-preview option.

### Client Preview

Use this for a shareable review link that is not the live client website.

- Source: the exact reviewed timestamped build
- URL: provider-generated or preview-specific URL
- Record required: yes
- Approval required: internal approval before sharing
- Production impact: none

A preview record must include client ID, profile, source build, environment,
provider, URL, publish time, status, and provider revision or commit when known.
Use an immutable build URL when possible. A friendly latest-preview URL may point
to the newest review candidate, but it must not replace the exact record.

### Production

Use this only for the client-approved live website.

- Source: the exact approved preview build
- URL: production domain
- Record required: yes
- Approval required: explicit human approval
- Production impact: replaces the current live version

A production record must identify the previous live build as the rollback target.
After deployment, verify the domain, HTTPS, primary pages, forms, external links,
and mobile behavior before marking the record live.

## Current GXE Preview

The current GXE client preview is temporary review infrastructure, not production.
Its exact details are stored in
`deployments/records/gxe/gxe-client-preview-20260714.json`.

## Provider Selection

Choose a provider per client using:

- static HTML, CSS, JavaScript, image, and video support
- custom domains and HTTPS
- immutable preview deployments
- promotion and rollback support
- environment variables and secret management
- compatibility with external forms, booking, and payment links
- reliability, cost, and ease of maintenance
- future need for server functions or authenticated features

GitHub Pages can remain a valid static production option when the site delegates
sensitive work to trusted services. A provider with formal Preview and Production
environments becomes preferable when review URLs, promotion, rollback, functions,
or environment variables become regular requirements.

## Credentials

Profiles and templates may contain public configuration such as a Formspree form
endpoint. Never store API tokens, payment secrets, domain credentials, private
keys, or provider passwords in profiles, templates, deployment records, generated
sites, or tracked documentation.

Use provider-managed environment variables, Windows Credential Manager, or an
approved secret store. Deployment logs may name a credential reference but must
never contain the secret value.

## Rollback

1. Identify the current live deployment record.
2. Select its recorded previous live build.
3. Confirm the previous artifact still contains required deployment files.
4. Redeploy or promote that exact artifact.
5. Verify the live URL.
6. Write a new deployment record describing the rollback.

Do not delete previous approved builds until a retention policy and provider-level
rollback have both been proven.
