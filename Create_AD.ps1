
# Demande du Nom de Server à l'Administrateur pour le renommage de la machine
$SRV_name = Read-Host "Renseigner le nom du server"

# Remplace le nom générique du serveur par le nom choisi et redémarrage du serveur
workflow Resume_Workflow
{
    .....
    Rename-Computer -NewName $SRV_name -Force -Passthru
    Restart-Computer -Wait
    # Fais des trucs supplémentaire
    .....
}

# Tâches effectués après le redémarrage du server:
# - Adressage IP / Nom de la nouvelle Forêt / installation du DNS et paramétrage de son IP.

$IPv4 = Read-Host "Renseigner l'adresse IPv4 du serveur"
$Mask = Read-Host "Renseigner le masque de sous réseau"
$Gateway = Read-Host "Renseigner la passerelle"
$IP_dns = Read-Host "Renseigner le DNS"
$name_domain = Read-Host "Renseigner le nom de domaine souhaité exemple.com"

# Permet d'attribuer l'IP / Masque / Gateway du server
New-NetIPAddress -InterfaceIndex 4 -IPAddress $IPv4 -PrefixLength $Mask DefaultGateway $Gateway

# Permet d'attribuer un DNS au server
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ("$IP_dns")

#Permet de voir l'adressage
Get-NetIPAddress 

# Installe les fonctionnalitées necessaire à la création d'un Active directory
Install-WindowsFeature –Name AD-Domain-Services –IncludeManagementTools`

# Paramétrage des différentes informations de l'Active directory
#https://docs.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=win10-ps

Install-ADDSForest `  
  -DomainName "$name_domain" `	#Le nom du domain  
  -CreateDnsDelegation:$false `   
  -DatabasePath "C:\Windows\NTDS" `   
  -DomainMode "7" `	#la valeur est pour les AD a partir de windows server 2016
  -DomainNetbiosName "example" `   
  -ForestMode "7" `#la valeur est pour les AD a partir de windows server 2016   
  -InstallDns:$true `   
  -LogPath "C:\Windows\NTDS" `   
  -NoRebootOnCompletion:$True `   
  -SysvolPath "C:\Windows\SYSVOL" `   
  -Force:$true
  
# Paramétrage du DnsClientServerAddress

# Check du DNS dans sa config initiale
Get-DnsServerZone

# Ajout de la zone de recherche inversé
$IPreverse = Read-Host "Entrée l'adresse du réseau"
Add-DnsServerPrimaryZone -Network ("$IPreverse") -ReplicationScope "Domain"

# Check des modifications du Dns
Get-DnsServerZone


