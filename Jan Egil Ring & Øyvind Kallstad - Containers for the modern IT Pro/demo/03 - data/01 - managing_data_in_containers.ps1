Write-Host "Demo!"
break

# Windows containers mode must be enabled

docker volume ls

docker volume create NICData01

docker volume inspect NICData01

docker volume inspect NICData01 | ConvertFrom-Json

# If you start a container with a volume that does not yet exist, Docker creates the volume for you

docker run --rm -it --name NICContainer01 --mount source=NICData01,target=C:\NICData01 microsoft/powershell:6.0.0-rc-nanoserver-1709

dir (docker volume inspect NICData01 | ConvertFrom-Json).Mountpoint -Recurse
Invoke-Item (docker volume inspect NICData01 | ConvertFrom-Json).Mountpoint 

docker volume rm NICData01

# SMB Global Mapping (Available in Windows Server version 1709 and later) https://blogs.msdn.microsoft.com/clustering/2017/08/10/container-storage-support-with-cluster-shared-volumes-csv-storage-spaces-direct-s2d-smb-global-mapping/
docker run -it –name NICDataDemo01 -v C:\ClusterStorage\Volume1\ContainerData:G:\AppData microsoft/windowsservercore cmd.exe

