param(
  [Parameter(Mandatory)][Alias('Input')][string]$UserInput,
  [string]$Client = "default",
  [switch]$DryRun
)
Set-StrictMode -Version Latest
$VerboseOn = $PSBoundParameters.ContainsKey('Verbose')
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
. "$PSScriptRoot\..\utils\config.ps1"
. "$PSScriptRoot\..\utils\utils.ps1"

Log "[ADVISOR] Starting with input '$UserInput' (client=$Client)" -Level "Info" 
Ensure-Directory -Path $TriggerLogsRoot 

$slug      = Slugify $UserInput
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$trigger   = [ordered]@{
  type="Build"; goal=$UserInput; client=$Client; style="default";
  pages=@("Home","About","Contact");
  meta=@{ created=(Get-Date).ToString("o"); source="advisor.ps1"; version="1.0.1" }
}
$path = Join-Path $TriggerLogsRoot ("trigger_{0}_{1}.json" -f $slug,$timestamp)

if ($DryRun) {
  Log "[ADVISOR] (DryRun) Would write trigger â†’ $path" -Level "Info" 
} else {
  $trigger | ConvertTo-Json -Depth 6 | Out-File -FilePath $path
  Log "[ADVISOR] Trigger saved â†’ $path" -Level "Success" 
}

[pscustomobject]@{ Path=$path; Name=(Split-Path $path -Leaf); Data=$trigger }








