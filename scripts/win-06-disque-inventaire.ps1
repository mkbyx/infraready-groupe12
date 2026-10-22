<# Inventaire SEUL (aucune modification). L'initialisation reste manuelle apres validation. #>
Get-Disk | Format-Table Number,FriendlyName,OperationalStatus,Size,PartitionStyle
Get-Partition
Get-Volume
Write-Host "Disque de test = celui SANS partition et SANS lettre. Ne jamais toucher le disque 0 (systeme)."
<# Apres validation, pour le disque N verifie :
Initialize-Disk -Number N -PartitionStyle GPT
New-Partition -DiskNumber N -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel LabData
#>
