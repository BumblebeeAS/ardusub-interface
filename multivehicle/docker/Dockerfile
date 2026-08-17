FROM multivehicle_sim:jazzy

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ARG HOME_DIR=/root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-transforms3d \
    ros-jazzy-navigation2 \
    ros-jazzy-nav2-bringup \
    ros-jazzy-py-trees \
    ros-jazzy-py-trees-ros \
    ros-jazzy-tf-transformations && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages mavsdk

WORKDIR ${HOME_DIR}
