###############################
#
# By Geds3169
#
# Idea and first research
#
# Adil Maallem - 16/10/2021
#
# Retrieves system information
# and
# splits domain name
#
# Used by Infomil
# 
###############################

# Emplacement du fichier de sortie
$FilePath = "C:\test.txt"


$computerSystem = Get-CimInstance CIM_ComputerSystem
$computerBIOS = Get-CimInstance CIM_BIOSElement
$computerOS = Get-CimInstance CIM_OperatingSystem
$computerCPU = Get-CimInstance CIM_Processor
$computerHDD = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'"
$ComputerDomain = wmic computersystem get domain
# Change le numéro entre [], si le résultat qui sort n'est pas bon
$Localisation = $ComputerDomain.Split(".")[1]

#Démarre la capture des informations
Start-Transcript -Path $FilePath

Write-Host "System Information for: " $computerSystem.Name -BackgroundColor DarkCyan
"Domain: " + $ComputerDomain
"Manufacturer: " + $computerSystem.Manufacturer
"Model: " + $computerSystem.Model
"Serial Number: " + $computerBIOS.SerialNumber
"CPU: " + $computerCPU.Name
"HDD Capacity: "  + "{0:N2}" -f ($computerHDD.Size/1GB) + "GB"
"HDD Space: " + "{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)"
"RAM: " + "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB"
"Operating System: " + $computerOS.caption + ", Service Pack: " + $computerOS.ServicePackMajorVersion
"Localisation: " + $Localisation

# Stope la capture
Stop-Transcript