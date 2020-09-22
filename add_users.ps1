Import-Module Active-Directory

#Entrez un chemin d’accès vers votre fichier d’importation CSV
$ADUsers = Import-csv C:\Users\Administrateur.WIN-TQQ6PTS3HS9\Desktop\users.csv

$ADOU = Import-csv C:\Users\Administrateur.WIN-TQQ6PTS3HS9\Desktop\ou.csv

# Création des 2 unités d'organisation principales

foreach ($OU in $ADOU)
{

       $Name    = $OU.department
       $OU      = $OU.ou


       #Vérifiez si l'unité d'organisation existe déjà dans AD
       if (Get-ADOrganizationalUnit -F {SamAccountName -eq $Name})
       {
               #Si l'unité d'organisation  existe, éditez un message d’avertissement
               Write-Warning "An Oraganizational Unit $Name has already exist in Active Directory."
       }
       else
       {
        #Si l'unité d'organisation n’existe pas, créez une nouvelle unité d'organisation
          
        #L'unité d'organisation sera créée suivant les paramètres du fichier CSV ;
              New-ADOrganizationalUnit `
            -Name $Name `
            -Path $OU `


       }
}


foreach ($User in $ADUsers)
{

       $Username    = $User.username
       $Password    = $User.password
       $Firstname   = $User.firstname
       $Lastname    = $User.lastname
       $Department  = $User.department
       $OU          = $User.ou

       #Vérifiez si le compte utilisateur existe déjà dans AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #Si l’utilisateur existe, éditez un message d’avertissement
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
              #Si un utilisateur n’existe pas, créez un nouveau compte utilisateur
          
        #Le compte sera créé dans I’unité d’organisation indiquée dans la variable $OU du fichier CSV ;
              New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@tlb.soundbuzz" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Lastname, $Firstname" `
            -Department $Department `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

       }
}
