Write-Host "Demo!"
break

# Windows containers mode must be enabled

# docker logs:Fetch the logs of a container

# Create a new container to inspect logs from
Start-Process -FilePath cmd -ArgumentList "/c docker run -it microsoft/powershell:6.0.0-nanoserver-1709 pwsh"

$ContainerID = docker ps -q

docker logs

docker logs --help

docker logs $ContainerID --details

docker logs $ContainerID --since 3m

docker logs $ContainerID --tail 6

docker logs $ContainerID --tail 6 --timestamps

docker logs $ContainerID --follow

# Show logs in Kitematic