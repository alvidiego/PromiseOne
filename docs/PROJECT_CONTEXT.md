PROJECT_CONTEXT.md

PromiseOne

Purpose

PromiseOne is a system for creating websites through structured context, reusable architecture, and AI-assisted workflows.

The long-term vision is to reduce repetitive implementation work so humans can spend more time on:

- understanding clients
- defining goals
- shaping brands
- designing experiences
- making creative decisions

PromiseOne should evolve through real projects and proven patterns rather than speculative rewrites.

---

Development Philosophy

Prefer practical progress over theoretical perfection.

Prototype first.
Learn from real usage.
Refactor after patterns become clear.

The goal is not to build the perfect system.

The goal is to continuously improve a working system.

---

Human vs Automation

Humans should remain responsible for:

- intent
- taste
- direction
- brand decisions
- user experience decisions
- final approval

Automation should increasingly handle:

- repetitive implementation
- content organization
- layout generation
- build workflows
- deployment workflows
- maintenance tasks

---

Architecture Principles

- Keep generation logic separate from presentation.
- Themes should remain independent from core generation.
- Preserve working functionality whenever possible.
- Source files should remain separate from generated output.
- Reusable systems should emerge from repeated needs.
- Avoid introducing complexity before it is needed.

---

Development Rules

For core system work:

- Prefer small, understandable patches.
- Avoid unnecessary rewrites.
- Preserve existing working projects.
- Make changes easy to review and test.

For visual and design exploration:

- Reversibility is helpful but should not prevent meaningful experimentation.
- Strong visual improvements are acceptable inside isolated templates, themes, and prototypes.
- The goal is visible learning, not maximum caution.
- Do not let "small changes" become an excuse for invisible changes.

Default rule:

Start with the smallest change that can meaningfully improve or validate an idea.

---

AI Collaboration Guidelines

When working on a task:

1. Understand the goal before proposing implementation.
2. Favor incremental improvements over large rewrites.
3. Explain tradeoffs when multiple approaches exist.
4. Respect existing architecture unless there is a clear reason to change it.
5. For visual work, prioritize user experience and visual clarity over excessive caution.
6. If a change is intentionally experimental, optimize for learning and feedback.

---

Documentation Workflow

Before planning or implementing substantial work:

1. Read PROJECT_CONTEXT.md.
2. Read CURRENT_WORK.md if it exists.
3. Read any relevant Architecture Decision Records in docs/decisions.
4. Inspect the current source folders and files relevant to the task so decisions
   reflect the project as it exists now rather than assumptions from an earlier
   session.

A complete project inventory is not required for every small prompt. Keep the
structure review proportional to the task, but broaden it before architectural
changes, folder or path changes, and cross-system work. Do not treat generated
output or run history as active source unless the task specifically involves it.

Read SYSTEM_EVOLUTION.md when reviewing capability history or planning system
architecture. It is not required for every routine task. For client maintenance,
follow MAINTENANCE_WORKFLOW.md and preserve its preview and approval boundary.

Read ARCHITECTURE.md before folder, path, pipeline, profile-contract, module, or
cross-system changes. Read DEPLOYMENT_WORKFLOW.md before publishing a client
preview, changing a deployment provider, or touching production.

After meaningful work, follow POST_CHANGE_REVIEW.md. Use its normal checklist
for scoped changes and its milestone checklist for public previews, production
releases, new clients, new modules, path changes, provider changes, security
boundaries, or durable architecture and experience decisions.

After accepting a major decision or materially changing the active direction:

- Review CURRENT_WORK.md.
- Update it when the current objective, active experiment, open questions, constraints, or next step have changed.
- Record permanent decisions in an ADR instead of CURRENT_WORK.md.
- Record verified capability-level improvements in SYSTEM_EVOLUTION.md.
- Do not use CURRENT_WORK.md as a backlog, changelog, or record of every small edit.
- Do not use SYSTEM_EVOLUTION.md for routine fixes, visual tweaks, or generated builds.
- Do not create documentation for minor styling, timing, copy, or routine bug fixes
  unless they change an established rule, workflow, or accepted decision.

---

Current Focus

PromiseOne is currently focused on:

- website generation
- client projects
- reusable themes
- optional capability modules that orchestrate trusted external services
- AI-assisted workflows
- improving project velocity through better tooling and context

Future expansion is allowed but should not distract from current execution.
