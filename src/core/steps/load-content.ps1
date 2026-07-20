param(
    [Parameter(Mandatory)]
    [string]$contentPath
)

Set-StrictMode -Version Latest

if (!(Test-Path $contentPath)) {
    throw "Content path not found: $contentPath"
}

$sectionsPath = Join-Path $contentPath "sections"

if (!(Test-Path $sectionsPath)) {
    throw "Sections folder not found: $sectionsPath"
}

$sections = @{}

Get-ChildItem $sectionsPath -Filter *.json | ForEach-Object {
    $name = $_.BaseName
    $json = Get-Content $_.FullName -Raw | ConvertFrom-Json
    $sections[$name] = $json.content
}

# OUTPUT CONTRACT (this matters)
return @{
    sections = $sections
}
