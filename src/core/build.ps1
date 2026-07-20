# ==========================================
# File: core\build.ps1
# Version: MAIN until dynamic
# Role: Renders HTML from plan using templates/<style>
# Notes: PowerShell 5.1 safe
# ==========================================

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PlanFile,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\ai\memory.ps1"

$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')

Log "[BUILD] Plan: $PlanFile" -Level "Info" -Verbose:$VerboseOn

if (-not (Test-Path -LiteralPath $PlanFile)) {
    Log "[BUILD] Missing plan file: $PlanFile" -Level "Error" -Verbose:$VerboseOn
    exit 1
}

$plan        = Get-Content -LiteralPath $PlanFile -Raw -Encoding UTF8 | ConvertFrom-Json
$timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
$client      = [string]$plan.client
$style       = [string]$plan.style
$templateDir = Join-Path $TemplatesRoot $style

# ----- load layout -----
$layoutPath = Join-Path $templateDir "layout.html"
if (-not (Test-Path -LiteralPath $layoutPath)) {
    Log "[BUILD] Missing layout: $layoutPath" -Level "Error" -Verbose:$VerboseOn
    exit 1
}
$baseLayout = Get-Content -LiteralPath $layoutPath -Raw -Encoding UTF8

# ----- load requested modules -----
$moduleDefinitions = @{}

if ($plan.PSObject.Properties.Name -contains 'modules' -and $null -ne $plan.modules) {
    foreach ($moduleProperty in $plan.modules.PSObject.Properties) {
        $moduleName = [string]$moduleProperty.Name
        $moduleConfig = $moduleProperty.Value

        if ($moduleName -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
            throw "[MODULE] Invalid module name: $moduleName"
        }

        $moduleDir = Join-Path $ModulesRoot $moduleName
        $manifestPath = Join-Path $moduleDir "module.json"
        if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
            throw "[MODULE] Module '$moduleName' is not available. Expected: $manifestPath"
        }

        $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ([string]$manifest.name -ne $moduleName) {
            throw "[MODULE] Manifest name does not match requested module '$moduleName'."
        }

        foreach ($settingName in @($manifest.required_settings)) {
            $settingProperty = $moduleConfig.PSObject.Properties[[string]$settingName]
            if ($null -eq $settingProperty -or [string]::IsNullOrWhiteSpace([string]$settingProperty.Value)) {
                throw "[MODULE] Module '$moduleName' requires setting '$settingName'."
            }
        }

        if ($manifest.PSObject.Properties.Name -contains 'allowed_providers') {
            $provider = [string]$moduleConfig.provider
            if (@($manifest.allowed_providers) -notcontains $provider) {
                throw "[MODULE] Provider '$provider' is not supported by module '$moduleName'."
            }
        }

        if ($manifest.PSObject.Properties.Name -contains 'endpoint_prefix') {
            $endpoint = [string]$moduleConfig.endpoint
            $endpointPrefix = [string]$manifest.endpoint_prefix
            if (-not $endpoint.StartsWith($endpointPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "[MODULE] Module '$moduleName' endpoint must begin with '$endpointPrefix'."
            }
        }

        $defaultComponent = Join-Path $moduleDir "component.en.html"
        if (-not (Test-Path -LiteralPath $defaultComponent -PathType Leaf)) {
            throw "[MODULE] Module '$moduleName' is missing component.en.html."
        }

        $moduleDefinitions[$moduleName] = [pscustomobject]@{
            Config    = $moduleConfig
            Directory = $moduleDir
        }
    }
}

function Get-IncludeContent {
    param(
        [string]$Name,
        [string]$Style
    )

    if ($null -eq $Name) { $Name = "" }
    $name = $Name.Trim()

    if ($name -match '\.\.') { return "" }

    if ($name -match '\.html?$') {
        $rel = $name
    } else {
        $rel = "$name.html"
    }

    $inc = Join-Path (Join-Path $TemplatesRoot $Style) (Join-Path "components" $rel)

    if (Test-Path -LiteralPath $inc) {
        return Get-Content -LiteralPath $inc -Raw -Encoding UTF8
    }

    return ""
}

function Inject-Includes {
    param(
        [string]$Html,
        [string]$Style
    )

    $out = $Html
    $pattern = '\[\[INCLUDE:(.*?)\]\]'

    for ($i = 0; $i -lt 6; $i++) {
        if ($out -notmatch $pattern) { break }

        $out = [regex]::Replace(
            $out,
            $pattern,
            {
                param($match)
                Get-IncludeContent -Name $match.Groups[1].Value -Style $Style
            }
        )
    }

    return $out
}

function Get-PnModuleContent {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Lang
    )

    $moduleName = $Name.ToLowerInvariant()
    if (-not $moduleDefinitions.ContainsKey($moduleName)) { return "" }

    $definition = $moduleDefinitions[$moduleName]
    $componentPath = Join-Path $definition.Directory ("component.{0}.html" -f $Lang)
    if (-not (Test-Path -LiteralPath $componentPath -PathType Leaf)) {
        $componentPath = Join-Path $definition.Directory "component.en.html"
    }

    $component = Get-Content -LiteralPath $componentPath -Raw -Encoding UTF8
    foreach ($setting in $definition.Config.PSObject.Properties) {
        $tokenName = $setting.Name.ToUpperInvariant().Replace('-', '_')
        $token = "[[MODULE_SETTING_${tokenName}]]"
        $safeValue = [System.Net.WebUtility]::HtmlEncode([string]$setting.Value)
        $component = $component.Replace($token, $safeValue)
    }

    if ($component -match '\[\[MODULE_SETTING_[A-Z0-9_]+\]\]') {
        throw "[MODULE] Module '$moduleName' contains an unresolved setting token."
    }

    return $component
}

function Inject-Modules {
    param(
        [string]$Html,
        [string]$Lang
    )

    return [regex]::Replace(
        $Html,
        '\[\[MODULE:([a-z0-9-]+)\]\]',
        {
            param($match)
            Get-PnModuleContent -Name $match.Groups[1].Value -Lang $Lang
        },
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
}

# ----- output folder -----
$output = Join-Path $SiteOutputRoot ("{0}_{1}" -f (Slugify $client), $timestamp)
if (-not $DryRun) {
    Ensure-Directory -Path $output -Verbose:$VerboseOn
}

# ----- copy assets -----
$assetsSrc = Join-Path $templateDir "assets"
if (-not $DryRun -and (Test-Path -LiteralPath $assetsSrc)) {
    $assetsDest = Join-Path $output "assets"
    Ensure-Directory -Path $assetsDest -Verbose:$VerboseOn
    Copy-Item -Path (Join-Path $assetsSrc '*') -Destination $assetsDest -Recurse -Force -ErrorAction SilentlyContinue
}

# ----- NAV from plan.pages -----
function New-PnNavHtml {
    param(
        [Parameter(Mandatory)]
        $Pages,

        [Parameter(Mandatory)]
        [string]$Lang
    )

    $seenNav = @{}
    $navLinks = @()

    foreach ($pp in $Pages) {
        $plang = if ($pp.PSObject.Properties.Name -contains 'lang' -and $pp.lang) {
            [string]$pp.lang
        } else {
            'en'
        }

        if ($plang -ne $Lang) { continue }

        $pageName = [string]$pp.name
        $key = $pageName.ToLowerInvariant()

        if ($seenNav.ContainsKey($key)) { continue }
        $seenNav[$key] = $true

        $pslug = Slugify $pageName
        $label = $pageName

        if ($Lang -eq 'es') {
            switch ($pageName.ToLowerInvariant()) {
                'home'     { $label = 'Inicio' }
                'index'    { $label = 'Inicio' }
                'services' { $label = 'Servicios' }
                'gallery'  { $label = 'Galeria' }
                'work'     { $label = 'Trabajos' }
                'about'    { $label = 'Nosotros' }
                'contact'  { $label = 'Contacto' }
                default    { $label = $pageName }
            }
        }

        $navLinks += "<a href='$pslug.$plang.html'>$label</a>"
    }

    return ($navLinks -join ' <span class="sep">|</span> ')
}

# ----- render pages -----
$pageIndex = @()
$firstFile = $null

foreach ($page in $plan.pages) {
    $html = Inject-Includes -Html $baseLayout -Style $style

    if ($page.PSObject.Properties.Name -contains 'lang' -and $page.lang) {
        $lang = [string]$page.lang
    } else {
        $lang = 'en'
    }

    if ($page.PSObject.Properties.Name -contains 'content' -and $null -ne $page.content) {
        $content = [string]$page.content
    } else {
        $content = ""
    }

    if ($page.PSObject.Properties.Name -contains 'head_extras' -and $null -ne $page.head_extras) {
        $headExtras = [string]$page.head_extras
    } else {
        $headExtras = ""
    }

   $pageTitle = [string]$page.name

if ($lang -eq 'es') {
    switch ($pageTitle.ToLowerInvariant()) {
        'home'     { $pageTitle = 'Inicio' }
        'index'    { $pageTitle = 'Inicio' }
        'services' { $pageTitle = 'Servicios' }
        'gallery'  { $pageTitle = 'Galeria' }
        'work'     { $pageTitle = 'Trabajos' }
        'about'    { $pageTitle = 'Nosotros' }
        'contact'  { $pageTitle = 'Contacto' }
    }
}

$tokens = @{
    '[[TITLE]]'       = $pageTitle
        '[[CONTENT]]'     = $content
        '[[CLIENT]]'      = $client
        '[[LANG]]'        = $lang
        '[[STYLE]]'       = $style
        '[[TIMESTAMP]]'   = $timestamp
        '[[HEAD_EXTRAS]]' = $headExtras
        '[[NAV]]'         = (New-PnNavHtml -Pages $plan.pages -Lang $lang)
    }

    foreach ($k in $tokens.Keys) {
        $html = $html.Replace($k, [string]$tokens[$k])
    }

    $html = Inject-Modules -Html $html -Lang $lang
    $html = $html -replace '\[\[MODULE:[^\]]+\]\]', ''
    $html = $html -replace '\[\[\w+\]\]', ''

    $slug = Slugify $page.name
    $file = Join-Path $output ("{0}.{1}.html" -f $slug, $lang)

    if ($DryRun) {
        Log "[BUILD] (DryRun) Would write -> $(Split-Path $file -Leaf)" -Level "Info" -Verbose:$VerboseOn
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
    # Create friendly language indexes
$homeEn = $null
$homeEs = $null

foreach ($idx in $pageIndex) {
    $pageName = ([string]$idx.page).ToLowerInvariant()
    $fileName = [string]$idx.file

    if (($pageName -eq "home" -or $pageName -eq "index") -and $fileName -eq "home.en.html") {
        $homeEn = Join-Path $output $fileName
    }

    if (($pageName -eq "home" -or $pageName -eq "index") -and $fileName -eq "home.es.html") {
        $homeEs = Join-Path $output $fileName
    }
}

if ($homeEn -and (Test-Path -LiteralPath $homeEn)) {
    Copy-Item -Path $homeEn -Destination (Join-Path $output "index.html") -Force
}
elseif ($firstFile) {
    Copy-Item -Path $firstFile -Destination (Join-Path $output "index.html") -Force
}

if ($homeEs -and (Test-Path -LiteralPath $homeEs)) {
    Copy-Item -Path $homeEs -Destination (Join-Path $output "index.es.html") -Force
}

    $pageIndex | ConvertTo-Json -Depth 3 |
        Out-File -FilePath (Join-Path $output "pages.json")

    # --- meta (robust) ---
    if (
        (-not ($plan.PSObject.Properties.Name -contains "meta")) -or
        ($null -eq $plan.meta) -or
        ($plan.meta -is [string]) -or
        ($plan.meta -is [array])
    ) {
        $plan | Add-Member -MemberType NoteProperty -Name meta -Value ([pscustomobject]@{}) -Force
    }

    $plan.meta | Add-Member -MemberType NoteProperty -Name build_version -Value "1.1.1" -Force
    $plan.meta | Add-Member -MemberType NoteProperty -Name output -Value $output -Force

    $plan | ConvertTo-Json -Depth 8 |
        Out-File -FilePath (Join-Path $output "build_summary.json")

    $null = Write-MemorySnapshot -Data $plan -Source "build.ps1" -Meta @{ output = $output } -Verbose:$VerboseOn

    $latest = Join-Path $SiteOutputRoot "latest"
    if (Test-Path -LiteralPath $latest) {
        Remove-Item -LiteralPath $latest -Recurse -Force
    }

    Copy-Item -Path $output -Destination $latest -Recurse -Force
}

[pscustomobject]@{
    Client = $client
    Output = $output
    Pages  = $pageIndex
}
