#########################################################
#
# Name: ImportTestUsers.ps1
# Author: Israel Vega (Adjusted for JSON by Steven Follis)
# Version: 1.0
# Date: 06/08/2011
# Comment: Create test users from a JSON array for import into an AD
#
#########################################################

Param(
    # Specify number of sample users to generate between 1-5000
    [int] $NumberUsers = 1,

    # Specify the target OU for new users
    [string] $TargetOU = "CN=Users,DC=contoso,DC=local"
)

# Import the Active Directory Powershell Module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

############################
#  Change these values
############################

# Password for all users
$password = ConvertTo-SecureString "Docker123!" -AsPlainText -Force

############################
#  Script below
############################

# Function to test existence of AD object
function Test-XADObject() {
    [CmdletBinding(ConfirmImpact = "Low")]
    Param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Identity if the AD object exists or not."
        )]
        [Object] $Identity
    )
    trap [Exception] {
        return $false
    }
    $auxObject = Get-ADObject -Identity $Identity
    return $true
}

# Check the params
if (!(1..5000 -contains $NumberUsers)) {
    Write-Error "The number has to be more than 1 and less than 5000"
    exit
}

# Find the current domain info
$domDns = (Get-ADDomain).dnsroot # for UPN generation

# Check if the target OU is valid
$validOU = Test-XADObject $TargetOU
if (!$validOU) { 
    write-host "Error: Specified OU for new users does not exist - exiting...."
    exit
} 

# Create groups
$Groups = @("Engineering", "Operations")
foreach ($Group in $Groups) {
    
    # Check if group already exists
    $groupExists = Get-ADGroup -Filter {(SamAccountName -eq $Group)}
    if ($groupExists -eq $null) {
        Write-Host "Group not found. Creating new group $Group"
        New-ADGroup -Name "$Group Members" `
                    -SamAccountName $Group `
                    -GroupCategory Security `
                    -GroupScope Global `
                    -DisplayName $Group `
                    -Path $TargetOU `
                    -Description "Members of this group work within $Group"
    }
    else {
        Write-Host "Group already exists named $Group"
    }
}

# Retrieve sample users from API and store as JSON
$sampleUsers = Invoke-WebRequest -UseBasicParsing -Uri "https://randomuser.me/api/?nat=us,gb&results=$($NumberUsers)&format=json&noinfo" | ConvertFrom-Json

# Count new users that are created
$newUsers = 0

# Loop through the returned sample users
foreach ($user in $sampleUsers.results) {
    # Map user attributes to variables
    $displayName = (Get-Culture).TextInfo.ToTitleCase($user.name.first + " " + $user.name.last)
    $samName = "$($user.name.first)".Substring(0, 1) + $($user.name.last)
    $surname = (Get-Culture).TextInfo.ToTitleCase($user.name.last)
    $givenName = (Get-Culture).TextInfo.ToTitleCase($user.name.first)
    $upnName = "$samName" + "@" + "$domDns"

    # Check if user already exists
    $userExists = Get-ADUser -Filter {(userPrincipalName -eq $upnName)}
    if ($userExists -eq $null) {
        Write-Host "User not found. Creating new user $upnName"
        
        # Create new AD User
        New-ADUser -Name $displayName `
            -SamAccountName $samName `
            -DisplayName $displayName `
            -GivenName $givenName `
            -Surname $surname `
            -UserPrincipalName $upnName `
            -Path $TargetOU `
            -Enabled $true `
            -ChangePasswordAtLogon $false `
            -AccountPassword $password 
        
        # Add user to a random group
        $GroupID = Get-Random -Minimum 0 -Maximum $Groups.Length
        Add-ADGroupMember $Groups[$GroupID] $samName

        # Iterate counter
        $newUsers++
        
        # Handle Error
        trap [Exception] {
            write-Error "An error occured::$_.Exception.Message. Exiting."
            exit
        }
    }
    else {
        Write-Host "User $upnName exists. Skipping"
    }    
}
Write-Host "Created $newUsers test users."

# Create a reader account for searching via LDAP
$readerExists = Get-ADUser -Filter {(userPrincipalName -eq "reader@contoso.local")}
if ($readerExists -eq $null) {
    Write-Host "Creating reader account"
    New-ADUser -Name "reader" `
                -SamAccountName "reader" `
                -DisplayName "reader" `
                -UserPrincipalName "reader@$domDns" `
                -Path $TargetOU `
                -Enabled $true `
                -ChangePasswordAtLogon $false `
                -AccountPassword $password 

    # Handle Error
    trap [Exception] {
        write-Error "An error occured::$_.Exception.Message. Exiting."
        exit
    }
}
else {
    Write-Host "Account for reader already exists"
}
 
# Finished
Write-Host "Completed sample user generation"