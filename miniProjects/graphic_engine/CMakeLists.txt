cmake_minimum_required(VERSION 3.0.0)
project(graphic_thing VERSION 0.1.0 LANGUAGES C CXX)

include(CTest)
enable_testing()

add_executable(graphic_thing simple_image_output.cpp)

set_property(TARGET graphic_thing PROPERTY CXX_STANDARD 17)