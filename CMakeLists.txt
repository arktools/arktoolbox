project (arkscicos C CXX)

# Requried cmake version
cmake_minimum_required (VERSION 2.8)
set(PROJECT_VERSION_MAJOR "0")
set(PROJECT_VERSION_MINOR "6")
set(PROJECT_VERSION_PATCH "1")
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(PROJECT_CONTACT_EMAIL james.goppert@gmail.com)
set(PROJECT_CONTACT_VENDOR arktools)
set(LIBRARY_VERSION ${PROJECT_VERSION})
set(LIBRARY_SOVERSION "0.0.0")

# third party
set(ARKMATH_VERSION "3035f67907946ca2b6ecb75eff6d550c8dbd55d7")
set(JSBSIM_VERSION "3f2acf03ccda7e6c4dbfeaa0ff94661e639361de")
set(ARKHANGAR_VERSION "909b552cfec0f99d67fcaee3afd9cd5e4a677523")
set(ARKOSG_VERSION "3118cc88ea63524f5ba75466abc7af601ce422ec")
set(ARKCOMM_VERSION "0c224b528ede947d410d9a56e2b7a47d6ae86048")

# options
option(WITH_BUILD_DEPS "Build dependencies." OFF)
option(WITH_PREFER_STATIC "Build preferring static linking." ON)
option(WITH_ARKOSG "Build arkosg graphics." OFF)
option(WITH_LAPACK "Use lapack libraries." OFF)
option(WITH_SCICOS_VERIFY "Verify scicos library loads correctly." OFF)

# variables
set(ROOT_THREAD TRUE CACHE INTERNAL "Is this the top level of the recursion?")
set(INSTALLED_TARGETS "")

# modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/arkcmake
    )
if (WITH_LAPACK)
    include(language_support_v2)
    enable_language(Fortran)
endif()
include(BundleUtilities)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckLibraryExists)
#include(CheckTypeSize)
#include(CheckPrototypeExists)
#include(CheckCXXSourceCompiles)
#include(CheckCSourceCompiles)
include(ExternalProject)
include(FindARKOSG)
include(FindARKMATH)
include(FindARKCOMM)
include(FindJSBSIM)
include(FindARKHANGAR)

# spawn new cmake to build deps
if (WITH_BUILD_DEPS AND ROOT_THREAD)
    execute_process(COMMAND ${CMAKE_COMMAND} "${CMAKE_SOURCE_DIR}"
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
        "-DEP_BASE_DIR=${EP_BASE_DIR}"
        "-DWITH_BUILD_DEPS=${WITH_BUILD_DEPS}"
        "-DWITH_PREFER_STATIC=${WITH_PREFER_STATIC}"
        "-DWITH_ARKOSG=${WITH_ARKOSG}"
        "-DWITH_LAPACK=${WITH_LAPACK}"
        "-DWITH_SCICOS_VERIFY=${WITH_SCICOS_VERIFY}"
        "-DROOT_THREAD=FALSE"
        RESULT_VARIABLE ERROR)
    if (ERROR)
        message(FATAL_ERROR "error, recursing loop returned error code: ${ERROR}")
    endif()
    message("** Making dependencies")
    execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} "-j4" "-f${CMAKE_BINARY_DIR}/Makefile")
    message("** Configuring ${PROJECT_NAME}")
endif()

# external projects find path
if(NOT EP_BASE_DIR)
    set(EP_BASE_DIR "${CMAKE_BINARY_DIR}/CMakeExternals")
endif()
list(APPEND CMAKE_FIND_ROOT_PATH ${EP_BASE_DIR})

# prefer static packages if building static library
message("** Finding libraries")
if (WITH_PREFER_STATIC)
    set(BOOST_USE_STATIC_LIBS ON)
    # prefer static libs
    if(WIN32)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif()
endif()

# find libraries with cmake modules
set(REQUIRED_IF_ROOT_THREAD)
if (ROOT_THREAD)
    set(REQUIRED_IF_ROOT_THREAD "REQUIRED")
endif()
find_package(SCICOSLAB)
if (NOT SCICOSLAB_FOUND)
    set(SCICOSLAB_FOUND TRUE)
    set(SCICOSLAB_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/src/scicoslab)
    if(UNIX)
        set(SCICOSLAB_CONTRIB_DIR "/usr/lib/scicoslab-gtk-4.4.1/contrib")
    elseif(WIN32)
        set(SCICOSLAB_CONTRIB_DIR "C:/Program\ Files/scicoslab-4.4.1/contrib")
    endif()
endif()
if (MSVC)
    set(Boost_USE_MULITHREADED ON)
    find_package(Boost 1.42 COMPONENTS thread system REQUIRED)
elseif(MINGW)
    find_package(Boost 1.42 COMPONENTS thread_win32-mt system-mt REQUIRED)
else()
    find_package(Boost 1.42 COMPONENTS thread-mt system-mt REQUIRED)
endif()
if (WITH_LAPACK)
    find_package(LAPACK REQUIRED)
endif()
if (WITH_ARKOSG)
    find_package(OpenSceneGraph 2.8.0 REQUIRED COMPONENTS osgViewer osgUtil osgDB osgGA osgManipulator)

    # find osg ac plugin
    get_filename_component(OSG_LIBRARY_ROOT "${OSG_LIBRARY}" PATH)
    find_library(OSG_AC
        NAMES osgdb_ac
        PATHS ${OSG_LIBRARY_ROOT}/osgPlugins-${OPENSCENEGRAPH_VERSION}
        )
    find_library(OSG_RGB
        NAMES osgdb_rgb
        PATHS ${OSG_LIBRARY_ROOT}/osgPlugins-${OPENSCENEGRAPH_VERSION}
        )
    set(OSG_PLUGINS_PROCESS_LIBS OSG_AC OSG_RGB)
    set(OSG_PLUGINS_PROCESS_INCLUDES)
    libfind_process(OSG_PLUGINS)

    find_package(OpenGL REQUIRED)
    find_package(ARKOSG ${REQUIRED_IF_ROOT_THREAD})
endif()
find_package(ARKCOMM ${REQUIRED_IF_ROOT_THREAD})
find_package(ARKMATH ${REQUIRED_IF_ROOT_THREAD})
find_package(ARKHANGAR ${REQUIRED_IF_ROOT_THREAD})
find_package(JSBSIM ${REQUIRED_IF_ROOT_THREAD})

# build dependencies
if (WITH_BUILD_DEPS AND (NOT ROOT_THREAD) )
    message("** Configuring dependencies")

    # add external projects 
    set(CMAKE_EP_DEFAULT_ARGS
        -DEP_BASE_DIR=${EP_BASE_DIR}
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )

    if (WITH_ARKOSG AND (NOT ARKOSG_FOUND))
        ExternalProject_Add(arkosg
            GIT_REPOSITORY "git://github.com/arktools/arkosg.git"
            GIT_TAG ${TAG}
            UPDATE_COMMAND ""
            INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_BASE_DIR} install
        )
    endif()

    if (NOT ARKHANGAR_FOUND)
        ExternalProject_Add(arkhangar
            GIT_REPOSITORY "git://github.com/arktools/arkhangar.git"
            GIT_TAG ${TAG}
            UPDATE_COMMAND ""
            INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR} install
        )
    endif()

    if (NOT ARKMATH_FOUND)
        ExternalProject_Add(arkmath
            GIT_REPOSITORY "git://github.com/arktools/arkmath.git"
            GIT_TAG ${TAG}
            UPDATE_COMMAND ""
            INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_BASE_DIR} install
           )
    endif()

    if (NOT ARKCOMM_FOUND)
        ExternalProject_Add(arkcomm
            GIT_REPOSITORY "git://github.com/arktools/arkcomm.git"
            GIT_TAG ${TAG}
            UPDATE_COMMAND ""
            INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_BASE_DIR} install
           )
    endif()

    if (NOT JSBSIM_FOUND)
        ExternalProject_Add(jsbsim
            GIT_REPOSITORY "git://github.com/jgoppert/jsbsim.git"
            GIT_TAG ${TAG}
            UPDATE_COMMAND ""
            INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_BASE_DIR} install
            )
    endif()

    # terminate non root cmake thread
    return()
endif()

# configure
#check_include_files(string.h HAVE_STRING_H)
#check_function_exists(memcopy HAVE_MEMCOPY)
#check_symbol_exists(LC_MESSAGES "locale.h" HAVE_LC_MESSAGES) 
#check_library_exists(arkosg  attachNode "" HAVE_ARKOSG)

# config files
set(INSTALL_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/arkscicos")
configure_file(src/config.h.in src/config.h)

# build settings
set(ARKSCICOS_LIBRARIES)
if (WITH_PREFER_STATIC OR MINGW)
    add_definitions(-DOSG_LIBRARY_STATIC)
endif()
if (WITH_ARKOSG)
    list(APPEND ARKSCICOS_LIBRARIES ${OSG_PLUGINS_LIBRARIES})
endif()

include_directories(
    ${CMAKE_SOURCE_DIR}/src 
    ${CMAKE_BINARY_DIR}/src
	${SCICOSLAB_INCLUDE_DIRS}
	${JSBSIM_INCLUDE_DIRS} 
	${Boost_INCLUDE_DIRS}
	${ARKCOMM_INCLUDE_DIRS}
	${ARKMATH_INCLUDE_DIRS}
	${ARKOSG_INCLUDE_DIRS}
	)

if (JSBSIM_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${JSBSIM_LIBRARIES})
endif()
if (ARKOSG_FOUND)
	list(APPEND ARKSCICOS_LIBRARIES ${ARKOSG_LIBRARIES})
endif()
if (OPENSCENEGRAPH_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${OPENSCENEGRAPH_LIBRARIES})
    list(APPEND ARKSCICOS_LIBRARIES ${OPENGL_LIBRARIES})
endif()
if (ARKMATH_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${ARKMATH_LIBRARIES})
endif()
if (LAPACK_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${LAPACK_LIBRARIES})
endif()
if (ARKCOMM_FOUND)
	list(APPEND ARKSCICOS_LIBRARIES ${ARKCOMM_LIBRARIES})
endif()
if (Boost_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${Boost_LIBRARIES})
endif()

set(ARKSCICOS_SRCS "")
set(SCICOSLAB_BLOCKS "")

list(APPEND SCICOSLAB_BLOCKS "mavlinkBlocks")
list(APPEND ARKSCICOS_SRCS
    src/sci_mavlinkHilSensor.cpp
    src/sci_mavlinkHilState.cpp
    src/sci_mavlinkHilTracker.cpp
)

list(APPEND SCICOSLAB_BLOCKS "mathBlocks")
list(APPEND ARKSCICOS_SRCS
    src/sci_euler2Dcm.cpp
    src/sci_waypointGuidance.cpp
    src/sci_quat2EulerDcm.cpp
    src/sci_insErrorDynamics.cpp
    src/sci_insDynamics.cpp
    src/sci_geoMag.cpp
    src/sci_magMeasModel.cpp
    src/sci_gpsMeasModel.cpp
    src/sci_eom6Dof.cpp
    src/sci_navigationEquations.cpp
    src/definitions.cpp
    src/sci_invPend.cpp
    src/utilities.cpp
    src/sci_zeroOrderHold.cpp
    src/sci_randn.cpp
    src/sci_quadForceMoments.cpp
)

list(APPEND SCICOSLAB_BLOCKS "lapackBlocks")
list(APPEND ARKSCICOS_SRCS
    src/sci_gpsIns.cpp
)

list(APPEND SCICOSLAB_BLOCKS "osgBlocks")
list(APPEND ARKSCICOS_SRCS
    src/osgPlugins.cpp
    src/sci_jet.cpp
    src/sci_plane.cpp
    src/sci_car.cpp
    src/sci_quad.cpp
    src/sci_sailboat.cpp
    src/sci_vector.cpp
)

list(APPEND SCICOSLAB_BLOCKS "jsbsimBlocks")
list(APPEND ARKSCICOS_SRCS
    src/sci_jsbsimTrim.cpp
    src/sci_jsbsimComm.cpp
)

set(CMAKE_C_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_CXX_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_LD_FLAGS "-lpthread -Wl,-flat_namespace,-undefined,suppress")

add_library(arkscicos MODULE ${ARKSCICOS_SRCS})
add_dependencies(arkscicos arkcomm arkmath arkhangar arkosg jsbsim)
target_link_libraries(arkscicos ${ARKSCICOS_LIBRARIES})
set_target_properties(arkscicos PROPERTIES
    SOVERSION ${LIBRARY_SOVERSION}
    VERSION ${LIBRARY_VERSION}
    )

if (UNIX AND WITH_SCICOS_VERIFY)
	# if using unix add script to see if scicoslab toolbox builds correctly
	add_custom_target(toolbox ALL
		DEPENDS arkscicos
		COMMAND cd ${PROJECT_SOURCE_DIR}/arkscicos-toolbox && ./build.sh)
endif()

get_target_property(ARKSCICOS_SCICOS_LOCATION arkscicos LOCATION)

configure_file(src/loadscicos.sce.in ${CMAKE_BINARY_DIR}/src/loadscicos.sce)
configure_file(src/VERSION.in ${CMAKE_SOURCE_DIR}/arkscicos-toolbox/VERSION)

install(FILES ${CMAKE_BINARY_DIR}/src/loadscicos.sce DESTINATION
	${SCICOSLAB_CONTRIB_DIR}/arkscicos-toolbox/scicos COMPONENT Runtime)

install(TARGETS arkscicos DESTINATION lib COMPONENT Runtime)

install(FILES
    src/definitions.hpp
    src/utilities.hpp
	DESTINATION include/arkscicos
    COMPONENT Runtime
    )

# install data files
install(DIRECTORY "${PROJECT_SOURCE_DIR}/projects" DESTINATION share/arkscicos
    COMPONENT Runtime 
    PATTERN "*.git*" EXCLUDE
    )
install(DIRECTORY "${PROJECT_SOURCE_DIR}/arkscicos-toolbox"
    DESTINATION ${SCICOSLAB_CONTRIB_DIR}
    COMPONENT Runtime
    PATTERN "*.git*" EXCLUDE
    )

if (WITH_ARKOSG)
    install(DIRECTORY "${ARKOSG_DATA_DIR}/arkosg"
        DESTINATION share/arkscicos
        COMPONENT Runtime
        PATTERN "*.git*" EXCLUDE
        )
endif()

install(DIRECTORY "${ARKMATH_DATA_DIR}/arkmath"
        DESTINATION share/arkscicos
        COMPONENT Runtime
        PATTERN "*.git*" EXCLUDE
        )

install(DIRECTORY "${ARKHANGAR_DATA_DIR}/arkhangar"
        DESTINATION share/arkscicos
        COMPONENT Runtime
        PATTERN "*.git*" EXCLUDE
        )

install(DIRECTORY "${JSBSIM_DATA_DIR}/jsbsim"
        DESTINATION share/arkscicos
        COMPONENT Runtime
        PATTERN "*.git*" EXCLUDE
        )

# install
install(TARGETS  ${INSTALLED_TARGETS}
    RUNTIME DESTINATION "bin" COMPONENT Runtime
    LIBRARY DESTINATION "lib" COMPONENT Runtime
    ARCHIVE DESTINATION "lib" COMPONENT Dev
    BUNDLE DESTINATION "/Applications" COMPONENT Runtime
    FRAMEWORK DESTINATION "/Library/Frameworks" COMPONENT Runtime
    # where to put files on non-mac computers, mac override and uses default
    PRIVATE_HEADER DESTINATION "include/jsbsim" COMPONENT Runtime
    PUBLIC_HEADER DESTINATION "include/jsbsim" COMPONENT Runtime
    RESOURCE DESTINATION "share/jsbsim" COMPONENT Runtime
    )

# packaging
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_COMPONENTS_GROUPING "ALL_COMPONENTS_IN_ONE")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libstdc++6, libgcc1, libc6")
if (WITH_ARKOSG)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS}, libgl1-mesa-glx")
endif()
include(CPack)

# pkgconfig
configure_file(pc.in ${PROJECT_NAME}.pc)
install(FILES
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.pc
    DESTINATION "lib/pkgconfig" COMPONENT Runtime
    )
# vim:sw=4:ts=4:expandtab
