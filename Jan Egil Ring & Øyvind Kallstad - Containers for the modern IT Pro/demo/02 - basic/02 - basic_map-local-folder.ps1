Write-Host "Demo!"
break

# Linux containers mode must be enabled

# map local folder to container
docker run -it -v "${PWD}:/local" alpine:latest
# /local inside the container is now mapped to the current folder where
# you ran the command from
# you need to cd /local to get to it within the container

# if you want to start at a specific location within the container
docker run -it -v "${PWD}:/local" -w /local alpine:latest

# you can map several folders by just adding more -v parameters