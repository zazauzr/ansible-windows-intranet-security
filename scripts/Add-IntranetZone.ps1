<#
.SYNOPSIS
    Configures Windows Internet Explorer / Intranet Zones via Registry.
.DESCRIPTION
    Adds a specific trusted IP/Domain to the Local Intranet Zone (Zone 1) 
    to prevent security warnings when launching files from network shares.
.PARAMETER TargetAddress
    The IP address or domain name of the internal file server.
#>

param (
    [string]$TargetAddress = "192.168.1.252"
)

$ErrorActionPreference = "Stop"

# Define the Registry Path for Internet Explorer Domains mapping
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
$SanitizedAddress = $TargetAddress -replace "http://|https://|file://", ""

Write-Host "Configuring Local Intranet Zone for: $SanitizedAddress" -ForegroundColor Cyan

try {
    # Check if domain key exists, create if missing
    if (-not (Test-Path "$RegPath\$SanitizedAddress")) {
        New-Item -Path "$RegPath\$SanitizedAddress" -Force | Out-Null
    }

    # Set 'file' protocol to Zone 1 (Local Intranet)
    # Value definitions: 1 = Local Intranet, 2 = Trusted, 3 = Internet, 4 = Restricted
    New-ItemProperty -Path "$RegPath\$SanitizedAddress" -Name "file" -Value 1 -PropertyType DWord -Force | Out-Null
    
    # Optional: Set http/https protocols to the same zone if web UI is hosted
    New-ItemProperty -Path "$RegPath\$SanitizedAddress" -Name "http" -Value 1 -PropertyType DWord -Force | Out-Null

    Write-Host "[SUCCESS] Intranet zone successfully configured for $SanitizedAddress." -ForegroundColor Green
}
catch {
    Write-Error "Failed to update registry settings: $_"
    exit 1
}
