#Basic output of the Cluster	
Get-StorageSubsystem cluster* | Get-StorageHealthReport
Get-StorageSubSystem Cluster* | Debug-StorageSubSystem  

#See if disks are bound to Cache devices
(get-counter -ListSet 'Cluster Storage Hybrid Disks').PathsWithInstances


#Check disk ID in each enclosure
gwmi -Namespace root\wmi ClusPortDeviceInformation | sort ConnectedNode,ConnectedNodeDeviceNumber,ProductId | ft ConnectedNode,ConnectedNodeDeviceNumber,ProductId


#Repair a Virtualdisk that goes into read only mode
Remove-clustersharedvolume -name "Disk1"
Get-ClusterResource -Name "Disk1" | Set-ClusterParameter -Name DiskRunChkDsk -Value 7
Start-clusterresource -Name "Disk1"

#Then add the disk back again
Get-ClusterResource -Name "Disk1" | Set-ClusterParameter -Name DiskRunChkDsk -Value 0
Add-clustersharedvolume -name "Disk1"
Get-Virtualdisk



#Reattach disks to a cache device if it's not attached, 2 diffrent options
Enable-ClusterS2D -Autoconfig:0 -CacheState Enabled –Verbose
Repair-ClusterS2D -RecoverUnboundDrives



#Some nice commands to get out some information from your disks
$ClusterName = 'JTHVS2DCL'                                                                                                                                                          
$nodes = Get-ClusterNode -Cluster $ClusterName | Select-Object -ExpandProperty Name                                                                                                  
$StorageNode = $nodes | Out-GridView -OutputMode Single -Title 'Select cluster node to operate against'                                                                              
$node = Get-StorageNode -CimSession $StorageNode | Where-Object Name -like "$StorageNode*"
                                                                                          
Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected -CimSession $ClusterName

Get-StorageQoSFlow -CimSession $ClusterName | Sort-Object StorageNodeIOPs -Descending | ft InitiatorName, @{Expression={$_.InitiatorNodeName.Substring(0,$_.InitiatorNodeName.IndexOf('.'))};Label="InitiatorNodeName"}, StorageNodeIOPs, Status, @{Expression={$_.FilePath.Substring($_.FilePath.LastIndexOf('\')+1)};Label="File"} -AutoSize 

Get-StorageQosVolume -CimSession $ClusterName | Format-List



#Turn on PhysicalDiskIndication on the disk
Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected | Where-Object SlotNumber -eq '14' | Enable-PhysicalDiskIndication
Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected | Where-Object SlotNumber -eq '14' | Disable-PhysicalDiskIndication 

$disk = Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected  | Out-GridView -PassThru 

$disk | Get-StorageReliabilityCounter | select deviceid,*errors*,poweron*,*latency* 


#Output to give MS Support for any storage related issues.
$Storage = @{
Disk = get-disk
PhysicalDisk = get-physicaldisk
StorageEnclosure = get-storageenclosure
VirtualDisk = get-virtualdisk
StoragePool = get-storagepool
StorageSubSystem = get-storagesubsystem
StorageJob = get-storagejob
StorageTier = get-storagetier
} | Export-Clixml -Path .\output.xml

#2nd output to use for support issues
$h = @{}
get-storagepool -isprimordial $false | Get-PhysicalDisk | %{$h[$_] = Get-PhysicalExtent -PhysicalDisk $_}
$h | Export-Clixml -Path .\extents.xml

#MS Support commands that always will be asked to run if you have any S2D issues and you contact support.
Install-Module PrivateCloud.DiagnosticInfo -Force
Import-Module PrivateCloud.DiagnosticInfo
Test-StorageHealth -IncludePerformance:0 -MonitoringMode:$false -IncludeLiveDump:0 -IncludeEvents:$true  






















#Example: Find hourly average, maximum, and minimum IO latency for one drive

$drive = Get-PhysicalDisk -SerialNumber "Z4FE23E"

$LastHour = $drive | Get-HealthMetric -PhysicalDiskSeriesName "PhysicalDisk.Latency.Average" -TimeFrame LastHour
$Points = @() ; @LastHour.Group | foreach { $Points += $_.Records.Value }
$Points | Measure -Average -Maximum -Minimum | FT Average, Maximum, Minimum


#Example 2: Sort all drives by their hourly average IO latency

@Averages = @{}

Get-StoragePool "S2D*" | Get-PhysicalDisk | foreach {
    $LastHour = $_ | Get-HealthMetric -PhysicalDiskSeriesName "PhysicalDisk.Latency.Average" -TimeFrame LastHour
    $Sum = 0 ; @LastHour.Group | foreach { $Sum += $_.Records.Value }
    $Averages[$_.SerialNumber] = $Sum / @LastHour.Count
}

$Averages.GetEnumerator() | Sort Value