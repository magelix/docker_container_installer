#!/bin/bash

set -e
container_name=""
traefik=false
optionstring=""
image=""
lb_network="traefik-backend"

source "./$1"

run=false
if [ "$(docker ps -aq -f name=$container_name)" ]; then
    #container existiert
    echo "$container_name existiert"
    if [ "$(docker ps -aq -f status=running -f name=$container_name)" ]; then
        #container laeuft
        echo "$container_name läuft"
        docker stop "$container_name"
        run=true
    fi
    echo "$container_name wird gelöscht"
    docker rm "$container_name"
fi

# run your container
echo "dummy wird neu erzeugt"
if [ "$traefik" == "false" ]; then
    traefik="-l traefik.enable=false"
else
    traefik="$traefik -l traefik.docker.network=$lb_network"
    connect=true
fi

docker create --name $container_name $traefik $optionstring $image

if [ $connect ]; then
    echo "verbinde $container_name mit $lb_network"
    docker network connect "$lb_network" "$container_name"
fi

if [ "$run" == true ]; then
    echo "$container_name wird gestartet"
    docker start "$container_name"
fi
