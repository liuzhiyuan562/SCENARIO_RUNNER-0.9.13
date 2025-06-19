# export PYTHONPATH="/home/zy/CARLA_0.9.14/PythonAPI/carla/dist/carla-0.9.14-py3.7-linux-x86_64.egg:/home/zy/CARLA_0.9.14/PythonAPI/carla"
# python3 scenario_runner.py --scenario FollowLeadingVehicle_1

#!/bin/bash
# all_in_one.sh - 启动容器并执行命令









# DOCKER_IMAGE=zenoh-autoware-20240903
# DOCKER_FILE=container/Dockerfile_autoware
# CONTAINER_NAME=zenoh_autoware_bridge

# # 构建镜像（如果不存在）
# if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
#     echo "${DOCKER_IMAGE} does not exist. Creating..."
#     docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
# fi

# # 如果容器已存在并在运行，直接在其中执行命令
# if docker ps | grep -q ${CONTAINER_NAME}; then
#     echo "Container ${CONTAINER_NAME} is already running."
#     echo "Executing commands in the container..."
#     docker exec -it ${CONTAINER_NAME} bash -c "
#         cd ~/autoware_carla_launch && 
#         source env.sh && 
#         ./script/run-bridge.sh
#     "
#     exit 0
# fi

# # 如果容器存在但没有运行，移除它
# if docker ps -a | grep -q ${CONTAINER_NAME}; then
#     echo "Container ${CONTAINER_NAME} exists but is not running. Removing it..."
#     docker rm -f ${CONTAINER_NAME}
# fi

# # 启动新容器（使用类似于 rocker 的参数）
# echo "Starting new container..."
# docker run -d \
#     --name ${CONTAINER_NAME} \
#     --gpus all \
#     --privileged \
#     -e DISPLAY=$DISPLAY \
#     -v /tmp/.X11-unix:/tmp/.X11-unix \
#     -v $(pwd):$HOME/autoware_carla_launch \
#     -v $HOME/.Xauthority:$HOME/.Xauthority \
#     --user $(id -u):$(id -g) \
#     ${DOCKER_IMAGE} \
#     tail -f /dev/null

# # 检查容器是否成功启动
# if ! docker ps | grep -q ${CONTAINER_NAME}; then
#     echo "Error: Failed to start container."
#     exit 1
# fi

# echo "Container started successfully. Executing commands..."

# # 在容器中执行命令
# docker exec -it ${CONTAINER_NAME} bash -c "
#     cd ~/autoware_carla_launch && 
#     source env.sh && 
#     ./script/run-bridge.sh
# "






# #!/bin/bash

# DOCKER_IMAGE=zenoh-carla-bridge-20240903
# DOCKER_FILE=container/Dockerfile_carla_bridge
# CONTAINER_NAME=zenoh_autoware_bridge  # 指定容器名称

# # 检查并构建镜像
# if [ ! "$(docker images -q ${DOCKER_IMAGE})" ]; then
#     echo "${DOCKER_IMAGE} does not exist. Creating..."
#     docker build --no-cache -f ${DOCKER_FILE} -t ${DOCKER_IMAGE} .
# fi

# # 检查容器是否已经存在
# if [ ! "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
#     # 如果容器不存在，创建并在后台启动容器
#     echo "Starting new container in background..."
#     docker run -d \
#         --name ${CONTAINER_NAME} \
#         --network host \
#         --privileged \
#         --gpus all \
#         -e DISPLAY=$DISPLAY \
#         -v /tmp/.X11-unix:/tmp/.X11-unix \
#         -v $(pwd):$HOME/autoware_carla_launch \
#         -v $HOME/.Xauthority:$HOME/.Xauthority \
#         ${DOCKER_IMAGE} \
#         tail -f /dev/null
# else
#     # 如果容器存在但没有运行，启动它
#     if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
#         echo "Starting existing container..."
#         docker start ${CONTAINER_NAME}
#     else
#         echo "Container is already running"
#     fi
# fi

# # 确保容器正在运行
# if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
#     echo "Container ${CONTAINER_NAME} is running in background"
#     echo "You can execute commands using:"
#     echo "docker exec -it ${CONTAINER_NAME} /bin/bash"
# else
#     echo "Failed to start container"
#     exit 1
# fi

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: ${SCRIPT_DIR}"



CONTAINER_NAME_CARLA=scenario-runner-0913
DOCKER_IMAGE_CARLA=2256906828/scenario_runner_0913:0.2.0

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

# start carla
echo "Starting new container ${CONTAINER_NAME_CARLA} in background..."
docker run -d \
    --name ${CONTAINER_NAME_CARLA} \
    --privileged \
    --gpus all \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    ${DOCKER_IMAGE_CARLA} \
    tail -f /dev/null

# start carla and change files for scenario_runner
if [ "$(docker ps -aq -f name=${CONTAINER_NAME_CARLA})" ]; then
    echo "Container ${CONTAINER_NAME_CARLA} is running in background"
    echo "loading Carla"
    docker exec ${CONTAINER_NAME_CARLA} /bin/bash -c "./CarlaUE4.sh > /dev/null 2>&1" &
    docker cp ${SCRIPT_DIR}/srunner/scenarios/follow_leading_vehicle.py ${CONTAINER_NAME_CARLA}:/home/carla/scenario_runner-0.9.13/srunner/scenarios/
    docker cp ${SCRIPT_DIR}/srunner/examples/FollowLeadingVehicle.xml ${CONTAINER_NAME_CARLA}:/home/carla/scenario_runner-0.9.13/srunner/examples/
    docker cp ${SCRIPT_DIR}/srunner/simulation/ ${CONTAINER_NAME_CARLA}:/home/carla/scenario_runner-0.9.13/srunner/
else
    echo "Failed to start container ${CONTAINER_NAME_CARLA}"
    exit 1
fi

echo "Container ${CONTAINER_NAME_CARLA} started successfully."

echo "sleep 10 seconds for carla to start"
sleep 10


# start zenoh_carla_bridge
echo "Starting new container ${CONTAINER_NAME_BRIDGE} in background..."
docker run -d \
    --name ${CONTAINER_NAME_BRIDGE} \
    --privileged \
    --gpus all \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    ${DOCKER_IMAGE_BRIDGE} \
    tail -f /dev/null
if [ "$(docker ps -aq -f name=${CONTAINER_NAME_BRIDGE})" ]; then
    echo "Container ${CONTAINER_NAME_BRIDGE} is running in background"
    echo "loading zenoh bridge"
    docker exec ${CONTAINER_NAME_BRIDGE} /bin/bash -c "cd autoware_carla_launch && source env.sh && ./script/run-bridge.sh > /dev/null 2>&1" &
else
    echo "Failed to start container ${CONTAINER_NAME_BRIDGE}"
    exit 1
fi

echo "sleep 10 seconds for zenoh bridge to start"
sleep 10


# start scenario_runner
if [ "$(docker ps -aq -f name=${CONTAINER_NAME_CARLA})" ]; then
    echo "Container ${CONTAINER_NAME_CARLA} is running in background"
    echo "Loading scenario_runner"
    docker exec ${CONTAINER_NAME_CARLA} /bin/bash -c "source ~/miniconda3/bin/activate && cd scenario_runner-0.9.13/ && conda activate scenario-runner-0913-py38 && python3 scenario_runner.py --scenario FollowLeadingVehicle_1 > /dev/null 2>&1" &
else
    echo "Failed to start container ${CONTAINER_NAME_CARLA} in starting scenario_runner"
    exit 1
fi

echo "sleep 5 seconds for scenario_runner to start"
sleep 5



echo "Starting new container ${CONTAINER_NAME_AUTOWARE} in background..."
docker run -d \
    --name ${CONTAINER_NAME_AUTOWARE} \
    --privileged \
    --gpus all \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    ${DOCKER_IMAGE_AUTOWARE} \
    tail -f /dev/null
if [ "$(docker ps -aq -f name=${CONTAINER_NAME_AUTOWARE})" ]; then
    echo "Container ${CONTAINER_NAME_AUTOWARE} is running in background"
    echo "loading autoware"
    docker exec ${CONTAINER_NAME_AUTOWARE} /bin/bash -c "cd autoware_carla_launch && source env.sh && ./script/run-autoware.sh hero > /dev/null 2>&1" &
else
    echo "Failed to start container ${CONTAINER_NAME_AUTOWARE}"
    exit 1
fi

echo "sleep 40 seconds for autoware to start"
sleep 40

if [ "$(docker ps -aq -f name=${CONTAINER_NAME_CARLA})" ]; then
    echo "Starting zenoh python command to control autoware"
    docker exec ${CONTAINER_NAME_CARLA} /bin/bash -c "source ~/miniconda3/bin/activate && conda activate scenario-runner-0913-py38 && cd /home/carla/zenoh_python_command && source env.sh && python3 /home/carla/zenoh_python_command/scenario_autoware.py > /dev/null 2>&1" &
else
    echo "Failed to start container ${CONTAINER_NAME_CARLA} in starting zenoh python command"
    exit 1
fi

echo "zenoh python send command to autoware"
echo "sleep 5 seconds for zenoh python command to start"
sleep 5