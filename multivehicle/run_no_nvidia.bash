#!/usr/bin/env bash

#
# SPDX-License-Identifier: MIT
# Adapted from OSRF dockwater (Apache-2.0), Copyright (C) 2018 Open Source
# Robotics Foundation; modified for multivehicle_sim by MonkeScripts.
#

# Runs the multivehicle_sim container WITHOUT NVIDIA GPU passthrough, for hosts with an
# Intel/AMD integrated GPU (or no discrete NVIDIA GPU). Rendering falls back to
# Mesa — the host's iGPU via /dev/dri, or llvmpipe software rendering — which is
# slower, so expect a low real-time factor in Gazebo.
#
# IMPORTANT: do NOT export the NVIDIA PRIME offload vars
# (__NV_PRIME_RENDER_OFFLOAD / __GLX_VENDOR_LIBRARY_NAME) on this host — just
# launch the world normally:
#   ros2 launch multivehicle_sim world.launch.py
# On a host with no X server, also pass headless:=true.
#
# For NVIDIA hosts use ./run.bash instead (and export the offload vars before
# launching, as in the README).
#
# Requires:
#   docker
#   an X server (for the GUI; omit on a headless host)
#   rocker
# Recommended:
#   A joystick mounted to /dev/input/js0
############################################################
# Help                                                     #
############################################################
Help()
{
   echo "Runs the multivehicle_sim container without NVIDIA GPU passthrough (Mesa/iGPU)."
   echo
   echo "Syntax: run_no_nvidia.bash [-h] [IMAGE]"
   echo "  IMAGE   docker image to run (default: multivehicle_sim:jazzy)"
   echo "options:"
   echo "  h     Print this help message and exit."
   echo
   echo "Do not export the NVIDIA PRIME offload vars on this host; just launch normally."
}

while getopts ":h" option; do
  case $option in
    h) Help; exit;;
  esac
done

JOY=/dev/input/js0

# Devices: the DRI render node gives the container the host GPU (iGPU) for Mesa.
# Add the joystick only if it exists, so rocker doesn't error on machines
# without one.
DEVICES="/dev/dri"
if [ -e "$JOY" ]; then
  DEVICES="/dev/dri $JOY"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# Same as run.bash but WITHOUT --nvidia. --x11 forwards the display for the GUI;
# drop it (and pass headless:=true to the world launch) on a headless host.
ROCKER_ARGS="--devices $DEVICES --dev-helpers --x11 --git --volume ${WORKSPACE_DIR}:/root/HOST/mvsim_ws --network=host"

IMG_NAME=${@:$OPTIND:1}
IMG_NAME=${IMG_NAME:-multivehicle_sim:jazzy}

# Replace `:` with `_` to comply with docker container naming, and append `_runtime`
CONTAINER_NAME="$(tr ':' '_' <<< "$IMG_NAME")_runtime"
ROCKER_ARGS="${ROCKER_ARGS} --name $CONTAINER_NAME"
echo ${ROCKER_ARGS}
echo "Using image <$IMG_NAME> to start container <$CONTAINER_NAME> (no NVIDIA)"
echo "Reminder: do not export the NVIDIA PRIME offload vars on this host."

rocker ${ROCKER_ARGS} $IMG_NAME
