# ADR 0002: GXE As Advanced Theme Prototype

Status: Accepted
Date: 2026-06-12

## Context
GXE is a premium, interaction-driven clothing experience. It is not a standard static business website page.

The project goal is to grow from practical working pieces instead of building a large abstract system before it is needed.

## Decision
GXE V1 is implemented as a standalone prototype theme, while keeping the file structure clean enough to become the first advanced theme blueprint later.

The GXE experience lives primarily in:

```text
templates/gxe/
content/profiles/gxe.json
```

Minimal generator hooks may select the `gxe` style/profile when the request or client mentions GXE, but the project should not build a full theme framework yet.

## Why
This lets GXE move quickly while preserving future expansion.

It follows the project rule: prototype first, then refactor.

## Alternatives Considered
Build a full theme system immediately:

- More powerful long term.
- Too much complexity before GXE proves the experience.

Treat GXE as a one-off static page outside PromiseOne:

- Fastest prototype.
- Less useful as a future advanced theme model.

## Consequences
GXE can evolve without disrupting standard client-site generation.

Future advanced themes can learn from GXE's structure, but they should not be abstracted until repeated need appears.

## Related Files
- templates/gxe/layout.html
- templates/gxe/assets/style.css
- templates/gxe/assets/experience.js
- content/profiles/gxe.json
- src/core/advisor.ps1
- src/ai/content.lib.ps1
