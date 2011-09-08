project (arkscicos)

# Requried cmake version
cmake_minimum_required (VERSION 2.8.2)

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

# cpack
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "arkTools scicoslab toolbox")
set(CPACK_PACKAGE_VENDOR "arkTools")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "james.goppert@gmail.com")
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")
set(CPACK_PACKAGE_VERSION_MAJOR "${APPLICATION_VERSION_MAJOR}") 
set(CPACK_PACKAGE_VERSION_MINOR "${APPLICATION_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${APPLICATION_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_SOURCE_IGNORE_FILES ${CPACK_SOURCE_IGNORE_FILES}
	/.git/;/build/;~$;.*\\\\.bin$;.*\\\\.swp$)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README")
set(CPACK_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
# find libraries with cmake modules

find_package(SCICOSLAB REQUIRED)
find_package(OpenSceneGraph 2.8.0 COMPONENTS osgGA osgDB osgUtil osgViewer)
find_package(SIMGEAR)
find_package(PLIB)
find_package(LAPACK)
find_package(ARKOSG)
find_package(ARKCOMM)
find_package(ARKMATH)
find_package(JSBSIM)
find_package(MAVLINK)
find_package(Boost 1.42 REQUIRED COMPONENTS thread-mt system-mt)

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
#if(WIN32 and not UNIX)
  ## There is a bug in NSI that does not handle full unix paths properly. Make
  ## sure there is at least one set of four (4) backlasshes.
  #set(CPACK_PACKAGE_ICON "${CMake_SOURCE_DIR}/Utilities/Release\\\\InstallIcon.bmp")
  #set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\MyExecutable.exe")
  #set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_INSTALL_DIRECTORY} ${PROJECT_NAME}")
  #set(CPACK_NSIS_HELP_LINK "http:\\\\\\\\www.my-project-home-page.org")
  #set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\www.my-personal-home-page.com")
  #set(CPACK_NSIS_CONTACT "me@my-personal-home-page.com")
  #set(CPACK_NSIS_MODIFY_PATH ON)
#else(WIN32 and not UNIX)
  #set(CPACK_STRIP_FILES "bin/MyExecutable")
  #set(CPACK_SOURCE_STRIP_FILES "")
#endif(WIN32 and not UNIX)
#set(CPACK_PACKAGE_EXECUTABLES "MyExecutable" "My Executable")
include(CPack)

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
enable_language(Fortran)

# add make dist target
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

# find libraries with cmake modules
find_package(SCICOSLAB REQUIRED)
find_package(OpenSceneGraph 2.8.0 COMPONENTS osgGA osgDB osgUtil osgViewer)
find_package(SIMGEAR)
find_package(PLIB)
find_package(LAPACK)
find_package(ARKOSG)
find_package(ARKCOMM)
find_package(ARKMATH)
find_package(JSBSIM)
find_package(MAVLINK)
find_package(Boost 1.42 REQUIRED COMPONENTS thread-mt system-mt)

# external projects
set(EP_BASE_DIR "${CMAKE_BINARY_DIR}/CMakeExternals")
set_property(DIRECTORY PROPERTY EP_BASE ${EP_BASE_DIR})

if( NOT MAVLINK_FOUND)
    ExternalProject_Add(mavlink
        GIT_REPOSITORY "git://github.com/pixhawk/mavlink.git"
        GIT_TAG ${MAVLINK_TAG}
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND ""
        UPDATE_COMMAND ""
		BUILD_IN_SOURCE 1
	)
	set(MAVLINK_FOUND TRUE)
	set(MAVLINK_INCLUDE_DIRS ${EP_BASE_DIR}/Source/mavlink/include)
endif()

if(NOT ARKCOMM_FOUND)
    set(ARKCOMM_INSTALL_DIR ${EP_BASE_DIR}/InstallRoot${CMAKE_INSTALL_PREFIX})
    ExternalProject_Add(arkcomm
        GIT_REPOSITORY "git://github.com/arktools/arkcomm.git"
        GIT_TAG ${ARKCOMM_TAG}
        UPDATE_COMMAND ""
        INSTALL_DIR ${ARKCOMM_INSTALL_DIR}
        INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR}/InstallRoot install
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )
    set(ARKCOMM_INCLUDE_DIRS ${ARKCOMM_INSTALL_DIR}/include)
    if(WIN32)
        set(ARKCOMM_LIBRARIES ${ARKCOMM_INSTALL_DIR}/lib/arkcomm.a)
    elseif(APPLE)
        set(ARKCOMM_LIBRARIES ${ARKCOMM_INSTALL_DIR}/lib/libarkcomm.a)
    elseif(UNIX)
        set(ARKCOMM_LIBRARIES ${ARKCOMM_INSTALL_DIR}/lib/libarkcomm.a)
    else()
        message(FATAL_ERROR "unknown operating system")
    endif()
    set(ARKCOMM_FOUND TRUE)
endif()

if(NOT ARKOSG_FOUND)
    set(ARKOSG_INSTALL_DIR ${EP_BASE_DIR}/InstallRoot${CMAKE_INSTALL_PREFIX})
    ExternalProject_Add(arkosg
        GIT_REPOSITORY "git://github.com/arktools/arkosg.git"
        GIT_TAG ${ARKOSG_TAG} 
        UPDATE_COMMAND ""
        INSTALL_DIR ${ARKOSG_INSTALL_DIR}
        INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR}/InstallRoot install
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )
    set(ARKOSG_INCLUDE_DIRS ${ARKOSG_INSTALL_DIR}/include)
    if(WIN32)
        set(ARKOSG_LIBRARIES ${ARKOSG_INSTALL_DIR}/lib/arkosg.a)
    elseif(APPLE)
        set(ARKOSG_LIBRARIES ${ARKOSG_INSTALL_DIR}/lib/libarkosg.a)
    elseif(UNIX)
        set(ARKOSG_LIBRARIES ${ARKOSG_INSTALL_DIR}/lib/libarkosg.a)
    else()
        message(FATAL_ERROR "unknown operating system")
    endif()
    set(ARKOSG_FOUND TRUE)
endif() 

if(NOT ARKMATH_FOUND)
    set(ARKMATH_INSTALL_DIR ${EP_BASE_DIR}/InstallRoot${CMAKE_INSTALL_PREFIX})
    ExternalProject_Add(arkmath
        GIT_REPOSITORY "git://github.com/arktools/arkmath.git"
        GIT_TAG ${ARKMATH_TAG} 
        UPDATE_COMMAND ""
        INSTALL_DIR ${ARKMATH_INSTALL_DIR}
        INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR}/InstallRoot install
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )
    set(ARKMATH_INCLUDE_DIRS ${ARKMATH_INSTALL_DIR}/include)
    set(ARKMATH_DATA_DIR ${ARKMATH_INSTALL_DIR}/share/arkmath/data)
    if(WIN32)
        set(ARKMATH_LIBRARIES ${ARKMATH_INSTALL_DIR}/lib/arkmath.a)
    elseif(APPLE)
        set(ARKMATH_LIBRARIES ${ARKMATH_INSTALL_DIR}/lib/libarkmath.a)
    elseif(UNIX)
        set(ARKMATH_LIBRARIES ${ARKMATH_INSTALL_DIR}/lib/libarkmath.a)
    else()
        message(FATAL_ERROR "unknown operating system")
    endif()
    set(ARKMATH_FOUND TRUE)
endif()

if(NOT JSBSIM_FOUND)
    set(JSBSIM_INSTALL_DIR ${EP_BASE_DIR}/InstallRoot${CMAKE_INSTALL_PREFIX})
    ExternalProject_Add(jsbsim
        GIT_REPOSITORY "git://github.com/jgoppert/jsbsim.git"
        GIT_TAG ${JSBSIM_TAG} 
        UPDATE_COMMAND ""
        INSTALL_DIR ${JSBSIM_INSTALL_DIR}
        INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR}/InstallRoot install
        CONFIGURE_COMMAND ${EP_BASE_DIR}/Source/jsbsim/autogen.sh --enable-libraries --prefix=${CMAKE_INSTALL_PREFIX}
        BUILD_COMMAND make -j4
        BUILD_IN_SOURCE 1
        )
    set(JSBSIM_INCLUDE_DIRS ${JSBSIM_INSTALL_DIR}/include ${JSBSIM_INSTALL_DIR}/include/JSBSim)
    set(JSBSIM_DATA_DIR ${JSBSIM_INSTALL_DIR}/share/jsbsim)
    if(WIN32)
        set(JSBSIM_LIBRARIES ${JSBSIM_INSTALL_DIR}/lib/JSBSim.a)
    elseif(APPLE)
        set(JSBSIM_LIBRARIES ${JSBSIM_INSTALL_DIR}/lib/libJSBSim.a)
    elseif(UNIX)
        set(JSBSIM_LIBRARIES ${JSBSIM_INSTALL_DIR}/lib/libJSBSim.a)
    else()
        message(FATAL_ERROR "unknown operating system")
    endif()
    set(JSBSIM_FOUND TRUE)
endif()

set(ARKSCICOS_LIBRARIES "")


# data directory
if(DEV_MODE)
    message(STATUS "configuring for in source build")
    set(DATADIR ${PROJECT_SOURCE_DIR}/data)
    set(LIBDIR ${CMAKE_BINARY_DIR}/bin)
    set(BINDIR ${CMAKE_BINARY_DIR}/bin)
else()
    message(STATUS "configuring for install build")
    set(DATADIR ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_NAME}/data)
    set(LIBDIR ${CMAKE_INSTALL_PREFIX}/lib)
    set(BINDIR ${CMAKE_INSTALL_PREFIX}/bin)
endif()

# install data files
#install(DIRECTORY "${PROJECT_SOURCE_DIR}/data" DESTINATION share/${PROJECT_NAME} PATTERN "*.git*" EXCLUDE)

install(DIRECTORY "${PROJECT_SOURCE_DIR}/arkscicos-toolbox"
    DESTINATION ${SCICOSLAB_CONTRIB_DIR}
	PATTERN "*.git*" EXCLUDE)

# install required external projects
install(DIRECTORY "${EP_BASE_DIR}/InstallRoot/${CMAKE_INSTALL_PREFIX}/include" DESTINATION ${CMAKE_INSTALL_PREFIX})
install(DIRECTORY "${EP_BASE_DIR}/InstallRoot/${CMAKE_INSTALL_PREFIX}/lib" DESTINATION ${CMAKE_INSTALL_PREFIX})
install(DIRECTORY "${EP_BASE_DIR}/InstallRoot/${CMAKE_INSTALL_PREFIX}/share" DESTINATION ${CMAKE_INSTALL_PREFIX})

# pkgconfig
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc)
install(FILES
	${PROJECT_BINARY_DIR}/${PROJECT_NAME}.pc
	DESTINATION lib/pkgconfig
	)

# subdirectories
add_subdirectory(src)

# vim:sw=4:ts=4:expandtab
