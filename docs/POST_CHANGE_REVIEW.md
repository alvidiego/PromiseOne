# Post-Change Review

## Purpose

Use this lightweight gate after meaningful work. The goal is accurate builds and
current documentation, not paperwork for every edit.

## Choose A Review Level

Use the normal review when a change is scoped, reversible, and does not alter a
public environment, durable decision, shared contract, security boundary, or
cross-system workflow.

Use the milestone review when work creates or changes any of these:

- public client preview or production release
- client, profile contract, module, or deployment provider
- source folder, centralized path, pipeline boundary, or shared architecture
- credential handling, payment, authentication, or external service boundary
- accepted experience direction or other durable decision
- maintenance, rollback, or operator workflow

Minor styling, timing, copy, and routine bug fixes normally use the normal review
and do not create documentation unless they change an established rule.

## Normal Review

- [ ] The intended profile was selected and validation passed.
- [ ] The relevant build, syntax check, or focused test succeeded.
- [ ] The exact timestamped output was reviewed where visual output changed.
- [ ] Relevant mobile, desktop, media, links, forms, or external destinations were checked.
- [ ] Only intended source files changed; generated history is not mistaken for source.
- [ ] Existing documentation remains accurate.
- [ ] The final summary names verification performed and any remaining risk.

Documentation triage:

- Update `CURRENT_WORK.md` only if the active goal, status, experiment, open
  question, constraint, or next step changed.
- Add or amend an ADR only for a durable decision and its reasoning.
- Update `SYSTEM_EVOLUTION.md` only for a verified capability or workflow milestone.
- Update a runbook only when the operator procedure changed.

## Milestone Review

Complete the normal review, then verify:

- [ ] The source state is committed and recoverable.
- [ ] The exact source build and revision are recorded.
- [ ] Preview and production environments are clearly distinguished.
- [ ] A deployment record contains client, profile, build, provider, URL, status, and time.
- [ ] Secrets and public configuration were reviewed.
- [ ] The previous known version can be identified for rollback.
- [ ] `CURRENT_WORK.md` reflects what is implemented and what remains deferred.
- [ ] ADR and System Evolution decisions were made deliberately.
- [ ] Architecture, deployment, and maintenance documentation still agree.
- [ ] Human approval was obtained before production.

## Documentation Ownership

| Information | Location |
|---|---|
| Enduring principles and review rules | `PROJECT_CONTEXT.md` |
| Current priorities and unresolved questions | `CURRENT_WORK.md` |
| Durable decisions and reasons | `docs/decisions/` |
| Verified capability history | `SYSTEM_EVOLUTION.md` |
| Current structure and flow | `ARCHITECTURE.md` |
| Preview, production, credentials, rollback | `DEPLOYMENT_WORKFLOW.md` |
| Recurring client updates | `MAINTENANCE_WORKFLOW.md` |
| Exact publish event | `deployments/records/` |
