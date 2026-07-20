Set-StrictMode -Version Latest

# config.ps1 lives in src\utils; project folders live at the repo root.
$SrcRoot         = Split-Path -Parent $PSScriptRoot
$Root            = Split-Path -Parent $SrcRoot
$RunsRoot        = Join-Path $Root "runs"
$TemplatesRoot   = Join-Path $Root "templates"
$ContentRoot     = Join-Path $Root "content"
$ModulesRoot     = Join-Path $Root "modules"
$MemoryRoot      = Join-Path $RunsRoot "memory"
$SystemLogsRoot  = Join-Path $RunsRoot "logs\system_logs"
$TriggerLogsRoot = Join-Path $RunsRoot "logs\trigger_logs"
$SiteOutputRoot  = Join-Path $Root "site_output"
$DeploymentsPath = Join-Path $Root "deployments"

# Ensure directories exist
$null = New-Item -ItemType Directory -Path @(
  $TemplatesRoot,$ContentRoot,$ModulesRoot,$MemoryRoot,$SystemLogsRoot,$TriggerLogsRoot,$SiteOutputRoot,$DeploymentsPath
) -Force -ErrorAction SilentlyContinue
