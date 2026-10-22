<#
 WIN-DC01 etape 2 : AD DS + DNS, creation de la foret infraready.test (redemarre).
 Le mot de passe DSRM est demande de facon securisee (jamais en clair dans le script).
#>
param(
  [string]$DomainName = "infraready.test",
  [string]$NetbiosName = "INFRAREADY"
)
$ErrorActionPreference = "Stop"
if ($env:COMPUTERNAME -ne "WIN-DC01") { throw "A executer sur WIN-DC01 uniquement." }

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

$dsrm = Read-Host "Mot de passe DSRM (a stocker dans le gestionnaire de mots de passe)" -AsSecureString
Install-ADDSForest -DomainName $DomainName -DomainNetbiosName $NetbiosName `
  -InstallDns -SafeModeAdministratorPassword $dsrm -Force
