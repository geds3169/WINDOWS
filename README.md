# SCRIPT Windows

-----------------------------------------------------------------------------------------------------------------

# Hello, my name is __Guilhem SCHLOSSER__, I am currently looking for a Company for a work-study program in Master 2 IS management & Cybersecurity.

Scripts Windows more or less successful.

!! Scripts intended for advanced users !!

-----------------------------------------------------------------------------------------------------------------

__I am glad that you are interested in my work.__

If you use my codes for your professional tasks, please mention me.

If you are a French company and you appreciate my work, do not hesitate to contact me, even just a thank you, it's nice.

-----------------------------------------------------------------------------------------------------------------

![alt text](https://user-images.githubusercontent.com/28867314/148208659-354aa33d-28d0-468a-851e-d457f9f74395.png)

# When you copy or download the powershell files, you must first execute two commands in order to avoid format errors and that they are executed in UTF8

1- Open PowerShell ISE copy and paste this lines:

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8' .
$PSDefaultParameterValues['Get-Content:Encoding'] = 'utf8' .

2- Select "RAW":
3- copy the contents of the script and paste it into PowerShell ISE; .
4- then save the file '.ps1'; .
5- Execute the script.

-----------------------------------------------------------------------------------------------------------------
#########################################
# AD-Manager.ps1
#########################################

Work perfectly but not finished for import users ces lignesFFo

-----------------------------------------------------------------------------------------------------------------

#########################################
# Create_AD.ps1
#########################################

Works perfectly for the installation of a domain controller, remains to test the import of users and add a workflow to simplify the return to the script in an automated way.

-----------------------------------------------------------------------------------------------------------------

#########################################
# Create_Users_OU_Groups.ps1
#########################################

Tester et à améliorer, problème d'intégration de l'appel de l'explorateur de fichier pour récupérer le fichier CSV.

