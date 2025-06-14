# Ask user for domain name input
$domain = Read-Host "Enter domain name (e.g. noob.local)"

$inputFile = "C:\Users\Public\devices.txt"
$outputFile = "C:\Users\Public\resolved_devices.txt"

# Clear output file if exists
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

Get-Content $inputFile | ForEach-Object {
    $hostname = $_.Trim()
    if (-not [string]::IsNullOrWhiteSpace($hostname)) {
        try {
            $fqdn = "$hostname.$domain"
            $ip = [System.Net.Dns]::GetHostAddresses($fqdn) | 
                  Where-Object { $_.AddressFamily -eq 'InterNetwork' } | 
                  Select-Object -First 1

            if ($ip) {
                "$hostname $fqdn $ip" | Out-File -FilePath $outputFile -Append
            }
            else {
                "$hostname - not found" | Out-File -FilePath $outputFile -Append
            }
        }
        catch {
            "$hostname - not found" | Out-File -FilePath $outputFile -Append
        }
    }
}

Write-Host "Output saved to $outputFile"
