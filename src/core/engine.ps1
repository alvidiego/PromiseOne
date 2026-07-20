# ==========================================
# File: core\engine.ps1
# Version: 1.0.0 (stable)
# Role: Orchestrate pipeline (advisor -> plan -> build -> deploy)
# Notes:
#   - Ignores pipeline.json/pipeline.txt for now (we’ll re-enable after stability)
#   - Uses correct param names for your current scripts:
#       advisor.ps1: -Input (Alias), -Client
#       plan.ps1   : -TriggerFile (or -TriggerPath)
#       build.ps1  : -PlanFile
#       deploy.ps1 : -BuildPath, -Provider, -ProjectName, -Client, -AutoOpen
# ==========================================

[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [Alias("Input")]
  [string]$UserInput,

  [string]$Client = "default",

  [string]$Profile = "",

  [ValidateSet("Folder","Vercel","GitHub")]
  [string]$Provider = "Folder",

  [string]$ProjectName = "",

  [switch]$AutoOpen,

  [switch]$DryRun
)

Set-StrictMode -Version Latest
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"

$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')

function Resolve-StepScript {
  param([Parameter(Mandatory)][string]$Name)
  $p = Join-Path $PSScriptRoot $Name
  if (-not ($p -match '\.ps1$')) { $p += ".ps1" }
  if (-not (Test-Path -LiteralPath $p)) { throw "Missing step script: $p" }
  return $p
}

function Invoke-StepSafe {
  param(
    [Parameter(Mandatory)][string]$ScriptPath,
    $Args
  )

  # Always coerce Args to hashtable (prevents Object[] -> Hashtable crashes)
  if ($null -eq $Args) {
    $Args = @{}
  }
  elseif ($Args -isnot [hashtable]) {
    try {
      $h = @{}
      foreach ($p in $Args.PSObject.Properties) { $h[$p.Name] = $p.Value }
      $Args = $h
    } catch {
      $Args = @{}
    }
  }

  if ($DryRun) { $Args["DryRun"] = $true }

  if ($VerboseOn) {
    try { return (& $ScriptPath @Args -Verbose 2>$null) }
    catch { return (& $ScriptPath @Args) }
  }

  return (& $ScriptPath @Args)
}

function Assert-RequiredPath {
  param(
    [Parameter(Mandatory)][ValidateSet("File","Folder")][string]$Type,
    [Parameter(Mandatory)][string]$Label,
    [Parameter(Mandatory)][string]$Path
  )

  $pathType = if ($Type -eq "File") { "Leaf" } else { "Container" }
  if (Test-Path -LiteralPath $Path -PathType $pathType) { return $null }

  $kind = $Type.ToLowerInvariant()
  return "[VALIDATION] Missing required ${kind}: $Label`nExpected path: $Path"
}

$defaultTemplate = Join-Path $TemplatesRoot "default"
$defaultAssets = Join-Path $defaultTemplate "assets"
$defaultComponents = Join-Path $defaultTemplate "components"
$contentProfiles = Join-Path $ContentRoot "profiles"
$runsLogsRoot = Join-Path $RunsRoot "logs"

$requiredPaths = @(
  @{ Type = "File";   Label = "advisor step";                 Path = (Join-Path $PSScriptRoot "advisor.ps1") },
  @{ Type = "File";   Label = "plan step";                    Path = (Join-Path $PSScriptRoot "plan.ps1") },
  @{ Type = "File";   Label = "build step";                   Path = (Join-Path $PSScriptRoot "build.ps1") },
  @{ Type = "File";   Label = "deploy step";                  Path = (Join-Path $PSScriptRoot "deploy.ps1") },
  @{ Type = "File";   Label = "config helper";                Path = (Join-Path $PSScriptRoot "..\utils\config.ps1") },
  @{ Type = "File";   Label = "utility helper";               Path = (Join-Path $PSScriptRoot "..\utils\utils.ps1") },
  @{ Type = "File";   Label = "memory helper";                Path = (Join-Path $PSScriptRoot "..\ai\memory.ps1") },
  @{ Type = "File";   Label = "content library";              Path = (Join-Path $PSScriptRoot "..\ai\content.lib.ps1") },
  @{ Type = "File";   Label = "default template layout";      Path = (Join-Path $defaultTemplate "layout.html") },
  @{ Type = "File";   Label = "default template stylesheet";  Path = (Join-Path $defaultAssets "style.css") },
  @{ Type = "File";   Label = "default header component";     Path = (Join-Path $defaultComponents "header.html") },
  @{ Type = "File";   Label = "default footer component";     Path = (Join-Path $defaultComponents "footer.html") },
  @{ Type = "File";   Label = "drywall content profile";      Path = (Join-Path $contentProfiles "drywall.json") },
  @{ Type = "Folder"; Label = "templates root";               Path = $TemplatesRoot },
  @{ Type = "Folder"; Label = "default template folder";      Path = $defaultTemplate },
  @{ Type = "Folder"; Label = "content root";                 Path = $ContentRoot },
  @{ Type = "Folder"; Label = "content profiles folder";      Path = $contentProfiles },
  @{ Type = "Folder"; Label = "runs root";                    Path = $RunsRoot },
  @{ Type = "Folder"; Label = "memory folder";                Path = $MemoryRoot },
  @{ Type = "Folder"; Label = "logs folder";                  Path = $runsLogsRoot },
  @{ Type = "Folder"; Label = "system logs folder";           Path = $SystemLogsRoot },
  @{ Type = "Folder"; Label = "trigger logs folder";          Path = $TriggerLogsRoot },
  @{ Type = "Folder"; Label = "site output folder";           Path = $SiteOutputRoot },
  @{ Type = "Folder"; Label = "deployments folder";           Path = $DeploymentsPath }
)

$missingRequiredPaths = @()
foreach ($req in $requiredPaths) {
  $message = Assert-RequiredPath -Type $req.Type -Label $req.Label -Path $req.Path
  if ($message) { $missingRequiredPaths += $message }
}

if ($missingRequiredPaths.Count -gt 0) {
  $nl = [Environment]::NewLine
  throw ("[VALIDATION] Project setup is incomplete." + $nl + ($missingRequiredPaths -join ($nl + $nl)) + $nl + "Fix: restore missing files/folders before running the generator.")
}

# Ensure core dirs exist
$dirs = @($TemplatesRoot,$MemoryRoot,$SystemLogsRoot,$TriggerLogsRoot,$SiteOutputRoot,$DeploymentsPath)
foreach ($d in $dirs) { Ensure-Directory -Path $d -Verbose:$VerboseOn }

try {
  $ctx = [ordered]@{
    trigger   = $null
    planFile  = (Join-Path $MemoryRoot "latest_plan.json")
    buildOut  = $null
    deployUrl = ""
  }

  # --- advisor ---
  Log "[ENGINE] Step: advisor" -Level "Info" -Verbose:$VerboseOn
  $advisor = Resolve-StepScript "advisor.ps1"

  $adv = Invoke-StepSafe -ScriptPath $advisor -Args @{
    Input  = $UserInput
    Client = $Client
    Profile = $Profile
  }

  if ($adv -and $adv.PSObject.Properties["Path"] -and $adv.Path) {
    $ctx.trigger = [string]$adv.Path
  } else {
    $latest = Get-ChildItem -LiteralPath $TriggerLogsRoot -Filter "trigger_*.json" -File |
      Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw "advisor did not produce a trigger file" }
    $ctx.trigger = $latest.FullName
  }

  # --- plan ---
  Log "[ENGINE] Step: plan" -Level "Info" -Verbose:$VerboseOn
  $plan = Resolve-StepScript "plan.ps1"

  $null = Invoke-StepSafe -ScriptPath $plan -Args @{
    TriggerFile = $ctx.trigger
  }

  if (-not (Test-Path -LiteralPath $ctx.planFile)) {
    throw "plan did not create latest_plan.json at $($ctx.planFile)"
  }

  # --- build ---
  Log "[ENGINE] Step: build" -Level "Info" -Verbose:$VerboseOn
  $build = Resolve-StepScript "build.ps1"

  $buildResults = @(Invoke-StepSafe -ScriptPath $build -Args @{
    PlanFile = $ctx.planFile
  })

  $buildResult = $buildResults |
    Where-Object {
      $_ -and $_.PSObject.Properties["Output"] -and
      -not [string]::IsNullOrWhiteSpace([string]$_.Output)
    } |
    Select-Object -Last 1

  if ($buildResult) {
    $ctx.buildOut = [string]$buildResult.Output
  } elseif (-not $DryRun) {
    $latestOut = Get-ChildItem -LiteralPath $SiteOutputRoot -Directory |
      Where-Object {
        $_.Name -ne "latest" -and
        (Test-Path -LiteralPath (Join-Path $_.FullName "index.html") -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $_.FullName "build_summary.json") -PathType Leaf)
      } |
      Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestOut) { $ctx.buildOut = $latestOut.FullName }
  }

  if (-not $ctx.buildOut) { throw "build did not produce an output folder" }
  if (-not $DryRun -and -not (Test-Path -LiteralPath $ctx.buildOut -PathType Container)) {
    throw "build output folder not found: $($ctx.buildOut)"
  }

  # --- deploy ---
  Log "[ENGINE] Step: deploy" -Level "Info" -Verbose:$VerboseOn
  $deploy = Resolve-StepScript "deploy.ps1"

  $dep = Invoke-StepSafe -ScriptPath $deploy -Args @{
    BuildPath   = $ctx.buildOut
    Provider    = $Provider
    ProjectName = $ProjectName
    Client      = $Client
    AutoOpen    = $AutoOpen
  }

  if ($dep -and $dep.PSObject.Properties["url"]) {
    $ctx.deployUrl = [string]$dep.url
  }

  [pscustomobject]@{
    status  = if ($DryRun) { "DryRun" } else { "Success" }
    url     = $ctx.deployUrl
    output  = $ctx.buildOut
    plan    = $ctx.planFile
    trigger = $ctx.trigger
  }
}
catch {
  Log "[ENGINE] Error -> $($_.Exception.Message)" -Level "Error" -Verbose:$VerboseOn
  [pscustomobject]@{
    status = "Failed"
    url    = ""
    output = $null
  }
}
