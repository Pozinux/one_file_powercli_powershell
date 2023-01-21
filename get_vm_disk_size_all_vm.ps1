#### FONCTION

function GetVMData($v) 
{
	$vmResMemory = [math]::Round($v.ExtensionData.ResourceConfig.MemoryAllocation.Reservation/1024,2)
	$vmMem = [math]::Round($v.MemoryMB/1024,2)
	$vmUsedSpace = [math]::Round($v.UsedSpaceGB,2)
 
 if ($v.PowerState -match "PoweredOn") 
 {
	$vmUsedSpaceNoSwap = $vmUsedSpace - $vmMem + $vmResMemory # removing swap space from calculations
 } 
 else
 {
	$vmUsedSpaceNoSwap = $vmUsedSpace
 }
 
 $vmProvSpace = [math]::Round($v.ProvisionedSpaceGB,2) # swap space included
 $vmName = $v.Name
 $vmNoDisks = ($v | Get-HardDisk).count

 $hash = New-Object PSObject -property @{Vm=$v.Name;NoDisks=$vmNoDisks;UsedSpaceNoSwap=$vmUsedSpaceNoSwap;UsedSpace=$vmUsedSpace;ProvSpace=$vmProvSpace}
 return $hash
}


#### MAIN 

$vmData = @('"Name","NoDisks","UsedSpaceGBnoSwap","UsedSpaceGB","ProvisionedSpaceGB"')
$csvFile = ($MyInvocation.MyCommand.Path | Split-Path -Parent)+"\vmData.csv"

foreach ($v in get-vm) {
	$hash = GetVMData -v $v
	$item = $hash.Vm + "," + $hash.NoDisks + "," + $hash.UsedSpaceNoSwap + "," + $hash.UsedSpace + "," + $hash.ProvSpace
	$vmData += $item
}

$vmData | foreach { Add-Content -Path  $csvFile -Value $_ }
