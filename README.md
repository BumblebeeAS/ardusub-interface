# Examples

Simulators and the end-to-end missions that run on them.

- [BlueROV with ArduSub](bluerov/README.md) — single-vehicle AUV sim (ROS 2 Humble)
  with the bin / torpedo / square behaviour trees and the vision stack.
- [Multi-vehicle simulation](multivehicle/README.md) — BlueROV2 AUV + BlueBoat USV +
  PX4 x500 drone on the RobotX 2026 Singapore River course (ROS 2 Jazzy), plus the
  operator dashboard.

## BlueROV

https://github.com/user-attachments/assets/6c262df8-bac6-492a-aef1-9e8cfc30d8a8

https://github.com/user-attachments/assets/9a9c25c5-637a-403a-b34d-4048f9afb5e0

## Multi-vehicle

Three vehicles in one Gazebo Harmonic world: a BlueROV2 on ArduSub SITL, a BlueBoat
USV under a LOS waypoint controller, and a PX4 x500 flying an offboard behaviour
tree — with the `bb_robotx_dashboard` operator view on top. Simulator and missions
build into a single image; see [`multivehicle/README.md`](multivehicle/README.md).

## Foxglove Layouts

Import our [Foxglove layouts](https://github.com/BumblebeeAS/controlkitv3/tree/main/foxglove_layouts) for a ready-made view of the relevant topics and services, making it easier to visualize and debug each mission.
