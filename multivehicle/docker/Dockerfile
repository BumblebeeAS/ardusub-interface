# syntax=docker/dockerfile:1
# Self-contained build for the multivehicle (PX4 + ArduSub + USV) simulator,
# the example missions/controllers built on top of it, and the
# bb_robotx_dashboard toolchain.
# Layout:
#   base              everything the FINAL image needs (apt + node + protoc + pip)
#   px4-builder       clones/patches/builds PX4 SITL          -> px4_sitl/ + gz models
#   ardupilot-builder clones/builds ArduSub                   -> bin/ardusub
#   final             base + the three artifacts above, nothing else
#
# --------------------------------------------------------------------------- #
# base
# --------------------------------------------------------------------------- #
FROM ros:jazzy-ros-base-noble AS base

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo $TZ > /etc/timezone && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime

RUN <<EOF
# Prerequisites for adding the third-party apt repos. Both stay in the final
# image (curl is used by setup_dashboard.sh's toolchain), so they are not
# repeated in the main list below.
apt-get update
apt-get install -y --no-install-recommends curl gnupg

# Gazebo / OSRF apt repository
curl https://packages.osrfoundation.org/gazebo.gpg \
    --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list

# Main install
apt-get update
apt-get install -y --no-install-recommends \
    bash-completion \
    bc \
    build-essential \
    cmake \
    gdb \
    git \
    glmark2-x11 \
    gstreamer1.0-gl \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gz-harmonic \
    iputils-ping \
    libeigen3-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgz-sim8-dev \
    libopencv-dev \
    libxcb-cursor-dev \
    locales \
    net-tools \
    nodejs \
    patch \
    pkg-config \
    protobuf-compiler \
    python3-empy \
    python3-pip \
    python3-rospkg \
    python3-sdformat14 \
    python3-setuptools \
    python3-venv \
    rapidjson-dev \
    ros-jazzy-actuator-msgs \
    ros-jazzy-ament-cmake-pycodestyle \
    ros-jazzy-desktop \
    ros-jazzy-foxglove-bridge \
    ros-jazzy-gps-msgs \
    ros-jazzy-image-common \
    ros-jazzy-image-transport \
    ros-jazzy-image-transport-plugins \
    ros-jazzy-joy-linux \
    ros-jazzy-joy-teleop \
    ros-jazzy-mavros \
    ros-jazzy-mavros-extras \
    ros-jazzy-mavros-msgs \
    ros-jazzy-radar-msgs \
    ros-jazzy-ros-gz \
    ros-jazzy-vision-msgs \
    ros-jazzy-xacro \
    sudo \
    tmux \
    unzip \
    vim \
    wget \
    xterm \
    xvfb

locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

ENV LANG=en_US.UTF-8

# ros-jazzy-mavros
RUN /opt/ros/jazzy/lib/mavros/install_geographiclib_datasets.sh

# Pinned protoc 33 baked offline to /opt/protoc (supports edition = "2024").
# Installed off the system path so it never shadows /usr/bin/protoc;
# setup_dashboard.sh wires it into the dashboard's third_party/protoc/.
ARG PROTOC_VERSION=33.0
RUN <<EOF
arch="$(uname -m)"
case "${arch}" in
  x86_64)        pc_arch="linux-x86_64" ;;
  aarch64|arm64) pc_arch="linux-aarch_64" ;;
  *) echo "unsupported arch: ${arch}" >&2; exit 1 ;;
esac
zip="protoc-${PROTOC_VERSION}-${pc_arch}.zip"
curl -fLo "/tmp/${zip}" \
    "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${zip}"
mkdir -p /opt/protoc
unzip -q -o "/tmp/${zip}" -d /opt/protoc
chmod +x /opt/protoc/bin/protoc
rm -f "/tmp/${zip}"
/opt/protoc/bin/protoc --version
EOF

RUN pip3 install --no-cache-dir --break-system-packages \
        'fastapi' \
        'uvicorn[standard]' \
        'pydantic' \
        'pydantic-settings' \
        'protobuf>=6.33,<8' \
        'tmuxp'

# --------------------------------------------------------------------------- #
# px4-builder -- produces ${PX4_DIR}/px4_sitl and the gz model/config tree.
# --------------------------------------------------------------------------- #
FROM base AS px4-builder

ARG PX4_DIR=/root/px4
ARG PX4_VERSION=v1.16.0

RUN <<EOF
git clone --recurse-submodules -b ${PX4_VERSION} \
    https://github.com/PX4/PX4-Autopilot.git ${PX4_DIR}/PX4-Autopilot
cd ${PX4_DIR}/PX4-Autopilot

# Move the PX4_PARAM_* env-var override block to after parameter loading so
# params like PX4_PARAM_UXRCE_DDS_SYNCT survive the autostart defaults --
# unpatched, the drone silently desyncs at runtime.
patch -p1 <<'PATCH'
diff --git a/ROMFS/px4fmu_common/init.d-posix/rcS b/ROMFS/px4fmu_common/init.d-posix/rcS
index fed292b9d1..1d34854077 100644
--- a/ROMFS/px4fmu_common/init.d-posix/rcS
+++ b/ROMFS/px4fmu_common/init.d-posix/rcS
@@ -126,15 +126,6 @@ then
 	set AUTOCNF yes
 fi

-# Allow overriding parameters via env variables: export PX4_PARAM_{name}={value}
-env | while IFS='=' read -r line; do
-  value=${line#*=}
-  name=${line%%=*}
-  case $name in
-    "PX4_PARAM_"*) param set "${name#PX4_PARAM_}" "$value" ;;
-  esac
-done
-
 # multi-instance setup
 # shellcheck disable=SC2154
 param set MAV_SYS_ID $((px4_instance+1))
@@ -239,6 +230,15 @@ then
 	exit 1
 fi

+# Allow overriding parameters via env variables: export PX4_PARAM_{name}={value}
+env | while IFS='=' read -r line; do
+  value=${line#*=}
+  name=${line%%=*}
+  case $name in
+    "PX4_PARAM_"*) param set "${name#PX4_PARAM_}" "$value" ;;
+  esac
+done
+
 dataman start

 # only start the simulator if not in replay mode, as both control the lockstep time
PATCH

./Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools
# Preliminary check
python3 -c "import numpy, setuptools as s; \
    v = (numpy.__version__, s.__version__); print('numpy %s, setuptools %s' % v); \
    assert numpy.__version__.startswith('1.'), 'pip numpy shadows apt 1.26: %s' % v[0]; \
    assert int(s.__version__.split('.')[0]) < 80, 'pip setuptools shadows apt 68: %s' % v[1]"

make px4_sitl_default
cd ${PX4_DIR}
mkdir -p px4_sitl/bin px4_sitl/romfs/etc
cp -a PX4-Autopilot/build/px4_sitl_default/bin px4_sitl/
tar xf PX4-Autopilot/build/px4_sitl_default/romfs_files.tar -C px4_sitl/romfs/etc
EOF

# --------------------------------------------------------------------------- #
# ardupilot-builder -- produces build/sitl/bin/ardusub.
# --------------------------------------------------------------------------- #
FROM base AS ardupilot-builder

ARG ARDUSUB_DIR=/root/auv
# master @ 2026-08-15, ArduPilot-4.6.0-beta1-7986-g08a9972abb. Pinned so rebuilds
# are reproducible; bump deliberately (and re-fly the BlueROV) when moving it.
ARG ARDUPILOT_VERSION=08a9972abb

WORKDIR ${ARDUSUB_DIR}/ardupilot
RUN <<EOF
git clone https://github.com/ArduPilot/ardupilot.git .
git checkout ${ARDUPILOT_VERSION}
git submodule update --init --recursive
EOF

ENV SKIP_AP_EXT_ENV=1 SKIP_AP_GRAPHIC_ENV=1 SKIP_AP_COV_ENV=1 SKIP_AP_GIT_CHECK=1

# install-prereqs-ubuntu.sh refuses to run as root, insists on `pip --user`, and
# wants to usermod the invoking user -- none of which apply in a container. Each
# rewrite is asserted, because `sed` exits 0 when it matches nothing: without the
# checks an upstream rename would silently no-op and fail much later, in waf.
RUN <<'EOF'
prereqs=Tools/environment_install/install-prereqs-ubuntu.sh

sed -i 's/if \[ \$EUID == 0 \]/if [ 1 == 0 ]/g' "${prereqs}"
if ! grep -q 'if \[ 1 == 0 \]' "${prereqs}"; then
    echo "install-prereqs: EUID root guard not found -- upstream changed" >&2; exit 1
fi

sed -i 's/PIP_USER_ARGUMENT="--user"/PIP_USER_ARGUMENT=""/g' "${prereqs}"
if grep -q 'PIP_USER_ARGUMENT="--user"' "${prereqs}"; then
    echo "install-prereqs: PIP_USER_ARGUMENT not neutralised -- upstream changed" >&2; exit 1
fi

sed -i 's/sudo usermod -a -G dialout $USER/true/g' "${prereqs}"
if grep -q 'usermod -a -G dialout' "${prereqs}"; then
    echo "install-prereqs: usermod call not stubbed -- upstream changed" >&2; exit 1
fi
EOF
RUN Tools/environment_install/install-prereqs-ubuntu.sh -y

# Build ArduSub. On Noble, install-prereqs-ubuntu.sh puts its python deps in a
# venv ($HOME/venv-ardupilot, --system-site-packages) instead of site-packages and
# writes the activation line to ~/.ardupilot_env (the docker path, since
# /.dockerenv exists). waf needs those deps, so source it here. It is deliberately
# NOT carried into the final image: ardusub_interface.launch.py execs the
# `ardusub` binary directly, not sim_vehicle.py, so this is a build-time need only.
RUN if [ -f ~/.ardupilot_env ]; then source ~/.ardupilot_env; fi \
 && modules/waf/waf-light configure --board sitl \
 && modules/waf/waf-light build --target bin/ardusub

# --------------------------------------------------------------------------- #
# final -- base plus the three artifacts. No autopilot source trees ship.
# --------------------------------------------------------------------------- #
FROM base AS final

ARG HOME_DIR=/root

ENV PX4_DIR=${HOME_DIR}/px4

# PX4 SITL binaries + romfs, and the gz model/config tree PX4_GZ_STANDALONE
# resolves through GZ_SIM_RESOURCE_PATH. Paths match the builder's so the env
# vars below (and anything referencing them) are unchanged.
COPY --from=px4-builder ${PX4_DIR}/px4_sitl ${PX4_DIR}/px4_sitl
COPY --from=px4-builder ${PX4_DIR}/PX4-Autopilot/Tools/simulation/gz \
                        ${PX4_DIR}/PX4-Autopilot/Tools/simulation/gz

# ArduSub SITL. Only the binary is needed -- it links nothing outside the apt
# libs already in `base`, and takes its parameters from
# multivehicle_interface/config/ardusub.parm at launch.
COPY --from=ardupilot-builder /root/auv/ardupilot/build/sitl/bin/ardusub /usr/local/bin/ardusub

# The example missions and controllers (multivehicle_examples, bluerov_tasks,
# mission_planner_2). Kept in `final` rather than `base` on purpose: touching this
# list must not invalidate the px4-builder / ardupilot-builder caches.
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

COPY scripts/setup_dashboard.sh /usr/local/bin/setup_dashboard.sh
RUN chmod +x /usr/local/bin/setup_dashboard.sh
RUN cat >> /root/.bashrc <<'EOF'

# bb_robotx_dashboard runtime env
export ROBOCOMMAND_HOST=localhost
export ROBOCOMMAND_PORT=9000
export ROBOCOMMAND_TEAM_ID=42
export DASHBOARD_LISTEN_HOST=0.0.0.0
export DASHBOARD_LISTEN_PORT=8080
export DASHBOARD_ADMIN_SECRET=bumblebee

# bb_robotx_dashboard one-shot proto bootstrap (against the mounted workspace)
if [ -z "${DASHBOARD_BOOTSTRAPPED:-}" ]; then
    export DASHBOARD_BOOTSTRAPPED=1
    /usr/local/bin/setup_dashboard.sh || true
fi
EOF

WORKDIR ${HOME_DIR}

ENV GZ_SIM_RESOURCE_PATH=${PX4_DIR}/PX4-Autopilot/Tools/simulation/gz/models
ENV GZ_SIM_SERVER_CONFIG_PATH=${PX4_DIR}/PX4-Autopilot/Tools/simulation/gz/server.config
# The ArduPilotPlugin comes from the colcon-built src/ardupilot_gazebo, which
# bb_worlds' resource_paths.sh hook prepends to GZ_SIM_SYSTEM_PLUGIN_PATH once
# install/setup.bash is sourced -- nothing to set here.
ENV PATH="/root/.local/bin:${PATH}"
