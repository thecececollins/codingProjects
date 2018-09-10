<#
Powershell Script to Create a New Simple Contractor in AD 
Created by Ty Hill                                                        
Last updated 6/30/17 
----------------------------------------------------------------#>

<# 
This script creates an AD user account for Simple contractors and 
generates the following...
#>   

# First name, last name, full name
# Description field: Full Name (Contractor) 
# Email: user@simple.com
# SAM account name: CORP\username
# UPN: username@simple.com
# Places the user in the "Domain Users" group
# Creates a randomly generated secure password
# Outputs the created content
# Checks if script is being ran with elevated privs
# Kills the script if any of the variables are NULL 
# Checks for duplciate AD properties, kills the script if found
# Outputs errors and generated AD content

<#                                                  
#requires -version 4.0
#requires –runasadministrator
Write-Host "Admin check passed!"
#>

# Prompt for the name and email address

$Firstname   = Read-Host "Enter the user's first name" 
$Lastname    = Read-Host "Enter the user's last name" 
$Email       = Read-Host "Enter the user's email address"


# If the variables are empty, kill the script and output the results

if (!$Firstname -or !$Lastname -or !$Email) {
    Write-Host "Please specify a first name, last name, and an e-mail address."
    exit 1
    }

# Set display name, description to "Full Name + (Contractor), OU path, and password

$Fullname     = $Firstname + " " + $Lastname
$Contractor   = "(Contractor)"
$Description  = $Fullname + " " + $Contractor
$OU           = "OU=Domain Users,DC=corp,DC=simple,DC=com"
$Password     = (ConvertTo-SecureString -AsPlainText 'uv6LBPF.HwZKmAZGq' -Force)
$SAM          = $Email -replace "@.*"

# Set password ----------------------------------------------------------------------------------

<# Gets a random password of specified length containing numbers, uppercase letters, 
   lowercase letters and special characters. Minimum length required is 4 characters
   since password must contain all four types of characters, hower the min length is
   hard set to 14 in this case since that's the minimum amount of characters our
   hardening policy will allow. The formatting is funky because I lifted this part 
   of the script from the internet. 
#>

Function GetRandomPassword ([int] $length=14) {
    if ($length -lt 14) {
        return $null
     }

# Define list of numbers, this will be CharType 1
    $numbers=$null
    
    For ($a=48;$a –le 57;$a++) {
        $numbers+=,[char][byte]$a 
    }

# Define list of uppercase letters, this will be CharType 2
    $uppercase=$null
    
    For ($a=65;$a –le 90;$a++) {
        $uppercase+=,[char][byte]$a 
    }

# Define list of lowercase letters, this will be CharType 3

    $lowercase=$null

    For ($a=97;$a –le 122;$a++) {
        $lowercase+=,[char][byte]$a 
    }

# Define list of special characters, this will be CharType 4

    $specialchars=$null

    For ($a=33;$a –le 47;$a++) {
        $specialchars+=,[char][byte]$a 
    }

    For ($a=58;$a –le 64;$a++) {
        $specialchars+=,[char][byte]$a 
    }
        
    For ($a=123;$a –le 126;$a++) {
        $specialchars+=,[char][byte]$a 
    }

# Need to ensure that result contains at least one of each CharType
# Initialize buffer for each character in the password
    
    $Buffer = @()
    
    For ($a=1;$a –le $length;$a++) {$Buffer+=0 }

# Randomly chose one character to be number

    while ($true) {
        $CharNum = (Get-Random -minimum 0 -maximum $length)
        
        if ($Buffer[$CharNum] -eq 0) {
            $Buffer[$CharNum] = 1; break
        }
    }

# Randomly chose one character to be uppercase

    while ($true) {
        $CharNum = (Get-Random -minimum 0 -maximum $length)
        
        if ($Buffer[$CharNum] -eq 0) {
            $Buffer[$CharNum] = 2; break
        }
   }

# Randomly chose one character to be lowercase

    while ($true) {
        $CharNum = (Get-Random -minimum 0 -maximum $length)
        
        if ($Buffer[$CharNum] -eq 0) {
            $Buffer[$CharNum] = 3; break
        }
   }

# Randomly chose one character to be special

    while ($true) {
        $CharNum = (Get-Random -minimum 0 -maximum $length)
        
        if ($Buffer[$CharNum] -eq 0) {
            $Buffer[$CharNum] = 4; break
        }
    }

# Cycle through buffer to get a random character from the available types
# if the buffer already contains the CharType then use that type
        
    $Password = ""
        
    foreach ($CharType in $Buffer) {
        if ($CharType -eq 0) {
            $CharType = ((1,2,3,4)|Get-Random)
        }
        
        switch ($CharType) {
            1 {$Password+=($numbers | GET-RANDOM)}
            2 {$Password+=($uppercase | GET-RANDOM)}
            3 {$Password+=($lowercase | GET-RANDOM)}
            4 {$Password+=($specialchars | GET-RANDOM)}
        }
    }
        return $Password
}


# Get the password and store it in a variable

    $pw = GetRandomPassword

# Convert the password string to a secure string
$SecurePassword = ConvertTo-SecureString -String $pw -AsPlainText -Force

# Fill in the variables
$Parameters = @{
    'SamAccountName'        = $SAM
    'UserPrincipalName'     = $Email 
    'Name'                  = "$Fullname"
    'EmailAddress'          = $Email 
    'GivenName'             = $Firstname 
    'Surname'               = $Lastname 
    'DisplayName'           = "$Fullname"
    'Description'           = “$Description” 
    'AccountPassword'       = $SecurePassword 
    'ChangePasswordAtLogon' = $false 
    'Enabled'               = $true 
    'Path'                  = $OU
    }

# Check to see if the user exists in AD, if so kill the script, if not create the account and output the results

try
{

New-ADUser @Parameters -ErrorAction Stop   

}
catch
{
 Write-Warning "Failed to create user: $($error[0])"
 Exit
}


#Ouput within window via Write-Host, or use a Messagebox, just un/comment either line as needed
Write-Host   "Account successfully created in AD with the following properties..." -ForegroundColor Green
Write-Host   "Full Name: " -ForegroundColor Gray -NoNewline; Write-Host "$Fullname" -ForegroundColor Green
Write-Host   "Description Field: " -ForegroundColor Gray -NoNewline; Write-Host "$Description" -ForegroundColor Green
Write-Host   "Email: " -ForegroundColor Gray -NoNewline; Write-Host "$Email" -ForegroundColor Green
Write-Host   "SAM Account Name: " -ForegroundColor Gray -NoNewline; Write-Host "CORP\$SAM" -ForegroundColor Green
Write-Host   "UPN: " -ForegroundColor Gray -NoNewline; Write-Host "$Email" -ForegroundColor Green
Write-Host   "Randomly Generated Password: " -ForegroundColor Gray -NoNewline; Write-Host "Securely exported to AD" -ForegroundColor Green






<#######################################################################################################################################
Below is the 2.0 version of the script. It includes enhanced error checking and prompts for O365 Licensing. 
#----------------------Enhanced Error Checking:-------------------------
The following will allow us to get more granular on the error checking to identify
which AD properties already exist rather than throwing a generic error that the account
already exists. I'll hopefully be able to add this and test it soon...
if (Get-ADuser -Filter {SamAccountName -eq "$SAM"})
{
    Write-Warning "An account with the SamAccountName of << $SAM  >> already exists on the domain! A new account has not been created."
}
elseif (Get-ADUser -Filter {DisplayName -eq "$Fullname"})
{
    Write-Warning "An account with Name << $Fullname >> already exists on the domain! A new account has not been created."
}
elseif (Get-ADUser -Filter {EmailAddress -eq "$Email"})
{
    Write-Warning "An account with the email address of << $Email >> already exists on the domain! A new account has not been created."
}
else
{
#--------------------- Prompt for O365 Products------------------------
$MSanswer    = Read-Host "Does the user need licensing for Microsoft Office, Sharepoint, PowerBI, or Axiom? Y / N"
$No          = Write-Host "Awesome, moving on..." 
$MSyes       = Read-Host "OK, just the MS Office Suite?" 
if (($MSanswer -eq "no") -or ($MSanswer -eq "No") -or ($MSanswer -eq "N") -or ($MSanswer -eq "n"))
 {
$No
}
Elseif  (($MSanswer -eq "yes") -or ($MSanswer -eq "Yes") -or ($MSanswer -eq "Y") -or ($MSanswer -eq "y"))
 {
$MSyes  
 }
  else
  { 
  Write-Host -ForegroundColor Red "Just answer the damn question!"
  }
 
# Found the below method on the web, using "Switch"...
Write-host "Does the user need licensing for Microsoft Office, Sharepoint, PowerBI, or Axiom? (Default it No)" 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
       Y {Write-host "Yes, D"; $PublishSettings=$true} 
       N {Write-Host "No, Skip PublishSettings"; $PublishSettings=$false} 
       Default {Write-Host "Default, Skip PublishSettings"; $PublishSettings=$false} 
     } 
#######################################################################################################################>
