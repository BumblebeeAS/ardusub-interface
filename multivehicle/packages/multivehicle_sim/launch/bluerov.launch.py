import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import (
    DeclareLaunchArgument,
    IncludeLaunchDescription,
    LogInfo,
    RegisterEventHandler,
    OpaqueFunction,
)
from launch.event_handlers import OnProcessExit
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def launch_setup(context, *args, **kwargs):
    """Spawn the BlueROV2 into an already-running Gazebo world.

    The world itself is started separately by ``world.launch.py``. Here we only
    spawn the vehicle, bring up its ROS<->gz bridge, and include the autopilot
    interface (ArduSub SITL + MAVROS + odom adapter) from the
    ``multivehicle_interface`` package. The interface launch derives the ArduSub
    home from the world's <spherical_coordinates> via GZ_SIM_RESOURCE_PATH.
    """

    pkg_multivehicle_sim = get_package_share_directory("multivehicle_sim")
    bluerov_gz_bridge_config_file = os.path.join(
        pkg_multivehicle_sim, "config", "bluerov_gz_bridge.yaml"
    )

    use_sim_time = LaunchConfiguration("use_sim_time")
    namespace = LaunchConfiguration("namespace")
    world_name = LaunchConfiguration("world_name")
    launch_ardusub = LaunchConfiguration("ardusub")
    launch_mavros = LaunchConfiguration("mavros")
    odom_source = LaunchConfiguration("odom_source")

    x = LaunchConfiguration("x")
    y = LaunchConfiguration("y")
    z = LaunchConfiguration("z")
    roll = LaunchConfiguration("roll")
    pitch = LaunchConfiguration("pitch")
    yaw = LaunchConfiguration("yaw")

    description_file = PathJoinSubstitution(
        [
            FindPackageShare("multivehicle_sim"),
            "models",
            "bluerov2",
            "model.sdf",
        ]
    )

    # Attach the vehicle to the running world via `ros_gz_sim create`.
    gz_spawner = Node(
        package="ros_gz_sim",
        executable="create",
        arguments=[
            "-name",
            namespace,
            "-file",
            description_file,
            "-x",
            x,
            "-y",
            y,
            "-z",
            z,
            "-R",
            roll,
            "-P",
            pitch,
            "-Y",
            yaw,
        ],
        output="both",
        parameters=[{"use_sim_time": use_sim_time}],
    )

    spawn_exit_handler = RegisterEventHandler(
        OnProcessExit(
            target_action=gz_spawner,
            on_exit=LogInfo(msg="Robot Model Spawn Process Finished"),
        )
    )

    gz_bridge = Node(
        package="ros_gz_bridge",
        executable="parameter_bridge",
        name="bluerov_gz_bridge",
        parameters=[{"config_file": bluerov_gz_bridge_config_file}],
    )

    # Autopilot interface: ArduSub SITL + MAVROS (+ ground_truth odom adapter),
    # provided by the multivehicle_interface package.
    ardusub_interface_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            [
                PathJoinSubstitution(
                    [
                        FindPackageShare("multivehicle_interface"),
                        "launch",
                        "ardusub_interface.launch.py",
                    ]
                )
            ]
        ),
        launch_arguments=[
            ("ardusub", launch_ardusub),
            ("mavros", launch_mavros),
            ("use_sim_time", use_sim_time),
            ("world_name", world_name),
            ("odom_source", odom_source),
        ],
    )

    return [
        gz_spawner,
        spawn_exit_handler,
        gz_bridge,
        ardusub_interface_launch,
    ]


def generate_launch_description():
    args = [
        DeclareLaunchArgument(
            "use_sim_time",
            default_value="true",
            description="Flag to indicate whether to use simulation time",
        ),
        DeclareLaunchArgument(
            "world_name",
            default_value="robotx_2026_sg_river",
            description="World the vehicle is spawned into; used by the interface "
            "launch to derive the ArduSub home coordinates (the world is launched "
            "by world.launch.py)",
        ),
        DeclareLaunchArgument(
            "namespace",
            default_value="bluerov",
            description="Namespace",
        ),
        DeclareLaunchArgument(
            "x",
            default_value="47.824",
            description="Initial x position (default incident-zone centre)",
        ),
        DeclareLaunchArgument(
            "y",
            default_value="-415.373",
            description="Initial y position (default incident-zone centre)",
        ),
        DeclareLaunchArgument(
            "z",
            default_value="0.0",
            description="Initial z position",
        ),
        DeclareLaunchArgument(
            "roll",
            default_value="0.0",
            description="Initial roll angle",
        ),
        DeclareLaunchArgument(
            "pitch",
            default_value="0.0",
            description="Initial pitch angle",
        ),
        DeclareLaunchArgument(
            "yaw",
            default_value="0.0",
            description="Initial yaw angle",
        ),
        DeclareLaunchArgument(
            "ardusub", default_value="true", description="Launch ArduSUB?"
        ),
        DeclareLaunchArgument(
            "mavros", default_value="true", description="Launch mavros?"
        ),
        DeclareLaunchArgument(
            "odom_source",
            default_value="ground_truth",
            description="Odometry adapter for MAVROS: ground_truth or none",
        ),
    ]

    return LaunchDescription(args + [OpaqueFunction(function=launch_setup)])
