Write-Host "Demo!"
break

# Windows containers mode must be enabled

# docker inspect: Return low-level information on Docker objects

docker inspect

$ContainerID = docker run -d --rm nicconf:nanodemowebsite

docker ps

docker inspect $ContainerID

docker inspect --help
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $ContainerID

$Container = docker inspect $ContainerID | ConvertFrom-Json

# Tip: Use Show-Object from Lee Holmes` PowerShellCookBook module to explore the object (Install-Module -Name PowerShellCookbook -AllowClobber)
$Container | Show-Object

$Container.NetworkSettings.Networks.nat.IPAddress

docker stop $ContainerID

# Examples from the documentation
# Get an instance’s image name
docker inspect --format='{{.Config.Image}}' $ContainerID

# List all port bindings
docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' $ContainerID
