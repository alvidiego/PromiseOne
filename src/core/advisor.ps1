# ==========================================
# File: core\advisor.ps1
# Version: 1.1.0
# Role: Takes user input, writes trigger JSON
# Notes: Native PowerShell -Verbose (CmdletBinding). No custom Verbose params.
# ==========================================

[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [Alias('Input')]
  [string]$UserInput,

  [string]$Client = "default",

  [string]$Profile = "",

  [switch]$DryRun
)

Set-StrictMode -Version Latest
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"

$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')

Log "[ADVISOR] Starting with input '$UserInput' (client=$Client)" -Level "Info" -Verbose:$VerboseOn
Ensure-Directory -Path $TriggerLogsRoot -Verbose:$VerboseOn

$slug      = Slugify $UserInput
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$intent = ("{0} {1}" -f $UserInput, $Client).ToLowerInvariant()
$profileName = if ($null -eq $Profile) { "" } else { $Profile.Trim() }
$hasExplicitProfile = -not [string]::IsNullOrWhiteSpace($profileName)
$isGxe = (-not $hasExplicitProfile -and $intent -match '\bgxe\b')
$isContracting = (-not $hasExplicitProfile -and -not $isGxe -and $intent -match 'drywall|construction|contractor|remodel|renov|finish|interior|patch|texture')

$trigger = [ordered]@{
  type   = "Build"
  goal   = $UserInput
  client = $Client
  style  = if ($isGxe) { "gxe" } else { "default" }
  pages  = if ($isGxe) { @("Home") } else { @("Home","About","Contact") }
  meta   = @{
    created = (Get-Date).ToString("o")
    source  = "advisor.ps1"
    version = "1.1.0"
  }
}

if ($hasExplicitProfile) {
  $trigger["profile"] = $profileName
}
elseif ($isGxe) {
  $trigger["profile"] = "gxe"
}
elseif ($isContracting) {
  $trigger["profile"] = "drywall"
}

$path = Join-Path $TriggerLogsRoot ("trigger_{0}_{1}.json" -f $slug, $timestamp)

if ($DryRun) {
  Log "[ADVISOR] (DryRun) Would write trigger -> $path" -Level "Info" -Verbose:$VerboseOn
}
else {
  $trigger | ConvertTo-Json -Depth 6 | Out-File -FilePath $path
  Log "[ADVISOR] Trigger saved -> $path" -Level "Success" -Verbose:$VerboseOn
}

[pscustomobject]@{
  Path = $path
  Name = (Split-Path $path -Leaf)
  Data = $trigger
}
