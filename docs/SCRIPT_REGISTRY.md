# Script Registry

This registry identifies active entry points and responsibilities. Script headers
and Git history are the source of version details; this file does not duplicate
manual version numbers.

| File | Status | Responsibility | Main dependencies |
|---|---|---|---|
| `src/core/engine.ps1` | Active entry point | Runs advisor, plan, build, and deploy | Core steps, config, utilities |
| `src/core/advisor.ps1` | Active | Converts user intent and explicit profile selection into a trigger | Config, utilities |
| `src/core/plan.ps1` | Active | Validates profile input and writes the current plan and snapshot | Content library, memory |
| `src/core/build.ps1` | Active | Renders a timestamped static build from a plan and template | Templates, modules, memory |
| `src/core/deploy.ps1` | Active | Publishes one exact reviewed build through a selected provider | Config, utilities |
| `src/ai/content.lib.ps1` | Active | Loads profiles, validates shared fields, and creates page content | Profiles, templates |
| `src/ai/memory.ps1` | Active helper | Writes generated run snapshots | Config |
| `src/utils/config.ps1` | Active helper | Defines centralized project paths | Repository structure |
| `src/utils/utils.ps1` | Active helper | Provides logging, directory, and slug helpers | None |
| `src/core/smoke.ps1` | Dormant helper | Runs a basic end-to-end command without assertions | Engine |

## Inactive Experiments

The files under `src/core/pipeline/`, `src/core/steps/load-content.ps1`, and
`content/library/sections/` are not part of the active engine flow. Do not treat
them as runtime dependencies. Review them together before moving them to
`archive/` or reviving the dynamic-pipeline experiment.
