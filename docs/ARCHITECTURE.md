# PromiseOne Architecture

## Purpose

This file explains the current working structure and data flow. It describes what
exists now; durable reasons behind major choices belong in `docs/decisions`.

## Repository Areas

| Path | Responsibility | Classification |
|---|---|---|
| `src/` | Active generator, validation, orchestration, and shared helpers | Source |
| `content/profiles/` | Controlled client and experience data | Source |
| `content/library/` | Inactive reusable-content experiment | Inactive experiment |
| `templates/` | Layouts, components, theme styling, and theme interaction | Source |
| `modules/` | Optional capabilities backed by trusted external providers | Source |
| `docs/` | Project context, current work, decisions, and runbooks | Source |
| `archive/` | Inactive or superseded experiments retained for reference | Archive |
| `notes/` | Local incoming material and temporary operator notes | Local only |
| `runs/` | Trigger logs, current plan, and memory snapshots | Generated history |
| `site_output/` | Timestamped static builds plus a convenience `latest` copy | Generated output |
| `deployments/` | Local deployment copies and compact deployment records | Generated artifacts and records |

Do not edit `runs/`, `site_output/`, or generated deployment copies as source.

## Active Generation Flow

```text
human intent + client + optional explicit profile
                    |
                    v
             src/core/advisor.ps1
                    |
              trigger JSON in runs/
                    |
                    v
              src/core/plan.ps1
                    |
        validated profile + generated page plan
                    |
                    v
             src/core/build.ps1
                    |
       exact timestamped build in site_output/
                    |
                    v
            src/core/deploy.ps1
                    |
       exact reviewed artifact copied or published
```

`src/core/engine.ps1` is the normal entry point and coordinates those steps.
`src/utils/config.ps1` owns repository paths. `src/ai/content.lib.ps1` loads and
validates profiles and currently creates page-level content.

## Presentation Boundary

The default business-site presentation lives in `templates/default`. The GXE
advanced-theme prototype lives in `templates/gxe` and uses
`content/profiles/gxe.json`.

GXE remains intentionally isolated. Some GXE-specific markup is still emitted by
`src/ai/content.lib.ps1`; move it into theme-owned components only when another
advanced theme proves the reusable boundary. Do not refactor it only for symmetry.

## Profiles And Modules

An explicit `-Profile` selection is the safest client handoff. Profiles provide
brand data, pages, style, and optional module declarations. Shared validation runs
before generation.

Modules orchestrate external capabilities. PromiseOne may render and configure a
module, but providers remain responsible for form delivery, payments, booking,
authentication, and other sensitive infrastructure.

## Current Scale Boundaries

PromiseOne supports multiple clients when builds run one at a time. These global
convenience pointers are not concurrency-safe:

- `runs/memory/latest_plan.json`
- `site_output/latest`

The exact timestamped build remains authoritative. Before concurrent builds or
multi-user operation, replace global pointers with run- or client-scoped IDs.

## Inactive Pipeline Experiment

`src/core/pipeline/`, `src/core/steps/load-content.ps1`, and
`content/library/sections/` are not used by the active engine. Keep them together
until they are deliberately archived or revived.
