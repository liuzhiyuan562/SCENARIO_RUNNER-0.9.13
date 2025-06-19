#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: ${SCRIPT_DIR}"



CONTAINER_NAME_CARLA=scenario-runner-0913
DOCKER_IMAGE_CARLA=scenario_runner_0913:0.2.0

if [ "$(docker ps -aq -f name=${CONTAINER_NAME_CARLA})" ]; then
    echo "Container ${CONTAINER_NAME_CARLA} already exists. Removing it..."
    docker stop ${CONTAINER_NAME_CARLA}
    docker rm -f ${CONTAINER_NAME_CARLA}
fi

CONTAINER_NAME_AUTOWARE=zenoh_autoware
DOCKER_IMAGE_AUTOWARE=2256906828/zenoh_autoware:0.2.0

if [ "$(docker ps -aq -f name=${CONTAINER_NAME_AUTOWARE})" ]; then
    echo "Container ${CONTAINER_NAME_AUTOWARE} already exists. Removing it..."
    docker stop ${CONTAINER_NAME_AUTOWARE}
    docker rm -f ${CONTAINER_NAME_AUTOWARE}
fi

CONTAINER_NAME_BRIDGE=zenoh-carla-bridge
DOCKER_IMAGE_BRIDGE=2256906828/zenoh_carla_bridge:0.3.0

if [ "$(docker ps -aq -f name=${CONTAINER_NAME_BRIDGE})" ]; then
    echo "Container ${CONTAINER_NAME_BRIDGE} already exists. Removing it..."
    docker stop ${CONTAINER_NAME_BRIDGE}
    docker rm -f ${CONTAINER_NAME_BRIDGE}
fi