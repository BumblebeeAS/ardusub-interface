from glob import glob

from setuptools import find_packages, setup

package_name = "multivehicle_interface"

setup(
    name=package_name,
    version="0.1.0",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", [f"resource/{package_name}"]),
        (f"share/{package_name}", ["package.xml"]),
        (f"share/{package_name}/config", glob("config/*")),
        (f"share/{package_name}/launch", glob("launch/*.launch.py")),
        (f"share/{package_name}/mavros_params", glob("mavros_params/*")),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="MonkeScripts",
    maintainer_email="shaolianghe0.0@gmail.com",
    description="Autopilot (ArduSub + MAVROS) interface and gz odometry adapters "
    "for the multivehicle simulator",
    license="MIT",
    tests_require=["pytest"],
    entry_points={
        "console_scripts": [
            "ground_truth_to_mavros = multivehicle_interface.ground_truth_to_mavros:main",
            "gz_pose_to_odom = multivehicle_interface.gz_pose_to_odom:main",
            "blueboat_odom_to_tf = multivehicle_interface.blueboat_odom_to_tf:main",
        ],
    },
)
