# ==========================================
# PROMISEONE STANDARDIZATION CHECKLIST
# ==========================================

========================
1. HEADER STANDARD
========================
[ ] File name correct
[ ] Role clearly stated (1 sentence)
[ ] Notes minimal (no fake version reliance)

========================
2. PARAM BLOCK
========================
[ ] Uses [CmdletBinding()]
[ ] Required params marked
[ ] Consistent param names

[ ] [switch]$DryRun declared IF used

========================
3. SETUP
========================
[ ] Set-StrictMode
[ ] UTF8 encoding
[ ] config + utils loaded

========================
4. VERBOSE
========================
[ ] $VerboseOn pattern used
[ ] -Verbose:$VerboseOn used

========================
5. LOGGING
========================
[ ] Log function used
[ ] Correct prefixes

========================
6. DRYRUN
========================
[ ] No real actions when DryRun
[ ] Logs instead

========================
7. ERRORS
========================
[ ] Validates inputs
[ ] Uses throw or exit 1
[ ] No silent failures

========================
8. PATHS
========================
[ ] Uses Join-Path
[ ] No hardcoding

========================
9. OUTPUT
========================
[ ] Returns ONE object

========================
10. RESPONSIBILITY
========================
advisor = input -> trigger
plan    = trigger -> plan
build   = plan -> site
deploy  = site -> published

========================
11. CLEANUP
========================
[ ] No dead code
[ ] No debug leftovers
