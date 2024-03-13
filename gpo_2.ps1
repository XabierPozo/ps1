# Importa los módulos necesarios
Import-Module ActiveDirectory
Import-Module GroupPolicy
# Nombre del grupo de Informática
$grupoInformatica = "G_Informatica"
# Obtén la información del grupo de Informática
$groupInfo = Get-ADGroup $grupoInformatica -Properties MemberOf
# Verifica si el grupo de Informática existe
if ($groupInfo) {
    # Nombre de la GPO y descripción
    $gpoName = "ConfiguracionContraseñaInformatica"
    # Crea una nueva GPO
    $gpo = New-GPO -Name $gpoName
    # Configura la longitud mínima de la contraseña
    $passwordLength = 10
    Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MinimumPasswordLength" -Type DWORD -Value $passwordLength
    # Configura el número de contraseñas que se pueden recordar
    $passwordHistory = 24
    Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordHistorySize" -Type DWORD -Value $passwordHistory
    # Linkea la GPO al grupo de Informática
    $groupDN = $groupInfo.DistinguishedName
    New-GPLink -Name $gpoName -Target $groupDN
    Write-Host "La GPO se ha configurado correctamente para el grupo Informatica."
} else {
    Write-Host "El grupo Informatica no existe. Verifica el nombre del grupo y vuelve a intentarlo."
}
