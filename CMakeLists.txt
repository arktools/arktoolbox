cmake_minimum_required(VERSION 2.8)

project(arktoolbox)

# modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(CPack)
enable_testing()

find_package(ARKTOOLS)
