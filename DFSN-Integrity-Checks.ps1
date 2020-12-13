#requires -version 3
<#
.SYNOPSIS
  DFS Namespace Integrity Checks

.DESCRIPTION
  Gets all DFS Namespace Roots and Folder Links and runs various dfsdiag tests against them.

.PARAMETER <Parameter_Name>
    n/a

.INPUTS
  n/a

.OUTPUTS
  to screen only.

.NOTES
  Version :        1.0
  Author :         Leon Evans
  Creation Date :  16/12/2016
  Location: https://gallery.technet.microsoft.com/scriptcenter/DFS-Namespace-Integrity-a27f7698?redir=0
  Purpose/Change: n/a

.EXAMPLE
  n/a
#>

# ---------------------------------------------------------
# INITIALISATIONS
# ---------------------------------------------------------

#1> define initialisations and global configurations
#2> list dot Source required Function Libraries

### TEST FOR/CREATE WORKING DIRECTORY C:\SCRIPTS\$teamname\$scriptname ###
#Modify the $teamname & $scriptname variables based on your team and script.

## DIRECTORY VARIABLES ##

$teamName = "WINTELBAU"        # MODIFY TO SUIT
$scriptName = "DFSN-INTEGRITY-CHECKS"    # MODIFY TO SUIT / ONLY REQUIRED IF SCRIPT PRODUCES OUTPUT/REPORTS

$scriptsRoot = "C:\SCRIPTS"

$scriptPaths = @()
$scriptPaths += "$scriptsRoot\$teamName\"


## OPTIONAL PATHS WHERE SCRIPT PRODUCES OUTPUT/REPORTS OR HAS DEDICATED INPUT FILES: ##
# UNCOMMENT AS REQURIED #

$scriptPaths += "$scriptsRoot\$teamName\$scriptName"
#$scriptPaths += "$scriptsRoot\$teamName\$scriptName\OUTPUTS"
#$scriptPaths += "$scriptsRoot\$teamName\$scriptName\REPORTS"
$scriptPaths += "$scriptsRoot\$teamName\$scriptName\INPUTS"


## TEST/CREATE PATHS: ##

foreach ($_ in $scriptPaths) {
	if ((Test-Path "$_") -eq $false) { New-Item -Path "$_" -ItemType Directory }
}

if ((Split-Path $script:MyInvocation.MyCommand.Path) -notlike "$scriptsRoot\$teamName*") {
	Write-Host "Script not initialised from correct location. Please ensure the script file is stored within $scriptsRoot\$teamName and run again." -foregroundColor Red
	exit
}

# $ErrorActionPreference = "SilentlyContinue"

# . "C:\Scripts\Functions\Logging_Functions.ps1"

# ---------------------------------------------------------
# DECLARATIONS
# ---------------------------------------------------------

#3> define and declare variables here
#e.g.
#$sScriptVersion = "1.0"
#Log File Info
#$sLogPath = "C:\Windows\Temp"
#$sLogName = "<script_name>.log"
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName


## DEFAULT VARIABLES ##

$inputs = "$scriptsRoot\$teamName\$scriptName\INPUTS"


## GET ALL DFSN ROOTS AND FOLDER LINKS ##
$dfsnroots = (Get-DfsnRoot).Path

foreach ($_ in $dfsnroots) {
	(Get-DfsnFolder -Path "$_\*").Path >> "$inputs\DfsnFolders.txt"
}

$dfsnfolders = Get-Content -Path "$inputs\DfsnFolders.txt"


# ---------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------

#4> primary functions and helpers should be abstracted here


# ---------------------------------------------------------
# EXECUTION
# ---------------------------------------------------------

#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

#6> execution, actions and callbacks should be placed here

Clear-Host
### TEST DFSNROOTS AD SITES ###
Write-Host "--== TESTING DFSN ROOTS AD SITES ==--" -BackgroundColor Red -ForegroundColor White
foreach ($_ in $dfsnroots) {
	""; ""
	Write-Host "STARTING TEST ON $_" -BackgroundColor Black -ForegroundColor Green
	dfsdiag /testsites /dfspath:"$_" /recurse /full
}


### TEST DFSN ROOT FOLDER LINKS AD SITES ###
""; ""; ""; ""
Write-Host "--== TESTING DFSNROOT FOLDER LINKS AD SITES ==--" -BackgroundColor Red -ForegroundColor White
foreach ($_ in $dfsnfolders) {
	""; ""
	Write-Host "STARTING TEST ON $_" -BackgroundColor Black -ForegroundColor Green
	dfsdiag /testsites /dfspath:"$_" /recurse /full
}


### TEST NAMESPACE CONFIGURATION ###
""; ""; ""; ""
Write-Host "--== TESTING NAMESPACE CONFIGURATION ==--" -BackgroundColor Red -ForegroundColor White
foreach ($_ in $dfsnroots) {
	""; ""
	Write-Host "STARTING TEST ON $_" -BackgroundColor Black -ForegroundColor Green
	dfsdiag /testdfsconfig /dfsroot:"$_"
}


### TEST NAMESPACE INTEGRITY ###
""; ""; ""; ""
Write-Host "--== TESTING NAMESPACE INTEGRITY ==--" -BackgroundColor Red -ForegroundColor White
foreach ($_ in $dfsnroots) {
	""; ""
	Write-Host "STARTING TEST ON $_" -BackgroundColor Black -ForegroundColor Green
	dfsdiag /testdfsintegrity /dfsroot:"$_" /recurse /full
}


### CLEANUP ###
Write-Host "--== CLEANING UP ==--" -BackgroundColor Red -ForegroundColor White

Remove-Item -Path "$inputs\DfsnFolders.txt" -Force
$dfsnfolders = $null

Write-Host "--== CLEAN UP COMPLETED SUCCESSFULLY ==--" -BackgroundColor Red -ForegroundColor White


#Log-Finish -LogPath $sLogFile