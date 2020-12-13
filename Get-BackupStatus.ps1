function Get-BackupStatus {
	<#
      .DEPENDENCIES
      Backup Exec PowerShell Module - BEMCLI

      .SYNOPSIS
      Uses the Backup Exec BEMCLI module to search for a specific server within all backup jobs to get the job status.

      .DESCRIPTION
      Gets the inferred backup status of a specific server based on the JobStatus of the backup job.
      Uses conditional queries to filter out the servername if it is (excluded) or 'To be removed (Excluded) in any of the backup jobs.
      Returns all backup jobs where the requested servername is found and gets the job history for these jobs and returns the most recent job result only.

      .PARAMETER ComputerName
      Input your desired server hostname.

      .EXAMPLE
      Get-BackupStatus -ComputerName <hostname>
      Gets the inferred backup status of this server based on the JobStatus of the Backup Exec backup job this server is a part of.

      .NOTES
      Qualifying Backup Job Selection Summary criteria:
      JobType = Backup
      <hostname>
      <hostname.fqdn>
      <hostname> (Partial)
      <hostname.fqdn (Partial)

      Ignored Selection Summary search criteria results:
      <hostname> (Excluded)
      <hostname.fqdn> (Excluded)
      <hostname> - To Remove (Excluded)
      <hostname.fqdn - To Remove (Excluded)

      ALL JOB STATUS OPTIONS:
      [BackupExec.Management.CLI.BEJobStatus]::Active
      [BackupExec.Management.CLI.BEJobStatus]::Canceled
      [BackupExec.Management.CLI.BEJobStatus]::Completed
      [BackupExec.Management.CLI.BEJobStatus]::Disabled
      [BackupExec.Management.CLI.BEJobStatus]::Dispatched
      [BackupExec.Management.CLI.BEJobStatus]::DispatchFailed
      [BackupExec.Management.CLI.BEJobStatus]::Error
      [BackupExec.Management.CLI.BEJobStatus]::InvalidSchedule
      [BackupExec.Management.CLI.BEJobStatus]::InvalidTimeWindow
      [BackupExec.Management.CLI.BEJobStatus]::Linked
      [BackupExec.Management.CLI.BEJobStatus]::Missed
      [BackupExec.Management.CLI.BEJobStatus]::NotInTimeWindow
      [BackupExec.Management.CLI.BEJobStatus]::OnHold
      [BackupExec.Management.CLI.BEJobStatus]::Queued
      [BackupExec.Management.CLI.BEJobStatus]::Ready
      [BackupExec.Management.CLI.BEJobStatus]::Recovered
      [BackupExec.Management.CLI.BEJobStatus]::Resumed
      [BackupExec.Management.CLI.BEJobStatus]::RuleBlocked
      [BackupExec.Management.CLI.BEJobStatus]::Scheduled
      [BackupExec.Management.CLI.BEJobStatus]::Succeeded
      [BackupExec.Management.CLI.BEJobStatus]::SucceededWithExceptions
      [BackupExec.Management.CLI.BEJobStatus]::Superseded
      [BackupExec.Management.CLI.BEJobStatus]::ThresholdAbort
      [BackupExec.Management.CLI.BEJobStatus]::ToBeScheduled
      [BackupExec.Management.CLI.BEJobStatus]::Unknown

      .LINK
      https://vox.veritas.com/t5/Articles/Preparing-your-Powershell-environment-to-run-BEMCLI-and-scripts/ta-p/810454
      The first link is opened by Get-Help -Online Get-BackupStatus

      .INPUTS
      Server hostname as a string
      pass through multiple hostnames via a foreach loop (foreach loop must only process one hostname at a time)

      .OUTPUTS
      ServerName - servername provided in the -ComputerName parameter.
      Backup Exec Job Name - the most recent job that matches the conditional search criteria for the ServerName.
      JobStatus - the status of the Backup Job, and hence, the inferred backup status of the server name provided.
      StartTime - The date/time the returned backup job started.
      EndTime - The date/time the returned backup job finished.
  #>


	[OutputType([String])]
	param(
		[Parameter(Mandatory = $true, HelpMessage = 'Input the Hostname of the Computer you want to Query')]
		[ValidatePattern('[A-Za-z0-9]')]
		[string]
		$ComputerName
	)

	function Get-ServerName {
		param
		(
			[Parameter(Mandatory = $true, ValueFromPipeline = $true, HelpMessage = 'Data to filter')]
			[Object]$InputObject
		)
		process {
			if ($(($InputObject.SelectionSummary -match "$ComputerName" `
							-or $InputObject.SelectionSummary -match "$ComputerName.$domain" `
							-or $InputObject.SelectionSummary -match "$ComputerName.$domain (Partial)") `
						-or $InputObject.SelectionSummary -match "$ComputerName (Partial)" `
						-and ($InputObject.SelectionSummary -notlike "*$ComputerName (Excluded)*" `
							-and $InputObject.SelectionSummary -notlike "*$ComputerName.$domain (Excluded)*" `
							-and $InputObject.SelectionSummary -notlike "*$ComputerName - To Remove (Excluded)*") `
						-and ($InputObject.JobType -eq 'Backup'))) {
				$InputObject
			}
		}
	}

	$domain = $env:USERDNSDOMAIN
	$backup = Get-BEJob | Get-ServerName | Get-BEJobHistory | Sort-Object -Property StartTime -Descending | Select-Object -First 1

	if ($backup -eq $null) {
		Write-Warning -Message "$ComputerName not found active in any backup jobs"
	}
	else {
		$backupstatus = New-Object -TypeName PSObject
		$backupstatus | Add-Member -MemberType NoteProperty -Name 'Server' -Value "$ComputerName"
		$backupstatus | Add-Member -MemberType NoteProperty -Name 'Backup Exec Job' -Value "$($backup.Name)"
		$backupstatus | Add-Member -MemberType NoteProperty -Name 'JobStatus' -Value "$($backup.JobStatus)"
		$backupstatus | Add-Member -MemberType NoteProperty -Name 'StartTime' -Value "$($backup.StartTime)"
		$backupstatus | Add-Member -MemberType NoteProperty -Name 'EndTime' -Value "$($backup.EndTime)"

		$backupstatus
	}
}
