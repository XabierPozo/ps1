# Define el nombre del dominio
$domain = "EXAMEN12.LAB"

# Importa el archivo CSV
$users = Import-Csv ".\usuaris.csv"

# Crea la estructura de la organización en Active Directory
New-ADOrganizationalUnit -Name "CENTRES" -Path "DC=EXAMEN12,DC=LAB"
New-ADOrganizationalUnit -Name "IESMANACOR" -Path "OU=CENTRES,DC=EXAMEN12,DC=LAB"
New-ADOrganizationalUnit -Name "Usuaris" -Path "OU=IESMANACOR,OU=CENTRES,DC=EXAMEN12,DC=LAB"
New-ADOrganizationalUnit -Name "Equips" -Path "OU=IESMANACOR,OU=CENTRES,DC=EXAMEN12,DC=LAB"
New-ADOrganizationalUnit -Name "Grups" -Path "OU=IESMANACOR,OU=CENTRES,DC=EXAMEN12,DC=LAB"

# Define las rutas de las carpetas compartidas
$carpetaPersonalsPath = "C:\Personals"
$carpetaPerfilsPath = "C:\Perfils"
$carpetaDepartamentsPath = "C:\Departaments"

# Crea las carpetas compartidas si no existen
if (-not (Test-Path $carpetaPersonalsPath)) {
    New-Item -ItemType Directory -Path $carpetaPersonalsPath
}

if (-not (Test-Path $carpetaPerfilsPath)) {
    New-Item -ItemType Directory -Path $carpetaPerfilsPath
}

if (-not (Test-Path $carpetaDepartamentsPath)) {
    New-Item -ItemType Directory -Path $carpetaDepartamentsPath
}

# Define las funciones necesarias
function Get-UniqueSamAccountName {
    param (
        [string]$baseSamAccountName
    )

    $suffix = 1
    $newSamAccountName = $baseSamAccountName
    while (Test-Path "AD:\Users\$newSamAccountName") {
        $suffix++
        $newSamAccountName = $baseSamAccountName + $suffix
    }

    return $newSamAccountName
}

# Itera sobre cada usuario del CSV para crearlos en Active Directory
foreach ($user in $users) {
    $nom = $user.Nom -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $llinatge1 = $user.Llinatge1 -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $llinatge2 = $user.Llinatge2 -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $groupN = $user.Departament -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $groupName = "G_$groupN"
    $givenName = $user.Nom
    $surname = "$llinatge1 $llinatge2"
    $samAccountName = Get-UniqueSamAccountName -baseSamAccountName "$nom$llinatge1"
    $userPrincipalName = "$samAccountName@$domain"
    $accountPassword = "A1234567890."

    # Crea el usuario en Active Directory
    New-ADUser -Name $nom -GivenName $givenName -Surname $surname -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName -AccountPassword (ConvertTo-SecureString $accountPassword -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -Path "OU=Usuaris,OU=IESMANACOR,OU=CENTRES,DC=EXAMEN12,DC=LAB"

    # Crea o añade el usuario al grupo correspondiente
    if (-not (Get-ADGroup $groupName)) {
        New-ADGroup -Name $groupName -GroupScope Global -Path "OU=Grups,OU=IESMANACOR,OU=CENTRES,DC=EXAMEN12,DC=LAB"
    }

    Add-ADGroupMember -Identity $groupName -Members $samAccountName

    # Crea el directorio personal y de perfiles para el usuario
    New-Item -ItemType Directory -Path "$carpetaPersonalsPath\$samAccountName"
    New-Item -ItemType Directory -Path "$carpetaPerfilsPath\$samAccountName"

    Write-Host "$user ha sido creado exitosamente y agregado a $groupName"
}

Write-Host "Usuarios creados y configurados correctamente."
