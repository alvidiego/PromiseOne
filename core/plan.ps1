param(
  [Parameter(Mandatory)][string]$TriggerFile,
  [switch]$DryRun
)
Set-StrictMode -Version Latest
$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\ai\memory.ps1"

Log "[PLAN] Trigger: $TriggerFile" -Level "Info" 

if (-not (Test-Path -LiteralPath $TriggerFile)) {
  $cand = Get-ChildItem -Path $TriggerFile -File -ErrorAction SilentlyContinue |
          Sort-Object LastWriteTime -Desc | Select-Object -First 1
  if (-not $cand) { Log "[PLAN] Missing trigger file." -Level "Error"; exit 1 }
  $TriggerFile = $cand.FullName
}

$trigger = Get-Content $TriggerFile -Raw -Encoding UTF8 | ConvertFrom-Json

$pages = foreach ($p in $trigger.pages) {
  if ($p -is [string]) { [pscustomobject]@{ name=$p; content=""; layout="default"; head_extras=""; lang="en" } }
  else { $p }
}

$plan = [ordered]@{
  goal=$trigger.goal; client=$trigger.client; style=$trigger.style; pages=$pages
  meta=@{ created=(Get-Date).ToString("o"); version="1.0.1"; source="plan.ps1"; trigger=$TriggerFile }
}

Ensure-Directory -Path $MemoryRoot 
$planPath = Join-Path $MemoryRoot "latest_plan.json"

if ($DryRun) {
  Log "[PLAN] (DryRun) Would write â†’ $planPath" -Level "Info"
} else {
  $plan | ConvertTo-Json -Depth 8 | Out-File -FilePath $planPath
  Log "[PLAN] Plan saved â†’ $planPath" -Level "Success"
  Write-MemorySnapshot -Data $plan -Source "plan.ps1" -Meta @{ path=$planPath } 
}

$plan







