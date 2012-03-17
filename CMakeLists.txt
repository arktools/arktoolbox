project (arkscicos C CXX)

# Requried cmake version
cmake_minimum_required (VERSION 2.8)
set(PROJECT_VERSION_MAJOR "0")
set(PROJECT_VERSION_MINOR "7")
set(PROJECT_VERSION_PATCH "0")
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(PROJECT_CONTACT_EMAIL james.goppert@gmail.com)
set(PROJECT_CONTACT_VENDOR arktools)
set(LIBRARY_VERSION ${PROJECT_VERSION})
set(LIBRARY_SOVERSION "0.0.0")

# options
option(WITH_BUILD_DEPS "Build dependencies." ON)
option(WITH_PREFER_STATIC "Build preferring static linking." ON)
option(WITH_ARKOSG "Build arkosg graphics." ON)
option(WITH_LAPACK "Use lapack libraries." OFF)

# variables
set(ROOT_THREAD TRUE CACHE INTERNAL "Is this the top level of the recursion?")

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
include(ExternalProjectWithFilename)

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
set_property(DIRECTORY PROPERTY EP_BASE ${EP_BASE_DIR})
set(EP_INSTALL_DIR "${EP_BASE_DIR}/Install")
list(APPEND CMAKE_FIND_ROOT_PATH ${EP_INSTALL_DIR})

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
find_package(ScicosLab 4.4.1)
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
    find_package(OpenSceneGraph 2.8.3 REQUIRED COMPONENTS osgViewer osgUtil osgDB osgGA osgManipulator)

    # find osg plugins
    find_package(OsgPlugin 2.8.3 REQUIRED COMPONENTS ac rgb)

    find_package(OpenGL REQUIRED)
    find_package(ArkOsg 0.2.3 ${REQUIRED_IF_ROOT_THREAD})
endif()
find_package(ArkComm 0.1.6 ${REQUIRED_IF_ROOT_THREAD})
find_package(ArkMath 0.2.7 ${REQUIRED_IF_ROOT_THREAD})
find_package(ArkHangar 1.3.0 ${REQUIRED_IF_ROOT_THREAD})
find_package(JSBSim 1.0.0.109 ${REQUIRED_IF_ROOT_THREAD})

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
        ExternalProjectWithFilename_Add(arkosg
            URL https://github.com/arktools/arkosg/tarball/0.2.3
            URL_MD5 0f074bb72d2ab61e7a710d177ad6feda
            FILENAME arkosg.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
        )
    endif()

    if (NOT ARKHANGAR_FOUND)
        ExternalProjectWithFilename_Add(arkhangar
            URL https://github.com/arktools/arkhangar/tarball/1.3.0
            URL_MD5 b937600f70df7129e8fb62efdea7faf3 
            FILENAME arkhangar.tar.gz 
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
        )
    endif()

    if (NOT ARKMATH_FOUND)
        ExternalProjectWithFilename_Add(arkmath
            URL https://github.com/arktools/arkmath/tarball/0.2.7
            URL_MD5 074718084d7627006e597a02a3e9404a
            FILENAME arkmath.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS} "-DWITH_LAPACK=${WITH_LAPACK}"
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
           )
    endif()

    if (NOT ARKCOMM_FOUND)
        ExternalProjectWithFilename_Add(arkcomm
            URL https://github.com/arktools/arkcomm/tarball/0.1.6
            URL_MD5 2f0bd4810366440e452e5e6872ece817
            FILENAME arkcomm.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
           )
    endif()

    if (NOT JSBSIM_FOUND)
        ExternalProjectWithFilename_Add(jsbsim
            URL https://github.com/jgoppert/jsbsim/tarball/1.0.0.109
            URL_MD5 6df871942815ac67e98074f68f72e9a2
            FILENAME jsbsim.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS} "-DWITH_BUILD_DEPS=y"
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
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
configure_file(src/config.h.in src/config.h)

# copy components of toolbox
file(COPY arkscicos-toolbox DESTINATION ${CMAKE_BINARY_DIR})
if (WITH_ARKOSG)
    file(COPY "${ARKOSG_DATADIR}/arkosg"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE)
endif()
file(COPY "${ARKMATH_DATADIR}/arkmath"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )
file(COPY "${ARKHANGAR_DATADIR}/arkhangar"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )
file(COPY "${JSBSIM_DATADIR}/jsbsim"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )

# build settings
set(ARKSCICOS_LIBRARIES)
if (WITH_PREFER_STATIC OR MINGW)
    add_definitions(-DOSG_LIBRARY_STATIC)
endif()
if (WITH_ARKOSG)
    list(APPEND ARKSCICOS_LIBRARIES ${OSGPLUGIN_LIBRARIES})
endif()

include_directories( ${CMAKE_SOURCE_DIR}/src 
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

set(ARKSCICOS_SRCS
    src/definitions.hpp
    src/utilities.hpp
    )
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
set(LIBRARY_OUTPUT_PATH arkscicos-toolbox/scicos)

add_custom_target(toolbox ALL
    COMMAND "${CMAKE_COMMAND}" -E chdir "${CMAKE_BINARY_DIR}/arkscicos-toolbox" ./build.sh
    DEPENDS arkscicos
    )

get_target_property(ARKSCICOS_SCICOS_LOCATION arkscicos LOCATION)

configure_file(src/loadscicos.sce.in ${CMAKE_BINARY_DIR}/arkscicos-toolbox/scicos/loadscicos.sce)
configure_file(src/VERSION.in ${CMAKE_BINARY_DIR}/arkscicos-toolbox/VERSION)

# construct toolbox
file(COPY ${CMAKE_SOURCE_DIR}/arkscicos-toolbox DESTINATION ${CMAKE_BINARY_DIR})
if (WITH_ARKOSG)
    file(COPY "${ARKOSG_DATADIR}/arkosg"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )
endif()
file(COPY "${ARKMATH_DATADIR}/arkmath"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )
file(COPY "${ARKHANGAR_DATADIR}/arkhangar"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )
file(COPY "${JSBSIM_DATADIR}/jsbsim"
        DESTINATION ${CMAKE_BINARY_DIR}/arkscicos-toolbox/data
        PATTERN "*.git*" EXCLUDE
        )

# install
install(DIRECTORY "${PROJECT_BINARY_DIR}/arkscicos-toolbox"
    DESTINATION ${SCICOSLAB_CONTRIB_DIR}
    COMPONENT Runtime
    PATTERN "*.git*" EXCLUDE
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
# vim:sw=4:ts=4:expandtab
