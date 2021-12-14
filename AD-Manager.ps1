Write-Host "       made by     "
Write-Host "                   "
Write-Host "            |      "
Write-Host " __,  _   __|   ,  "
Write-Host "/  | |/  /  |  / \_"
Write-Host "\_/|/|__/\_/|_/ \/ "
Write-Host "  /|               "
Write-Host "  \|               "
Write-Host "                   "
Write-Host "     08/12/2021    "

#Functions Menu
function Get-Menu
{
    param (
        [string]$Title = 'Manage AD'
    )
    #Clear-Host
    Write-Host "================ $Title ================"
    Write-Host ""
    Write-Host ""
    Write-Host "1: Press '1' Rename server."
    Write-Host "2: Press '2' Configure network."
    Write-Host "3: Press '3' Install Active Directory Domain Services role and features."
    Write-Host "4: Press '4' Configure Active Directory Domain. "
    Write-Host "5: Press '5' Configure DNS forwarder. "
    Write-Host "6: Press '6' Import Users and create OU. "
    Write-Host "7: Press '7' Check Users inactive. "
    Write-Host "Q: Press 'Q' to quit."
    Write-Host ""
    $selection = Read-Host "Please make a selection"

    Switch( $selection ){
    1{Get-Rename}
    2{Get-IP}
    3{Get-AD}
    4{Get-conf}
    5{Get-DnsForward}
    6{Get-SubMenu}
    7{Get-InactiveUsers}
    }
    
}

# Sub Menu for importing users and create OU
function Get-SubMenu
    {
        param (
            [string]$Title = 'Core or GUI'
            )
        Clear-Host
        Write-Host "================ $Title ================"
        Write-Host ""
        Write-Host ""
        Write-Host "1: Press '1' Core Import CSV."
        Write-Host "2: Press '2' GUI Import CSV."
        Write-Host "3: Press '3' Back to main menu."
        Write-Host ""
        $selection = Read-Host "Please make a selection"

        Switch( $selection ){
        1{Get-CORE}
        2{Get-GUI}
        3{Get-Menu}
        }  
}

#Functions  Rename the server
function Get-Rename {
    
    process
    {
        $input = Read-Host “Enter the desired name for this server”
        $confirmation = Read-Host "Do you want to apply the changes ? [y/n] "

        If ($confirmation -eq 'y')
        {
            Rename-Computer -NewName "$input"
            Write-Host = "The server will restart"
            Start-Sleep -Seconds 2
            restart-computer
        }

        else
        {
            Write-Host "Operation canceled"
            Start-Sleep -Seconds 2
            Get-Menu       
        }
    }
}

#Functions  Change IP server
Function Get-IP {

    process
    {
        # List Net Adapter
        Get-NetAdapter
        Write-Host ""
        Start-Sleep -Seconds 2

        # Show parameters
        $adapter = Read-Host "Enter the ifIndex of the adapter"
        $adapterName = Read-Host "Enter the Name of the adapter"

        Write-Host ""
        Write-Host "This is the current configuration"
        Get-NetIPConfiguration -InterfaceIndex "$adapter" | Format-List
        Start-Sleep -Seconds 2

        Write-Host "If you accept, the selected adapter will be reset to apply the new configuration."
        Write-Host ""
        $confirmation = Read-Host "Do you want reconfigure this adapter ? [y/n] "
        If ($confirmation -eq 'y')
        {
		$IP = Read-Host "Enter the desired IP address "
		$CIDR = Read-Host "Enter the CIDR "
            	$Gateway = Read-Host "Enter the Gateway "
            	$DNS = Read-Host "Enter the desired DNS IP (Like 127.0.0.1 for a ADDS Server) "

           	#Disable DHCP
            	Set-NetIPInterface -InterfaceIndex "$adapter" -Dhcp Disabled

            	#Turn off adapter and turn on
            	Disable-NetAdapter -Name "$adapterName"
            	Enable-NetAdapter -Name "$adapterName"

            	#Remove Config
            	Get-NetAdapter | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$false
            	Get-NetAdapter | Remove-NetRoute -AddressFamily IPv4 -Confirm:$false

            	#New address & Mask & Gateway
            	Get-NetAdapter -InterfaceIndex "$adapter" | New-NetIPAddress `
                	-AddressFamily IPv4 `
                	-IPAddress $IP `
                	-PrefixLength $CIDR `
                	-DefaultGateway $Gateway
            
            	#New DNS server
            	Set-DnsClientServerAddress -InterfaceIndex "$adapter" -ServerAddresses "$DNS"
            	Start-Sleep -Seconds 5
            	Write-Host = "Modified configuration "
	    	Write-Output $_

            	$Nconfirmation = Read-Host "Do you want disable IPv6 on this adapter ? [y/n]  "
            	If ($Nconfirmation -eq 'y')
             	{
                 	Disable-NetAdapterBinding -Name "$AdapterName" -ComponentID ms_tcpip6
			Get-NetAdapterBinding -Name "$AdapterName" -ComponentID ms_tcpip6
                 	Write-Output $_
                 	Get-Menu
             	}

             	else
             	{
               		Write-Host "The script does not manage the IPv6 configuration, please do it manually"
               		Start-Sleep -Seconds 2
               		Get-Menu            
             	}
        }
        else
        {
		Write-Host "Operation canceled"
            	Get-Menu       
        }
    }
}


#Functions  Install role en feature
Function Get-AD {

    process
    {
	$FeatureList = @("RSAT-AD-Tools", "AD-Domain-Services")
        Get-WindowsFeature -Name $FeatureList

        Foreach ($Feature in $FeatureList) 
        {
	        If (((Get-WindowsFeature -Name $Feature).InstalState -Ne "Installed")) 
            {
	            Write-Host "Feature $Feature is not installed"
		    
	            Try 
		    {
		        $confirmation = Read-Host "RSAT and ADDS role are not installed did you want install it ? [y/n] "
        	        If ($confirmation -eq 'y')
                        {
                            Add-WindowsFeature -Name $Feature -IncludeManagementTools -IncludeAllSubfeature
		            Write-Host "$Feature installed successfully" -ForegroundColor Green
                            Write-Host "Server need to be restarted" -ForegroundColor Yellow
		                    Start-Sleep -Seconds 10
                            Get-WindowsFeature -Name $FeatureList
                            restart-computer
                         }
			 
                    	else
                    	{
                        	Write-Host "Operation canceled"
                        	Get-Menu
                    	}
	            }

	            Catch
		    {
                    Write-Host "An error occurred:"
                    Write-Output $_
                    Get-Menu
	            }

            }

            else
            {
                Write-Host "Operation canceled"
                Get-Menu
            }
        }
    }
}


Function Get-conf {

Import-Module ADDSDeployment

Write-Host "Define the functional level of the active directory (like 3 to 7)"
Write-Host "Windows Server 2008: 3 : 3"
Write-Host "Windows Server 2008 R2 : 4"
Write-Host "Windows Server 2012 : 5"
Write-Host "Windows Server 2012 R2 : 6"
Write-Host "Windows Server 2016 : 7"

$level = Read-Host "Enter the N° functional level of the active directory : "
$DomainName = Read-Host "Enter the domain name : "
$ForestMode = Read-Host "Enter the level of the forest like 3 to 7 same of the functional level : "


$NetbiosName = ($DomaineName -split {$_ -eq "."})[0]
$NetbiosNameSub = $NetbiosName.Substring(0,10)

    Try
    {
        Install-ADDSForest `
            -CreateDnsDelegation:$false `
            -DatabasePath “C:\Windows\NTDS” `
            -DomainMode “$level” `
            -DomainName “$DomainName” `
            -DomainNetbiosName “$NetbiosNameSub” `
            -ForestMode “Win2012R2” `
            -InstallDns:$true `
            -LogPath “C:\Windows\NTDS” `
            -NoRebootOnCompletion:$false
            -SysvolPath “C:\Windows\SYSVOL” `
            -Force:$true
    }

    Catch
    {
        Write-Host "An error occurred:"
        Get-Menu
    }
}


Function Get-DnsForward {
    Process
    {
        $confirmation = Read-Host "Do you want to enter a DNS forwarder ? [y/n] "
        If ($confirmation -eq 'y')
        {
            $forwarder = Read-Host "Enter the resolver's IP address"
            Set-DnsServerForwarder -IPAddress "$forwarder" -PassThru
            $DNSforwarder = Get-DnsServerForwarder
            Write-Host "Dns Server Forwarder success created"
            Get-Menu
        }
        
        Else
        {
        Write-Host "Operation canceled"
        Get-Menu
        }
    }

}




Function Get-Core {
    process
    {
       Import-Module activedirectory

       # Warning
       Write-Host "Be careful, this script uses the SamAccountName@domainname to create the user's e-mail address (check that this matches your expectations (otherwise modify line 278 so that it corresponds to your e-mail column in the CSV)" -ForegroundColor Red

       #Retrieve the domain name
       $Domain = (Get-ADDomain).DNSRoot

       $csvFile = Read-Host "Enter the path and name of the .CSV file"
       $Delimiter = Read-Host "Confirm the delimiter (Like ,/; ) "

       Import-CSV $csvFile -Delimiter $Delimiter

        # Read CSV
        $lastname = $_.Surname  # Last name
        $firstname = $_.GivenName # first name
        $SamAccountName  = $_.SamAccountName # Login
        $DisplayName = $_.GivenName+" "+$_.Surname # Login on the screen
        $Department  = $_.Department # Services
        $RawPassword = $_.Password # Password
        $ADGroup = $_.ADGroup #Group user
        $Description = $_.Description # Role or Job user
        $login = $firstname.Substring(0,1)+"."+$lastname.ToUpper()
        $UPN = "$SamAccountName@$Domain"
        $Password = ConvertTo-SecureString -AsPlainText $RawPassword -Force

        # Read and print the file
        Write-Host $csvFile | Format-Table


        If ($confirmation = Read-Host "Do you want to import [y/n] " -eq 'y')
        {
            #Create OU if not exist, we need to split the path before
            $split = $OU.Split(',')
            $PathSplit = $split[$split.length - 2]+','+$split[$split.length - 1]

                for ($i = $split.length - 3; $i -ge 0; $i --)
                {
                    $Path = $PathSplit
                    $Name = $Split[$i].Split('=')[1]
                    $chemin = $split[$i]+','+$PathSplit
                    write-host $PathSplit

                    Try
                    { 
                        Get-ADOrganizationalUnit -Identity $PathSplit
                        $isCreated = $true
                        Write-Host $PathSplit "already exist"
    
                    }
                    Catch 
                    {
                        write-host $Path $OU
                        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $false
                        Write-Host "Creation of the organizational unit" $PathSplit "successfully performed"
                    }
    
                    New-ADUser -GivenName $firstname -Surname $lastname -SamAccountName $login -Name $SamAccountName -DisplayName $DisplayName -UserPrincipalName $UPN -Path $OU -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false


                    # Verification of user creation
                    if ($?) {Write-Host "User $DisplayName successfully created !"
                    }
                    else {Write-Host "Error with user $DisplayName !"
                    }
                 }
            }
            else
            {
               Write-Host "Operation canceled"
               Start-Sleep -Seconds 2
               Get-Menu       
            }
    }
}

Function Get-GUI {
    process
    {
       Import-Module activedirectory

       $Domain = (Get-ADDomain).DNSRoot

       # Open Windows Explorer and import the .CSV
       $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        if ($OpenFileDialog.ShowDialog() -ne "Cancel") {
            Split-Path -Parent $OpenFileDialog.FileName
        } else {
            "No File Selected"
        }

            $Delimiter = Read-Host "Confirm the delimiter (Like ,/; ) "

            Import-CSV $csvFile -Delimiter $Delimiter

            # Read CSV
            $lastname = $_.Surname  # Last name
            $firstname = $_.GivenName # first name
            $SamAccountName  = $_.SamAccountName # Login
            $DisplayName = $_.GivenName+" "+$_.Surname # Login on the screen
            $Department  = $_.Department # Services
            $RawPassword = $_.Password # Password
            $ADGroup = $_.ADGroup #Group user
            $Description = $_.Description # Role or Job user
            $login = $firstname.Substring(0,1)+"."+$lastname.ToUpper()
            $UPN = "$SamAccountName@$Domain"
            $Password = ConvertTo-SecureString -AsPlainText $RawPassword -Force

            # Read and print the file
            Write-Host $csvFile | Format-Table


        If ($confirmation = Read-Host "Do you want to import [y/n] " -eq 'y')
        {
            #Create OU if not exist, we need to split the path before
            $split = $OU.Split(',')
            $PathSplit = $split[$split.length - 2]+','+$split[$split.length - 1]

                for ($i = $split.length - 3; $i -ge 0; $i --)
                {
                    $Path = $PathSplit
                    $Name = $Split[$i].Split('=')[1]
                    $chemin = $split[$i]+','+$PathSplit
                    write-host $PathSplit

                    Try
                    { 
                        Get-ADOrganizationalUnit -Identity $PathSplit
                        $isCreated = $true
                        Write-Host $PathSplit "already exist"
    
                    }
                    Catch 
                    {
                        write-host $Path $OU
                        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $false
                        Write-Host "Creation of the organizational unit" $PathSplit "successfully performed"
                    }
    
                    New-ADUser -GivenName $firstname -Surname $lastname -SamAccountName $login -Name $SamAccountName -DisplayName $DisplayName -UserPrincipalName $UPN -Path $OU -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false


                    # Verification of user creation
                    if ($?) {Write-Host "User $DisplayName successfully created !"
                    }
                    else {Write-Host "Error with user $DisplayName !"
                    }
                 }
            }
            else
            {
               Write-Host "Operation canceled"
               Start-Sleep -Seconds 2
               Get-Menu       
            }
    }
}

Function Get-InactiveUsers {

Read-Host "This option only retrieves active accounts, not deactivated accounts " -ForegroundColor Cyan

$Duration = Read-Host "Enter the duration in day "
$OU = Read-Host "Enter the name of the specific OU where the search should be performed (avoid errors with built-in accounts) "

$InactivesObjects = Search-ADaccount -AccountInactive -Timespan $Duration | Where{ ($_.DistinguishedName -notmatch "CN=$OU") -and ($_.Enabled -eq $true) } | foreach
        {
            if(($_.objectClass -eq "user") -and (Get-ADUser -Filter "Name -eq '$($_.Name)'" -Properties WhenCreated).WhenCreated -lt (Get-Date).AddDays(-7)){ $_ }
            if(($_.objectClass -eq "computer") -and (Get-ADComputer -Filter "Name -eq '$($_.Name)'" -Properties WhenCreated).WhenCreated -lt (Get-Date).AddDays(-7)){ $_ }
        }
}


#Call the Menu
Get-Menu
