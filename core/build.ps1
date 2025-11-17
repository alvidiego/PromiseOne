param(
    [Parameter(Mandatory)][string]$PlanFile,
    [switch]$Chatty,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\ai\memory.ps1"

Log "[BUILD] Plan: $PlanFile" -Level "Info" -Verbose:$Chatty

if (-not (Test-Path -LiteralPath $PlanFile)) {
    Log "[BUILD] Missing plan file." -Level "Error"
    exit 1
}

$plan      = Get-Content $PlanFile -Raw -Encoding UTF8 | ConvertFrom-Json
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$client    = $plan.client
$style     = $plan.style
$templateDir = Join-Path $TemplatesRoot $style

# ----- load layout -----
$layoutPath = Join-Path $templateDir "layout.html"
if (-not (Test-Path -LiteralPath $layoutPath)) {
    Log "[BUILD] Missing layout: $layoutPath" -Level "Error"
    exit 1
}
$baseLayout = Get-Content $layoutPath -Raw -Encoding UTF8

function Get-IncludeContent {
    param(
        [string]$Name,
        [string]$Style
    )
    $name = ($Name ?? '').Trim()
    if ($name -match '\.\.') { return "" }

    $rel  = if ($name -match '\.html?$') { $name } else { "$name.html" }
    $inc  = Join-Path (Join-Path $TemplatesRoot $Style) (Join-Path "components" $rel)

    if (Test-Path -LiteralPath $inc) {
        return Get-Content $inc -Raw -Encoding UTF8
    }
    return ""
}

function Inject-Includes {
    param(
        [string]$Html,
        [string]$Style
    )
    $out = $Html
    for ($i = 0; $i -lt 6; $i++) {
        if ($out -notmatch '\[\[INCLUDE:(.*?)\]\]') { break }
        $out = $out -replace '\[\[INCLUDE:(.*?)\]\]', { Get-IncludeContent -Name $matches[1] -Style $Style }
    }
    return $out
}

# ----- output folder -----
$output = Join-Path $SiteOutputRoot ("{0}_{1}" -f (Slugify $client), $timestamp)
if (-not $DryRun) {
    Ensure-Directory -Path $output -Verbose:$Chatty
}

# ----- copy assets -----
$assetsSrc = Join-Path $templateDir "assets"
if (-not $DryRun -and (Test-Path -LiteralPath $assetsSrc)) {
    Copy-Item -Path (Join-Path $assetsSrc '*') -Destination $output -Recurse -Force
}

# ----- NAV from plan.pages -----
$navLinks = foreach ($pp in $plan.pages) {
    $pslug = Slugify $pp.name
    $plang = if ($pp.PSObject.Properties.Name -contains 'lang' -and $pp.lang) { $pp.lang } else { 'en' }
    "<a href='$pslug.$plang.html'>$($pp.name)</a>"
}
$navHtml = "<nav class='nav'>" + ($navLinks -join ' | ') + "</nav>"

# ----- render pages -----
$pageIndex = @()
$firstFile = $null

foreach ($page in $plan.pages) {
    $html = Inject-Includes -Html $baseLayout -Style $style

    $lang = if ($page.PSObject.Properties.Name -contains 'lang' -and $page.lang) { $page.lang } else { 'en' }
    $content = if ($page.PSObject.Properties.Name -contains 'content') { $page.content } else { "" }
    $headExtras = if ($page.PSObject.Properties.Name -contains 'head_extras') { $page.head_extras } else { "" }

    $tokens = @{
        '[[TITLE]]'       = $page.name
        '[[CONTENT]]'     = $content
        '[[CLIENT]]'      = $client
        '[[LANG]]'        = $lang
        '[[STYLE]]'       = $style
        '[[TIMESTAMP]]'   = $timestamp
        '[[HEAD_EXTRAS]]' = $headExtras
        '[[NAV]]'         = $navHtml
    }

    foreach ($k in $tokens.Keys) {
        $html = $html.Replace($k, [string]$tokens[$k])
    }

    # strip any leftover [[TOKEN]]
    $html = $html -replace '\[\[\w+\]\]', ''

    $slug = Slugify $page.name
    $file = Join-Path $output ("{0}.{1}.html" -f $slug, $lang)

    if ($DryRun) {
        Log "[BUILD] (DryRun) Would write → $(Split-Path $file -Leaf)" -Level "Info"
    } else {
        $html | Out-File -FilePath $file
    }

    if (-not $firstFile) { $firstFile = $file }
    $pageIndex += [pscustomobject]@{
        page = $page.name
        file = (Split-Path $file -Leaf)
    }
}

# ----- index + summaries -----
if (-not $DryRun) {
    if ($firstFile) {
        Copy-Item -Path $firstFile -Destination (Join-Path $output "index.html") -Force
    }

    $pageIndex | ConvertTo-Json -Depth 3 |
        Out-File -FilePath (Join-Path $output "pages.json")

    if (-not $plan.PSObject.Properties["meta"]) {
        $plan | Add-Member -MemberType NoteProperty -Name meta -Value ([pscustomobject]@{}) -Force
    }

    $m = $plan.meta
    if (-not $m.PSObject.Properties["build_version"]) {
        $m | Add-Member -MemberType NoteProperty -Name build_version -Value "1.0.2" -Force
    } else {
        $m.build_version = "1.0.2"
    }
    if (-not $m.PSObject.Properties["output"]) {
        $m | Add-Member -MemberType NoteProperty -Name output -Value $output -Force
    } else {
        $m.output = $output
    }
    $plan.meta = $m

    $plan | ConvertTo-Json -Depth 8 |
        Out-File -FilePath (Join-Path $output "build_summary.json")

    Write-MemorySnapshot -Data $plan -Source "build.ps1" -Meta @{ output = $output } -Verbose:$Chatty
}

[pscustomobject]@{
    Client = $client
    Output = $output
    Pages  = $pageIndex
}
