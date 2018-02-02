# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Aleksandar Nikolic & Jan Egil Ring
    Name:        Honolulu - HCI.ps1
    Description: This demo script is part of the presentation
                 Windows Server Management - The Next Generation
                 
#>


#region Storage Spaces Direct Cluster installation

$ClusterName = 'S2D-CLU-01'
$StaticIPAddress = '10.0.1.50/24'
$Nodes = @('S2D-01','S2D-02')
$PoolFriendlyName = 'S2D on S2D-CLU-01'
$CloudWitnessAccountName = 'democlusterwitness'
$CloudWitnessAccountAccessKey = '123'

Invoke-Command -ComputerName $Nodes {Install-WindowsFeature Hyper-V, Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools -Restart}


#region Cluster configuration

Enter-PSSession -ComputerName $Nodes[0]

Test-Cluster -Node $Nodes -Include 'Storage Spaces Direct','Inventory','Network','System Configuration'

New-Cluster -Name $ClusterName -Node $Nodes -NoStorage -StaticAddress $StaticIPAddress

#Configure cluster quorom
Set-ClusterQuorum -CloudWitness -AccountName $CloudWitnessAccountName -AccessKey $CloudWitnessAccountAccessKey


# Rename cluster networks
(Get-ClusterNetwork | Where-Object {$_.address -eq '10.0.1.0'}).Name='Management'

# Configure Live Migration to use the Storage NICs
Get-ClusterResourceType -Name 'Virtual Machine' | Set-ClusterParameter -Name MigrationExcludeNetworks -Value ([String]::Join(';',(Get-ClusterNetwork | Where-Object {$_.Name -notlike "Storage*"}).ID))


#region Enable Storage Spaces Direct
# Run locally, issues when invoked remotely
#Enable-ClusterStorageSpacesDirect -CimSession $ClusterName -PoolFriendlyName $PoolFriendlyName

Enable-ClusterStorageSpacesDirect -PoolFriendlyName $PoolFriendlyName


<#

    Important consideration before creating volumes:
    Leave enough available capacity in the storage pool to allow for a disks to fail and still be able to repair the virtual disks with the remaining disks. 
    For example, if you have 20 disks of 2TB each and you want to allow the system to have 1 disk failure with automatic repair of the virtual disks, 
    you would create a volume that leaves a minimum of 2TB of available capacity in the storage pool. If you allocate all of the pool capacity to virtual 
    disks and a disk fails, the virtual disks will not be able to repair until the failed disk is replaced or new disks are added to the pool.

#>

New-Volume -StoragePoolFriendlyName S2D* -FriendlyName VMData01 -FileSystem CSVFS_ReFS -ResiliencySettingName Mirror -PhysicalDiskRedundancy 1 -UseMaximumSize

Rename-Item -Path C:\ClusterStorage\volume1\ -NewName VMData01

Get-ChildItem C:\ClusterStorage


#endregion


<#

    Note:
    The New-Volume cmdlet simplifies deployments as it ties together a long list of operations that would otherwise have to be done in individual commands 
    such as creating the virtual disk, partitioning and formatting the virtual disk, adding the virtual disk to the cluster, and converting it into CSVFS.

#>

#endregion

#endregion


#region Operational tasks

Stop-Cluster -Cluster $ClusterName
Restart-Computer -ComputerName S2D-01,S2D-02 -Wait -For PowerShell -Force

Get-StorageQoSFlow -CimSession $ClusterName | Sort-Object StorageNodeIOPs -Descending | ft InitiatorName, @{Expression={$_.InitiatorNodeName.Substring(0,$_.InitiatorNodeName.IndexOf('.'))};Label="InitiatorNodeName"}, StorageNodeIOPs, Status, @{Expression={$_.FilePath.Substring($_.FilePath.LastIndexOf('\')+1)};Label="File"} -AutoSize 

Get-StorageQosVolume -CimSession $ClusterName | Format-List

$StorageSubSystem = Get-StorageSubSystem -FriendlyName Clustered* -CimSession $ClusterName
Get-StorageJob -CimSession $ClusterName -StorageSubsystem $StorageSubSystem

Suspend-ClusterNode -Name S2D-01 -Drain -Wait -Cluster $ClusterName
Restart-Computer -ComputerName S2D-01 -Wait -For PowerShell -Force
Resume-ClusterNode -Name S2D-01 -Cluster $ClusterName

$StorageNode = $nodes | Out-GridView -OutputMode Single -Title 'Select cluster node to operate against'
$node = Get-StorageNode -CimSession $StorageNode | Where-Object Name -like "$StorageNode*"

Get-PhysicalDisk -StorageNode $node[1] -CimSession $ClusterName |
Select-Object FriendlyName, SerialNumber, IsIndicationEnabled, HealthStatus, OperationalStatus, Usage | Out-GridView -PassThru |
Enable-PhysicalDiskIndication

Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected -CimSession $ClusterName | Where-Object SlotNumber -eq '4' | Enable-PhysicalDiskIndication
Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected | Where-Object SlotNumber -eq '14' | Disable-PhysicalDiskIndication
Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected | Where-Object SlotNumber -eq '14' | Set-PhysicalDisk -Usage Retired
Get-PhysicalDisk -StorageNode $node[1] -PhysicallyConnected | Where-Object SlotNumber -eq '14' | Set-PhysicalDisk -Usage AutoSelect

Get-PhysicalDisk -StorageNode $node[1] -CimSession $ClusterName | Get-StorageReliabilityCounter -CimSession $ClusterName | select deviceid,*errors*,poweron*,*latency*

#endregion