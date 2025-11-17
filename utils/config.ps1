Set-StrictMode -Version Latest

# Root is ONE level up from utils\
$Root            = Split-Path -Parent $PSScriptRoot
$TemplatesRoot   = Join-Path $Root "templates"
$MemoryRoot      = Join-Path $Root "memory"
$SystemLogsRoot  = Join-Path $Root "logs\system_logs"
$TriggerLogsRoot = Join-Path $Root "logs\trigger_logs"
$SiteOutputRoot  = Join-Path $Root "site_output"
$DeploymentsPath = Join-Path $Root "deployments"

# Ensure directories exist
$null = New-Item -ItemType Directory -Path @(
  $TemplatesRoot,$MemoryRoot,$SystemLogsRoot,$TriggerLogsRoot,$SiteOutputRoot,$DeploymentsPath
) -Force -ErrorAction SilentlyContinue
