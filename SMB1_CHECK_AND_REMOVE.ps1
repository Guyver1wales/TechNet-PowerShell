Clear-Host
Import-Module ActiveDirectory


## DEFINE DOMAIN SEARCH AREA ##
$searchbase = 'DC=contoso,DC=local'



########################################################################
### CHECK FOR SMB1, SMB2 AND DIALECT OF CURRENT OPEN SMB CONNECTIONS ###
########################################################################



### CHECK ALL SERVER 2008 R2 SERVERS ###
''
'SERVER 2008 R2'
$2008R2hosts = (Get-ADComputer -Filter * -ResultSetSize $null -SearchBase "$searchbase" -Properties * | `
			Where-Object { $_.OperatingSystem -like '*2008 R2*' }).DnsHostName

foreach ($_ in $2008R2hosts) {
	Invoke-Command -ComputerName $_ -ScriptBlock {
		# FUNCTION - TEST REGISTRY VALUE (Function taken from:
		# http://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html)
		function Test-RegistryValue {
			param (
				[parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]$Path,

				[parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]$Value
			)
			try {
				Get-ItemProperty -Path $Path | `
						Select-Object -ExpandProperty $Value -ErrorAction Stop | `
							Out-Null
				return $true
			}

			catch {
				return $false
			}
		}
		$hostname = hostname
		$regvaluesmb1 = Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Value "SMB1"
		if ($regvaluesmb1 -eq $false) { Write-Host "$hostname,SMB1 enabled" }
		$regvaluesmb2 = Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Value "SMB2"
		if ($regvaluesmb2 -eq $false) { Write-Host "$hostname,SMB2 enabled" }
	}
}



### CHECK ALL SERVER 2012 SERVERS ###
''
'SERVER 2012'
$2012hosts = (Get-ADComputer -Filter * -ResultSetSize $null -SearchBase "$searchbase" -Properties * | `
			Where-Object { $_.OperatingSystem -eq 'Windows Server 2012 Standard' -or `
				$_.OperatingSystem -eq 'Windows Server 2012 Enterprise' -or `
				$_.OperatingSystem -eq 'Windows Server 2012 Datacenter' }).DnsHostName

foreach ($_ in $2012hosts) {
	Invoke-Command -ComputerName $_ -ScriptBlock {
		$hostname = hostname
		$smb12012 = (Get-SmbServerConfiguration | `
					Select-Object -Property EnableSMB1Protocol).EnableSMB1Protocol
		if ($smb12012 -eq 'True') { Write-Host "$hostname,SMB1 enabled" }
		$smb22012 = (Get-SmbServerConfiguration | `
					Select-Object -Property EnableSMB2Protocol).EnableSMB2Protocol
		if ($smb22012 -eq 'True') { Write-Host "$hostname,SMB2 enabled" }
		Get-SmbConnection | Format-Table ServerName, Dialect -AutoSize
	}
}



### CHECK ALL SERVER 2012 R2 SERVERS ###
''
'SERVER 2012 R2'
$2012R2hosts = (Get-ADComputer -Filter * -ResultSetSize $null -SearchBase "$searchbase" -Properties * | `
			Where-Object { $_.OperatingSystem -like '*2012 R2*' }).DnsHostName

foreach ($_ in $2012R2hosts) {
	Invoke-Command -ComputerName $_ -ScriptBlock {
		$hostname = hostname
		$smb12012R2 = (Get-WindowsFeature -Name FS-SMB1).InstallState
		if ($smb12012R2 -eq 'Installed') { Write-Host "$hostname,SMB1 enabled" }
		Get-SmbConnection | Format-Table ServerName, Dialect -AutoSize
	}
}



break
###################
### REMOVE SMB1 ###
###################

### REMOVE SMB1 ON ALL SERVER 2008 R2 SERVERS ###
$2008R2hosts = (Get-ADComputer -Filter * -ResultSetSize $null -SearchBase "$searchbase" -Properties * | `
			Where-Object { $_.OperatingSystem -like '*2008 R2*' }).DnsHostName

foreach ($_ in $2008R2hosts) {
	Invoke-Command -ComputerName $_ -ScriptBlock {
		#FUNCTION - TEST REGISTRY VALUE (Function taken from:
		# http://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html)
		function Test-RegistryValue {
			param (
				[parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]$Path,

				[parameter(Mandatory = $true)]
				[ValidateNotNullOrEmpty()]$Value
			)
			try {
				Get-ItemProperty -Path $Path | `
						Select-Object -ExpandProperty $Value -ErrorAction Stop | `
							Out-Null
				return $true
			}

			catch {
				return $false
			}
		}
		hostname
		$regvalue = Test-RegistryValue -Path `
			"HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Value "SMB1"
		if ($regvalue -eq $false) {
			Set-ItemProperty -Path `
				"HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force
		}
	}
}


### REMOVE SMB1 ON ALL SERVER 2012 SERVERS ###
$2012hosts = (Get-ADComputer -Filter * -ResultSetSize $null -SearchBase "$searchbase" -Properties * | `
			Where-Object { $_.OperatingSystem -eq 'Windows Server 2012 Standard' `
				-or $_.OperatingSystem -eq 'Windows Server 2012 Enterprise' `
				-or $_.OperatingSystem -eq 'Windows Server 2012 Datacenter' }).DnsHostName

foreach ($_ in $2012hosts) {
	Invoke-Command -ComputerName $_ -ScriptBlock {
		hostname
		$smb12012 = (Get-SmbServerConfiguration | Select-Object -Property EnableSMB1Protocol).EnableSMB1Protocol
		if ($smb12012 -eq 'True') { Set-SmbServerConfiguration -EnableSMB1Protocol $false }
	}
}


### REMOVE SMB1 ON ALL SERVER 2012 R2 SERVERS ###
$2012R2hosts = (Get-ADComputer -Filter * -ResultSetSize $null -SearchBase "$searchbase" -Properties * | `
			Where-Object { $_.OperatingSystem -like '*2012 R2*' }).DnsHostName

foreach ($_ in $2012R2hosts) {
	Invoke-Command -ComputerName $_ -ScriptBlock {
		hostname
		$smb12012R2 = (Get-WindowsFeature -Name FS-SMB1).InstallState
		if ($smb12012R2 -eq 'Installed') { Remove-WindowsFeature -Name FS-SMB1 }
	}
}
