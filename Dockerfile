from ubuntu:18.04

# Install base libs
run apt-get update && apt-get install --no-install-recommends -y libpng16-16=1.6.34-1ubuntu0.18.04.2 \
libtiff5=4.0.9-5ubuntu0.3 libjpeg8=8c-2ubuntu8 build-essential=12.4ubuntu1 wget=1.19.4-1ubuntu2.2 git=1:2.17.1-1ubuntu0.7 \
 python3.6 python3.6-dev python3-pip libxerces-c-dev \
 && rm -rf /var/lib/apt/lists/* 

# Install python requirements
run pip3 install --user setuptools==46.3.0 wheel==0.34.2 && pip3 install py_trees==0.8.3 networkx==2.2 pygame==1.9.6 \
    six==1.14.0 numpy==1.18.4 psutil==5.7.0 shapely==1.7.0 xmlschema==1.1.3 ephem==3.7.6.0 tabulate==0.8.7\
&& mkdir -p /app/scenario_runner 

# Install scenario_runner 
copy . /app/scenario_runner

# setup environment :
# 
#   CARLA_HOST :    uri for carla package without trailing slash. 
#                   For example, "https://carla-releases.s3.eu-west-3.amazonaws.com/Linux".
#                   If this environment is not passed to docker build, the value
#                   is taken from CARLA_VER file inside the repository.
#
#   CARLA_RELEASE : Name of the package to be used. For example, "CARLA_0.9.9".
#                   If this environment is not passed to docker build, the value
#                   is taken from CARLA_VER file inside the repository.
# 
#
#  It's expected that $(CARLA_HOST)/$(CARLA_RELEASE).tar.gz is a downloadable resource.
#

env CARLA_HOST ""
env CARLA_RELEASE ""

# Extract and install python API and resources from CARLA
run export DEFAULT_CARLA_HOST="$(sed -e 's/^\s*HOST\s*=\s*//;t;d' /app/scenario_runner/CARLA_VER)" && \
    echo "$DEFAULT_CARLA_HOST" && \
    export CARLA_HOST="${CARLA_HOST:-$DEFAULT_CARLA_HOST}" && \
    export DEFAULT_CARLA_RELEASE="$(sed -e 's/^\s*RELEASE\s*=\s*//;t;d' /app/scenario_runner/CARLA_VER)" && \
    export CARLA_RELEASE="${CARLA_RELEASE:-$DEFAULT_CARLA_RELEASE}" && \
    echo "$CARLA_HOST/$CARLA_RELEASE.tar.gz" && \
    wget -qO- "$CARLA_HOST/$CARLA_RELEASE.tar.gz" | tar -xzv PythonAPI/carla -C / && \
    mv /PythonAPI/carla /app/ && \
    python3 -m easy_install --no-find-links --no-deps "$(find /app/carla/ -iname '*py3.*.egg' )"


# Setup working environment
workdir /app/scenario_runner
env PYTHONPATH "${PYTHONPATH}:/app/carla/agents:/app/carla"
entrypoint ["/bin/sh" ]




# FROM ubuntu:22.04

# # Prevent interactive prompts
# ENV DEBIAN_FRONTEND=noninteractive

# # Install base libs
# RUN apt-get update && apt-get install -y \
#     wget \
#     bzip2 \
#     ca-certificates \
#     libpng16-16 \
#     libtiff5 \
#     libjpeg8 \
#     build-essential \
#     git \
#     libxerces-c-dev \
#     libgeos-dev \
#     libgeos-c1v5 \
#     && rm -rf /var/lib/apt/lists/*

# # Install Miniconda
# ENV CONDA_DIR /opt/conda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
#     rm ~/miniconda.sh

# # Add conda to path and initialize
# ENV PATH=$CONDA_DIR/bin:$PATH
# RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc
    

# # Create conda environment
# RUN conda create -n scenario-runner-0913-py38 python=3.8 -y && \
#     echo "conda activate scenario-runner-0913-py38" >> ~/.bashrc

# # Make RUN commands use the new environment   --login is used to source the bashrc
# SHELL ["/bin/bash", "--login", "-c"]

# # Set entrypoint to ensure conda environment is always activated
# ENTRYPOINT ["/bin/bash", "--login", "-c"]

# # Install python requirements
# RUN pip3 install setuptools==75.1.0 wheel==0.44.0 py_trees==0.8.3 networkx==2.2 pygame==2.6.1 six==1.16.0 
# RUN conda install numpy
# RUN pip3 install psutil==5.9.0 shapely==1.7.1 xmlschema==1.0.18 ephem==4.1.5 tabulate==0.9.0
# RUN mkdir -p /app/scenario_runner 

# # Install scenario_runner 
# copy . /app/scenario_runner

# # setup environment :
# # 
# #   CARLA_HOST :    uri for carla package without trailing slash. 
# #                   For example, "https://carla-releases.s3.eu-west-3.amazonaws.com/Linux".
# #                   If this environment is not passed to docker build, the value
# #                   is taken from CARLA_VER file inside the repository.
# #
# #   CARLA_RELEASE : Name of the package to be used. For example, "CARLA_0.9.9".
# #                   If this environment is not passed to docker build, the value
# #                   is taken from CARLA_VER file inside the repository.
# # 
# #
# #  It's expected that $(CARLA_HOST)/$(CARLA_RELEASE).tar.gz is a downloadable resource.
# #

# env CARLA_HOST "https://tiny.carla.org"
# env CARLA_RELEASE "carla-0-9-13-linux"

# # Extract and install python API and resources from CARLA
# run export DEFAULT_CARLA_HOST="$(sed -e 's/^\s*HOST\s*=\s*//;t;d' /app/scenario_runner/CARLA_VER)"
# run echo "$DEFAULT_CARLA_HOST"
# run export CARLA_HOST="${CARLA_HOST:-$DEFAULT_CARLA_HOST}"
# run export DEFAULT_CARLA_RELEASE="$(sed -e 's/^\s*RELEASE\s*=\s*//;t;d' /app/scenario_runner/CARLA_VER)"
# run export CARLA_RELEASE="${CARLA_RELEASE:-$DEFAULT_CARLA_RELEASE}"
# run echo "$CARLA_HOST/$CARLA_RELEASE.tar.gz"
# run wget -q "${CARLA_HOST}/${CARLA_RELEASE}.tar.gz" -O carla_template.tar.gz
# run tar -xzvf carla_template.tar.gz PythonAPI/carla -C
# run rm -f carla_template.tar.gz
# run mv /PythonAPI/carla /app/ 
# run python3 -m easy_install --no-find-links --no-deps "$(find /app/carla/ -iname '*py3.*.egg' )"


# # Setup working environment
# workdir /app/scenario_runner
# env PYTHONPATH "${PYTHONPATH}:/app/carla/agents:/app/carla"
# entrypoint ["/bin/sh" ]



