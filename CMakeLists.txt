project (arkscicos)

# Requried cmake version
cmake_minimum_required (VERSION 2.6)

# global needed variables
set(APPLICATION_NAME ${PROJECT_NAME})

# set these for release
set(APPLICATION_VERSION_MAJOR "0")
set(APPLICATION_VERSION_MINOR "0")
set(APPLICATION_VERSION_PATCH "0")
set(ARKOSG_TAG "master")
set(ARKMATH_TAG "master")
set(ARKCOMM_TAG "master")

set(APPLICATION_VERSION "${APPLICATION_VERSION_MAJOR}.${APPLICATION_VERSION_MINOR}.${APPLICATION_VERSION_PATCH}")
set(LIBRARY_VERSION ${APPLICATION_VERSION})

# SOVERSION scheme: CURRENT.AGE.REVISION
#   If there was an incompatible interface change:
#     Increment CURRENT. Set AGE and REVISION to 0
#   If there was a compatible interface change:
#     Increment AGE. Set REVISION to 0
#   If the source code was changed, but there were no interface changes:
#     Increment REVISION.
set(LIBRARY_SOVERSION "0.0.0")

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/arkcmake
)

# add definitions
include(DefineCMakeDefaults)
include(DefinePlatformDefaults)
include(DefineCompilerFlags)
include(DefineInstallationPaths)

# disallow in-source build
include(MacroEnsureOutOfSourceBuild)
macro_ensure_out_of_source_build("${PROJECT_NAME} requires an out of source build. 
Please create a separate build directory and run 'cmake /path/to/${PROJECT_NAME} [options]' there.")

# add macros
include(MacroAddPlugin)
include(MacroCopyFile)
include(MacroSetDefault)
include(language_support_v2)
include(MacroAddLinkFlags)
include(ExternalProject)
include(CTest)

# settings
option(DEV_MODE "Setup paths for developer testing." OFF)
option(BUILD_SHARED_LIBS "Build shared libraries instead of static." OFF)

# built variables
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

# set build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif(NOT CMAKE_BUILD_TYPE)

# enable languages
enable_language(C)
enable_language(CXX)

# add make dist target
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

# find libraries with cmake modules
find_package(ARKOSG)
find_package(ARKCOMM)
find_package(ARKMATH)
find_package(Boost 1.40.0 REQUIRED COMPONENTS thread-mt system-mt)

# external projects
set(EP_BASE_DIR "${CMAKE_BINARY_DIR}/CMakeExternals")
set_property(DIRECTORY PROPERTY EP_BASE ${EP_BASE_DIR})

if( NOT ARKCOMM_FOUND)
    ExternalProject_Add(arkcomm
        GIT_REPOSITORY "git://github.com/arktools/arkcomm.git"
        GIT_TAG ${ARKCOMM_TAG}
        )
    set(ARKCOMM_FOUND true)
endif()

if( NOT ARKOSG_FOUND)
    ExternalProject_Add(arkosg
        GIT_REPOSITORY "git://github.com/arktools/arkosg.git"
        GIT_TAG ${ARKOSG_TAG} 
        )
    set(ARKOSG_FOUND true)
endif()

if( NOT ARKMATH_FOUND)
    ExternalProject_Add(arkmath
        GIT_REPOSITORY "git://github.com/arktools/arkmath.git"
        GIT_TAG ${ARKMATH_TAG} 
        )
    set(ARKMATH_FOUND true)
endif()

# data directory
if(DEV_MODE)
    message(STATUS "configuring for in source build")
    set(DATADIR ${PROJECT_SOURCE_DIR}/data)
    set(LIBDIR ${CMAKE_BINARY_DIR}/bin)
    set(BINDIR ${CMAKE_BINARY_DIR}/bin)
else()
    message(STATUS "configuring for install build")
    set(DATADIR ${CMAKE_INSTALL_PREFIX}/share/mavsim/data)
    set(LIBDIR ${CMAKE_INSTALL_PREFIX}/lib)
    set(BINDIR ${CMAKE_INSTALL_PREFIX}/bin)
endif()

# install data files
install(DIRECTORY "${PROJECT_SOURCE_DIR}/data"
    DESTINATION share/mavsim
    PATTERN "*.git*" EXCLUDE)

# pkgconfig
install(FILES
    ${PROJECT_NAME}.pc
    DESTINATION lib/pkgconfig
    )

#
# internal library list definition / dep summary
message(STATUS "=================================")
message(STATUS "\tLIBRARY\t\tBUILDING")
message(STATUS "=================================")

message(STATUS "\tARKCOMM\t\t${ARKCOMM_FOUND}")
if (ARKCOMM_FOUND)
endif()

message(STATUS "\tARKOSG\t\t${ARKOSG_FOUND}")
if (ARKOSG_FOUND)
endif()

message(STATUS "\tARKMATH\t\t${ARKMATH_FOUND}")
if (ARKMATH_FOUND)
endif()

message(STATUS "=================================")

# project wide flags
include_directories( ${PROJECT_SOURCE_DIR}/src ${PROJECT_BINARY_DIR}/src)

# subdirectories
add_subdirectory(src)

# vim:sw=4:ts=4:expandtab
