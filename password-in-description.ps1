# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OU Where to Enumerate with this Script
$OU = "DC=test,DC=local"

# Define the keyword to search for in the description (case-insensitive) - Make Sure to rename the keyword to somethign PW,pw,password,Passwd,passwd
$keyword = "*Password*"

# Search for all user accounts in the OU that have 'Password' in their description
try {
    # Using -Filter with case-insensitive search for the keyword in Description
    $users = Get-ADUser -Filter { Description -like $keyword } -SearchBase $OU -Properties Description
    
    # Check if any users were found
    if ($users) {
        # Output the relevant information (Name and Description)
        $users | Select-Object Name, Description

        # Define the output file path
        $outputFilePath = "C:\Temp\ound_keyword.txt"
        
        # Save the output to the file
        $users | Select-Object Name, Description | Out-File -FilePath $outputFilePath

        # Confirmation message
        Write-Host "Results saved to $outputFilePath"
    } else {
        Write-Host "No users found with 'Password' in their description."
    }
} catch {
    Write-Host "An error occurred: $_"
}
