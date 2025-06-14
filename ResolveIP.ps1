$inputFile = "C:\Users\Public\ips.txt"
$outputFile = "C:\Users\Public\resolved_ips.txt"

# Clear output file if exists
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

Get-Content $inputFile | ForEach-Object {
    $ip = $_.Trim()
    if (-not [string]::IsNullOrWhiteSpace($ip)) {
        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($ip)
            if ($hostEntry.HostName) {
                "$ip $($hostEntry.HostName)" | Out-File -FilePath $outputFile -Append
            }
            else {
                "$ip - not found" | Out-File -FilePath $outputFile -Append
            }
        }
        catch {
            "$ip - not found" | Out-File -FilePath $outputFile -Append
        }
    }
}

Write-Host "Output saved to $outputFile"
