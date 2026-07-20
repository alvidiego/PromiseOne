# ADR 0007: Profile-Driven Maintenance Workflow

Status: Accepted
Date: 2026-06-24

## Context
Client websites need recurring updates such as contact changes, services, hours,
photos, prices, testimonials, and provider links.

PromiseOne already has profiles, validation, timestamped builds, and exact
build-to-deploy handoff. Maintenance should reuse those capabilities instead of
introducing a CMS or editing generated sites directly.

## Decision
V1 maintenance uses profiles and referenced source assets as the source of truth.
Each update follows this sequence:

```text
confirm request
edit source
validate and build with an explicit profile
review the timestamped Folder preview
obtain human approval
deploy the exact reviewed build
```

Generated site and deployment folders remain immutable history. Production
deployment is separate from preview and requires human approval.

## Why
This preserves working sites, makes updates reproducible, reuses existing
PromiseOne architecture, and keeps rollback possible without building a CMS.

## Alternatives Considered
Edit generated HTML directly:

- Fast for one change.
- Loses the source of truth and will be overwritten by the next build.

Build a CMS immediately:

- More convenient for frequent editing.
- Introduces authentication, storage, permissions, and deployment complexity
  before recurring maintenance patterns are proven.

Automatically deploy every source edit:

- Faster.
- Removes the preview and human-approval boundary needed for client work.

## Consequences
V1 remains partly manual. New maintenance fields are added only for real client
needs and receive targeted validation when their failure would be harmful.

Future automation should preserve profiles as controlled input, immutable builds,
preview before production, and exact artifact deployment.

## Related Files
- docs/MAINTENANCE_WORKFLOW.md
- content/profiles/
- src/ai/content.lib.ps1
- src/core/engine.ps1
- src/core/build.ps1
- src/core/deploy.ps1
