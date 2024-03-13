# Importa el módulo de Active Directory
Import-Module ActiveDirectory

# Nombre de la GPO y descripción
$gpoName = "PerfilMovilGPO"
$gpoDescription = "GPO para configurar perfiles móviles para todos los usuarios"

# Crea una nueva GPO
$gpo = New-GPO -Name $gpoName -Description $gpoDescription

# Configura el tipo de perfil móvil
$profilePath = "\\172.16.12.12\PerfilesMóviles\%USERNAME%"
$gpo | Set-GPRegistryValue -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ValueName "Personal" -Type String -Value "$profilePath\Documents"
$gpo | Set-GPRegistryValue -Key "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ValueName "Desktop" -Type String -Value "$profilePath\Desktop"

# Linkea la GPO a una Unidad Organizativa (OU) donde residen los usuarios
# Asegúrate de reemplazar 'OU=Usuaris,DC=EXAMEN12,DC=lab' con la ruta correcta de tu OU
New-GPLink -Name $gpoName -Target "OU=Usuaris,DC=EXAMEN12,DC=lab"

# Guarda los cambios
$gpo | Save-GPO

# Forzar la actualización de las políticas de grupo en los equipos afectados
Invoke-GPUpdate -Force -Computer "NombreDelEquipo"
