<#
  This script can be used to configure Email action triggers for defined vCenter alarms.
  
  Usage: setAlarmEmail.ps1 -vcenter <vcenter_fqdn>
  						   -email <email_address>,<email_address>,...
						   -alarms <alarms_text_file>
#>

param(
	[Parameter(Mandatory=$true)]
		[string]$vcenter,
	[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[string[]]$email,
	[Parameter(Mandatory=$true)]
		[string]$alarms
)

if (!(get-pssnapin -name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue )) { add-pssnapin "VMware.VimAutomation.Core" }
 
write-host "`nConnecting to vCenter server $vcenter ..."
Connect-VIServer $vcenter | out-null

<# set alarm actions #>
foreach ($alarm in (Get-Content $alarms)){
	write-host "`nConfigure $alarm alarm:"
	Get-AlarmDefinition -Name "$alarm" | Get-AlarmAction -ActionType SendEmail | Remove-AlarmAction -Confirm:$false
	Get-AlarmDefinition -Name "$alarm" | New-AlarmAction -Email -To @($email)
	Get-AlarmDefinition -Name "$alarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
	#Get-AlarmDefinition -Name "$alarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red"
	Get-AlarmDefinition -Name "$alarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"
	Get-AlarmDefinition -Name "$alarm" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
}

Disconnect-VIServer -Force -Confirm:$false