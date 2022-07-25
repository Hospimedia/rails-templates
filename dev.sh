#!/bin/bash

docker_compose="docker-compose -f docker-compose.yml"

if [[ $(uname) == "Darwin" ]]; then
  docker_compose="$docker_compose -f docker-compose.osx.yml"
fi

if [[ -f "docker-compose.dev.yml" ]]; then
  docker_compose="$docker_compose -f docker-compose.dev.yml"
fi

function start() {
  $docker_compose up -d ${*}
}

function up() {
  start ${*}
}

function reboot() {
  down ${*}
  up ${*}
}

function restart() {
  $docker_compose restart ${*}
}

function exec() {
  $docker_compose exec app ${*}
}

function logs() {
  $docker_compose logs ${*}
}

function stop() {
  $docker_compose stop
}

function ps() {
  $docker_compose ps
}

function down() {
  $docker_compose down
}

function bundle() {
  $docker_compose exec app bundle ${*}
}

function yarn() {
  $docker_compose exec app yarn ${*}
}

case "$1" in
  start|up|restart|stop|down|reboot|exec|logs|ps|bundle|yarn)
    ${*}
    ;;

  *)
    echo "Usage: $(basename $0) (start|up|restart|stop|down|reboot|exec|logs|ps|bundle|yarn)"
    exit 1
    ;;
esac
