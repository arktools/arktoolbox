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

# third party library version
set(ARKOSG_REQUIRED_VERSION             0.2.3)
set(ARKCOMM_REQUIRED_VERSION            0.1.6)
set(ARKMATH_REQUIRED_VERSION            0.2.7)
set(ARKHANGAR_REQUIRED_VERSION          1.3.0)
set(JSBSIM_REQUIRED_VERSION             1.0.0.110) 
set(SCICOSLAB_REQUIRED_VERSION          4.4.1) 
set(OPENSCENEGRAPH_REQUIRED_VERSION     2.8.3) 
set(BOOST_REQUIRED_VERSION              1.42.0) 

# md5 check sums
set(ARKOSG_MD5      33f3d9f09f14efe53e5d15a4919d4663)
set(ARKCOMM_MD5     a8151d8de8c5c560826858c39780a508)
set(ARKMATH_MD5     4f82a86f0f301406eb51c4e147f0117e)
set(ARKHANGAR_MD5   149c59d1093864f644278379ad7e5bb9)
set(JSBSIM_MD5      8381c4bb8da2bb05694d6c6e225d9d9f)

# options
option(WITH_BUILD_DEPS "Build dependencies." OFF)
option(WITH_PREFER_STATIC "Build preferring static linking." ON)
option(WITH_ARKOSG "Build arkosg graphics." ON)
option(WITH_LAPACK "Use lapack libraries." OFF)
option(WITH_WARNINGS "Enable warnings." OFF)

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
include(DefineCMakeDefaults)
include(DefineCompilerFlags)
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

# add wine to find path
if (MINGW)
    list(APPEND CMAKE_FIND_ROOT_PATH "$ENV{HOME}/.wine/drive_c")
endif()

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
find_package(ScicosLab REQUIRED ${SCICOSLAB_REQUIRED_VERSION})
if (MSVC)
    set(Boost_USE_MULITHREADED ON)
    find_package(Boost ${BOOST_REQUIRED_VERSION} COMPONENTS thread system REQUIRED)
elseif(MINGW)
    find_package(Boost ${BOOST_REQUIRED_VERSION} COMPONENTS thread_win32-mt system-mt REQUIRED)
else()
    find_package(Boost ${BOOST_REQUIRED_VERSION} COMPONENTS thread-mt system-mt REQUIRED)
endif()
if (WITH_LAPACK)
    find_package(LAPACK REQUIRED)
endif()
if (WITH_ARKOSG)
    find_package(OpenSceneGraph ${OPENSCENEGRAPH_REQUIRED_VERSION} REQUIRED COMPONENTS osgViewer osgUtil osgDB osgGA osgManipulator)

    # find osg plugins
    find_package(OsgPlugin ${OPENSCENEGRAPH_REQUIRED_VERSION} REQUIRED COMPONENTS ac rgb)

    find_package(OpenGL REQUIRED)
    find_package(ArkOsg ${ARKOSG_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
endif()
find_package(ArkComm ${ARKCOMM_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(ArkMath ${ARKMATH_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(ArkHangar ${ARKHANGAR_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(JSBSim ${JSBSIM_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})

# build dependencies
if (WITH_BUILD_DEPS AND (NOT ROOT_THREAD) )
    message("** Configuring dependencies")

    # add external projects 
    set(CMAKE_EP_DEFAULT_ARGS
        -DEP_BASE_DIR=${EP_BASE_DIR}
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DWITH_BUILD_DEPS=${WITH_BUILD_DEPS}
        )

    if (NOT JSBSIM_FOUND)
        ExternalProjectWithFilename_Add(jsbsim
            URL https://github.com/jgoppert/jsbsim/tarball/${JSBSIM_REQUIRED_VERSION}
            URL_MD5 ${JSBSIM_MD5}
            FILENAME jsbsim-${JSBSIM_MD5}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
            )
    endif()

    if (WITH_ARKOSG AND (NOT ARKOSG_FOUND))
        ExternalProjectWithFilename_Add(arkosg
            URL https://github.com/arktools/arkosg/tarball/${ARKOSG_REQUIRED_VERSION}
            URL_MD5 ${ARKOSG_MD5}
            FILENAME arkosg-${ARKOSG_MD5}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
        )
    endif()

    if (NOT ARKHANGAR_FOUND)
        ExternalProjectWithFilename_Add(arkhangar
            URL https://github.com/arktools/arkhangar/tarball/${ARKHANGAR_REQUIRED_VERSION}
            URL_MD5 ${ARKHANGAR_MD5} 
            FILENAME arkhangar-${ARKHANGAR_MD5}.tar.gz 
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
        )
    endif()

    if (NOT ARKMATH_FOUND)
        ExternalProjectWithFilename_Add(arkmath
            URL https://github.com/arktools/arkmath/tarball/${ARKMATH_REQUIRED_VERSION}
            URL_MD5 ${ARKMATH_MD5}
            FILENAME arkmath-${ARKMATH_MD5}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS} "-DWITH_LAPACK=${WITH_LAPACK}"
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
           )
    endif()

    if (NOT ARKCOMM_FOUND)
        ExternalProjectWithFilename_Add(arkcomm
            URL https://github.com/arktools/arkcomm/tarball/${ARKCOMM_REQUIRED_VERSION}
            URL_MD5 ${ARKCOMM_MD5}
            FILENAME arkcomm-${ARKCOMM_MD5}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
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
add_definitions(-DBOOST_FILESYSTEM_VERSION=2)
set(ARKSCICOS_LIBRARIES)
if(WITH_PREFER_STATIC OR MINGW)
    add_definitions(-DOSG_LIBRARY_STATIC)
endif()
if(WITH_ARKOSG)
    list(APPEND ARKSCICOS_LIBRARIES ${OSGPLUGIN_LIBRARIES})
endif()
if(MINGW)
    add_definitions(-D_WIN32_WINNT=0x0501)
    list(APPEND ARKSCICOS_LIBRARIES 
        ${SCICOSLAB_LIBRARIES})
endif()

if (WITH_WARNINGS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99 -pedantic")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wshadow -Wmissing-prototypes -Wdeclaration-after-statement")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wunused -Wfloat-equal -Wpointer-arith -Wwrite-strings -Wformat-security")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wmissing-format-attribute")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wshadow")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wunused -Wfloat-equal -Wpointer-arith -Wwrite-strings -Wformat-security")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wmissing-format-attribute")
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

# scicoslab plugin
if(JSBSIM_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${JSBSIM_LIBRARIES})
endif()
if(ARKOSG_FOUND)
	list(APPEND ARKSCICOS_LIBRARIES ${ARKOSG_LIBRARIES})
endif()
if(ARKCOMM_FOUND)
	list(APPEND ARKSCICOS_LIBRARIES ${ARKCOMM_LIBRARIES})
endif()
if(ARKMATH_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${ARKMATH_LIBRARIES})
endif()
if(LAPACK_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${LAPACK_LIBRARIES})
endif()
if(OPENSCENEGRAPH_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${OPENSCENEGRAPH_LIBRARIES})
    list(APPEND ARKSCICOS_LIBRARIES ${OPENGL_LIBRARIES})
endif()
if(Boost_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${Boost_LIBRARIES})
endif()
if(MINGW)
    list(APPEND ARKSCICOS_LIBRARIES wsock32)
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

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_LD_FLAGS "${CMAKE_LD_FLAGS} -lpthread -Wl,-flat_namespace,-undefined,suppress")

add_library(arkscicos MODULE ${ARKSCICOS_SRCS})
add_dependencies(arkscicos arkcomm arkmath arkhangar arkosg jsbsim)
target_link_libraries(arkscicos ${ARKSCICOS_LIBRARIES})
set_target_properties(arkscicos PROPERTIES
    SOVERSION ${LIBRARY_SOVERSION}
    VERSION ${LIBRARY_VERSION}
    )
set(LIBRARY_OUTPUT_PATH arkscicos-toolbox/scicos)
add_custom_target(toolbox ALL
    COMMAND "${CMAKE_COMMAND}" -E chdir "${CMAKE_BINARY_DIR}/arkscicos-toolbox" 
        ${SCICOSLAB_SCILAB_PROGRAM} "-nb" "-nwni" "-e" "\"exit\""
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
set(ARKSCICOS_CONTRIB_DIR ${SCICOSLAB_CONTRIB_DIR})
if (WIN32)
    set(ARKSCICOS_CONTRIB_DIR "contrib")
endif()
install(DIRECTORY "${PROJECT_BINARY_DIR}/arkscicos-toolbox"
    DESTINATION ${ARKSCICOS_CONTRIB_DIR}
    COMPONENT Runtime
    PATTERN "*.git*" EXCLUDE
    )

# packaging
if (WIN32)
    # set NSIS image, nsis bug requuires atleast one file with 4 slashes to install correctly
    #set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\/cmake/arkscicos-nsis.bmp")
    #set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/cmake/arkscicos.ico")
    #set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/cmake/arkscicos.ico")
    set(CPACK_NSIS_INSTALL_ROOT "C:\\\\Program Files\\\\scicoslab-4.4.1")
    set(CPACK_NSIS_PACKAGE_NAME "${PROJECT_NAME} ${PROJECT_VERSION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "")
endif()
configure_file("COPYING" "COPYING.txt" COPYONLY) # adding file extensions
configure_file("README" "README.txt" COPYONLY)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_BINARY_DIR}/COPYING.txt")
set(CPACK_RESOURCE_FILE_README "${CMAKE_BINARY_DIR}/README.txt")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CPACK_RESOURCE_FILE_README}")
set(CPACK_RESOURCE_FILE_WELCOME "${CMAKE_SOURCE_DIR}/cmake/WELCOME.txt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "autonomous robotics kit scicoslab toolbox")
set(CPACK_PACKAGE_VENDOR ${PROJECT_CONTACT_VENDOR})
set(CPACK_PACKAGE_CONTACT "${PROJECT_CONTACT_EMAIL}")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_COMPONENTS_GROUPING "ALL_COMPONENTS_IN_ONE")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libstdc++6, libgcc1, libc6")
if (WITH_ARKOSG)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS}, libgl1-mesa-glx")
endif()
set(CPACK_PACKAGE_EXECUTABLES
    #"command" "Description"
    )
include(CPack)
# vim:sw=4:ts=4:expandtab
