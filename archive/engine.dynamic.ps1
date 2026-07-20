param(
    [Parameter(Mandatory)][string]$UserInput,
    [string]$Client = "default",
    [ValidateSet("Folder","Vercel","GitHub")]
    [string]$Provider = "Folder",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"

$pipelinePath = Join-Path $PSScriptRoot "pipeline.json"
if (-not (Test-Path $pipelinePath)) {
    throw "Missing pipeline.json"
}

$pipeline = Get-Content $pipelinePath -Raw | ConvertFrom-Json
$context  = @{}

Log "[ENGINE] Dynamic pipeline start" -Level "Info"

foreach ($step in $pipeline.steps) {

    if (-not $step.enabled) {
        Log "[ENGINE] Skipping $($step.name)" -Level "Info"
        continue
    }

    $scriptPath = Join-Path $PSScriptRoot $step.script
    if (-not (Test-Path $scriptPath)) {
        throw "Missing script: $($step.script)"
    }

    $params = @{}
    foreach ($key in $step.params.PSObject.Properties.Name) {
        $val = $step.params.$key

        if ($val -is [string] -and $val.StartsWith('$')) {
            $expr = $val.Substring(1)
            $params[$key] = Invoke-Expression "`$$expr"
        } else {
            $params[$key] = $val
        }
    }

    Log "[ENGINE] Running $($step.name)" -Level "Info"

    if ($DryRun) {
        Log "[ENGINE] (DryRun) $($step.script)" -Level "Info"
        continue
    }

    $result = & $scriptPath @params

    $context[$step.name] = $result
    Set-Variable -Name $step.name -Value $result -Scope Script
}

Log "[ENGINE] Pipeline complete" -Level "Success"

[pscustomobject]@{
    status = "Complete"
    context = $context
}