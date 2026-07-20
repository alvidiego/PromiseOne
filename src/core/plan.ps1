# ==========================================
# File: core\plan.ps1
# Version: 1
# Role: Reads trigger -> emits plan JSON, writes memory\latest_plan.json
# Notes: Native PowerShell -Verbose (CmdletBinding). No custom Verbose params.
# ==========================================

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$TriggerFile,

    [Parameter(Mandatory=$false)]
    [string]$TriggerPath,

    [switch]$DryRun
)

# Normalize trigger path
if (-not $TriggerFile -and $TriggerPath) {
    $TriggerFile = $TriggerPath
}

if (-not $TriggerFile) {
    throw "Missing trigger file path."
}

Set-StrictMode -Version Latest
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\ai\memory.ps1"
. "$PSScriptRoot\..\ai\content.lib.ps1"

$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')

Log "[PLAN] Trigger: $TriggerFile" -Level "Info" -Verbose:$VerboseOn

if (-not (Test-Path -LiteralPath $TriggerFile)) {
    Log "[PLAN] Missing trigger file: $TriggerFile" -Level "Error" -Verbose:$VerboseOn
    exit 1
}

$trigger = Get-Content $TriggerFile -Raw -Encoding UTF8 | ConvertFrom-Json

$goal   = $trigger.goal
$client = $trigger.client
$style  = if ($trigger.PSObject.Properties.Name -contains 'style' -and $trigger.style) { $trigger.style } else { "default" }
$profileName = if ($trigger.PSObject.Properties.Name -contains 'profile' -and $trigger.profile) { [string]$trigger.profile } else { "" }
$modules = [pscustomobject]@{}

if ($profileName) {
    $profile = Get-PnProfile -ProfileName $profileName -Required

    if ($profile.PSObject.Properties.Name -contains 'style' -and -not [string]::IsNullOrWhiteSpace([string]$profile.style)) {
        $style = [string]$profile.style
    }

    if ($profile.PSObject.Properties.Name -contains 'modules' -and $profile.modules) {
        $modules = $profile.modules
    }
}
# ----- normalize pages -----
$pageObjs = @()

if ($trigger.PSObject.Properties.Name -contains 'pages' -and $trigger.pages) {

    $pageNames = @()

    foreach ($p in $trigger.pages) {
        if ($p -is [string]) {
            $pageNames += [string]$p
        }
        else {
            if (-not ($p.PSObject.Properties.Name -contains 'content'))     { $p | Add-Member -MemberType NoteProperty -Name content     -Value ""        -Force }
            if (-not ($p.PSObject.Properties.Name -contains 'layout'))      { $p | Add-Member -MemberType NoteProperty -Name layout      -Value "default" -Force }
            if (-not ($p.PSObject.Properties.Name -contains 'head_extras')) { $p | Add-Member -MemberType NoteProperty -Name head_extras -Value ""        -Force }
            if (-not ($p.PSObject.Properties.Name -contains 'lang'))        { $p | Add-Member -MemberType NoteProperty -Name lang        -Value "en"      -Force }

            $pageObjs += $p
        }
    }

    if ($pageNames.Count -gt 0) {
        $generatedPages = New-PnPagePlan -Goal $goal -Client $client -PageNames $pageNames -ProfileName $profileName
        $pageObjs += $generatedPages
    }
}
else {
    # no pages specified -> default single-page site
$pageObjs = New-PnPagePlan -Goal $goal -Client $client -PageNames @("Home") -ProfileName $profileName
}

$plan = [pscustomobject]@{
    goal   = $goal
    client = $client
    style  = $style
    profile = $profileName
    modules = $modules
    pages  = $pageObjs
    meta   = @{
        created = (Get-Date).ToString("o")
        version = "1.1.0"
        source  = "plan.ps1"
        trigger = $TriggerFile
    }
}

Ensure-Directory -Path $MemoryRoot -Verbose:$VerboseOn
$planPath = Join-Path $MemoryRoot "latest_plan.json"

if ($DryRun) {
    Log "[PLAN] (DryRun) Would write -> $planPath" -Level "Info" -Verbose:$VerboseOn
}
else {
    $plan | ConvertTo-Json -Depth 8 | Out-File -FilePath $planPath
    Log "[PLAN] Plan saved -> $planPath" -Level "Success" -Verbose:$VerboseOn

    # memory.ps1 defines Write-MemorySnapshot and supports -Verbose
    Write-MemorySnapshot -Data $plan -Source "plan.ps1" -Meta @{ path = $planPath } -Verbose:$VerboseOn
}

return $plan
