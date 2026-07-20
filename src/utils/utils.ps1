param()  # keep import quiet
Set-StrictMode -Version Latest

function Log {
  param([string]$Message,[ValidateSet("Info","Warn","Success","Error")]$Level="Info",[switch]$Verbose)
  if (-not $Verbose -and $Level -eq "Info") { return }
  $color = @{Info="Gray";Warn="Yellow";Success="Green";Error="Red"}[$Level]
  Write-Host ("[{0}] {1}" -f $Level.ToUpper(), $Message) -ForegroundColor $color
}

function Ensure-Directory { param([string]$Path,[switch]$Verbose)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Log "Created dir: $Path" -Verbose:$Verbose
  }
}

function Slugify {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) { return "page" }

  $s = $Text.ToLowerInvariant()
  $s = $s -replace '[^\w\s-]', ''
  $s = $s -replace '\s+', '_'
  $s = $s -replace '_+', '_'
  $s = $s.Trim('_')

  if ([string]::IsNullOrWhiteSpace($s)) { return "page" }

  return $s
}
