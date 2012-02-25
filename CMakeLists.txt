project (arkscicos C CXX)

# Requried cmake version
cmake_minimum_required (VERSION 2.8.2)
set(PROJECT_VERSION_MAJOR "0")
set(PROJECT_VERSION_MINOR "4")
set(PROJECT_VERSION_PATCH "0")
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(PROJECT_CONTACT_EMAIL james.goppert@gmail.com)
set(PROJECT_CONTACT_VENDOR arktools)
set(LIBRARY_VERSION ${PROJECT_VERSION})
set(LIBRARY_SOVERSION "0.0.0")

set(ARKOSG_VERSION "9001fbbfe8cf2b0b43d7c3a92247e8e8fdb0b263")
set(ARKMATH_VERSION "ff34296dcc92bb00eb4fcd36422b1069a77e7df8")
set(ARKCOMM_VERSION "0266e0406ae1a913dd8140f804699a277f86626c")
set(JSBSIM_VERSION "d1f5868d303f776e92a4947feb72003053229c44")
set(ARKHANGAR_VERSION "5b26b872ea4e2667ee82acfe7beb43bf50c95357")

# options
option(WITH_BUILD_DEPS "Build dependencies." ON)
option(WITH_BUILD_STATIC "Build preferring static linking." ON)
option(WITH_ARKOSG "Build arkosg graphics." OFF)
option(WITH_LAPACK "Use lapack libraries" OFF)

# variables
set(ROOT_THREAD TRUE CACHE INTERNAL "Is this the top level of the recursion?")
set(INSTALLED_TARGETS "")

# modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/arkcmake
    )
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
        "-DROOT_THREAD=FALSE"
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
        "-DWITH_BUILD_DEPS=${WITH_BUILD_STATIC}"
        "-DWITH_BUILD_STATIC=${WITH_BUILD_STATIC}"
        "-DWITH_GUI=${WITH_GUI}"
        "-DWITH_ARKOSG=${WITH_ARKOSG}"
        "-DWITH_LAPACK=${WITH_LAPACK}"
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
if (WITH_BUILD_STATIC)
    set(BOOST_USE_STATIC_LIBS ON)
    # prefer static libs
    if(WIN32)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif()
endif()

# find libraries with cmake modules
find_package(SCICOSLAB REQUIRED)
find_package(Boost 1.42 REQUIRED COMPONENTS thread-mt system-mt)
if (WITH_LAPACK)
    find_package(LAPACK REQUIRED)
endif()
if (WITH_ARKOSG)
    find_package(OpenSceneGraph 2.8.0 REQUIRED COMPONENTS osgViewer osgUtil osgDB osgGA osgManipulator)
    find_package(OpenGL REQUIRED)
endif()
if (ROOT_THREAD)
    find_package(ARKCOMM REQUIRED)
    find_package(ARKMATH REQUIRED)
    if (WITH_ARKOSG)
        find_package(ARKOSG REQUIRED)
    endif()
    find_package(ARKHANGAR REQUIRED)
    find_package(JSBSIM REQUIRED)
else()
    find_package(ARKCOMM)
    find_package(ARKMATH)
    if (WITH_ARKOSG)
        find_package(ARKOSG)
    endif()
    find_package(ARKHANGAR)
    find_package(JSBSIM)
endif()

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
        build_arkosg(${ARKOSG_VERSION} ${EP_BASE_DIR} "${CMAKE_EP_DEFAULT_ARGS}")
    endif()

    if (NOT ARKHANGAR_FOUND)
        build_arkhangar(${ARKHANGAR_VERSION} ${EP_BASE_DIR} "${CMAKE_EP_DEFAULT_ARGS}")
    endif()

    if (NOT ARKMATH_FOUND)
        build_arkmath(${ARKMATH_VERSION} ${EP_BASE_DIR} "${CMAKE_EP_DEFAULT_ARGS}")
    endif()

    if (NOT ARKCOMM_FOUND)
        build_arkcomm(${ARKCOMM_VERSION} ${EP_BASE_DIR} "${CMAKE_EP_DEFAULT_ARGS}")
    endif()

    if (NOT JSBSIM_FOUND)
        build_jsbsim(${JSBSIM_VERSION} ${EP_BASE_DIR} "${CMAKE_EP_DEFAULT_ARGS}")
    endif()

    # terminate non root cmake thread
    return()
endif()

# configure
#check_include_files(string.h HAVE_STRING_H)
#check_function_exists(memcopy HAVE_MEMCOPY)
#check_symbol_exists(LC_MESSAGES "locale.h" HAVE_LC_MESSAGES) 
#check_library_exists(arkosg  attachNode "" HAVE_ARKOSG)

# initialize list of libraries to build with
set(ARKSCICOS_LIBRARIES "")

configure_file(src/config.h.cmake src/config.h)

include_directories(
    ${CMAKE_SOURCE_DIR}/src 
    ${CMAKE_BINARY_DIR}/src
	${SCICOSLAB_INCLUDE_DIRS}
	${JSBSIM_INCLUDE_DIRS} 
	${Boost_INCLUDE_DIRS}
	${MAVLINK_INCLUDE_DIRS}
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

set(${PROJECT_NAME}Sources "")
set(SCICOSLAB_BLOCKS "")

list(APPEND SCICOSLAB_BLOCKS "mavlinkBlocks")
list(APPEND ${PROJECT_NAME}Sources
    src/sci_mavlinkHilSensor.cpp
    src/sci_mavlinkHilState.cpp
    src/sci_mavlinkHilTracker.cpp
)

list(APPEND SCICOSLAB_BLOCKS "mathBlocks")
list(APPEND ${PROJECT_NAME}Sources
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
list(APPEND ${PROJECT_NAME}Sources
    src/sci_gpsIns.cpp
)

list(APPEND SCICOSLAB_BLOCKS "osgBlocks")
list(APPEND ${PROJECT_NAME}Sources
    src/sci_jet.cpp
    src/sci_plane.cpp
    src/sci_car.cpp
    src/sci_quad.cpp
    src/sci_sailboat.cpp
    src/sci_vector.cpp
)

list(APPEND SCICOSLAB_BLOCKS "jsbsimBlocks")
list(APPEND ${PROJECT_NAME}Sources
    src/sci_jsbsimTrim.cpp
    src/sci_jsbsimComm.cpp
)

set(CMAKE_C_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_CXX_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_LD_FLAGS "-lpthread -Wl,-flat_namespace,-undefined,suppress")

add_library(${PROJECT_NAME} MODULE ${${PROJECT_NAME}Sources})
add_dependencies(${PROJECT_NAME} mavlink jsbsim arkosg arkmath arkcomm arkhangar)

target_link_libraries(${PROJECT_NAME} ${ARKSCICOS_LIBRARIES})


set_target_properties(${PROJECT_NAME} PROPERTIES SOVERSION ${LIBRARY_SOVERSION})
if(NOT APPLE)
	set_target_properties(${PROJECT_NAME} PROPERTIES VERSION ${LIBRARY_VERSION})
endif()

if (UNIX AND NOT APPLE)
	# if using unix add script to see if scicoslab toolbox builds correctly
	add_custom_target(toolbox ALL
		DEPENDS ${PROJECT_NAME}
		COMMAND cd ${PROJECT_SOURCE_DIR}/arkscicos-toolbox && ./build.sh)
endif()

get_target_property(ARKSCICOS_SCICOS_LOCATION ${PROJECT_NAME} LOCATION)

set(SCICOSLAB_INSTALL_SETTINGS 0)
configure_file(src/loadscicos.sce.in ${CMAKE_SOURCE_DIR}/arkscicos-toolbox/scicos/loadscicos.sce)
set(SCICOSLAB_INSTALL_SETTINGS 1)
configure_file(src/loadscicos.sce.in ${CMAKE_CURRENT_BINARY_DIR}/src/loadscicos.sce)

configure_file(src/VERSION.in ${CMAKE_SOURCE_DIR}/arkscicos-toolbox/VERSION)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/loadscicos.sce DESTINATION
	${SCICOSLAB_CONTRIB_DIR}/arkscicos-toolbox/scicos)

install(TARGETS ${PROJECT_NAME} DESTINATION lib COMPONENT Runtime)

install(FILES
    src/definitions.hpp
    src/utilities.hpp
	DESTINATION include/arkscicos
    COMPONENT Runtime
    )

# install data files
install(DIRECTORY "${PROJECT_SOURCE_DIR}/projects" DESTINATION share/${PROJECT_NAME}
    COMPONENT Runtime 
    PATTERN "*.git*" EXCLUDE
    )
install(DIRECTORY "${PROJECT_SOURCE_DIR}/arkscicos-toolbox"
    DESTINATION ${SCICOSLAB_CONTRIB_DIR}
    COMPONENT Runtime
    PATTERN "*.git*" EXCLUDE
    )

# install required dependencies from external projects
install(DIRECTORY ${EP_BASE_DIR}/${EP_INSTALL_PREFIX}/
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    COMPONENT Runtime
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

# install external projects, if built
if (EXISTS ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}/)
    install(DIRECTORY ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}/ DESTINATION ${CMAKE_INSTALL_PREFIX} COMPONENT Runtime)
endif()

# packaging
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_COMPONENTS_GROUPING "ALL_COMPONENTS_IN_ONE")
include(CPack)

# pkgconfig
configure_file(pc.in ${PROJECT_NAME}.pc)
install(FILES
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.pc
    DESTINATION "lib/pkgconfig" COMPONENT Runtime
    )
# vim:sw=4:ts=4:expandtab
