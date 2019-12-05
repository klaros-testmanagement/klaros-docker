#!/bin/bash

sudo docker-compose down --volume

sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)

sudo docker volume prune -f
#sudo docker image prune -f

#sudo docker volume create --name 'klaros-data'
sudo docker-compose build && sudo docker-compose up
