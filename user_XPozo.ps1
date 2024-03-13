# Función para obtener un nombre de cuenta SAM único
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

# Dominio
$domain = "EXAMEN12.LAB"

# Unidades Organizativas
$ouPath = "OU=Usuaris,OU=IESMANACOR,OU=CENTRES,DC=EXAMEN12,DC=LAB"
$ouPathEquipos = "OU=Equips,OU=IESMANACOR,OU=Equips,DC=EXAMEN12,DC=LAB"
$ouPathGrupos = "OU=Grups,OU=IESMANACOR,OU=Grups,DC=EXAMEN12,DC=LAB"

# Rutas de carpetas
$personalFolderPath = "C:\Personals"
$profilesFolderPath = "C:\Perfils"
$departmentFolderPath = "C:\Departaments"

# Importar usuarios desde el archivo CSV
$users = Import-Csv ".\usuaris.csv"

# Crear carpetas compartidas
New-Item -Path $personalFolderPath -ItemType Directory -Force
New-Item -Path $profilesFolderPath -ItemType Directory -Force
New-Item -Path $departmentFolderPath -ItemType Directory -Force

foreach ($user in $users) {
    # Limpiar y formatear nombres y apellidos
    $nom = $user.Nom -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $llinatge1 = $user.Llinatge1 -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $llinatge2 = $user.Llinatge2 -replace " ", "" -replace "[áàâä]", "a" -replace "éèêë", "e" -replace "íìîï", "i" -replace "óòôö", "o" -replace "úùûü", "u" -replace "ñ", "n" -replace "[^a-z0-9]", ""
    $givenName = $user.Nom
    $surname = "$llinatge1 $llinatge2"
    $samAccountName = Get-UniqueSamAccountName -baseSamAccountName "$nom$llinatge1"
    $userPrincipalName = "$samAccountName@$domain"
    $accountPassword = "A1234567890."
    
    # Crear usuario en AD
    New-ADUser -Name $nom -GivenName $givenName -Surname $surname -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName -AccountPassword (ConvertTo-SecureString $accountPassword -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -Path $ouPath

    # Crear carpeta personal
    New-Item -Path "$personalFolderPath\$samAccountName" -ItemType Directory -Force

    # Asignar usuario a grupo global
    Add-ADGroupMember -Identity "NomDelGrupGlobal" -Members $samAccountName

    Write-Host "Usuari $nom creat correctament."
}

# Mover equipos a la OU correspondiente
Get-ADComputer -Filter * | Move-ADObject -TargetPath $ouPathEquipos

# Crear grupos en AD
New-ADGroup -Name "NomDelGrup" -GroupScope Global -Path $ouPathGrupos

Write-Host "Usuaris creats, equips moguts i grups creats."
