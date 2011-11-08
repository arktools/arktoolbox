project (arkscicos)

# Requried cmake version
cmake_minimum_required (VERSION 2.8.2)

# global needed variables
set(APPLICATION_NAME ${PROJECT_NAME})

# set these for release
set(APPLICATION_VERSION_MAJOR "0")
set(APPLICATION_VERSION_MINOR "3")
set(APPLICATION_VERSION_PATCH "7")
set(ARKOSG_VERSION "0.1.6")
set(ARKMATH_VERSION "0.2.3")
set(ARKCOMM_VERSION "0.1.3")
set(JSBSIM_VERSION "1.100.0")
set(MAVLINK_VERSION "0.9.0")

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

# add macros
include(DefineCMakeDefaults)
include(DefinePlatformDefaults)
include(DefineCompilerFlags)
include(DefineInstallationPaths)
include(FindMAVLINK)
include(FindARKOSG)
include(FindARKMATH)
include(FindARKCOMM)
include(FindJSBSIM)
include(MacroAddPlugin)
include(MacroCopyFile)
include(MacroSetDefault)
include(language_support_v2)
include(MacroAddLinkFlags)
include(ExternalProject)
include(CTest)

# cpack
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "arkTools scicoslab toolbox")
set(CPACK_PACKAGE_VENDOR "arkTools")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "james.goppert@gmail.com")
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING.txt")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.txt")
set(CPACK_PACKAGE_VERSION_MAJOR "${APPLICATION_VERSION_MAJOR}") 
set(CPACK_PACKAGE_VERSION_MINOR "${APPLICATION_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${APPLICATION_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_SOURCE_IGNORE_FILES ${CPACK_SOURCE_IGNORE_FILES}
    /.git/;/build/;~$;.*\\\\.bin$;.*\\\\.swp$)
set(CPACK_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

if(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_SOURCE_GENERATOR "ZIP")
elseif(APPLE)
    set(CPACK_GENERATOR "PackageMaker")
    set(CPACK_SOURCE_GENERATOR "TGZ")
elseif(UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_SOURCE_GENERATOR "TGZ")
else()
    message(FATAL_ERROR "unknown operating system")
endif()
include(CPack)

# disallow in-source build
include(MacroEnsureOutOfSourceBuild)
macro_ensure_out_of_source_build("${PROJECT_NAME} requires an out of source build. 
Please create a separate build directory and run 'cmake /path/to/${PROJECT_NAME} [options]' there.")


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
if(NOT APPLE)
    enable_language(Fortran)
endif()

# add make dist target
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

# install/developer mode
if(DEV_MODE)
    message(STATUS "configuring for in source build")
    set(DATADIR ${PROJECT_SOURCE_DIR}/data)
    set(LIBDIR ${CMAKE_BINARY_DIR}/lib)
    set(BINDIR ${CMAKE_BINARY_DIR}/bin)
    set(EP_DATADIR ${EP_BASE_DIR}/${EP_INSTALL_PREFIX}/share)
else()
    message(STATUS "configuring for install build")
    set(DATADIR ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_NAME}/data)
    set(LIBDIR ${CMAKE_INSTALL_PREFIX}/lib)
    set(BINDIR ${CMAKE_INSTALL_PREFIX}/bin)
    set(EP_DATADIR ${EP_INSTALL_PREFIX}/share)
endif()

# external projects
set(EP_BASE_DIR "${CMAKE_BINARY_DIR}/CMakeExternals")
set_property(DIRECTORY PROPERTY EP_BASE ${EP_BASE_DIR})
set(EP_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}-external)

# find libraries with cmake modules
find_package(SCICOSLAB REQUIRED)
find_package(OpenSceneGraph 2.8.0 COMPONENTS osgGA osgDB osgUtil osgViewer)
find_package(Boost 1.42 REQUIRED COMPONENTS thread-mt system-mt)
find_package(PLIB)
find_package(SIMGEAR)
find_package(LAPACK)
find_or_build_arkcomm(${ARKCOMM_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
find_or_build_arkmath(${ARKMATH_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
find_or_build_arkosg(${ARKOSG_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
find_or_build_jsbsim(${JSBSIM_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
find_or_build_mavlink(${MAVLINK_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})

# initialize list of libraries to build with
set(ARKSCICOS_LIBRARIES "")

# install data files
install(DIRECTORY "${PROJECT_SOURCE_DIR}/projects" DESTINATION share/${PROJECT_NAME} PATTERN "*.git*" EXCLUDE)
install(DIRECTORY "${PROJECT_SOURCE_DIR}/arkscicos-toolbox"
    DESTINATION ${SCICOSLAB_CONTRIB_DIR}
    PATTERN "*.git*" EXCLUDE)

# install required dependencies from external projects
install(DIRECTORY ${EP_BASE_DIR}/${EP_INSTALL_PREFIX} DESTINATION ${CMAKE_INSTALL_PREFIX})

# pkgconfig
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc)
install(FILES
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.pc
    DESTINATION lib/pkgconfig
    )

# subdirectories
add_subdirectory(src)

# vim:sw=4:ts=4:expandtab
