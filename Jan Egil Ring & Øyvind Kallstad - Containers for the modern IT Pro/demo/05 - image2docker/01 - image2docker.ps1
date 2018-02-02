Write-Host "Demo!"
break

# Windows containers mode must be enabled

#region Run the following from the machine you want to convert a server role to a Docker file from. In this demo, an IIS server running WS 2016.

Install-Module -Name Image2Docker

Get-Command -Module Image2Docker

Get-WindowsArtifact

ConvertTo-Dockerfile -Artifact IIS -Local -OutputPath C:\temp -Verbose
ConvertTo-Dockerfile -Artifact IIS -Local -OutputPath D:\temp\Image2DockerDemo\ -Verbose -ArtifactParam Pester

Copy-Item -Path C\temp -Destination \\laptop-running-docker\c$\temp

#endregion

cd C:\temp
psedit C:\temp\Image2Docker
cd ~\Git\NIC.Containers\docker
psedit ~\Git\NIC.Containers\docker\Image2DockerDemo\Dockerfile

# Note: Remember to switch to Windows Containers before building the docker file (Linux is the default after installing Docker for Windows)
docker build Image2DockerDemo -t nicconf:image2dockerdemo

# A new image should now be available
docker image ls

# Start a container instance based on the image we just generated
$ContainerID = docker run -d --rm nicconf:image2dockerdemo

# We should now see our new container running
docker ps

# Connect interactively to retrieve the container`s IP address
docker exec -ti $ContainerID powershell

# Another option is to to docker inspect
$ContainerIP = docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $ContainerID

# Launch the website running in the container from a web browser to verify it`s running
Start-Process -FilePath iexplore.exe -ArgumentList http://$ContainerIP
Start-Process -FilePath chrome.exe -ArgumentList http://$ContainerIP

# Since -rm was specified when starting the container, it will be removed when it`s stopped
docker stop $ContainerID

# Let`s verify
docker ps