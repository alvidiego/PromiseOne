param(
    [string]$UserInput = "Jarvis Smoke Test Site",
    [string]$Client    = "smoke",
    [string]$Provider  = "Folder"
)

pwsh -f ".\core\engine.ps1" -UserInput $UserInput -Client $Client -Provider $Provider
