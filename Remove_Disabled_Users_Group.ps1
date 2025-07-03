# Define the group name
$GroupName = "Group Name"

# Define CSV output path
$CSVPath = "C:\users\Public\DisabledUsersReport.csv"

# Ensure the AD module is loaded
Import-Module ActiveDirectory

# Create an empty list to store the report
$Report = @()

# Get all user members of the group
$GroupMembers = Get-ADGroupMember -Identity $GroupName -Recursive | Where-Object { $_.objectClass -eq 'user' }

foreach ($User in $GroupMembers) {
    # Get full user details including Enabled property
    $UserDetails = Get-ADUser -Identity $User.SamAccountName -Properties Enabled

    # Track the action taken
    $ActionTaken = "No action - user enabled"

    if ($UserDetails.Enabled -eq $false) {
        # Remove the user from the group
        Remove-ADGroupMember -Identity $GroupName -Members $UserDetails -Confirm:$false
        $ActionTaken = "Removed from group - user disabled"
    }

    # Add to report
    $Report += [PSCustomObject]@{
        Username    = $UserDetails.SamAccountName
        Enabled     = $UserDetails.Enabled
        ActionTaken = $ActionTaken
    }
}

# Export the report to CSV
$Report | Export-Csv -Path $CSVPath -NoTypeInformation -Encoding UTF8

Write-Output "CSV report saved to: $CSVPath"
