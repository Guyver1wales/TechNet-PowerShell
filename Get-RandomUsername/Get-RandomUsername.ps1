function Get-RandomUsername {
	<#
		.SYNOPSIS
		Creates random usernames from 3 plaintext name dictionary files.

		.DESCRIPTION
		Creates random usernames from 3 plaintext name dictionary files:
		firstNameFemale.txt
		firstNameMale.txt
		surnames.txt
		Both male and female names will get a random surname from the surnames.txt file.

		.PARAMETER Female
		Tells the function to create a username using the firstNameFemale.txt given names text file.

		.PARAMETER Male
		Tells the function to create a username using the firstNameMale.txt given names text file.

		.PARAMETER Amount
		Interger.
		Define how many users you want to create.

		.EXAMPLE
		Get-RandomUsername -Female
		FirstName Surname
		--------- -------
		Elody     Serum

		.EXAMPLE
		Get-RandomUsername -Male
		FirstName   Surname
		---------   -------
		Christopher Paraz

		.EXAMPLE
		Get-RandomUsername -Male -Amount 10

		FirstName Surname
		--------- -------
		Denver    Harootunian
		Sukhpal   Cahoone
		Rivan     Bassignani
		Neo       Bildner
		Hussnain  Paller
		Jensen    Artho
		Raunaq    Pilkey
		Kenzi     Vahsholtz
		Alfred    Spolarich
		Umair     Devargas

		.OUTPUTS
		PSCustomObject. Get-RandomUsername outputs a PSCustomObject made up of two System.string objects.
		TypeName: System.Management.Automation.PSCustomObject

		Name        MemberType   Definition
		----        ----------   ----------
		Equals      Method       bool Equals(System.Object obj)
		GetHashCode Method       int GetHashCode()
		GetType     Method       type GetType()
		ToString    Method       string ToString()
		FirstName   NoteProperty System.String
		Surname     NoteProperty System.String

		.NOTES
		Version :		1.0
		Author:			Leon Evans
		Email			info@leonlive.co.uk
		Creation Date:		2nd March 2020
		Location:		<insert url of script location>
		Purpose/Change:		Original Version
	#>

	[CmdletBinding()]
	Param(
		[Parameter(ParameterSetName = 'Female', Mandatory = $true)]
		[switch]$Female,
		[Parameter(ParameterSetName = 'Male', Mandatory = $true)]
		[switch]$Male,
		[Parameter()]
		[int]$Amount
	)

	begin {
		### DICTIONARY OF FEMALE GIVEN NAMES ###
		[array]$firstNameFemale = Get-Content -Path '.\firstNameFemale.txt'

		### DICTIONARY OF MALE GIVEN NAMES ###
		[array]$firstNameMale = Get-Content -Path '.\firstNameMale.txt'

		### DICTIONARY OF SURNAMES ###
		[array]$surnames = Get-Content -Path '.\surnames.txt'

		# COUNTS OF NAMES #
		$femaleCount = $firstNameFemale.count
		$maleCount = $firstNameMale.count
		$surnameCount = $surnames.count

		# DEFINE OUTPUT OBJECT #
		[array]$output = @()
	}

	process {
		if ($Amount) {
			if ($Female) {
				$output += for ($x = 1; $x -le $Amount; $x += 1) {
					# DEFINE FEMALE UPPER LIMITS FOR GET-RANDOM #
					[int]$randomGivenName = Get-Random -Minimum 0 -Maximum $($femaleCount)
					[int]$randomSurname = Get-Random -Minimum 0 -Maximum $($surnameCount)

					# CREATE FEMALE USERNAME #
					$firstName = $($firstNameFemale[$randomGivenName])
					$surname = $($surnames[$randomSurname])

					# CREATE FEMALE USERNAME OBJECT #
					[pscustomobject]@{
						FirstName = $firstName
						Surname   = $surname
					}
				}
			}
			If ($Male) {
				$output += for ($x = 1; $x -le $Amount; $x += 1) {
					# DEFINE MALE UPPER LIMITS FOR GET-RANDOM #
					[int]$randomGivenName = Get-Random -Minimum 0 -Maximum $($MaleCount)
					[int]$randomSurname = Get-Random -Minimum 0 -Maximum $($surnameCount)

					# CREATE MALE USERNAME #
					$firstName = $($firstNameMale[$randomGivenName])
					$surname = $($surnames[$randomSurname])

					# CREATE MALE USERNAME OBJECT #
					[pscustomobject]@{
						FirstName = $firstName
						Surname   = $surname
					}
				}
			}
		}
		else {
			if ($Female) {
				# DEFINE FEMALE UPPER LIMITS FOR GET-RANDOM #
				[int]$randomGivenName = Get-Random -Minimum 0 -Maximum $($femaleCount)
				[int]$randomSurname = Get-Random -Minimum 0 -Maximum $($surnameCount)

				# CREATE FEMALE USERNAME #
				$firstName = $($firstNameFemale[$randomGivenName])
				$surname = $($surnames[$randomSurname])

				# CREATE FEMALE USERNAME OBJECT #
				$output = [pscustomobject]@{
					FirstName = $firstName
					Surname   = $surname
				}
			}
			### PROCESS SINGLE RANDOM MALE USERNAME ###
			if ($Male) {
				# DEFINE MALE UPPER LIMITS FOR GET-RANDOM #
				[int]$randomGivenName = Get-Random -Minimum 0 -Maximum $($maleCount)
				[int]$randomSurname = Get-Random -Minimum 0 -Maximum $($surnameCount)

				# CREATE MALE USERNAME #
				$firstName = $($firstNameMale[$randomGivenName])
				$surname = $($surnames[$randomSurname])

				# CREATE MALE USERNAME OBJECT #
				$output = [pscustomobject]@{
					FirstName = $firstName
					Surname   = $surname
				}
			}
		}
	}
	end {
		$output
	}
}
