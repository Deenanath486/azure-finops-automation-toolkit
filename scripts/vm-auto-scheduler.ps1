<#
.SYNOPSIS
    Automated start and deallocation scheduler for non-production Azure VMs.
.DESCRIPTION
    Saves up to 65% on VM compute costs by stopping non-production VMs outside business hours.
    Honors tag 'ExcludeFromAutoShutdown=true' to protect critical servers.
.PARAMETER Action
    'Start' to power on VMs, 'Stop' to deallocate VMs (releasing compute billing).
.PARAMETER TagFilter
    Environment tag to target, e.g. 'Development', 'UAT', or 'Testing'.
#>

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action,

    [string]$EnvironmentTag = "Development"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       Azure FinOps: Automated VM Scheduler ($Action)     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$vms = Get-AzVM -Status

$targetVms = $vms | Where-Object {
    $tags = $_.Tags
    $isTargetEnv = ($tags -ne $null -and $tags["Environment"] -eq $EnvironmentTag)
    $isNotExcluded = ($tags -eq $null -or $tags["ExcludeFromAutoShutdown"] -ne "true")
    $isTargetEnv -and $isNotExcluded
}

Write-Host "Found $($targetVms.Count) VMs matching Environment='$EnvironmentTag' (Exclusions respected)." -ForegroundColor White

foreach ($vm in $targetVms) {
    $powerState = ($vm.Statuses | Where-Object { $_.Code -like "PowerState/*" }).DisplayStatus

    if ($Action -eq "Stop" -and $powerState -eq "VM running") {
        Write-Host "[>] Deallocating VM: $($vm.Name) in RG: $($vm.ResourceGroupName)..." -ForegroundColor Yellow
        Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force -NoWait
    }
    elseif ($Action -eq "Start" -and $powerState -ne "VM running") {
        Write-Host "[<] Starting VM: $($vm.Name) in RG: $($vm.ResourceGroupName)..." -ForegroundColor Green
        Start-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -NoWait
    }
    else {
        Write-Host "[-] Skipping VM: $($vm.Name) (Current state: $powerState)" -ForegroundColor Gray
    }
}

Write-Host "`n[✓] Scheduler execution completed successfully!" -ForegroundColor Green
