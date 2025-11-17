# Script Registry

| File               | Version | Status  | Notes                                      | Dependencies                          | Runtime |
|--------------------|---------|---------|--------------------------------------------|---------------------------------------|---------|
| core/engine.ps1    | 1.0.2   | stable  | Orchestrates advisor ? plan ? build ? deploy | utils/config.ps1, utils/utils.ps1, core/*.ps1 | PS 7+   |
| core/advisor.ps1   | 1.0.2   | stable  | Turns user input into a trigger JSON       | utils/config.ps1, utils/utils.ps1     | PS 7+   |
| core/plan.ps1      | 1.0.2   | stable  | Reads trigger, writes site plan            | utils/config.ps1, utils/utils.ps1, ai/memory.ps1 | PS 7+ |
| core/build.ps1     | 1.0.2   | stable  | Builds static HTML from plan + templates   | utils/config.ps1, utils/utils.ps1, templates/*  | PS 7+ |
| core/deploy.ps1    | 1.0.2   | stable  | Folder deployment (copies built site)      | utils/config.ps1, utils/utils.ps1     | PS 7+   |
| core/smoke.ps1     | 1.0.0   | helper  | One-shot end-to-end smoke test             | core/engine.ps1                        | PS 7+   |
| utils/config.ps1   | 1.0.0   | shared  | Defines root paths (templates, logs, etc.) | —                                     | PS 7+   |
| utils/utils.ps1    | 1.0.0   | shared  | Log, Ensure-Directory, Slugify, helpers    | —                                     | PS 7+   |
| ai/memory.ps1      | 1.0.0   | shared  | Saves snapshots of plans/builds            | utils/config.ps1                       | PS 7+   |
