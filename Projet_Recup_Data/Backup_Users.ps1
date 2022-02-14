# Variables
$Destination=Read-Host "Veuillez entrer la destination de sauvegarde :"
$UserName=Read-Host "Veuillez entrer le nom d'utilisateur (sans espace) : "
$DestinationFolderUser= ("$destination" + "\" + "$UserName" + "\" + "\")
$LanguageListGet=Get-WinUserLanguageList
$FR= "fr-FR"
$EN="en-EN"


$EN_FoldersSource= "Desktop",
"Downloads",
"Favorites",
"Documents",
"Music",
"Pictures",
"OneDrive",
"Videos",
"AppData\Local\Mozilla",
"AppData\Local\Google",
"AppData\Local\Microsoft\Outlook",
"AppData\Roaming\Mozilla",
"AppData\Roaming\Microsoft\Signatures",
"AppData\Roaming\Microsoft\Outlook"

$FR_FoldersSource="Bureau",
"Téléchargements",
"Favoris",
"Documents",
"Musique",
"Images",
"OneDrive",
"Vidéos",
"AppData\Local\Mozilla",
"AppData\Local\Google",
"AppData\Local\Microsoft\Outlook",
"AppData\Roaming\Mozilla",
"AppData\Roaming\Microsoft\Signatures",
"AppData\Roaming\Microsoft\Outlook"
 
####################################### END OF VARIABLES ############################################



####################################### START SCRIPT #########################################

################################
# Check cible backup user exist
################################

Write-Host "Teste de l'existance du dossier [$DestinationFolderUser] sur l'environnement de sauvegarde"
if (Test-Path -Path $DestinationFolderUser) {
    Write-Host "Un dossier utilisateur avec ce nom existe déjà"
}
else {
    Write-Hosts "Aucun dossier avec ce nom n'est présent. Le dossier va être créé"
    New-Item -ItemType Directory -Force -Path $DestinationFolderUser

}


######################
#
# user profile backups
#
######################

#Google Chrome Backup Bookmarks
if (Test-Path "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default\Bookmarks") {
	if (-not (test-path ("$DestinationFolderUser" + "\Chrome"))) { New-Item -Path ("$DestinationFolderUser" + "\Chrome") -Type Directory -Force:$true }
	Copy-Item -Path "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default\Bookmarks" -Destination ("$DestinationFolderUser" + "\Chrome") -Force:$true -Confirm:$false
}

#Google Edge Backup Bookmarks
if (Test-Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\Default\Bookmarks") {
	if (-not (test-path ("$DestinationFolderUser" + "\Edge"))) { New-Item -Path ("$DestinationFolderUser" + "\Edge") -Type Directory -Force:$true }
	Copy-Item -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\Default\Bookmarks" -Destination ("$DestinationFolderUser" + "\Edge" + "\Bookmarks") -Force:$true -Confirm:$false
}

#Mozilla Firefox Backup Bookmarks
if (Test-Path "$($env:APPDATA)\Mozilla\Firefox\Profiles") {
	if (-not (test-path ("$DestinationFolderUser" + "\FireFox"))) { New-Item -Path ("$DestinationFolderUser" + "\FireFox") -Type Directory -Force:$true }
	$MozillaPlaces = (get-childitem "$($env:APPDATA)\Mozilla\Firefox\Profiles" -force -recurse -ErrorAction SilentlyContinue | where-object { $_.Name -eq 'places.sqlite' }).DirectoryName
	copy-item -path "$MozillaPlaces" -Destination ("$DestinationFolderUser" + "\FireFox") -Force:$true -Confirm:$false
}

#Outlook Backup .pst
if (Test-Path "$($env:APPDATA)\Mozilla\Firefox\Profiles") {
	if (-not (test-path ("$DestinationFolderUser" + "\FireFox"))) { New-Item -Path ("$DestinationFolderUser" + "\FireFox") -Type Directory -Force:$true }
	$MozillaPlaces = (get-childitem "$($env:APPDATA)\Mozilla\Firefox\Profiles" -force -recurse -ErrorAction SilentlyContinue | where-object { $_.Name -eq 'places.sqlite' }).DirectoryName
	copy-item -path "$MozillaPlaces" -Destination ("$DestinationFolderUser" + "\FireFox") -Force:$true -Confirm:$false
}

######################
#
# user profile restore
#
######################

#Google Chrome Restore Bookmarks
if (Test-Path "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default\Bookmarks") {
	if (test-path d:\Backup\Chrome) {
		Copy-Item -Path d:\Backup\Chrome\bookmarks -destinatiom	"$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default\" -Force:$true -Confirm:$false
	}
}

#Google Edge Restore Bookmarks
if (Test-Path "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\Default\Bookmarks") {
	if (test-path d:\Backup\Edge) {
		Copy-Item -Path d:\Backup\Edge\bookmarks -destination "$($env:LOCALAPPDATA)\Microsoft\Edge\User Data\Default\" -Force:$true -Confirm:$false
	}
}
#Mozilla Firefox Restore Bookmarks
# To copy it back... SIDE NOTE*** if mozilla being re-installed or fresah installed, must open mozilla first to recreate a default place.sqlite to replace
if (Test-Path "$($env:APPDATA)\Mozilla\Firefox\Profiles") {
	if (test-path d:\Backup\FireFox) {
		$MozillaPlaces = (get-childitem "$($env:APPDATA)\Mozilla\Firefox\Profiles" -force -recurse -ErrorAction SilentlyContinue | where-object Name -eq 'places.sqlite').DirectoryName
		Copy-Item D:\Backup\FireFox\*.* -Recurse -Destination "$($MozillaPlaces)" -Force:$true -Confirm:$false
	}
}
