# Script qui se lance après avoir lancé le script powercli get_disk_size.ps1
# La liste des serveurs fournie doit avoir une entête "NameSource" dans cet exemple


$vmData = Import-CSV "vmData.csv"  # Comme ça vient d'un script powercli, ne pas mettre UseCulture
$listSource = Import-CSV "listSource.csv" -UseCulture  # Comme ça vient d'un CSV fait à la main, mettre UseCulture

$vmDataFiltered = @('"Name","NoDisks","UsedSpaceGB(noSwap)","UsedSpaceGB","ProvisionedSpaceGB"')
$csvFilevmDataFiltered = ($MyInvocation.MyCommand.Path | Split-Path -Parent)+"\vmDataFiltered.csv"

foreach ($lineListSource in $listSource) 
{  
    foreach ($linevmData in $vmData)
    {    
        if ($linevmData.Name -in $lineListSource.NameSource)
        {
        	$item = $linevmData.Name + "," + $linevmData.NoDisks + "," + $linevmData.UsedSpaceGBnoSwap + "," + $linevmData.UsedSpaceGB + "," + $linevmData.ProvisionedSpaceGB
            Write-Host $item
            $vmDataFiltered += $item
        }
    }
}

$vmDataFiltered | foreach { Add-Content -Path  $csvFilevmDataFiltered -Value $_ }  # Création du csv à partir de la liste créée
