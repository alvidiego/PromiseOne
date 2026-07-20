# Current Work

Last reviewed: 2026-07-20

This file describes what matters right now. It is not a backlog or changelog.
Permanent decisions belong in `docs/decisions`.

## Current Objective

Preserve GXE as a strong, publicly deployed advanced-theme V1 while continuing
client-led refinement and keeping PromiseOne's repository, preview, production,
deployment, and maintenance boundaries explicit. Do not generalize the advanced
theme system prematurely.

## Current GXE State

- The accepted first-visit experience begins with `Press and hold` in a black
  void, reveals GXE stone by stone, forms Orb V1 behind the jewelry, and uses the
  accumulated bloom to hide the product handoff.
- The supplied GXE reference image is the active V1 artwork. Chrome leads the
  reveal and the purple structural star appears later.
- The selected product-video segment begins around 8.6 seconds, plays twice, and
  settles naturally at the end of the selected segment without a final seek.
- The first Main Menu landing shell is implemented. It keeps the product dominant,
  introduces the menu information during the film, and uses `Reserve Piece` as a
  visible but intentionally unwired placeholder action. That inactive action and
  the visible `Product Name` placeholder are accepted limitations of the initial
  production release.
- GXE remains mobile-primary with functional mouse and Space/Enter hold support
  on desktop.
- The current client-review build is `gxe_20260714_221516`.
- The current shareable preview is recorded in
  `deployments/records/gxe/gxe-client-preview-20260714.json`.
- The first production release serves that exact approved build from GitHub Pages
  at `https://alvidiego.github.io/PromiseOne/`.
- Production uses branch `gh-pages` at revision `c06a0aa`; its exact source and
  validation results are recorded in
  `deployments/records/gxe/gxe-production-20260720.json`.

## Active Direction

- Treat the current GXE production release as a craftsmanship and client-feedback
  milestone, not a reason to redesign the accepted interaction.
- Keep the Main Menu as the future hub for the featured piece and one or two
  additional destinations.
- Do not connect `Reserve Piece` to checkout until the client confirms the buying
  path, product details, and fulfillment process.
- Keep the visit-aware returning-user loader, cyclic section navigation, focused
  product inspection, and final product imagery as separate future milestones.
- Continue proving GXE inside `templates/gxe` before extracting reusable advanced
  theme behavior.
- Keep explicit profiles, timestamped builds, exact-build deployment, and external
  capability providers as PromiseOne's operational foundation.
- Verify the Formspree contact module through one real submission before adding
  another provider or module.
- Exercise the maintenance workflow on the next real client update before adding
  maintenance automation.

## Open Questions

- What final product still or product asset will the client provide?
- What purchasing path should replace the `Reserve Piece` placeholder?
- What are the final one or two Main Menu destinations and section names?
- When should returning-visitor behavior be implemented and how long should visit
  status persist?
- Which real client update should first exercise the maintenance workflow?
- Has the Formspree contact form delivered a real test submission successfully?

## Not Doing Yet

- A generalized advanced-theme framework
- CMS, custom payments, custom authentication, or a PromiseOne database
- Automatic production deployment
- True 3D or invented 360-degree product views
- Multiple GXE products or a full ecommerce catalog
- Detailed arrival architecture, particles, audio, or real-time chrome rendering

## Relevant Decisions

- [ADR 0001: Source And Generated Folder Separation](decisions/0001-source-generated-folder-separation.md)
- [ADR 0002: GXE Advanced Theme Prototype](decisions/0002-gxe-advanced-theme-prototype.md)
- [ADR 0003: GXE Visual Layer Separation](decisions/0003-gxe-visual-layer-separation.md)
- [ADR 0005: Optional Capability Modules](decisions/0005-optional-capability-modules.md)
- [ADR 0006: Explicit Profile Selection And Validation](decisions/0006-explicit-profile-selection-and-validation.md)
- [ADR 0007: Profile-Driven Maintenance Workflow](decisions/0007-profile-driven-maintenance-workflow.md)
- [ADR 0009: GXE Press-And-Hold Ice-Out Transition](decisions/0009-gxe-press-and-hold-ice-out-transition.md)
- [ADR 0010: GXE Visit-Aware Main Menu Hub](decisions/0010-gxe-visit-aware-main-menu-hub.md)

## Next Step

Gather focused feedback from the production URL and monitor the first public
release. The next GXE implementation should respond to client feedback or a
confirmed product and purchasing asset rather than add speculative features.
