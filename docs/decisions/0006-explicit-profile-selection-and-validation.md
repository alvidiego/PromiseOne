# ADR 0006: Explicit Profile Selection And Validation

Status: Accepted
Date: 2026-06-23

## Context
PromiseOne can infer the GXE and drywall profiles from user-input keywords, but
inference alone becomes less reliable as more clients, themes, and modules are
added. A new profile should not require another hardcoded advisor rule.

Profiles also lacked a small shared validation boundary, so malformed or
incomplete profile data could fail later during planning or building.

## Decision
The engine accepts an optional `-Profile` parameter. An explicitly selected
profile wins over keyword inference. When no profile is supplied, current keyword
detection remains available for backward compatibility.

Selected profiles are validated before page generation. V1 validation is limited
to shared requirements:

- safe profile name
- readable JSON
- matching internal profile name
- non-empty brand name
- non-empty page list
- valid template when a style is specified
- object-shaped modules configuration when modules are present

The selected profile can provide its pages, style, and modules to the plan.

## Why
This makes builds reproducible, allows new profiles without expanding keyword
rules, and catches configuration mistakes before generation or deployment.

## Alternatives Considered
Continue using inference only:

- Keeps commands short.
- Couples every new client type to advisor code and can select the wrong profile.

Make profiles mandatory:

- Fully deterministic.
- Would break existing commands and reduce the usefulness of conversational input.

Introduce JSON Schema immediately:

- More formal validation.
- Adds tooling and complexity before the shared profile contract has matured.

## Consequences
Existing commands continue working. Explicit commands can reliably select a
profile even when the user input contains unrelated or conflicting keywords.

Validation must remain universal. Client-specific fields should not become core
requirements unless repeated project needs prove they belong there.

## Related Files
- src/core/engine.ps1
- src/core/advisor.ps1
- src/core/plan.ps1
- src/ai/content.lib.ps1
- content/profiles/
