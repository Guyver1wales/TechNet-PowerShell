#requires -version 2
<#
    .SYNOPSIS
    DFSR \PreExisting Folder Cleanup

    .DESCRIPTION
    Finds all \PreExisting folders across all local disks and removes all the data.
    Also gives you before and after free disk space for each disk so you know how much space has been cleared.
    Only use once initial sync has been completed and Event ID 4104 has been logged for all replicated folders on all volumes.

    .PARAMETER <Parameter_Name>
    N/A

    .INPUTS
    None

    .OUTPUTS
    To each disk:
    dfsr_PreExisting_Cleanup_FreeSpace_Before.txt
    dfsr_PreExisting_Cleanup_FreeSpace_After.txt

    *if you uncomment the robocopy log switch:
    <GUID>-dfsr_PreExisting_cleanup_robocopy.log

    .NOTES
    Version :        1.1
    Author :         Leon Evans
    Creation Date :  20/03/2018
    Location: https://gallery.technet.microsoft.com/scriptcenter/DFSR-PreExisting-Folder-0983e9cb?redir=0
    Purpose/Change:
    v1.1
    removed commented out robocopy log parameter
    changed message when no \DFSR folder found on a volume.

    .EXAMPLE
    n/a
#>

# ---------------------------------------------------------
# INITIALISATIONS
# ---------------------------------------------------------

#1> define initialisations and global configurations
#2> list dot Source required Function Libraries


### CREATE EMPTY DIRECTORY ###
if ((Test-Path -Path 'c:\dfsr_PreExisting_Cleanup_Empty') -ne $true) {
	New-Item -Path 'c:\dfsr_PreExisting_Cleanup_Empty' -ItemType Directory
}

# ---------------------------------------------------------
# DECLARATIONS
# ---------------------------------------------------------

#3> define and declare variables here
#e.g.
#$sScriptVersion = "1.0"


## FREESPACE TABLE FORMATTING ##
$Size =
@{
	Expression = { [int]($_.Size / 1GB) }
	Name       = 'Size(GB)'
}

$Freespace =
@{
	Expression = { [int]($_.Freespace / 1GB) }
	Name       = 'FreeSpace(GB)'
}

$PercentFree =
@{
	Expression = { [int]($_.Freespace * 100 / $_.Size) }
	Name       = 'FreeSpace(%)'
}


### GET ALL LOCAL DISKS ###
$localdisks = @((Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq '3' }).DeviceID)



# ---------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------

#4> primary functions and helpers should be abstracted here



# ---------------------------------------------------------
# EXECUTION
# ---------------------------------------------------------

#6> execution, actions and callbacks should be placed here


### DFSR PRE-EXISTING CLEANUP ###
foreach ($i in $localdisks) {
	### REMOVE ANY PRE-EXISTING FILES ###
	if ((Test-Path -Path "$i\dfsr_PreExisting_Cleanup_FreeSpace_Before.txt") -eq $true) {
		Remove-Item -Path "$i\dfsr_PreExisting_Cleanup_FreeSpace_Before.txt" -Force
	}

	if ((Test-Path -Path "$i\dfsr_PreExisting_Cleanup_FreeSpace_After.txt") -eq $true) {
		Remove-Item -Path "$i\dfsr_PreExisting_Cleanup_FreeSpace_After.txt" -Force
	}

	### GET FREE DISK SPACE BEFORE SCRIPT ###
	Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$i" } | Select-Object `
		-Property DeviceID, $Size, $Freespace, $PercentFree | `
			Format-Table -AutoSize > "$i\dfsr_PreExisting_Cleanup_FreeSpace_Before.txt"

### CLEANUP PREEXISTING FOLDERS ###
if ((Test-Path "$i\System Volume Information\DFSR") -eq $true) {
	Write-Host "$i has a \DFSR folder"
	Write-Host 'Testing for PreExisting Folders'
	(Get-ChildItem -Path "$i\System Volume Information\DFSR\Private").Name > "$i\dfsr_folders.txt"
	$dfsrfolders = Get-Content -Path "$i\dfsr_folders.txt"
	foreach ($a in $dfsrfolders) {
		$preexisting = Test-Path -Path "$i\System Volume Information\DFSR\Private\$a\PreExisting"
		if ($preexisting -eq $true) {
			Write-Host "$i\$a PreExisting Folder Present, Deleting PreExisting Data..."
			robocopy "c:\dfsr_PreExisting_Cleanup_Empty" "$i\System Volume Information\DFSR\Private\$a\PreExisting" /purge /MT:64
		}
	}
}
else {
	Write-Host "$i does not have a \DFSR folder"
}
# CLEANUP FILES #
Remove-Item -Path "$i\dfsr_folders.txt" -Force


### GET FREE DISK SPACE AFTER SCRIPT ###
Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "$i" } | `
		Select-Object -Property DeviceID, $Size, $Freespace, $PercentFree | `
			Format-Table -AutoSize > "$i\dfsr_PreExisting_Cleanup_FreeSpace_After.txt"
}

### CLEANUP EMPTY FOLDER ###
Remove-Item -Path 'c:\dfsr_PreExisting_Cleanup_Empty' -Recurse -Force
