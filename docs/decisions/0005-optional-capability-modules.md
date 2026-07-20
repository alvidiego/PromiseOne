# ADR 0005: Optional Capability Modules

Status: Accepted
Date: 2026-06-23

## Context
PromiseOne should support common business website capabilities without rebuilding
specialized services such as form delivery, booking, payments, authentication, or
content management.

The first experiment needs to prove that a client profile can request an optional
capability without changing sites that do not request it.

## Decision
PromiseOne will treat modules as optional capabilities declared by name in a
profile. Core is responsible for carrying declarations through the plan,
validating module source and public configuration, placing module markup, and
building the site.

External providers remain responsible for sensitive or specialized operations.
The first module is `contact-form`, backed by Formspree and implemented with a
native HTML form.

Profiles that do not contain a `modules` object continue through the existing
build path unchanged.

## Why
This proves the orchestration boundary with a common small-business need while
avoiding a generalized plugin framework before repeated module needs exist.

## Alternatives Considered
Build form processing inside PromiseOne:

- Would require email delivery, spam controls, rate limiting, and secure storage.
- Conflicts with the orchestration-not-replacement direction.

Create a complete module framework first:

- Might anticipate future needs.
- Adds abstractions before one real module reveals the useful shared contract.

Embed the form directly in the drywall template:

- Smaller initially.
- Would not establish an optional profile-to-build capability path.

## Consequences
Module names and required public settings are validated during the build.
Secrets must never be stored in profiles, templates, or generated output.

V1 does not include module lifecycle hooks, versions, JavaScript loading,
deployment adapters, or provider switching. Those should emerge only from real
module requirements.

## Related Files
- modules/contact-form/module.json
- modules/contact-form/component.en.html
- modules/contact-form/component.es.html
- content/profiles/drywall.json
- src/core/plan.ps1
- src/core/build.ps1
- src/ai/content.lib.ps1
- templates/default/assets/style.css
