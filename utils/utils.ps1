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

function Slugify { param([string]$Input)
  $s = $Input.ToLowerInvariant()
  $s = $s -replace '[^\w\s-]', '' -replace '\s+', '_' -replace '_+', '_'
  $s.Trim('_')
}
