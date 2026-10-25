<#
.SYNOPSIS
    Detects unassociated Azure Public IP addresses incurring idle hourly charges.
.DESCRIPTION
    Scans Azure for Public IPs not bound to any NIC, Load Balancer, or Gateway.
#>

param (
    [string]$ExportCsvPath = ".\unused-public-ips.csv"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     Azure FinOps: Unused Public IP Detection Tool        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$unusedIps = Get-AzPublicIpAddress | Where-Object { $_.IpConfiguration -eq $null -and $_.NatGateway -eq $null }

if ($unusedIps.Count -eq 0) {
    Write-Host "[✓] Zero unassociated Public IPs found." -ForegroundColor Green
    return
}

$results = @()
# Standard static IP cost ~ $3.65/month each
$monthlyRatePerIp = 3.65
$totalWaste = [math]::Round($unusedIps.Count * $monthlyRatePerIp, 2)

foreach ($ip in $unusedIps) {
    $results += [PSCustomObject]@{
        SubscriptionId    = (Get-AzContext).Subscription.Id
        ResourceGroupName = $ip.ResourceGroupName
        Name              = $ip.Name
        Location          = $ip.Location
        Sku               = $ip.Sku.Name
        IpAddress         = $ip.IpAddress
        EstMonthlyWaste   = $monthlyRatePerIp
    }

    Write-Host "[-] Unused Public IP: $($ip.Name) ($($ip.IpAddress)) in RG: $($ip.ResourceGroupName)" -ForegroundColor Yellow
}

$results | Export-Csv -Path $ExportCsvPath -NoTypeInformation
Write-Host "`n[✓] Audit Report successfully exported to: $ExportCsvPath" -ForegroundColor Green
Write-Host "Total Unused Public IPs: $($unusedIps.Count) | Est Waste: `$$totalWaste / month" -ForegroundColor Red
