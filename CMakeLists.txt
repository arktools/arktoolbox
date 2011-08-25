project (arkOsg)

# Requried cmake version
cmake_minimum_required (VERSION 2.6)

# global needed variables
set(APPLICATION_NAME ${PROJECT_NAME})

set(APPLICATION_VERSION_MAJOR "0")
set(APPLICATION_VERSION_MINOR "0")
set(APPLICATION_VERSION_PATCH "0")

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
	${CMAKE_SOURCE_DIR}/cmake/arkCMake
)

# add definitions
include(DefineCMakeDefaults)
include(DefinePlatformDefaults)
include(DefineCompilerFlags)
include(DefineInstallationPaths)
include(DefineOptions.cmake)
include(CPackConfig.cmake)

# disallow in-source build
include(MacroEnsureOutOfSourceBuild)
macro_ensure_out_of_source_build("${PROJECT_NAME} requires an out of source build. 
Please create a separate build directory and run 'cmake /path/to/${PROJECT_NAME} [options]' there.")

# add macros
include(MacroAddPlugin)
include(MacroCopyFile)
include(MacroFindOrBuild)
include(MacroSetDefault)
include(language_support_v2)
include(MacroAddLinkFlags)

# settings
MacroSetDefault(IN_SRC_BUILD FALSE)

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

# git submodules
if(IS_DIRECTORY ${PROJECT_SOURCE_DIR}/.git)
	message(STATUS "git repository detected, will attempt to load submodules")
	set(FOUND_GIT_REPO TRUE)
	add_custom_command(OUTPUT GIT.stamp 
		COMMAND cd ${PROJECT_SOURCE_DIR} && git submodule init ${GIT_SUBMODULES}
		COMMAND cd ${PROJECT_SOURCE_DIR} && git submodule update ${GIT_SUBMODULES})
	add_custom_target(GIT DEPENDS GIT.stamp)
else()
	set(FOUND_GIT_REPO FALSE)
endif()

# find libraries with cmake modules
find_package(Qt4)
find_package(Boost 1.40.0 REQUIRED COMPONENTS thread-mt system-mt)
set(QT_USE_QTOPENGL TRUE)
set(QT_USE_QTUITOOLS TRUE)
find_package(OpenGL)
find_package(OpenSceneGraph 2.8.0 COMPONENTS osgGA osgDB osgUtil osgViewer)
if ("OSG_LIBRARY-NOTFOUND" STREQUAL "${OSG_LIBRARY}")
    set(OPENSCENEGRAPH_FOUND FALSE)
else()
    set(OPENSCENEGRAPH_FOUND TRUE)
endif()

# data directory
if(IN_SRC_BUILD)
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

message(STATUS "\tOpenSceneGraph\t${OPENSCENEGRAPH_FOUND}")
if (OPENSCENEGRAPH_FOUND)
endif()

message(STATUS "\tQT4\t\t${QT4_FOUND}")
if (QT4_FOUND)
endif ()

message(STATUS "\tBoost\t\t${Boost_FOUND}")
if (Boost_FOUND)
endif ()



message(STATUS "=================================")

# project wide flags
include_directories( ${PROJECT_SOURCE_DIR}/src ${PROJECT_BINARY_DIR}/src)

# subdirectories
add_subdirectory(src)
