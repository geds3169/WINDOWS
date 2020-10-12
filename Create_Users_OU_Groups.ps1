########################### Appel de l'explorateur de fichier pour récupérer le fichier CSV ##################################
<#
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
$objForm = New-Object System.Windows.Forms.OpenFileDialog
$objForm.InitialDirectory = "c:\"
$objForm.Title = "Selectionner un fichier :"
$objForm.FilterIndex = 3
$Show = $objForm.ShowDialog()
 
If ($Show -eq "Cancel")
{
"Annulé par l'utilisateur"
}
Else
{
write-host $objForm.FileName
}
#>

###############################################################################################################################

#Efface tout ce qu'il y a dans la console. Ainsi que les erreurs des précédante commandes ou scripts.
# Clear-Host

Write-Host "`n===== Script de création Utilisateurs, OU & Groupes =====`n" -BackgroundColor DarkGray

#En cas d'erreur du script on continue
#$ErrorActionPreference = "Continue"

#Import du Module AD
Import-Module activedirectory


#Variables
$Domain = (Get-ADDomain).DNSRoot



#################################################
#                                               #
#                  Debut du script              #
#                                               #
#################################################



#       creation des comptes utilisateurs       #
#################################################


#Import du fichier CSV a traiter et pour chaque objet

Import-CSV "C:\account.csv" -Delimiter ";" | ForEach-Object {


# Variables fixes

$lastname = $_.Surname  # Nom
$firstname = $_.GivenName # Prenom
$SamAccountName  = $_.SamAccountName # Login
$DisplayName = $_.GivenName+" "+$_.Surname # Nom Affiché à l'écran de l'ordinateur
$Department  = $_.Department # Services auquel l'utilisateur appartient
$RawPassword = $_.Password # Mot de passe
$ADGroup = $_.ADGroup #Groupe auquel l'utilisateur appartient
$Description = $_.Description # Rôle ou Job de l'utilisateur
$login = $firstname.Substring(0,1)+"."+$lastname.ToUpper()
$OU = $_.OU #OU pour chaque utilisateurs

# Variable Complémentaires
$UPN = "$SamAccountName@$Domain" # permettra en cas de besoin par la suite de créer automatiquement le champ mail de l'utilisateur

$Password = ConvertTo-SecureString -AsPlainText $RawPassword -Force # Gestion des mots de passe en clair


#       creation des OU      #
##############################

    $split = $OU.Split(',') #On découpe le chemin complet de la OU (dans le CSV) avec le séparateur dans la ligne qui est une virgule
    $chemin = $split[$split.length - 2]+','+$split[$split.length - 1] #Cela créer un tableau
    

    for ($i = $split.length - 3; $i -ge 0; $i --)
    {
        $Path = $chemin
        $Name = $Split[$i].Split('=')[1]
        $chemin = $split[$i]+','+$chemin
        write-host $chemin

        ##on essaye de recuper l'ou
        Try
        { 
            Get-ADOrganizationalUnit -Identity $chemin
            $isCreated = $true
            Write-Host 'La $chemin existe'
    
        }
    
    
        #si elle existe on fait rien
        Catch 
        {
        write-host $Path $OU
         New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $false
         Write-Host "Création de l''unité organisationnelle $chemin effectué avec succés"
        }
     
    }


 # Création de l'utilisateur
 #New-ADUser -GivenName $firstname.ToLower() -Surname $lastname.ToUpper() -SamAccountName $SamAccountName -Name $SamAccountName -DisplayName $DisplayName -UserPrincipalName $UPN ` -Path $_.OU -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
 #FONCTIONNE New-ADUser -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -Name $SamAccountName -DisplayName $DisplayName -UserPrincipalName $UPN ` -Path $_.OU -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
 New-ADUser -GivenName $firstname -Surname $lastname -SamAccountName $login -Name $SamAccountName -DisplayName $DisplayName -UserPrincipalName $UPN -Path $OU -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false


# Vérification de la création de l'utilisateur
if ($?) {Write-Host "Utilisateur $DisplayName créé avec succès !" -BackgroundColor DarkGreen}
else {Write-Host "Erreur avec l'utilisateur $DisplayName !" -BackgroundColor DarkRed}






}


Write-Host "`n======= Fin du script ========`n" -BackgroundColor DarkGray

