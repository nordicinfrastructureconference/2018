# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Aleksandar Nikolic & Jan Egil Ring
    Name:        Honolulu Under the Hood.ps1
    Description: This demo script is part of the presentation
                 Windows Server Management - The Next Generation
                 
#>

# Inspect logs after performing actions in the Honolulu portal

$HonoluluServer = 'VMM-JR-01'

Get-WinEvent -LogName Microsoft-ServerManagementExperience -ComputerName $HonoluluServer

Get-WinEvent -FilterHashTable @{LogName='Microsoft-ServerManagementExperience';StartTime=$((Get-Date).AddMinutes(-5))} -ComputerName $HonoluluServer


# Management Tools Task Manager WMI Provider
# https://msdn.microsoft.com/en-us/library/dn958299(v=vs.85).aspx

$mtnamespace = 'root/microsoft/windows/managementtools'

Get-CimClass -Namespace $mtnamespace

Get-CimInstance -Namespace $mtnamespace -ClassName MSFT_MTProcess

Get-CimInstance -Namespace $mtnamespace -ClassName MSFT_MTProcess | where elevated -eq $false |
Select-Object name

Get-CimInstance -Namespace $mtnamespace -ClassName MSFT_MTNetworkAdapter

Get-CimInstance -Namespace $mtnamespace -ClassName MSFT_MTMemorySummary

Get-CimInstance -Namespace $mtnamespace -ClassName MSFT_MTProcessorSummary

Get-CimInstance -Namespace $mtnamespace -ClassName MSFT_MTDisk