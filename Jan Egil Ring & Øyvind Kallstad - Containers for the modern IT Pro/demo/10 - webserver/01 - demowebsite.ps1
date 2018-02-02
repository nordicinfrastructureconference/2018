break #Safety net. This script is supposed to be run line by line interactively, not all at once.


cd ~\Git\NIC.Containers\docker

# Note: Remember to switch to Windows Containers before building the docker file (Linux is the default after installing Docker for Windows)
docker build WindowsServerCoreDemoWebsite -t nicconf:demowebsite --no-cache
docker build NanoDemoWebsite -t nicconf:nanodemowebsite --no-cache

# 1 Windows Server Core
$ContainerID = docker run -d --rm nicconf:demowebsite

# 2 Nano Server 1709
$ContainerID = docker run -d --rm nicconf:nanodemowebsite

docker ps

# Retrieve the container`s IP address
$ContainerIP = docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $ContainerID

# Launch the website running in the container from a web browser to verify it`s running
Start-Process -FilePath iexplore.exe -ArgumentList http://$ContainerIP
Start-Process -FilePath chrome.exe -ArgumentList http://$ContainerIP

docker stop $ContainerID