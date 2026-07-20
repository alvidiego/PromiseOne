# System Evolution

This file records practical improvements that materially changed PromiseOne's
capabilities, safety, or working workflow. It is a curated milestone history, not
a changelog, backlog, or replacement for Architecture Decision Records.

Add an entry only when a future contributor could misunderstand the working
system without it. Group related changes and omit routine visual adjustments,
copy edits, generated builds, and small local fixes.

## 2026-07-14 - First Shareable Advanced-Theme Client Preview

Area: Themes and client preview

Improvement: GXE reached a client-shareable V1 and was published from the exact
timestamped build `gxe_20260714_221516` through a dedicated GitHub preview branch.

Impact: PromiseOne has now carried an advanced theme from structured profile and
isolated template through local generation to a mobile-accessible client review
URL without treating the preview as production.

Verified: The public preview opened successfully for client-style mobile review.
The exact build, preview branch, commit, and URL are preserved in a deployment
record.

Related: ADR 0002, ADR 0009, ADR 0010,
`deployments/records/gxe/gxe-client-preview-20260714.json`

## 2026-06-23 - Explicit Profile Selection And Validation

Area: Profiles

Improvement: The engine accepts an optional `-Profile` value. Explicit selection
wins over keyword inference, and shared profile fields are validated before page
generation.

Impact: Builds are reproducible, new profiles need fewer advisor changes, and
invalid profile data fails before build or deployment.

Verified: Explicit GXE and drywall builds, conflicting-keyword selection, legacy
commands, generic no-profile behavior, and validation failures passed.

Related: ADR 0006

## 2026-06-23 - Exact Build-To-Deploy Handoff

Area: Build and deployment

Improvement: The engine deploys the exact timestamped build returned by the build
step. Deployment fallback excludes the `latest` alias and rejects folders missing
`index.html` or `build_summary.json`.

Impact: Deployment no longer risks selecting a stale alias, and deployment
summaries record the exact source build.

Verified: Exact artifact deployment, fallback selection, and incomplete-folder
rejection passed.

Related: ADR 0001

## 2026-06-23 - First Optional Capability Module

Area: Modules

Improvement: Profiles can declare optional modules. The first implementation is
a native contact form backed by Formspree.

Impact: PromiseOne can orchestrate external business capabilities without owning
sensitive provider infrastructure or changing sites that request no modules.

Verified: Profile-to-plan-to-build rendering, module validation, no-module builds,
and mobile form layout passed.

Related: ADR 0005

## 2026-06-20 - Living Project Context

Area: Documentation

Improvement: `CURRENT_WORK.md` was added between the long-term project context and
permanent ADR history.

Impact: Future work can distinguish enduring principles, active direction,
unresolved questions, and accepted decisions.

Related: `docs/PROJECT_CONTEXT.md`, `docs/CURRENT_WORK.md`

## 2026-06-12 - GXE Advanced Theme Prototype

Area: Themes

Improvement: GXE became an isolated advanced-theme prototype with its own profile,
template, styling, and interaction script.

Impact: PromiseOne can explore a highly custom experience without destabilizing
standard business-site generation.

Related: ADR 0002, ADR 0003, ADR 0004

## 2026-06-12 - Source And Generated Output Separation

Area: Project structure

Improvement: Active source, reusable content, templates, run history, generated
sites, deployments, documentation, and archived material received clear folder
boundaries and centralized paths.

Impact: Source work is easier to understand and safer to change without confusing
generated history for active code.

Related: ADR 0001

## 2026-06 - Pre-Generation Setup Validation

Area: Engine reliability

Improvement: The engine checks required scripts, templates, profiles, and project
folders before generation begins.

Impact: Missing project pieces now fail early with clear expected paths instead of
causing harder-to-understand errors later in the pipeline.
