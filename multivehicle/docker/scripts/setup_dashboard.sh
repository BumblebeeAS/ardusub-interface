#!/usr/bin/env bash
# bb_robotx_dashboard runtime bootstrap.
#
# Runs once per container shell (hooked from ~/.bashrc). Generates the protobuf
# bindings the dashboard backend needs, against the dashboard source in the
# mounted workspace.

set -uo pipefail

# Locate the dashboard package in the mounted workspace. Override with
# DASHBOARD_PKG_DIR if your workspace lives somewhere else.
PKG_DIR="${DASHBOARD_PKG_DIR:-/root/HOST/mvsim_ws/src/bb_robotx_dashboard}"
if [ ! -d "${PKG_DIR}" ]; then
    # Fall back to a shallow search under the mounted home.
    PKG_DIR="$(find /root/HOST -maxdepth 5 -type d -name bb_robotx_dashboard \
        -not -path '*/build/*' -not -path '*/install/*' 2>/dev/null | head -n1)"
fi

# No dashboard checked out — nothing to bootstrap, stay quiet.
[ -n "${PKG_DIR}" ] && [ -d "${PKG_DIR}" ] || exit 0

did_work=0

# 1. Clone the upstream robocommand repo (provides the .proto source).
#    RobotX_2026/proto is the guard: a pre-RobotX (RoboBoat-era) checkout has
#    only a top-level proto/ and must be deleted, not cloned into.
RC_DIR="${PKG_DIR}/third_party/robocommand"
if [ ! -d "${RC_DIR}/RobotX_2026/proto" ]; then
    if [ -d "${RC_DIR}" ]; then
        echo "[setup_dashboard] ${RC_DIR} is a stale pre-RobotX checkout." >&2
        echo "[setup_dashboard] delete it and re-run:  rm -rf ${RC_DIR}" >&2
    else
        echo "[setup_dashboard] cloning robocommand proto source..."
        git clone https://github.com/robonation/robocommand "${RC_DIR}" || true
        did_work=1
    fi
fi

# 2. Wire the image's pinned protoc 33 into third_party/protoc/ so
#    compile_protos.sh picks the local (edition-2024-capable) binary instead of
#    the system protoc 3.x. We symlink the baked /opt/protoc rather than
#    re-downloading it over the network.
if [ ! -x "${PKG_DIR}/third_party/protoc/bin/protoc" ] \
        && [ -x /opt/protoc/bin/protoc ]; then
    mkdir -p "${PKG_DIR}/third_party/protoc/bin"
    ln -sf /opt/protoc/bin/protoc "${PKG_DIR}/third_party/protoc/bin/protoc"
fi

# 3. Generate the Python protobuf bindings if missing. The sentinel is a
#    RobotX-era module — keying on the old report_pb2.py would let a stale
#    RoboBoat binding suppress regeneration forever.
if [ -d "${RC_DIR}/RobotX_2026/proto" ] \
        && [ ! -f "${PKG_DIR}/bb_robotx_dashboard/proto/robotx/rx_reports_pb2.py" ]; then
    echo "[setup_dashboard] compiling proto bindings..."
    ( cd "${PKG_DIR}" && bash scripts/compile_protos.sh ) || true
    did_work=1
fi

# 4. paho-mqtt 2.x fallback for containers built from a pre-MQTT image (the
#    rebuilt image bakes it; apt's 1.x is not API-compatible).
python3 -c "import paho.mqtt" 2>/dev/null || \
    pip3 install --break-system-packages --no-cache-dir 'paho-mqtt>=2.1,<3' || true

if [ ! -d "${PKG_DIR}/frontend/dist" ]; then
    cat <<MSG
[setup_dashboard] dashboard tooling ready. Remaining manual steps:
  cd ${PKG_DIR}/frontend && npm ci && npm run build
  cd /root/HOST/mvsim_ws && colcon build --packages-up-to bb_robotx_dashboard && source install/setup.bash
MSG
elif [ "${did_work}" -eq 1 ]; then
    echo "[setup_dashboard] proto bindings generated. Rebuild if needed: colcon build --packages-up-to bb_robotx_dashboard"
fi

exit 0
