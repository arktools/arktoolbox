cmake_minimum_required(VERSION 2.8)

project(arktoolbox)

# package info
set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 0)
set(CPACK_PACKAGE_VERSION_PATCH 0)
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_GENERATOR "ZIP")
set(CPACK_SOURCE_GENERATOR "ZIP")

# dependencies
set(PLIB_REQUIRED_VERSION                   1.8.5) # joystick 
set(BOOST_REQUIRED_VERSION                  1.4.2) # math

# options
option(WITH_PREFER_STATIC "Prefer static linking." ON)
set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "Build architectures for OSX" FORCE)

# modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(CPack)

# find packages
#   prefer static packages if building static library
if (WITH_PREFER_STATIC)
    set(Boost_USE_STATIC_LIBS ON)
    # prefer static libs
    if(WIN32)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif()
endif()
find_package(PLIB ${PLIB_REQUIRED_VERSION} REQUIRED COMPONENTS js ul)
set(Boost_USE_MULTITHREADED ON)
find_package(Boost ${BOOST_REQUIRED_VERSION} REQUIRED COMPONENTS system thread)
if (APPLE)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    find_library(IOKIT_LIBRARY IOKit)
endif()

# library
add_subdirectory(src)

# install xcos toolbox
install(DIRECTORY "${PROJECT_SOURCE_DIR}/xcos/"
    DESTINATION "."
    COMPONENT xcos
    PATTERN "*.git*" EXCLUDE
    )
