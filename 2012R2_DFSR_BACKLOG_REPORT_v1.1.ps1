#requires -version 4.0
<#
.SYNOPSIS
  Gets the DFSR Backlog between two DFSR Servers.
  SERVER 2012 R2 ONLY
  Get-module -ListAvailable
  This Script does not work with the Server 2012 ScriptCenter DFSR Module v1.1.1

.DESCRIPTION
  Gets all DFSR Connections between two specified DFSR Servers
  Runs dfsrdiag.exe comdlet to get backlog of each folder.
  Outputs figures to .txt files and then gets a total backlog figure from the contents of the files.
  Gets Backlog figures in both directions between the two servers specified.

  NEW FEATURES OF V1.1:
  * Script entirely re-written to use just dfsrdiag.exe as PowerShell cmdlet Get-DfsrBacklog too unreliable.
  * Script now handles and reports dfsrdiag errors and notifies inaccurate total backlog figures if errors occur.

.PARAMETER <Parameter_Name>
    n/a

.INPUTS
  n/a

.OUTPUTS
  script outputs two plain text files to get the backlog figures for both servers:
  C:\SCRIPTS\DFSR-BACKLOG\reports\<servername>-Folder-Backlog-Report.txt
  C:\SCRIPTS\DFSR-BACKLOG\reports\<servername>-TOTAL-Backlog-Report.txt

.NOTES
  Version :        1.1
  Author :         Leon Evans
  Creation Date :  19/01/2017
  Location : https://gallery.technet.microsoft.com/scriptcenter/DFSR-Backlog-Automated-a2e18d5b?redir=0
  Purpose/Change: removed Get-DfsrBacklog and replaced with dfsrdiag.exe. Added error reporting.

.EXAMPLE
  n/a
#>

# ---------------------------------------------------------
# INITIALISATIONS
# ---------------------------------------------------------
### TEST FOR/CREATE WORKING DIRECTORY C:\SCRIPTS\DFSR-BACKLOG ###

### DIRECTORY VARIABLES ###

$scriptsRoot = 'C:\SCRIPTS\DFSR-BACKLOG'

$scriptPaths = @()
$scriptPaths += "$scriptsRoot\$teamName\$scriptName\OUTPUTS"
$scriptPaths += "$scriptsRoot\$teamName\$scriptName\REPORTS"


### TEST/CREATE PATHS: ###
foreach ($_ in $scriptPaths) {
	if ((Test-Path "$_") -eq $false) { New-Item -Path "$_" -ItemType Directory }
}


#1> define initialisations and global configurations
#2> list dot Source required Function Libraries

# ---------------------------------------------------------
# DECLARATIONS
# ---------------------------------------------------------

### DEFAULT OUTPUT VARIABLES ###
$reports = "$scriptsRoot\REPORTS"
$outputs = "$scriptsRoot\OUTPUTS"


### INPUT YOUR TWO DFS SERVERS: ###
$S1 = 'HOSTNAME1'	#MODIFY THIS VARIABLE TO SUIT
$S2 = 'HOSTNAME2'	#MODIFY THIS VARIABLE TO SUIT


### GET ALL REPLICATED FOLDERS FOR BOTH SERVERS: ###
# This gives the following: -GroupName and -FolderName
$connection1 = Get-DfsrConnection | Where-Object { $_.SourceComputerName -eq "$S1" } | `
		Get-DfsReplicatedFolder | Sort-Object -Property FolderName
$connection2 = Get-DfsrConnection | Where-Object { $_.SourceComputerName -eq "$S2" } | `
		Get-DfsReplicatedFolder | Sort-Object -Property FolderName


### ENSURE OUTPUTS FOLDER EMPTY ###
Get-ChildItem -Path $outputs | Remove-Item -Force
Start-Sleep 1


### CREATE TEMP OUTPUT FILES ###
$temp = $null

## SERVER1 TEMP FILES ##
New-Item -Path "$outputs\S1errors.txt" -ItemType File -Force > $temp
$S1errors = "$outputs\S1errors.txt"

New-Item -Path "$outputs\S1foldercounts.txt" -ItemType File -Force > $temp
$S1foldercounts = "$outputs\S1foldercounts.txt"

New-Item -Path "$outputs\S1count.txt" -ItemType File -Force > $temp
$S1count = "$outputs\S1count.txt"

## SERVER2 TEMP FILES ##
New-Item -Path "$outputs\S2errors.txt" -ItemType File -Force > $temp
$S2errors = "$outputs\S2errors.txt"

New-Item -Path "$outputs\S2foldercounts.txt" -ItemType File -Force > $temp
$S2foldercounts = "$outputs\S2foldercounts.txt"

New-Item -Path "$outputs\S2count.txt" -ItemType File -Force > $temp
$S2count = "$outputs\S2count.txt"


### REPORT FILES ###
$S1FolderReport = "$reports\$S1-Folder-Backlog-Report.txt"
$S1TotalReport = "$reports\$S1-TOTAL-Backlog-Report.txt"
$S2FolderReport = "$reports\$S2-Folder-Backlog-Report.txt"
$S2TotalReport = "$reports\$S2-TOTAL-Backlog-Report.txt"


# ---------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------

#4> primary functions and helpers should be abstracted here

# ---------------------------------------------------------
# EXECUTION
# ---------------------------------------------------------

### PREP CLEANUP ###
# CLEAR TEMP OUTPUT VARIABLES #
$temp = $null
$content0 = $null
$content1 = $null
$S1totalcount = $null
$S2totalcount = $null
$S1errorwarning = $null
$S2errorwarning = $null
$S1totalbacklog = $null
$S2totalbacklog = $null



####################
# SERVER 1 BACKLOG #
####################

Clear-Host
### INDIVIDUAL FOLDER BACKLOG: ###
Write-Host "--== DFSR BACKLOG FOR SERVER $S1 ==--" -BackgroundColor Black -ForeGroundColor Cyan
''
Start-Sleep 1

Foreach ($_ in $connection1) {
	$rfname = "$($_.FolderName)"
	$rgname = "$($_.GroupName)"
	$dfsrdiag = "$outputs\$S1-$rfname-dfsrdiag.txt"

	Write-Host "PROCESSING FOLDER - $rfname" -ForegroundColor Green
	dfsrdiag.exe backlog /sendingmember:$S1 /receivingmember:$S2 /rfname:$rfname /rgname:$rgname > $dfsrdiag
}
''
''
## ANALYSE AND PARSE DFSRDIAG OUTPUT ##
Start-Sleep 1

Foreach ($_ in $connection1) {
	$rfname = "$($_.FolderName)"
	$rgname = "$($_.GroupName)"
	$dfsrdiag = "$outputs\$S1-$rfname-dfsrdiag.txt"
	$content0 = Get-Content -Path $dfsrdiag | Select-Object -Index 0
	$content1 = Get-Content -Path $dfsrdiag | Select-Object -Index 1

	if ($content0 -ne "$null") {
		Add-Content -Path $s1errors -Value "$rfname - $content0"
	}
	if ($content0 -eq "$null") {
		Add-Content -Path $S1foldercounts -Value "$rfname - $content1"
	}
}

## CREATE TOTAL COUNT FILE ##
$S1totalcount = Get-Content -Path $S1foldercounts | Where-Object { $_ -like '*count*' }

foreach ($_ in $S1totalcount) {
	$_.split(':')[1] | Out-File -FilePath $S1count -Append
}


## DISPLAY FOLDER BACKLOG COUNTS TO SCREEN ##
$S1errorwarning = Get-Content -Path $S1errors

Write-Host 'FOLDER STATUS:' -ForegroundColor Green
Get-Content -Path $S1foldercounts
''
''
if ($S1errorwarning -ne $null) {
	Write-Host 'FOLDERS WITH ERRORS:' -ForegroundColor Green
	Get-Content -Path $S1errors
	''
	''
}


###################################
#### TOTAL BACKLOG FOR SERVER1: ###
###################################



### SERVER1 TOTAL BACKLOG FIGURE ###
Start-Sleep 1

Write-Host "--== TOTAL BACKLOG FOR SERVER $S1 ==--" -BackgroundColor Black -ForeGroundColor Cyan

if ($S1errorwarning -ne $null) {
	Write-Host 'WARNING: THERE WERE ERRORS RECORDED. BACKLOG TOTAL FIGURE IS INACCURATE' `
		-BackgroundColor Black -ForegroundColor Red
	$S1totalbacklog = Get-Content -Path $S1count | Measure-Object -Sum
	Write-Host "TOTAL BACKLOG FOR SERVER $S1 ="($S1totalbacklog).sum" (FIGURE NOT ACCURATE DUE TO ERRORS)" `
		-BackgroundColor Black -ForegroundColor Green
}
Else {
	$S1totalbacklog = Get-Content -Path $S1count | Measure-Object -Sum
	Write-Host "TOTAL BACKLOG FOR SERVER $S1 ="($S1totalbacklog).sum"" `
		-BackgroundColor Black -ForegroundColor Green
}
''
''


#######################################
### UPDATE REPORT FILES FOR SERVER1 ###
#######################################

Write-Host "WRITING TO REPORT FILES FOR $S1 IN $reports" -BackgroundColor Black -ForeGroundColor Yellow
''
''

### UPDATE FOLDER COUNT REPORT ###
(Get-Date).ToString() 1>>$S1FolderReport
$S1 1>>$S1FolderReport
Get-Content -Path $S1foldercounts 1>>$S1FolderReport
Get-Content -Path $S1errors 1>>$S1FolderReport
'' 1>>$S1FolderReport

### UPDATE TOTAL BACKLOG COUNT REPORT ###
(Get-Date).ToString() 1>>$S1TotalReport
$S1 1>>$S1TotalReport
if ($S1errorwarning -eq $null) {
	($S1totalbacklog).sum 1>>$S1TotalReport
}
Else {
	($S1totalbacklog).sum 1>>$S1TotalReport
	Add-Content -Path $S1TotalReport -Value "ERRORS: VALUE NOT ACCURATE"
}
'' 1>>$S1TotalReport





####################
# SERVER 2 BACKLOG #
####################


### INDIVIDUAL FOLDER BACKLOG: ###
Write-Host "--== DFSR BACKLOG FOR SERVER $S2 ==--" -BackgroundColor Black -ForeGroundColor Cyan
''
Start-Sleep 1

Foreach ($_ in $connection2) {
	$rfname = "$($_.FolderName)"
	$rgname = "$($_.GroupName)"
	$dfsrdiag = "$outputs\$S2-$rfname-dfsrdiag.txt"

	Write-Host "PROCESSING FOLDER - $rfname" -ForegroundColor Green
	dfsrdiag.exe backlog /sendingmember:$S2 /receivingmember:$S1 /rfname:$rfname /rgname:$rgname > $dfsrdiag
}
''
''
## ANALYSE AND PARSE DFSRDIAG OUTPUT ##
Start-Sleep 1

Foreach ($_ in $connection2) {
	$rfname = "$($_.FolderName)"
	$rgname = "$($_.GroupName)"
	$dfsrdiag = "$outputs\$S2-$rfname-dfsrdiag.txt"
	$content0 = Get-Content -Path $dfsrdiag | Select-Object -Index 0
	$content1 = Get-Content -Path $dfsrdiag | Select-Object -Index 1

	if ($content0 -ne "$null") {
		Add-Content -Path $s2errors -Value "$rfname - $content0"
	}
	if ($content0 -eq "$null") {
		Add-Content -Path $S2foldercounts -Value "$rfname - $content1"
	}
}

## CREATE TOTAL COUNT FILE ##
$S2totalcount = Get-Content -Path $S2foldercounts | Where-Object { $_ -like '*count*' }

foreach ($_ in $S2totalcount) {
	$_.split(':')[1] | Out-File -FilePath $S2count -Append
}


## DISPLAY FOLDER BACKLOG COUNTS TO SCREEN ##
$S2errorwarning = Get-Content -Path $S2errors

Write-Host 'FOLDER STATUS:' -ForegroundColor Green
Get-Content -Path $S2foldercounts
''
''
if ($S2errorwarning -ne $null) {
	Write-Host 'FOLDERS WITH ERRORS:' -ForegroundColor Green
	Get-Content -Path $S2errors
	''
	''
}


###################################
#### TOTAL BACKLOG FOR SERVER2: ###
###################################



### SERVER2 TOTAL BACKLOG FIGURE ###
Start-Sleep 1

Write-Host "--== TOTAL BACKLOG FOR SERVER $S2 ==--" -BackgroundColor Black -ForeGroundColor Cyan

if ($S2errorwarning -ne $null) {
	Write-Host 'WARNING: THERE WERE ERRORS RECORDED. BACKLOG TOTAL FIGURE IS INACCURATE' `
		-BackgroundColor Black -ForegroundColor Red
	$S2totalbacklog = Get-Content -Path $S2count | Measure-Object -Sum
	Write-Host "TOTAL BACKLOG FOR SERVER $S2 ="($S2totalbacklog).sum" (FIGURE NOT ACCURATE DUE TO ERRORS)" `
		-BackgroundColor Black -ForegroundColor Green
}
Else {
	$S2totalbacklog = Get-Content -Path $S2count | Measure-Object -Sum
	Write-Host "TOTAL BACKLOG FOR SERVER $S2 ="($S2totalbacklog).sum"" `
		-BackgroundColor Black -ForegroundColor Green
}
''
''


#######################################
### UPDATE REPORT FILES FOR SERVER2 ###
#######################################

Write-Host "WRITING TO REPORT FILES FOR $S2 IN $reports" -BackgroundColor Black -ForeGroundColor Yellow
''
''

### UPDATE FOLDER COUNT REPORT ###
(Get-Date).ToString() 1>>$S2FolderReport
$S2 1>>$S2FolderReport
Get-Content -Path $S2foldercounts 1>>$S2FolderReport
Get-Content -Path $S2errors 1>>$S2FolderReport
'' 1>>$S2FolderReport

### UPDATE TOTAL BACKLOG COUNT REPORT ###
(Get-Date).ToString() 1>>$S2TotalReport
$S2 1>>$S2TotalReport
if ($S2errorwarning -eq $null) {
	($S2totalbacklog).sum 1>>$S2TotalReport
}
Else {
	($S2totalbacklog).sum 1>>$S2TotalReport
	Add-Content -Path $S2TotalReport -Value "ERRORS: VALUE NOT ACCURATE"
}
'' 1>>$S2TotalReport



###############
### CLEANUP ###
###############

Write-Host 'CLEANING UP OUTPUT FILES AND VARIABLES'  -BackgroundColor Black -ForeGroundColor Yellow
Get-ChildItem -Path $outputs | Remove-Item -Force
$temp = $null
$content0 = $null
$content1 = $null
$S1totalcount = $null
$S2totalcount = $null
$S1errorwarning = $null
$S2errorwarning = $null
$S1totalbacklog = $null
$S2totalbacklog = $null

Write-Host 'CLEANUP SUCCESSFUL. SCRIPT HAS COMPLETED.' -BackgroundColor Black -ForeGroundColor Yellow