#######################################################################################################################
# Script d'exportation massif de configuration ESX
# un paramètre: nom de vcenter 
# les exports de configuration sont créés dans un dossier EXPORT sous le dossier de ce script powershell
# Les exports peuvent être réutilisés pour reconfigurer un ESX après une réinstall lorsque du LAG LACP est utilisé
# Cela permet de rapidement reconnecter un ESX au vCenter sans reconf LAG
#######################################################################################################################

param(
[string]$myvCenter
)

$myRootFolder = $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition



# prépa du timestamp pour le dossier de stockage des exports
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"


# Récupération du login DOMAIN
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$CurrentUserName = $CurrentUser.split("\")[1]

# Stockage des paramètres de connexion 
$CompteConnexion = Get-Credential -Credential $CurrentUserName

# Connection au vCenter
Write-Host -NoNewline "Connexion au vCenter $myvCenter ..."
Connect-VIServer -Server $myvCenter -Credential $CompteConnexion -ea SilentlyContinue -ev err  | Out-Null
if ($err.count) {
    Write-Host -ForegroundColor Red "Connexion au vCenter $myvCenter impossible"
    exit 1
} else
{
Write-Host -ForegroundColor Green "OK"
}


# Liste des Clusters 
$Clusters = Get-Cluster -Server $myvCenter

# boucle de traitement cluster
foreach($myCluster in $Clusters) {

    $myFolder = "$myRootFolder\EXPORTS\$myvCenter\$myCluster\"
    $myTargetFolder = New-Item -Path $myFolder -Name $timestamp -ItemType "directory" -Force
    Write-Host "Traitement du cluster $myCluster"
    Write-Host "Dossier d'export : "$myTargetFolder

    # Liste des ESX concernés
    $VMhosts = Get-Cluster $myCluster | Get-VMHost

    # boucle de traitement ESX
    foreach($VMhost in $VMhosts) {

        Write-Host -NoNewline "Export configuration de $VMhost en cours..."
        $myObject = Get-VMHostFirmware -vmhost $VMhost -BackupConfiguration -DestinationPath $myTargetFolder
        $myFileName = Split-Path $myObject.Data -Leaf 
        $myFileNameNoExt = $myFileName.Substring(0,$myFileName.LastIndexOf('.')) 
        $newName = $myFileNameNoExt+".Build-"+$VMhost.build+".tgz" 
        $file = Rename-Item -Path $myObject.Data -NewName $newName -ea SilentlyContinue -ev err  | Out-Null
        if ($?) {
            Write-Host -NoNewline $newName
            Write-Host -ForegroundColor Green " : OK"
        } else
        {
            Write-Host -NoNewline $newName
            Write-Host -ForegroundColor Red " : KO"
        }
    }

}
