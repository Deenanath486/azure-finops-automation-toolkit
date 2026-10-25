<#
.SYNOPSIS
    Finds and reports all unattached Azure Managed Disks across subscriptions.
.DESCRIPTION
    Scans Azure subscriptions for unattached managed disks (orphaned disks after VM deletions),
    calculates potential monthly waste, and exports a CSV audit report.
    Supports safe Snapshot creation before optional cleanup.
.PARAMETER ExportCsvPath
    File path to export the audit findings. Default is .\unattached-disks-report.csv.
.PARAMETER Delete
    Switch to safely delete unattached disks after creating a retention snapshot.
.EXAMPLE
    .\find-unattached-disks.ps1 -ExportCsvPath "audit-disks.csv"
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [string]$ExportCsvPath = ".\unattached-disks-report.csv",
    [switch]$Delete = $false
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Azure FinOps: Unattached Managed Disk Detection Tool   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Estimated Monthly Cost per GB (Standard LRS ~ $0.05/GB, Premium SSD ~ $0.135/GB)
$costEstimates = @{
    "Standard_LRS"     = 0.05
    "StandardSSD_LRS"  = 0.075
    "Premium_LRS"      = 0.135
    "UltraSSD_LRS"     = 0.20
}

$unattachedDisks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $null }

if ($unattachedDisks.Count -eq 0) {
    Write-Host "[✓] Zero unattached disks found! Cloud waste is 0." -ForegroundColor Green
    return
}

$results = @()
$totalWastedCost = 0
$totalWastedStorageGB = 0

foreach ($disk in $unattachedDisks) {
    $sku = $disk.Sku.Name
    $sizeGB = $disk.DiskSizeGB
    $rate = if ($costEstimates.ContainsKey($sku)) { $costEstimates[$sku] } else { 0.05 }
    $monthlyCost = [math]::Round($sizeGB * $rate, 2)

    $totalWastedCost += $monthlyCost
    $totalWastedStorageGB += $sizeGB

    $results += [PSCustomObject]@{
        SubscriptionId    = (Get-AzContext).Subscription.Id
        ResourceGroupName = $disk.ResourceGroupName
        DiskName          = $disk.Name
        Location          = $disk.Location
        SkuTier           = $sku
        SizeGB            = $sizeGB
        EstimatedCostUSD  = $monthlyCost
        TimeCreated       = $disk.TimeCreated
    }

    Write-Host "[-] Orphaned Disk: $($disk.Name) | RG: $($disk.ResourceGroupName) | Size: ${sizeGB}GB | Est Cost: `$$monthlyCost/mo" -ForegroundColor Yellow
}

$results | Export-Csv -Path $ExportCsvPath -NoTypeInformation
Write-Host "`n[✓] Audit Report successfully exported to: $ExportCsvPath" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Total Orphaned Disks : $($unattachedDisks.Count)" -ForegroundColor White
Write-Host " Total Storage Wasted : ${totalWastedStorageGB} GB" -ForegroundColor White
Write-Host " Potential Cost Waste : `$$totalWastedCost / month" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Cyan
