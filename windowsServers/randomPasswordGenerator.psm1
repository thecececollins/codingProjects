# Gets a random password of specified length containing numbers, uppercase letters, 
# lowercase letters and special characters. Minimum length required is 4 characters
# since password must contain all four types of characters, hower the min length is
# hard set to 14 in this case since that's the minimum amount of characters our
# hardening policy will allow. Oh, by the way, I stole this part and so that's why
# the formatting is fucky. 

Function Get-RandomPassword ([int] $length=14) {
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

Function Get-Admin {
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    $IsAdmin=$prp.IsInRole($adm)

    if (!$IsAdmin) {
        Write-Host "You need to run this script with elevated priveleges. Right click on Powershell and select Run As Administrator"
        Break
    }
}

Function Get-SimpleConfigFile {

    if (-Not (Test-Path ($PSScriptRoot + "\config.xml"))) {
        Write-Output "Config file not found in the expected location: $($PSScriptRoot + "\config.xml")`nPlease generate one and try again."
        Break   
    }
}

Function New-SimpleConfigFile {
    
    $configFileLocation = ($PSScriptRoot + "\config.xml")

    if (Test-Path $configFileLocation) {
        Write-Output "A config file exists in $configFileLocation. Bailing."
        Break
    }

    
    $configFile = New-Object System.XML.XmlTextWriter($configFileLocation, $null)
    $configFile.Formatting = 'Indented'
    $configFile.Indentation = 1
    $configFile.IndentChar ="`t"

    $configFile.WriteStartDocument()
    $configFile.WriteComment('Standard AF Simple Config File')
    $configFile.WriteStartElement('Server')
    $configFile.WriteElementString('Name',' ')
    $configFile.WriteElementString('Key',' ')
    $configFile.WriteElementString('Text',' ')
    $configFile.WriteEndElement()
    $configFile.WriteEndDocument()
    $configFile.Flush()
    $configFile.Close()

    Write-Output "Created a config file at: $configFileLocation"
}

function New-User {

# A script to generate a list of local Windows users with complex passwords given either
# a CSV file as input or a series of arguments. The password generation portion of this 
# script was STRAIGHT LIFTED from the internet because scripting is hard. 

# -------------------------------------------------------------------------------------#

# Get the login name and the full name of the user

    param (
            [string]$accountName = $(Read-Host "Enter the username"), 
            [string]$fullName = $(Read-Host "Enter the full name of the user"),
            [String]$emailAddress = $(Read-Host "Enter the user's e-mail address")
    )

    Get-SimpleConfigFile

        $configFile = ($PSScriptRoot + "\config.xml")
        [xml]$config = (Get-Content $configFile)
        $server = $config.Server.Name
        $apikey =  $config.Server.key
        $text = $config.Server.Text

    # Check to see if this script is being run as an admin. 

    Get-Admin

    # If the variables are NULL then bail


    if (!$accountName -or !$fullName -or !$emailAddress) {
        Write-Host "Yo, you need to specify a username, a full name and an e-mail address."
        Break
    }
    else {

    # If the variables are there, we'll proceed in grabbing the Slack user associated with this account. Starting with the e-mail address we got earlier
    # We're going to dig through all the Slack accounts until we find one with an e-mail that matches
        $slackUser = (Invoke-RestMethod -Uri https://slack.com/api/users.list -Body @{token=$apikey}).members | where {$_.profile.email -eq $emailAddress}

    # If there are no matches, we're going to ask for their actual Slack username, which should be easy enough to find, and use that to search for the user ID.
        if (!$slackUser) {
            Write-Host "I can't find that Slack user by their e-mail."
            $retry = $( Read-Host "Please enter the user's Slack username")
            $slackUser = (Invoke-RestMethod -Uri https://slack.com/api/users.list -Body @{token=$apikey}).members | where {$_.name -eq $retry}

    # If a user still cannot be found, we bail. Something is wrong!
            if (!$slackuser) {
                Write-Output "Can't find that Slack user. Make sure they have a Slack account - one is required before you can make an account in this system. Sorry bb."
                Break
            }
         }

    # Get the hostname of the local machine to connect to the ADSI interpreter and  provide the ADSI interpreter the correct path.
    # We're also setting the $slackid variable, because the PostMessage method at the end of the script really likes a clean variable with no dots.

        $slackid = $slackuser.id
        $hostname = hostname
        $comp = [adsi] "WinNT://$hostname"

    # Dump all user objects into $localUsers so we can make sure we aren't making duplicate usernames. 

        $localUsers = $comp.Children | where {$_.SchemaClassName -eq 'user'}  |  % {$_.name[0].ToString()} 

    # If the account we're trying to make already exists, dump the script. Nothing to see here! 
        if($localUsers -Contains $accountName) {    
            Write-Host $accountName "already exists, hoss."
            Break
        }

    # Get the password and store it in a variable

        $pw = Get-RandomPassword

    # Create the user and set their password

        $user = $comp.Create("User", $accountName)   
        $user.SetPassword("$pw")
        $user.SetInfo()

        $user.FullName = $fullName
        $user.Description = $slackUser.id
        $user.SetInfo()

    # Add user to the appropriate group (Remote Desktop Users)

        $group = [ADSI]"WinNT://$hostname/Remote Desktop Users,group"
        $group.Add("WinNT://$hostname/$accountName,user")

    # We're using the postMessage method to send over instructions to the user. This is fairly straightforward. Formatting is really wonky in this code because we're sending a bunch
    # text and I'm trying to make it pretty. 

        $postSlackMessage = @{
            token=$apikey;
            channel=$slackid.ToString();
            text=$ExecutionContext.InvokeCommand.ExpandString($text);
            link_names=1
            as_user="true"

        }

        Invoke-RestMethod -Uri https://slack.com/api/chat.postMessage -Body $postSlackMessage

    # Tell us what you've done, friendly robot.

        Write-Output "Created the user: $accountname with the full name $fullName. This account has been associated with the the Slack user:" 
        Write-Output $slackUser.name
        Write-Host "A FRIENDLY ROBOT has sent this user their credentials, so there's nothing for you to do!"
    }

}

function Reset-UserPassword {
    param (
        [string]$accountName = $( Read-Host "Enter the username" )
    )

    # Gets a random password of specified length containing numbers, uppercase letters, 
    # lowercase letters and special characters. Minimum length required is 4 characters
    # since password must contain all four types of characters, hower the min length is
    # hard set to 14 in this case since that's the minimum amount of characters our
    # hardening policy will allow. Oh, by the way, I stole this part and so that's why
    # the formatting is fucky. 

    # Check to make sure this script is being run as an administrator. 

    Get-Admin

    # If the variable is NULL then bail

    if (!$accountName) {
        Write-Host "Yo, you need to specify a username"
        Break
    }
 
    # Get the hostname of the local machine to connect to the ADSI interpreter and tell
    # the provide the ADSI interpreter the correct path

    $hostname = hostname
    $comp = [adsi] "WinNT://$hostname"
    $user = $comp.children | where {$_.schemaclassname -eq "user" -and $_.name -eq $accountName}

    # Dump all user objects into $localUsers so we can make sure the account exists. 

    $localUsers = $comp.Children | where {$_.SchemaClassName -eq 'user'}  |  % {$_.name[0].ToString()}  

    if($localUsers -Contains $accountName) {

    # Get the password and display it on screen so that it can
    # be copied off someplace

        $pw = Get-RandomPassword
        
    #  Set their password

        $user.SetPassword($pw)
        $user.PasswordExpired = 0
        $user.IsAccountLocked = $False
        $user.SetInfo()

        Write-Host "$accountname, aka "$user.Fullname" has had their password reset to: $pw and this password is now stored in your clipboard."
        $pw | clip
    }

    else {
            Write-Host $accountName "is not an account that exists in this system. Try again!"
            Break
    }

}

Export-ModuleMember -Function New-User, Reset-UserPassword, New-SimpleConfigFile
