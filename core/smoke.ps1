param(
    [string]$Input    = "Jarvis Smoke Test Site",
    [string]$Client   = "smoke",
    [string]$Provider = "Folder"
)

pwsh -f "$PSScriptRoot\engine.ps1" -Input $Input -Client $Client -Provider $Provider
