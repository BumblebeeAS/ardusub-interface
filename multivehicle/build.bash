#!/usr/bin/env bash

#
# Build the multivehicle_sim Docker image (Gazebo Harmonic + prebuilt PX4 &
# ArduSub + the bb_robotx_dashboard toolchain + the mission/control stack the
# examples need).
#
# Usage: ./build.bash   (from src/examples/multivehicle)
# Tags the build as both multivehicle_sim:<tag> and multivehicle_sim:<timestamp>.
#
# SPDX-License-Identifier: MIT
# Adapted from OSRF dockwater (Apache-2.0), Copyright (C) 2018 Open Source
# Robotics Foundation; modified for multivehicle_sim by MonkeScripts.
image_name=multivehicle_sim
dockerfile_dir=${1:-docker}
distro=${2:-jazzy}

if [ ! -f "${dockerfile_dir}"/Dockerfile ]
then
    echo "Err: Directory '${dockerfile_dir}' does not contain a Dockerfile to build."
    echo "     Run this from src/examples/multivehicle."
    exit 1
fi

export DOCKER_BUILDKIT=1

image_plus_tag=$image_name:$(export LC_ALL=C; date +%Y_%m_%d_%H%M)
docker build --rm -t $image_plus_tag -f "${dockerfile_dir}"/Dockerfile "${dockerfile_dir}" && \
docker tag $image_plus_tag $image_name:$distro && \
echo "Built $image_plus_tag and tagged as $image_name:$distro" || exit 1
echo "To run:"
echo "./run.bash $image_name:$distro"
