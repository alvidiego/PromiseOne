param(
    [Parameter(Mandatory)]
    [Alias("Input")]            # only "Input" is the alias, not "UserInput"
    [string]$UserInput,

    [string]$Client = "default",

    [ValidateSet("Folder","Vercel","GitHub")]
    [string]$Provider = "Folder",

    [switch]$Chatty,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"

# ensure core dirs exist so the other scripts don't freak out
$dirs = @(
    $TemplatesRoot,
    $MemoryRoot,
    $SystemLogsRoot,
    $TriggerLogsRoot,
    $SiteOutputRoot,
    $DeploymentsPath
)
foreach ($d in $dirs) {
    Ensure-Directory -Path $d -Verbose:$Chatty
}

try {
    # 1) advisor → trigger json
    $adv = & "$PSScriptRoot\advisor.ps1" -Input $UserInput -Client $Client -DryRun:$DryRun
    if (-not $adv -or -not $adv.Path) {
        throw "advisor failed to return a trigger path"
    }

    # 2) plan → latest_plan.json
    $plan = & "$PSScriptRoot\plan.ps1" -TriggerFile $adv.Path -DryRun:$DryRun
    if (-not $plan) {
        throw "plan failed"
    }

    $planFile = Join-Path $MemoryRoot "latest_plan.json"

    # 3) build → site_output\<client_timestamp>
    $build = & "$PSScriptRoot\build.ps1" -PlanFile $planFile -DryRun:$DryRun

    # figure out the output path in a safe way
    $outputPath = $null
    if ($build -and $build.PSObject.Properties["Output"]) {
        $outputPath = $build.Output
    } elseif (-not $DryRun -and (Test-Path $SiteOutputRoot)) {
        # fallback: latest folder in site_output
        $outputPath = (Get-ChildItem -Path $SiteOutputRoot -Directory |
                       Sort-Object LastWriteTime -Descending |
                       Select-Object -First 1).FullName
    }

    if (-not $outputPath) {
        throw "build did not produce an output path"
    }

    # 4) deploy
    $deploy = & "$PSScriptRoot\deploy.ps1" `
        -BuildPath $outputPath `
        -Provider  $Provider `
        -Client    $Client `
        `
        -DryRun:$DryRun

    # final status + url, but don't crash if deploy object is weird
    $status = if ($deploy -and $deploy.PSObject.Properties["status"]) {
        $deploy.status
    } elseif ($DryRun) {
        "DryRun"
    } else {
        "Unknown"
    }

    $url = if ($deploy -and $deploy.PSObject.Properties["url"]) {
        $deploy.url
    } else {
        ""
    }

    [pscustomobject]@{
        status = $status
        url    = $url
        output = $outputPath
    }
}
catch {
    Log "[ENGINE] Error -> $($_.Exception.Message)" -Level "Error" -Verbose:$Chatty
    [pscustomobject]@{
        status = "Failed"
        url    = ""
        output = $null
    }
}

