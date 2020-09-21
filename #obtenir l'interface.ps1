#obtenir l'interface
get-netipaddress | ft
#config réseau
New-NetIPAddress -InterfaceIndex 4  -IPAddress 192.168.127.100 -PrefixLength 24 -DefaultGateway 192.168.127.2
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 127.0.0.1
rename-computer -newname xxxx
shutdown -r

#installation AD
Install-WindowsFeature AD-Domain-Services, RSAT-ADDS
Install-ADDSForest -DomainName liteware.fr -InstallDns -DomainMode WinThreshold -ForestMode WinThreshold -DatabasePath "c:\Windows\NTDS" -SysvolPath "c:\Windows\SYSVOL" -LogPath "c:\Windows\NTDS" 
Install-ADDSDomainController -DomainName "domain.tld" -InstallDns:$true -Credential (Get-Credential "DOMAIN\administratreur")

#ajouter une OU
New-ADOrganizationalUnit -Name:"demo" -Path:"DC=liteware,DC=fr" -ProtectedFromAccidentalDeletion:$true -Server:"srv1.liteware.fr" 

#ajouter un utilisateur
New-ADUser -Name Audrey -Surname Allery -DisplayName "Audrey Allery" -SamAccountName aallery -UserPrincipalName aallery@liteware.fr -Path "ou=mlv,dc=liteware,dc=fr"
$password = Read-Host -AsSecureString
Set-ADAccountPassword -NewPassword $password "cn=audrey,ou=mlv,dc=liteware,dc=fr"
Set-ADUser "cn=audrey,ou=mlv,dc=liteware,dc=fr" -Enabled $true

#config réseau
New-NetIPAddress -InterfaceIndex 4 -IPAddress 192.168.70.1 -PrefixLength 24 -DefaultGateway 192.168.70.254
Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 127.0.0.1
rename-computer -newname win16-1
shutdown -r

#installation AD + promotion contrôleur de domaine
Install-WindowsFeature AD-Domain-Services, RSAT-ADDS, -IncludeManagementTools
Install-ADDSForest -DomainName tlb.soundbuzz -InstallDns -DomainMode WinThreshold -ForestMode WinThreshold -DatabasePath "c:\Windows\NTDS" -SysvolPath "c:\Windows\SYSVOL" -LogPath "c:\Windows\NTDS" 
Install-ADDSDomainController -DomainName " tlb.soundbuzz" -InstallDns:$true -Credential (Get-Credential "DOMAIN\administratreur")
