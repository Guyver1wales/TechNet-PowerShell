function Connect-SccmSite {
    <#
      .SYNOPSIS
      A function to connect you to an SCCM site to be able to run SCCM comdlets.

      .DESCRIPTION
      Connects to the specified SCCM Site to allow you to use the ConfigurationManager.psd1 module.
      Requires the existence of the environment variable 'Env:\SMS_ADMIN_UI_PATH'

      .PARAMETER Site
      Specify the SCCM Site followed by a colon

      .EXAMPLE
      Example 1:
      Connect-SccmSite -Site ABC:

      .INPUTS
      N/A

      .OUTPUTS
      N/A

      .NOTES
      Version :        1.1
      Author :         Leon Evans
      Creation Date :  6th March 2019
      Location : https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=Guyver-1
      Purpose/Change:
      v1.1
      Improved error handling for the CMSite PSDrive detection after module load.
      Improved error handling when attempting to change location to CMSite PSDrive.

      v1.0
      Original Version.
  #>
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            Position = 0)]
        [ValidatePattern("[a-z0-9-]:")]
        [String]
        $Site
    )

    ### CHECK FOR SMS ENV: PROPERTY AND CHECK CONFIGURATIONMANAGER.PSD1 EXISTS ###

    if (Test-Path -Path 'Env:\SMS_ADMIN_UI_PATH') {
        # CREATE VARIABLE FROM PATH FOUND #
        $smspath = (Get-Item -Path 'Env:\SMS_ADMIN_UI_PATH').Value

        # CHANGE TO WORKING DIRECTORY #
        cd "$($smspath.TrimEnd('i386'))"

        # CREATE SCCM PS MODULE PATH FROM ENV: PROPERTY PATH #
        $smspsModule = "$($smspath.TrimEnd('i386'))" + "ConfigurationManager.psd1"

        # CHECK PS MODULE EXISTS IN LOCATION #
        if (Test-Path -Path $smspsmodule) {
            Write-Output -InputObject 'ConfigurationManager.psd1 found, continuing...'
        }
    }
    else {
        Write-Warning -Message 'ConfigurationManager.psd1 not found, exiting.'
        break
    }

    ### IMPORT THE PS MODULE CONFIGURATIONMANAGER.PSD1 ###
    Import-Module $smspsModule -Verbose

    ### CHANGE DIRECTORY TO THE SCCM SITE ###
    # TEST PSDRIVE CREATED AFTER PS MODULE IMPORT #
    if (Test-Path -Path $site) {
        Write-Output -InputObject "PSDrive $site found, changing location to $site..."
    }
    else {
        Write-Warning -Message "PSDrive - $site not created after PS Module Import, exiting."
        break
    }

    # CHANGE LOCATION TO SSCCM SITE PSDRIVE #
    try {
        Set-Location $site -ErrorAction Stop -WarningAction Stop
    }
    catch {
        Write-Warning -Message "Cannot change directory to SCCM Site - $site, exiting."
        break
    }
    Write-Output -InputObject "Connected to SCCM SITE - $site"
}