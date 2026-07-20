# Website Maintenance Workflow

## Purpose

PromiseOne maintenance is a repeatable way to update controlled source data,
validate it, generate a new timestamped site, review it, and deploy that exact
build after human approval.

PromiseOne is not replacing a CMS. Do not edit files inside `site_output` or
`deployments`; those folders contain generated history, not source.

## V1 Maintenance Scope

Maintain fields that already flow through a client profile and template:

- phone and contact copy
- service area
- hero and CTA text
- services and descriptions
- gallery captions
- public module endpoints, booking links, or payment links when supported
- GXE product name and product copy

Staff lists, hours, prices, testimonials, and real gallery images should be added
only when a real client and template need them. Do not create a generalized
maintenance schema first.

## Maintenance Checklist

1. Confirm the client's requested change and exact replacement information.
2. Identify the client profile and any referenced source assets.
3. Edit only the profile, template-owned content, or referenced assets.
4. Generate a local Folder preview with an explicit profile.
5. Review the timestamped build on desktop and phone.
6. Confirm forms, booking links, payment links, phone numbers, and other external
   destinations involved in the change.
7. Obtain human approval.
8. Deploy the exact reviewed build path through the chosen provider.
9. Keep the previous timestamped build and deployment available for rollback.

## Preview Command

Use a short maintenance description so the build summary preserves the purpose of
the update:

```powershell
.\src\core\engine.ps1 -UserInput "Maintenance preview: update contact information" -Client "Sanchez Drywall" -Profile drywall -Provider Folder -Verbose
```

The result should report an exact timestamped output such as:

```text
C:\PromiseOne\site_output\sanchez_drywall_YYYYMMDD_HHMMSS
```

Review that folder, not `site_output/latest`.

## Final Deployment

Production deployment is a separate, intentional action after preview approval:

```powershell
.\src\core\deploy.ps1 -BuildPath "C:\PromiseOne\site_output\client_timestamp" -Provider Folder -Client "Client Name" -Verbose
```

Use `Folder` until a production provider is deliberately configured and tested.
When a production provider is added, keep the same rule: deploy the exact reviewed
build path.

## Validation Expectations

Maintenance must stop before deployment when:

- the profile name is unsafe or missing
- profile JSON cannot be read
- required shared profile fields are missing
- the selected template does not exist
- module configuration is incomplete or unsupported
- referenced source assets are missing
- the generated build lacks required deployment files

Add targeted validation only when a real maintenance field needs it. Do not add a
validation framework or require client-specific fields globally.

## Manual Responsibilities

Humans remain responsible for interpreting the request, confirming factual
changes, choosing and approving imagery, reviewing the result, approving
deployment, and verifying external providers.

## Later Automation

After repeated maintenance work exposes stable patterns, PromiseOne may add guided
profile edits, content diffs, image optimization, preview links, broken-link
checks, reminders, and one-command rollback. These are not part of V1.
