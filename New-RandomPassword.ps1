function New-RandomPassword {
	<#
      .SYNOPSIS
      Create a random password

      .DESCRIPTION
      Creates a random password using the [char] set unicode characters from 33 to 126:
      Standard keyboard symbols
      Alpha-numeric both uppercase and lowercase
      To see the full list of characters used for this function type the following command:
      foreach ($i in 33..126) {"$i,$([char]$i)"}

      .PARAMETER Length
      Input the length of the password required.
      Password length can be a maximum of 2147483647 characters long.

      .EXAMPLE
      New-RandomPassword -Length 8

      PS C:\> New-RandomPassword -length 8
      m]8&.r?u

      Creates a random password 8 characters in length

      .NOTES
      Version :        1.0
      Author :         Leon Evans
      Creation Date :  12/12/2018
      Location : https://gallery.technet.microsoft.com/scriptcenter/Function-New-RandomPassword-3f3703ac?redir=0
      Purpose/Change: Original Version
  #>

	[CmdletBinding()]
	[OutputType([string])]
	Param
	(
		# input the length of the password required
		[Parameter(
			Mandatory = $true,
			Position = 0,
			ValueFromPipeline = $true
		)]
		[int]
		$length
	)

	Begin {
		$n = 0
		[array]$RandomString = $null
		$CharString = $null
	}
	Process {
		While ($n -lt $length) {
			[array]$RandomString += Get-Random -Minimum 33 -Maximum 126
			$n++
		}

		foreach ($i in $RandomString) {
			$CharString += [char]$i
		}
	}
	End {
		return $CharString
	}
}
