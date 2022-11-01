function Update-MDAntivirus {
	<#
	.SYNOPSIS
		Update MDA security intelligence update

	.DESCRIPTION
		Trigger manual update and immediately download and apply the latest security intelligence update

	.PARAMETER UpdateSignatures
		Updating antivirus definitions and signature files

	.PARAMETER RemoveSignatures
		Remove and update antivirus definitions and signature files

	.EXAMPLE
		Update-MDAntivirus -UpdateSignatures

		Update antivirus definitions and signature files

	.EXAMPLE
		Update-MDAntivirus -RemoveSignatures

		Remove and update antivirus definitions and signature files

	.NOTES
		https://www.microsoft.com/en-us/wdsi/defenderupdates
	#>

	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
	[OutputType([System.String])]
	param(
		[switch]
		$UpdateSignatures,

		[switch]
		$RemoveSignatures
	)

	# Being block
	begin {
		Write-Output "Manually download the latest security intelligence update"
		$parameters = $PSBoundParameters
	}

	# Process Block
	process {
		if (-NOT(Test-Path -Path "$env:ProgramFiles\Windows Defender" -ErrorAction Stop)) {
			Write-Output "ERROR! $("$env:ProgramFiles\Windows Defender") not found!"
		}
		else {
			Set-Location "$env:ProgramFiles\Windows Defender"
			Write-Verbose "Changing location to c:\Program Files\Windows Defender"
			Write-Verbose "Checking for elevated permissions"
			if ($parameters.ContainsKey('RemoveSignatures')) {
				if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
					Write-Output "You need to run this script as an Administrator to remove older definitions and signatures. Open the PowerShell console as an administrator and run this script again."
					return
				}

				if ($PSCmdlet.ShouldProcess("Removing older definitions and signatures")) {
					Start-Process -FilePath ".\MpCmdRun.exe" -NoNewWindow -ArgumentList "-removedefinitions -dynamicsignatures"
				}
			}

			if ($PSCmdlet.ShouldProcess("Updating definitions and signatures")) {
				Start-Process -FilePath ".\MpCmdRun.exe" -NoNewWindow -ArgumentList "-SignatureUpdate"
			}
		}
	}

	# End Block - Warning. Code in here might not execute if there is an exception or we terminate the function
	end {
		Write-Output "Completed! For more information please see: https://www.microsoft.com/en-us/wdsi/defenderupdates"
	}
}
