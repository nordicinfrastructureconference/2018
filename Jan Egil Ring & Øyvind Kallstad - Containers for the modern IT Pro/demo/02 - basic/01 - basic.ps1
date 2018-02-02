Write-Host "Demo!"
break

# Linux containers mode must be enabled

# Docker for Windows
# https://www.docker.com/docker-windows


# Public Docker Hub
# https://hub.docker.com/

# 01 - Run container
# This will run the latest version of the Azure CLI 2.0 image
docker run --rm -it azuresdk/azure-cli-python:latest
# -it       run interactive
# --rm      automatically remove container

# show that container have been removed
docker ps

# show that the image is still there
docker images

# tag = version (VERY simplified)
# run specific version of the image
docker run --rm -it azuresdk/azure-cli-python:2.0.18

# show version 2.0.18 of the image is downloaded
docker images

# run image again without --rm
docker run -it azuresdk/azure-cli-python:2.0.18

# inside image, run command 'az show'
# from another terminal session:
docker ps

# now we see the running container.
# get it's id - and run
docker logs <id>
# everything written to stderr and stdout is shown with 'logs'

# start long running container
docker run --detach alpine:latest /bin/sleep 1000

# show that container is running in the background
docker ps

# attach to running container
docker attach <id>
# ctrl+x to exit

# docker exec

#docker run -p 443:443

# delete container
docker rm <id> -f

# show that it's gone
docker ps
