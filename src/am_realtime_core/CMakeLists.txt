cmake_minimum_required(VERSION 3.8)
project(am_realtime_core)

if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)

include_directories(include)

add_executable(am_preempt_rt_core src/preempt_rt_loop.cpp)
target_link_libraries(am_preempt_rt_core rclcpp::rclcpp std_msgs::ament_cmake rt) # Links rt library for shared memory

install(TARGETS am_preempt_rt_core
  DESTINATION lib/${PROJECT_NAME})

ament_package()
