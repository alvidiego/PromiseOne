# ==========================================
# File: core\deploy.ps1
# Version: 1.0.1
# Role: Publish a built folder (Folder | Vercel | GitHub)
# ==========================================

param(
  [string]$BuildPath,
  [ValidateSet("Folder","Vercel","GitHub")] [string]$Provider = "Folder",
  [string]$ProjectName = "",
  [string]$Client = "default",
  [switch]$AutoOpen,
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"

# Handy: latest build if none given
function _LatestBuild {
  if (-not (Test-Path -LiteralPath $SiteOutputRoot)) { return $null }
  (Get-ChildItem -Path $SiteOutputRoot -Directory |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1).FullName
}

if (-not $BuildPath) { $BuildPath = _LatestBuild }
if (-not $BuildPath -or -not (Test-Path -LiteralPath $BuildPath)) {
  Log "[DEPLOY] Build path not found: $BuildPath" -Level "Error" 
  exit 1
}

$timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
$deployLabel = "{0}_{1}_{2}" -f (Slugify $Client), $Provider, $timestamp
$logFile     = Join-Path $DeploymentsPath ($deployLabel + ".json")

$summary = [ordered]@{
  client=$Client; provider=$Provider; buildPath=$BuildPath; project=$ProjectName;
  timestamp=(Get-Date).ToString("o"); status="Pending"; url=""; notes=@()
}
function Note([string]$m){ $summary.notes += $m; Log $m -Level "Info"  }

# --- Provider: Folder (local copy) ---
function Deploy-Folder {
  $target = Join-Path $DeploymentsPath $deployLabel
  if ($DryRun) { Note "[Folder] Would copy â†’ $target"; return @{ url=$target } }
  Ensure-Directory -Path $DeploymentsPath 
  Ensure-Directory -Path $target 
  Copy-Item -Path (Join-Path $BuildPath '*') -Destination $target -Recurse -Force
  @{ url=$target }
}

# --- Provider: Vercel ---
function Deploy-Vercel {
  $vercel = Get-Command vercel -ErrorAction SilentlyContinue
  if (-not $vercel) {
    Note "Missing vercel CLI. Install: npm i -g vercel  |  then run: vercel login"
    return @{ url=""; error="Missing vercel CLI" }
  }
  if ($DryRun) { Note "[Vercel] Would deploy --prod --yes"; return @{ url="" } }

  Push-Location $BuildPath
  try {
    $args = @("deploy","--prod","--yes")
    if ($ProjectName) { $args += @("--name",$ProjectName) }
    $out = & vercel @args 2>&1
    $url = ($out | Select-String -Pattern 'https?://[^\s]+' | Select-Object -Last 1).Matches.Value
    if (-not $url) { return @{ url=""; error="No URL parsed; ensure vercel login/scope" } }
    @{ url=$url }
  } catch {
    @{ url=""; error=$_.Exception.Message }
  } finally {
    try { Pop-Location | Out-Null } catch {}
  }
}

# --- Provider: GitHub Pages (gh-pages force push) ---
function Deploy-GitHub {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Note "Missing git CLI. Install git and ensure itâ€™s in PATH."
    return @{ url=""; error="Missing git CLI" }
  }
  if ($DryRun) { Note "[GitHub] Would push gh-pages"; return @{ url="" } }
  if (-not $env:GITHUB_REPO -or -not $env:GITHUB_TOKEN) {
    Note "Missing env vars. Set GITHUB_REPO='owner/repo' and GITHUB_TOKEN='ghp_...'"
    return @{ url=""; error="Missing GITHUB_REPO/TOKEN" }
  }

  $tmp = Join-Path $env:TEMP ("pn_gh_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
  try {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -Recurse -Force $tmp }
    New-Item -ItemType Directory -Path $tmp | Out-Null
    Copy-Item -Path (Join-Path $BuildPath '*') -Destination $tmp -Recurse -Force
    New-Item -ItemType File -Path (Join-Path $tmp ".nojekyll") -Force | Out-Null
    if ($env:GITHUB_CNAME) { Set-Content -Path (Join-Path $tmp "CNAME") -Value $env:GITHUB_CNAME }

    Push-Location $tmp
    git init | Out-Null
    git checkout -b gh-pages | Out-Null
    git add .; git commit -m "Deploy $deployLabel" | Out-Null
    $remote = "https://$($env:GITHUB_TOKEN)@github.com/$($env:GITHUB_REPO).git"
    git remote add origin $remote | Out-Null
    git push -f origin gh-pages | Out-Null
    $owner = ($env:GITHUB_REPO -split '/')[0]; $repo=($env:GITHUB_REPO -split '/')[1]
    @{ url = "https://$owner.github.io/$repo/" }
  } catch {
    @{ url=""; error=$_.Exception.Message }
  } finally {
    try { Pop-Location | Out-Null } catch {}
    if (Test-Path -LiteralPath $tmp) { Remove-Item -Recurse -Force $tmp }
  }
}

# Dispatch
$result = switch ($Provider) {
  "Folder" { Deploy-Folder }
  "Vercel" { Deploy-Vercel }
  "GitHub" { Deploy-GitHub }
}

$summary.url    = $result.url
$summary.status = if ( ($null -ne $result) -and ($result.PSObject.Properties["error"]) -and $result.error ) { "Failed" } else { "Deployed" }

if ($DryRun) {
  Note "[DEPLOY] (DryRun) Would write log â†’ $logFile"
} else {
  Ensure-Directory -Path $DeploymentsPath 
  $summary | ConvertTo-Json -Depth 8 | Out-File -FilePath $logFile
}

if ($AutoOpen -and -not $DryRun) {
  if ($summary.url -and $Provider -ne "Folder")      { Start-Process $summary.url }
  elseif ($Provider -eq "Folder" -and (Test-Path $summary.url)) { Start-Process $summary.url }
  elseif (Test-Path -LiteralPath $logFile)           { Start-Process $logFile }
}
if ( ($null -ne $result) -and ($result.PSObject.Properties["error"]) -and $result.error ) { Log "[DEPLOY] Failed: $($result.error)" -Level "Error" ; exit 1 }
Log "[DEPLOY] Success ($Provider) â†’ $($summary.url)" -Level "Success" 
[pscustomobject]$summary









