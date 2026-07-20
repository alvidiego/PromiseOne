# ADR 0001: Source And Generated Folder Separation

Status: Accepted
Date: 2026-06-12

## Context
PromiseOne started as a static website generator, but the project direction is broader: an orchestration system that turns human intent into working digital outputs through reusable structure and AI-assisted workflows.

The project had source files, generated sites, logs, memory snapshots, deployments, notes, and experiments mixed together. That made it harder for a future developer or Codex conversation to understand what is active source code versus generated history.

## Decision
PromiseOne should keep source files, reusable inputs, generated output, and history in separate top-level areas.

Current intended separation:

```text
src/           active scripts and helpers
content/       reusable profiles and content inputs
templates/     presentation themes and visual experiences
runs/          logs, triggers, memory, and run history
site_output/   generated website builds
deployments/   deployment copies and deployment summaries
docs/          project context, registry, and decisions
archive/       old experiments, backups, and inactive material
```

## Why
This supports the project rule: separate source files from generated output/history.

It also helps future work stay safe. Source changes can be reviewed without confusing them with generated build artifacts.

## Alternatives Considered
Keep the original flat structure:

- Easier in the short term.
- Harder to reason about as generated history grows.

Move everything into a larger app-style structure:

- Cleaner for a mature product.
- Too much refactor for the current stage.

## Consequences
Future scripts should use centralized path variables from `src/utils/config.ps1` instead of hardcoded assumptions.

Generated output and run history may still exist in Git during development, but they should not be mistaken for core source.

## Related Files
- src/utils/config.ps1
- src/core/engine.ps1
- site_output/
- runs/
- deployments/
