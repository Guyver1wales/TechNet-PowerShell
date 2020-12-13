# DEFINE DEFAULT VALUE FOR PARAMETER: COMPUTERNAME
$script:PSDefaultParameterValues = @{"Get-DriveInfo:ComputerName" = "$env:COMPUTERNAME" }

function Get-DriveInfo {
	<#
      .SYNOPSIS
      Get all drives on a local or remote computer.

      .DESCRIPTION
      Uses the [system.io.GetDriveInfo] .NET class to query all drives on a local or remote computer.
      Depending on the ParameterSet used, you can return all drives, drives of a specific type,
      or a specific drive letter.
      You can specify what units you want your drives reported in.
      The script defaults to GigaBytes (GB) when the -Units parameter is not used.
      When the -Units parameter is used you can choose between the following units to display:
      KB (KiloBytes)
      MB (MegaBytes)
      GB (GigaBytes)
      TB (TeraBytes)
      The FreeSpace and Size columns adjust their column names based on the Units chosen.

      .PARAMETER Units
      Specify the Units used to display the following:
      Size of Drive
      Available Free Space
      Valid inputs for this parameter are:
      KB
      MB
      GB
      TB
      Column names change to reflect the Unit size chosen.

      .PARAMETER DriveType
      Specify the DriveType you want to return
      DriveTypes are defined by the [System.IO.DriveType] .NET Class.
      Valid options for this parameter are:
      CDRom
      Fixed
      Network
      NoRootDirectory
      Ram
      Removable
      Unknown

      .PARAMETER DriveLetter
      Specify the drive letter to query.
      input the drive letter in the format:
      <driveletter><colon>
      Example:
      C:

      .PARAMETER ComputerName
      Specify the name of a remote computer to query.
      If this parameter is not used then the local hostname is used.
      When a remote computer is specified the hostname is validated using Test-NetConnection.
      This checks the hostname is valid and the WinRM ports are open.

      .NOTES
      Version:      1.0
      Author:       Leon Evans
      Creation Date:22/12/2018
      Location:     https://github.com/Guyver1wales/PowerShell/tree/master/Technet-Published
                    https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=Guyver-1
      Purpose/Change:
      v1.0 - Original release

      .LINK
      https://github.com/Guyver1wales/PowerShell
      https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=Guyver-1

      .EXAMPLE

      Get-DriveInfo

      Name DriveType DriveFormat IsReady RootDirectory VolumeLabel   FreeSpace(GB) Size(GB) FreeSpace(%)
      ---- --------- ----------- ------- ------------- -----------   ------------- -------- ------------
      A:\  Removable               False A:\                                     0        0
      C:\      Fixed NTFS           True C:\                                 32.66    59.66 54.74
      D:\      Fixed NTFS           True D:\           SomeVolLabel1          9.38     9.97 94.07
      E:\      Fixed NTFS           True E:\           E                      9.58     9.97 96.16
      F:\      Fixed NTFS           True F:\           F                      9.36     9.97 93.93
      G:\      Fixed NTFS           True G:\           G                      7.38     9.97 74.01
      Z:\    Network HGFS           True Z:\           Shared Folders        171.98   465.21 36.97

      EXAMPLE 1 runs the function with no parameters.
      The function defaults to the following:
      All drives returned
      local computername for the -ComputerName parameter
      GB for the -Units parameter


      .EXAMPLE

      Get-DriveInfo -Units MB

      Name DriveType DriveFormat IsReady RootDirectory VolumeLabel   FreeSpace(MB) Size(MB) FreeSpace(%)
      ---- --------- ----------- ------- ------------- -----------   ------------- -------- ------------
      A:\  Removable               False A:\                                     0        0
      C:\      Fixed NTFS           True C:\                              33441.55    61088 54.74
      D:\      Fixed NTFS           True D:\           SomeVolLabel1       9600.48    10206 94.07
      E:\      Fixed NTFS           True E:\           E                   9814.15    10206 96.16
      F:\      Fixed NTFS           True F:\           F                    9586.2    10206 93.93
      G:\      Fixed NTFS           True G:\           G                   7553.95    10206 74.01
      Z:\    Network HGFS           True Z:\           Shared Folders      176107.6   476373 36.97

      EXAMPLE 2 runs the function with the -Units Parameter
      The function defaults to the following:
      All drives returned
      local computername for the -ComputerName parameter
      Valid input for -Units: KB,MB,GB,TB


      .EXAMPLE

      Get-DriveInfo -Units MB -ComputerName 2008R2-PS2

      PSComputerName Name DriveType DriveFormat IsReady RootDirectory VolumeLabel FreeSpace(MB) Size(MB) FreeSpace(%)
      -------------- ---- --------- ----------- ------- ------------- ----------- ------------- -------- ------------
      2008R2-PS2     A:\  Removable               False A:\                                   0        0
      2008R2-PS2     C:\  Fixed     NTFS           True C:\                            40092.82    61338 65.36

      EXAMPLE 3 runs the function against a remote computer
      The function defaults to the following:
      All drives returned
      GB for the -Units parameter


      .EXAMPLE

      Get-DriveInfo -DriveType Fixed

      Name DriveType DriveFormat IsReady RootDirectory VolumeLabel   FreeSpace(GB) Size(GB) FreeSpace(%)
      ---- --------- ----------- ------- ------------- -----------   ------------- -------- ------------
      C:\      Fixed NTFS           True C:\                                 32.66    59.66        54.74
      D:\      Fixed NTFS           True D:\           SomeVolLabel1          9.38     9.97        94.07
      E:\      Fixed NTFS           True E:\           E                      9.58     9.97        96.16
      F:\      Fixed NTFS           True F:\           F                      9.36     9.97        93.93
      G:\      Fixed NTFS           True G:\           G                      7.38     9.97        74.01

      EXAMPLE 4 runs the function specifying the -DriveType parameter
      The function defaults to the following:
      Defaults to the local machine
      Only drives of type specified in -DriveType parameter returned
      GB for the -Units parameter



      .EXAMPLE

      Get-DriveInfo -DriveType Fixed -Units MB

      Name DriveType DriveFormat IsReady RootDirectory VolumeLabel   FreeSpace(MB) Size(MB) FreeSpace(%)
      ---- --------- ----------- ------- ------------- -----------   ------------- -------- ------------
      C:\      Fixed NTFS           True C:\                              33441.55    61088        54.74
      D:\      Fixed NTFS           True D:\           SomeVolLabel1       9600.48    10206        94.07
      E:\      Fixed NTFS           True E:\           E                   9814.15    10206        96.16
      F:\      Fixed NTFS           True F:\           F                    9586.2    10206        93.93
      G:\      Fixed NTFS           True G:\           G                   7553.95    10206        74.01

      EXAMPLE 5 runs the function specifying the -DriveType and -Units parameters
      The function defaults to the following:
      Defaults to the local machine
      Only drives of type specified in -DriveType parameter returned
      Valid input for -Units: KB,MB,GB,TB


      .EXAMPLE

      Get-DriveInfo -DriveType Fixed -Units MB -ComputerName 2008R2-PS2

      PSComputerName Name DriveType DriveFormat IsReady RootDirectory VolumeLabel FreeSpace(MB) Size(MB) FreeSpace(%)
      -------------- ---- --------- ----------- ------- ------------- ----------- ------------- -------- ------------
      2008R2-PS2     C:\  Fixed     NTFS           True C:\                            40092.82    61338        65.36

      EXAMPLE 6 runs the function specifying the -DriveType and -Units parameters against a remote computer
      The function defaults to the following:
      Only drives of type specified in -DriveType parameter returned
      Valid input for -Units: KB,MB,GB,TB


      .EXAMPLE

      Get-DriveInfo -DriveLetter C:

      Name DriveType DriveFormat IsReady RootDirectory VolumeLabel FreeSpace(GB) Size(GB) FreeSpace(%)
      ---- --------- ----------- ------- ------------- ----------- ------------- -------- ------------
      C:\      Fixed NTFS           True C:\                               32.66    59.66        54.74

      EXAMPLE 7 runs the function specifying the -DriveLetter parameter
      The function defaults to the following:
      Defaults to the local machine
      Only drive specified in -DriveLetter parameter returned
      GB for the -Units parameter


      .EXAMPLE

      Get-DriveInfo -DriveLetter C: -Units MB

      Name DriveType DriveFormat IsReady RootDirectory VolumeLabel FreeSpace(MB) Size(MB) FreeSpace(%)
      ---- --------- ----------- ------- ------------- ----------- ------------- -------- ------------
      C:\      Fixed NTFS           True C:\                            33441.55    61088        54.74

      EXAMPLE 8 runs the function specifying the -DriveLetter and -Units parameters
      The function defaults to the following:
      Defaults to the local machine
      Only drive specified in -DriveLetter parameter returned
      Valid input for -Units: KB,MB,GB,TB


      .EXAMPLE

      Get-DriveInfo -DriveLetter C: -Units MB -ComputerName 2008R2-PS2

      PSComputerName Name DriveType DriveFormat IsReady RootDirectory VolumeLabel FreeSpace(MB) Size(MB) FreeSpace(%)
      -------------- ---- --------- ----------- ------- ------------- ----------- ------------- -------- ------------
      2008R2-PS2     C:\  Fixed     NTFS           True C:\                            40092.82    61338        65.36

      EXAMPLE 9 runs the function specifying the -DriveLetter and -Units parameters against a remote computer
      The function defaults to the following:
      Only drive specified in -DriveLetter parameter returned
      Valid input for -Units: KB,MB,GB,TB
  #>

	[cmdletBinding(DefaultParameterSetName = 'Default')]
	param(
		# COMPUTERNAME
		[Parameter(
			Position = 0,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true)]
		[Parameter(ParameterSetName = 'Default', Mandatory = $true)]
		[Parameter(ParameterSetName = 'DriveType')]
		[Parameter(ParameterSetName = 'DriveLetter')]
		[Alias("ServerName", "Name", "Server")]
		[ValidatePattern("[a-zA-Z0-9-]")]
		[ValidateLength(1, 15)]
		[string]
		$ComputerName,
		# DRIVETYPE
		[Parameter(ParameterSetName = 'DriveType', Mandatory = $true)]
		[ValidateSet('CDRom', 'Fixed', 'Network', 'NoRootDirectory', 'Ram', 'Removable', 'Unknown')]
		[string]
		$DriveType,
		# DRIVE LETTER
		[Parameter(ParameterSetName = 'DriveLetter', Mandatory = $true)]
		[ValidatePattern("^[c-zC-Z]{1}:{1}`$")]
		[string]
		$DriveLetter,
		# UNITS
		[Parameter(ParameterSetName = 'Default')]
		[Parameter(ParameterSetName = 'DriveType')]
		[Parameter(ParameterSetName = 'DriveLetter')]
		[ValidateSet('KB', 'MB', 'GB', 'TB')]
		[string]
		$Units = 'GB'
	)

	begin {
		$set = $PSCmdlet.ParameterSetName
		$drives = $null

		# DEFINE UNITS
		Switch ($units) {
			'KB' {
				$Size = @{
					Expression = { [Math]::Round(($_.TotalSize / 1KB), 2) }
					Name       = 'Size(KB)'
				}
				$Freespace = @{
					Expression = { [Math]::Round(($_.TotalFreeSpace / 1KB), 2) }
					Name       = 'FreeSpace(KB)'
				}
			}
			'MB' {
				$Size = @{
					Expression = { [Math]::Round(($_.TotalSize / 1MB), 2) }
					Name       = 'Size(MB)'
				}
				$Freespace = @{
					Expression = { [Math]::Round(($_.TotalFreeSpace / 1MB), 2) }
					Name       = 'FreeSpace(MB)'
				}
			}
			'GB' {
				$Size = @{
					Expression = { [Math]::Round(($_.TotalSize / 1GB), 2) }
					Name       = 'Size(GB)'
				}
				$Freespace = @{
					Expression = { [Math]::Round(($_.TotalFreeSpace / 1GB), 2) }
					Name       = 'FreeSpace(GB)'
				}
			}
			'TB' {
				$Size = @{
					Expression = { [Math]::Round(($_.TotalSize / 1TB), 2) }
					Name       = 'Size(TB)'
				}
				$Freespace = @{
					Expression = { [Math]::Round(($_.TotalFreeSpace / 1TB), 2) }
					Name       = 'FreeSpace(TB)'
				}
			}
		}

		# DEFINE % FREE EXPRESSION
		$PercentFree = @{
			Expression = { [Math]::Round(($_.TotalFreeSpace * 100 / $_.TotalSize), 2) }
			Name       = 'FreeSpace(%)'
		}
	}

	process {
		# DEFINE $DRIVES ARRAY VARIABLE BASED ON WHETHER $COMPUTERNAME IS THE LOCAL OR A REMOTE COMPUTER
		# DEFINE $LOCALCOMPUTER VARIABLE
		if ($ComputerName -eq $env:COMPUTERNAME) {
			$localcomputer = $true
			$drives = [System.IO.DriveInfo]::GetDrives()
		}
		else {
			$testconnection = (Test-NetConnection `
					-ComputerName $ComputerName `
					-CommonTCPPort WinRM).TcpTestSucceeded
			if ($testconnection -eq $true) {
				$localcomputer = $false
				$drives = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
					[System.IO.DriveInfo]::GetDrives()
				}
			}
			else {
				Write-Warning -Message `
					"Cannot connect to remote computer $ComputerName. Exiting..."
				break
			}
		}

		### DEFINE OUTPUT BASED ON PARAMETER SET NAME AND WHETHER LOCAL OR REMOTE COMPUTER ###
		## DEFAULT PARAMETER SET ##
		# LOCAL MACHINE #
		if ($set -eq 'Default' -and $localcomputer -eq $true) {
			return $drives | Select-Object -Property `
				Name,
			DriveType,
			DriveFormat,
			IsReady,
			RootDirectory,
			VolumeLabel,
			$Freespace,
			$Size,
			$PercentFree
		}
		# REMOTE MACHINE #
		if ($set -eq 'Default' -and $localcomputer -eq $false) {
			return $drives | Select-Object -Property `
				PSComputerName,
			Name,
			DriveType,
			DriveFormat,
			IsReady,
			RootDirectory,
			VolumeLabel,
			$Freespace,
			$Size,
			$PercentFree
		}

		## DRIVETYPE PARAMETER SET ##
		# LOCAL MACHINE #
		if ($set -eq 'DriveType' -and $localcomputer -eq $true) {
			return $drives | Where-Object { $_.DriveType -eq $DriveType } | `
					Select-Object -Property `
					Name,
				DriveType,
				DriveFormat,
				IsReady,
				RootDirectory,
				VolumeLabel,
				$Freespace,
				$Size,
				$PercentFree
	}
	# REMOTE MACHINE #
	if ($set -eq 'DriveType' -and $localcomputer -eq $false) {
		return $drives | Where-Object { $_.DriveType -eq $DriveType } | `
				Select-Object -Property `
				PSComputerName,
			Name,
			DriveType,
			DriveFormat,
			IsReady,
			RootDirectory,
			VolumeLabel,
			$Freespace,
			$Size,
			$PercentFree
}

## DRIVELETTER PARAMETER SET ##
# LOCAL MACHINE #
if ($set -eq 'DriveLetter' -and $localcomputer -eq $true) {
	return $drives | Where-Object { $_.Name -eq "$DriveLetter\" } | `
			Select-Object -Property `
			Name,
		DriveType,
		DriveFormat,
		IsReady,
		RootDirectory,
		VolumeLabel,
		$Freespace,
		$Size,
		$PercentFree
}
# REMOTE MACHINE #
if ($set -eq 'DriveLetter' -and $localcomputer -eq $false) {
	return $drives | Where-Object { $_.Name -eq "$DriveLetter\" } | `
			Select-Object -Property `
			PSComputerName,
		Name,
		DriveType,
		DriveFormat,
		IsReady,
		RootDirectory,
		VolumeLabel,
		$Freespace,
		$Size,
		$PercentFree
}
}
}
