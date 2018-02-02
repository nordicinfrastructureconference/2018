Write-Host "Demo!"
break

# Linux containers mode must be enabled

# start docker registry in a container
# https://docs.docker.com/registry/
docker run -d -p 5000:5000 --name registry registry:2

docker pull alpine:latest

# push local image to our new registry
# first we need to tag it
docker tag alpine localhost:5000/myalpine

# show our new tagged image
docker images

# push image to registry
docker push localhost:5000/myalpine

# pull image from registry
docker pull localhost:5000/myalpine

