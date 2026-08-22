# Multi-vehicle simulation

Gazebo (Harmonic) simulator for a multi-vehicle marine environment — a BlueROV2
AUV (ArduSub), a BlueBoat USV, and a PX4 x500 drone in the RobotX 2026 Singapore
River course — plus the missions and controllers that drive them and the
`bb_robotx_dashboard` operator dashboard.

## Layout

```
examples/multivehicle/
  build.bash  run.bash  run_no_nvidia.bash
  examples.repos              # every sibling dependency, imported under src/
  docker/Dockerfile           # multivehicle_sim:jazzy — multi-stage (gz harmonic + PX4 + ArduSub + dashboard + mission stack)
  docker/scripts/setup_dashboard.sh
  tmuxp/mvsim.yaml            # sim only: world + 3 vehicles + dashboard
  tmuxp/mvsim_debug.yaml      # the above + the missions/controllers
  packages/
    multivehicle_interface/   # ament_python — ArduSub SITL + MAVROS + gz odometry adapters
    multivehicle_sim/         # ament_cmake  — gazebo bringup, vehicle models (bluerov2/blueboat), gz bridges
    multivehicle_examples/    # ament_cmake  — BlueBoat mission/control, PX4 offboard launch wrappers
```

Course/environment models and worlds (incl. `robotx_2026_sg_river.world`) come
from the [`bb_worlds`](https://github.com/BumblebeeAS/bb_worlds) package, and the
dashboard's ROS interfaces from [`bb_msgs`](https://github.com/BumblebeeAS/bb_msgs)
(which provides the `bb_robotx_msgs` package). Only the **vehicle** models
(`bluerov2`, `blueboat`) ship here; the x500 drone is spawned by PX4 SITL (baked
into the image).

## Get the dependencies

Clone this repo into `~/mvsim_ws/src`, then import the external dependencies:

```bash
sudo apt-get update && sudo apt-get install python3-vcstool
cd ~/mvsim_ws
vcs import src < src/examples/multivehicle/examples.repos --recursive
```

`bb_worlds` supplies the worlds and course/environment models (resolved via
`GZ_SIM_RESOURCE_PATH` from its colcon env hooks); `bb_msgs` (pinned to its
`multivehicle_sim` branch, which carries the dashboard's LED/incident interfaces)
supplies `bb_robotx_msgs`; `Micro-XRCE-DDS-Agent` and `px4_msgs` are the ROS↔PX4
bridge and message definitions for the drone; `uav2_offboard`,
`mission_planner_release` and `frames` are the mission stack. `--recursive` is
required for `bb_robotx_dashboard`'s `robocommand` submodule.

## Build the image

```bash
cd ~/mvsim_ws/src/examples/multivehicle
./build.bash
```

This creates `multivehicle_sim:jazzy`.

The Dockerfile is multi-stage: `px4-builder` and `ardupilot-builder` compile PX4
SITL and ArduSub, and the final image copies out only `$PX4_DIR/px4_sitl`, PX4's
`Tools/simulation/gz` model tree, and `/usr/local/bin/ardusub`. 

## Start the container

Install [rocker](https://github.com/osrf/rocker#installation), then:

```bash
cd ~/mvsim_ws/src/examples/multivehicle
./run.bash multivehicle_sim:jazzy          # NVIDIA host
# or, on an Intel/AMD iGPU host:
./run_no_nvidia.bash multivehicle_sim:jazzy
```

## Build the ROS packages

Inside the container:

```bash
cd /root/HOST/mvsim_ws
source /opt/ros/jazzy/setup.bash
colcon build --symlink-install --packages-up-to multivehicle_examples microxrcedds_agent bb_robotx_dashboard
source install/setup.bash
```

(For just the sim, without the dashboard or the missions:
`colcon build --symlink-install --packages-up-to multivehicle_interface multivehicle_sim`.)

## Run

On a hybrid-GPU (NVIDIA) host, enable PRIME render offload in the shell **before**
launching so gz renders on the discrete GPU (otherwise RTF tanks on the iGPU /
llvmpipe). The tmuxp sessions below already do this when `/dev/nvidia0` is present.

```bash
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
```

**Full stack** — sim plus the missions and controllers:

```bash
tmuxp load /root/HOST/mvsim_ws/src/examples/multivehicle/tmuxp/mvsim_debug.yaml
```

**Sim only** — world, all three vehicles, and the dashboard, no example apps:

```bash
tmuxp load /root/HOST/mvsim_ws/src/examples/multivehicle/tmuxp/mvsim.yaml
```

Both sessions **pre-type every command without running it** (`enter: false`), one
window each, so you start them in dependency order and watch each come up.
Nothing works if the world isn't up first: Gazebo owns the spawn for every
vehicle, and PX4 SITL runs with `PX4_GZ_STANDALONE=1` (it attaches to the
already-running gz server rather than starting one).

**Or launch the pieces manually**, each in its own shell in the container:

```bash
# 1. World (Gazebo).
ros2 launch multivehicle_sim world.launch.py world_name:=robotx_2026_sg_river

# 2. BlueROV2 — spawn + ArduSub + MAVROS, then the square-mission tree.
ros2 launch multivehicle_sim bluerov.launch.py
ros2 launch bluerov_tasks bluerov_square_bt.launch.py

# 3. BlueBoat USV — spawn + odom bridge, then the mixer/LOS controller + mission.
ros2 launch multivehicle_sim boat.launch.py
ros2 launch multivehicle_examples boat_control.launch.py use_mission:=true

# 4. PX4 x500 drone — agent, then PX4 SITL (spawns the x500), then its gz bridge,
#    then the offboard demo tree.
MicroXRCEAgent udp4 -p 8888
PX4_GZ_STANDALONE=1 PX4_SYS_AUTOSTART=4010 PX4_UXRCE_DDS_NS=x500 PX4_PARAM_UXRCE_DDS_SYNCT=0 \
  PX4_GZ_MODEL_POSE="47.40,-388.95,3.85,0,0.0" ${PX4_DIR}/px4_sitl/bin/px4 -w ${PX4_DIR}/px4_sitl/romfs -i 1
ros2 launch multivehicle_sim uav_gz.launch.py model_name:=x500_mono_cam_1
ros2 launch multivehicle_examples px4_offboard.launch.py
```

`bluerov.launch.py` includes the autopilot interface from
`multivehicle_interface` (ArduSub SITL + MAVROS + a ground-truth odometry
adapter). Toggle pieces with `ardusub:=false`, `mavros:=false`, or
`odom_source:=none`.

Only the `square` BlueROV mission runs in this sim — the `bin` / `torpedo`
behaviour trees need the vision stack from the [`bluerov`](../bluerov) example
image.

## Example launch files

- BlueROV square mission: `ros2 launch bluerov_tasks bluerov_square_bt.launch.py`
- `boat_control.launch.py`: BlueBoat thrust mixer + LOS waypoint controller
  (+ optional mission node, `use_mission:=true`)
- `px4_offboard.launch.py`: the `uav2_offboard` `offboard_node` action backend +
  the `mission_planner_2` UAV2 offboard demo behaviour tree
  (`uav2_offboard_demo_main.py`) driving it (takeoff → standoff → return → land).
  Per-deployment PX4 topic names and `mav_sys_id` come from
  `config/uav2_offboard_x500.yaml`, overridable via `params_file:=`.

## Dashboard

The dashboard source is pulled by `examples.repos` into `src/bb_robotx_dashboard`.
Inside the container, the one-shot bootstrap (`docker/scripts/setup_dashboard.sh`,
wired into `~/.bashrc`) generates the proto bindings and builds the frontend
against the mounted source. The `dashboard` window of either tmuxp session brings
up the web backend (`http://localhost:8080`) plus the sim-side LED/incident bridges.

That integration launch (`robotx_2026_sim.launch.py`) takes both of its plugin
packages from `bb_worlds`: `bridges_pkg:=robotx_gz` (it imports
`robotx_gz.bridges`, the canonical gz↔ROS bridge helpers, which `bb_worlds`
installs as a top-level Python package) and `models_pkg:=bb_worlds` (the
`robotx26/incident_cube` model and friends).

The sim used to ship a partial fork of those helpers as `multivehicle_sim.bridges`.
It has been removed — it drifted behind `robotx_gz.bridges` and broke the dashboard
launch whenever a new helper was added upstream (`module
'multivehicle_sim.bridges' has no attribute 'clock'`). Always point `bridges_pkg`
at `robotx_gz`.

## Architecture

Who provides what:

| Component | Responsibility |
|-----------|----------------|
| `multivehicle_sim` | Gazebo bringup (world + vehicle spawns), vehicle models (bluerov2, blueboat), and the per-vehicle gz↔ROS bridge configs |
| `multivehicle_interface` | ArduSub SITL + MAVROS bringup and the gz→ROS odometry adapters |
| `multivehicle_examples` | BlueBoat thrust mixer + LOS waypoint controller + mission, and the PX4 offboard launch wrappers |
| `bluerov_tasks` | BlueROV behaviour trees (`square` here; `bin`/`torpedo` need the vision image) |
| `bb_worlds` | The world + course/environment models (placed on `GZ_SIM_RESOURCE_PATH`), plus the `robotx_gz.bridges` helpers the dashboard imports |
| PX4 SITL + `Micro-XRCE-DDS-Agent` + `px4_msgs` | The x500 autopilot + ROS↔PX4 bridge (PX4 baked into the image) |
| `uav2_offboard` + `mission_planner_2` | The drone's action backend and the behaviour-tree framework |
| `bb_robotx_dashboard` + `bb_msgs` | Operator dashboard + its ROS interfaces |

### BlueROV2 (ArduSub)

```
ROS command → MAVROS → ArduSub SITL → ardupilot_gazebo plugin → Gazebo physics
            → ground-truth odometry adapter → MAVROS and TF
```

The gz bridge publishes groundtruth `/bluerov/odom` (+ front camera);
`ground_truth_to_mavros` republishes it to `/mavros/odometry/out` so ArduSub's
EKF has a position source.

### BlueBoat (USV)

```
mission → LOS waypoint controller → thrust mixer
        → /blueboat/thrusters/{left,right}/thrust → Gazebo thrusters → physics
        → /blueboat/odom (groundtruth)
```

No autopilot in the sim — the model, groundtruth odom, and thruster-command
bridge come from `multivehicle_sim`; the mixer and waypoint controller from
`multivehicle_examples`.

### PX4 x500 drone

```
ROS 2 (/x500/fmu/...) ⇄ uXRCE-DDS agent ⇄ PX4 SITL → Gazebo physics
                                          → gz pose bridge → /x500/odom (+ camera)
```

PX4 SITL spawns the x500 into the running world; the agent bridges its uORB
topics to ROS 2; `uav_gz.launch.py` bridges groundtruth pose + camera. The x500
is PX4 SITL instance `-i 1`, hence `mav_sys_id: 2`.

### Dashboard

```
vehicle /…/odom ─┐
                 ├→ robotx_2026_sim bridges → incident markers + LED change_mode (gz)
RoboCommand TCP ─┘→ dashboard backend (FastAPI :8080) → Vue frontend
```

### Notes

- Map poses use ENU; depth below the surface has negative z.
- Host networking is required for the default MAVLink + uXRCE-DDS (UDP 8888) ports.
- ROS namespaces are per-vehicle (`/bluerov/…`, `/blueboat/…`, `/x500/…`).
