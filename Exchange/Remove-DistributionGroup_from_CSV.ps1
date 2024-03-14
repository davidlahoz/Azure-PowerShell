# Needed Modules. "PowershellGet" and "ExchangeOnlineManagement"


# Connect to Exchange Online - prompts user-interactive login
Connect-ExchangeOnline


# Define the path to the CSV file - CSV column name must be "Identity"
$csvPath = "C:\temp\DistributionGroupsToDelete.csv"

# Check if the CSV file exists
if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file not found at $csvPath"
    Exit
}

# Read the CSV file recursively
$groups = Import-Csv -Path $csvPath

# Iterate through each row in the CSV
foreach ($group in $groups) {
    # Check if the 'Identity' column exists
    if ($group.PSObject.Properties.Name -contains 'Identity') {
        # Get the identity of the distribution group
        $identity = $group.Identity
        
        # Try to remove the distribution group
        $errorActionPreference = "Stop"
        try {
            Remove-DistributionGroup -Identity $identity -ErrorAction Stop
            Write-Host "Distribution group '$identity' removed successfully."
        } catch {
            $errorMessage = $_.Exception.Message
            if ($errorMessage -match "couldn't be found on") {
                Write-Host "The group $identity was not deleted since it does not exist in your Directory."
            } else {
                Write-Host "Failed to remove distribution group '$identity': $_"
            }
        } finally {
            $errorActionPreference = "Continue"
        }
    } else {
        Write-Host "Identity column not found in the CSV file."
        Exit
    }
}