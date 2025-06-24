# This script identifies a user's UPN by appending each specified domain to the username, then checks how many licenses are assigned to the account.
# It outputs the results in a CSV file and provides verbose console output.

Connect-MgGraph -Scopes "User.Read.All"
# Configuration
$UserListPath = "C:\UsersList.txt"
$DomainsToTry = @("domain1.local", "domain2.local")

# Output collection
$results = @()

# Read usernames (without domain)
$Usernames = Get-Content $UserListPath

foreach ($username in $Usernames) {
    Write-Host "🔎 Checking: $username" -ForegroundColor Cyan
    $resolvedUPN = "Not Found"
    $licenseCount = "N/A"

    foreach ($domain in $DomainsToTry) {
        $upn = "$username@$domain"
        Write-Host "    → Trying UPN: $upn" -ForegroundColor Yellow

        try {
            $user = Get-MgUser -UserId $upn -Property AssignedLicenses -ErrorAction Stop
            $resolvedUPN = $user.UserPrincipalName
            $licenseCount = $user.AssignedLicenses.Count

            Write-Host "        ✅ Found! Resolved UPN: $resolvedUPN | Licenses: $licenseCount" -ForegroundColor Green
            break  # Found, stop checking other domains
        }
        catch {
            Write-Host "        ❌ Not found: $upn" -ForegroundColor DarkGray
            continue  # Try next domain
        }
    }

    if ($resolvedUPN -eq "Not Found") {
        Write-Host "    ⚠️ User '$username' not found in any domain!" -ForegroundColor Red
    }

    # Add result to collection
    $results += [PSCustomObject]@{
        Username      = $username
        ResolvedUPN   = $resolvedUPN
        LicenseCount  = $licenseCount
    }
}

# Export to CSV
$results | Export-Csv -Path "C:\UserLicenseReport.csv" -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ CSV Report saved to: C:\UserLicenseReport.csv" -ForegroundColor Green

