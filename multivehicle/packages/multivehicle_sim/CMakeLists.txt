cmake_minimum_required(VERSION 3.12.2)
project(multivehicle_sim)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)

ament_python_install_package(${PROJECT_NAME})

install(DIRECTORY launch config models
  DESTINATION share/${PROJECT_NAME})

ament_environment_hooks(hooks/setup.dsv)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
