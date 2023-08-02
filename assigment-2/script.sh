#!/bin/bash
# This script will build for you Docker container based on Dockerfile with Golang app with options.
usage() {
  # Display the usage and exit.
  echo "Usage of ${0}"
  echo 'This script will build for you Docker container with Golang app with options:'
  echo '  --default  Default option: it will built normally with default port 8080.'
  echo '  --port  It will build an app with port specified numerically by user.'
  echo '  --healthcheck  It will check for you if container is healthy.' 
  exit 0
}
# Help a user
if [[ $1 -eq 0 ]]
then
  echo "You didn't make a choice!"
  usage
  exit 1
fi
# What options there are.
ARGS=$(getopt --options 'd,p:h' --longoptions 'default,port:,healthcheck' -- "${@}") || exit
eval "set -- ${ARGS}"

while true; do
    case "${1}" in
        (-h | --healthcheck)
            # Here we built image for Go-app
              docker build -t go-app-health .
            # Here we run a container based on that image
              docker run -p 8080:8080 --name go-app-health go-app-health & 
              sleep 20
              CONTAINER_ID=$(docker ps -a | grep "go-app-health" | cut -d" " -f1) &
            # Let's check if it is running:
              if [ "$( docker container inspect -f '{{.State.Running}}' go-app-health )" = "true" ] 
                then 
                  notify-send "Golang-app form container: Hey! I'm healthy!"
                  echo "Do you want me to stop? Yes/no"
                  read $REPLY
                  case $REPLY in
                  Yes|Y|yes) echo "Okey :(" && docker stop go-app-health && docker rm go-app-health && exit 0 ;;
                  No|N|no) echo "Okey dokey!" && exit 0 ;;
                  *)        echo "Well this is invalid option. I'm gonna stay alive, okey?" && exit 0 ;;
                  esac
                else
                  notify-send "Golang-app form container: Oh my... I think I might be sick :("
              fi
              echo "Do you want me to stop? Yes/no"
              read $REPLY
              case $REPLY in
              Yes|Y|yes) echo "Okey :(" && docker stop go-app-health && docker rm go-app-health;;
              No|N|no) echo "Okey dokey!" && exit 0 ;;
              *)        echo "Well this is invalid option. I'm gonna stay alive, okey?" && exit 0 ;;
              esac
            shift
        ;;
        (-d | --default)
            # Here we built image for Go-app
              docker build -t go-app-def .
            # Here we run a container based on that image
              docker run -p 8080:8080 go-app-def
            # On exiting app container gets removed
              CONTAINER_ID=$(docker ps -a | grep "go-app-def" | cut -d" " -f1)
              docker rm "${CONTAINER_ID}"
            shift 2
        ;;
        (-p | --port)
              BIND_ADDRESS=:${2}
            # Here we built image for Go-app
              docker build --build-arg BIND_ADDRESS=${BIND_ADDRESS} -t go-app-dp .
            # Here we run a container based on that image
              docker run -p ${2}:${2} go-app-dp
            # On exiting app container gets removed
              CONTAINER_ID=$(docker ps -a | grep "go-app-dp" | cut -d" " -f1)
              docker rm "${CONTAINER_ID}"
            shift 2
        ;;
        (--)
            shift
            break
        ;;
        (?)
            usage
            exit 1    # error
        ;;
        (*)
            exit 0    # success
        ;;
    esac
done

remaining_args=("${@}")
