include_directories( ${CMAKE_SOURCE_DIR}/src 
    ${CMAKE_BINARY_DIR}/src
    ${SCICOSLAB_INCLUDE_DIRS}
    ${JSBSIM_INCLUDE_DIRS} 
    ${Boost_INCLUDE_DIRS}
    ${ARKCOMM_INCLUDE_DIRS}
    ${ARKMATH_INCLUDE_DIRS}
    ${ARKOSG_INCLUDE_DIRS}
    ${PLIB_INCLUDE_DIRS}
    ${OPENSCENEGRAPH_INCLUDE_DIRS}
    )

# scicoslab plugin
if(JSBSIM_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${JSBSIM_LIBRARIES})
endif()
if(ARKOSG_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${ARKOSG_LIBRARIES})
endif()
if(ARKCOMM_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${ARKCOMM_LIBRARIES})
endif()
if(ARKMATH_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${ARKMATH_LIBRARIES})
endif()
if(LAPACK_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${LAPACK_LIBRARIES})
endif()
if(OPENSCENEGRAPH_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${OPENSCENEGRAPH_LIBRARIES})
    list(APPEND ARKTOOLBOX_LIBRARIES ${OPENGL_LIBRARIES})
endif()
if(Boost_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${Boost_LIBRARIES})
endif()
if(PLIB_FOUND)
    list(APPEND ARKTOOLBOX_LIBRARIES ${PLIB_LIBRARIES})
endif()
if(MINGW)
    list(APPEND ARKTOOLBOX_LIBRARIES winmm wsock32)
endif()

set(ARKTOOLBOX_SRCS
    src/definitions.hpp
    src/utilities.hpp
    src/osgPlugins.cpp
    src/definitions.cpp
    src/utilities.cpp
    )

# joystick
if(WITH_JOYSTICK)
    list(APPEND ARKTOOLBOX_SRCS
        src/jsinput.cxx
        src/jssuper.cxx
        src/jsinput.h
        src/jssuper.h
    )
list(APPEND ARKTOOLBOX_BLOCKS
    joystick
    )
endif()

# mavlink blocks
list(APPEND ARKTOOLBOX_BLOCKS
    mavlinkHilSensor
    mavlinkHilState
    )

# general blocks
list(APPEND ARKTOOLBOX_BLOCKS
    euler2Dcm
    waypointGuidance
    quat2EulerDcm
    insErrorDynamics
    insDynamics
    geoMag
    magMeasModel
    gpsMeasModel
    eom6Dof
    navigationEquations
    invPend
    zeroOrderHold
    randn
    #quadForceMoments
    sailboatForceMoments
    pidDLP
    pidDFB
    )

# lapack blocks
list(APPEND ARKTOOLBOX_BLOCKS
    gpsIns
    )

# osg blocks
list(APPEND ARKTOOLBOX_BLOCKS
    jet
    plane
    car
    quad
    sailboat
    vector
    )

# jsbsim
list(APPEND ARKTOOLBOX_BLOCKS
    jsbsimComm
    )
list(APPEND ARKTOOLBOX_SRCS
    src/sci_jsbsimTrim.cpp
    )

set(ARKTOOLBOX_BLOCKS_STRING "")
foreach(BLOCK ${ARKTOOLBOX_BLOCKS})
    list(APPEND ARKTOOLBOX_SRCS
        src/sci_${BLOCK}.cpp
        )
    set(ARKTOOLBOX_BLOCKS_STRING "${ARKTOOLBOX_BLOCKS_STRING}'sci_${BLOCK}' ")
    set(INTERFACE_FUNCTION_FILE "${CMAKE_SOURCE_DIR}/scicos/scicos/arktoolbox/${BLOCK}.sci")
    if ( NOT EXISTS ${INTERFACE_FUNCTION_FILE} )
        message(FATAL_ERROR "block ${BLOCK} requires you to define an interface, please create : ${INTERFACE_FUNCTION_FILE}")
    endif()
endforeach()

add_library(arktoolbox MODULE ${ARKTOOLBOX_SRCS})
add_dependencies(arktoolbox arkcomm arkmath arkhangar arkosg jsbsim)
target_link_libraries(arktoolbox ${ARKTOOLBOX_LIBRARIES})
set_target_properties(arktoolbox PROPERTIES
    SOVERSION ${LIBRARY_SOVERSION}
    #VERSION ${LIBRARY_VERSION}
    )
set(LIBRARY_OUTPUT_PATH arktoolbox-scicos/scicos)

# create toolbox
glob_copy_tracked(TARGET "toolboxSrcs" RECURSE
    SRCDIR ${CMAKE_SOURCE_DIR}
    GLOB_ARGS "${CMAKE_SOURCE_DIR}/scicos/*"
    DESTDIR ${CMAKE_BINARY_DIR})

if (WITH_ARKOSG)
    glob_copy_tracked(TARGET "arkosgData" RECURSE
        SRCDIR ${ARKOSG_DATADIR}
        GLOB_ARGS "${ARKOSG_DATADIR}/arkosg/*"
        DESTDIR ${CMAKE_BINARY_DIR}/arktoolbox-scicos/data)
endif()

glob_copy_tracked(TARGET "arkmathData" RECURSE
    SRCDIR ${ARKMATH_DATADIR}
    GLOB_ARGS "${ARKMATH_DATADIR}/arkmath/*"
    DESTDIR ${CMAKE_BINARY_DIR}/arktoolbox-scicos/data)

glob_copy_tracked(TARGET "arkhangarData" RECURSE
    SRCDIR ${ARKHANGAR_DATADIR}
    GLOB_ARGS "${ARKHANGAR_DATADIR}/arkhangar/*"
    DESTDIR ${CMAKE_BINARY_DIR}/arktoolbox-scicos/data)

glob_copy_tracked(TARGET "jsbsimData" RECURSE
    SRCDIR ${JSBSIM_DATADIR}
    GLOB_ARGS "${JSBSIM_DATADIR}/jsbsim/*"
    DESTDIR ${CMAKE_BINARY_DIR}/arktoolbox-scicos/data)

set(TOOLBOX_DEPS
    arktoolbox
    toolboxSrcs
    ${CMAKE_BINARY_DIR}/arktoolbox-scicos/scicos/loadscicos.sce
    ${CMAKE_BINARY_DIR}/arktoolbox-scicos/scicos/buildscicos.sce
    arkosgData arkmathData arkhangarData jsbsimData
    )

if (APPLE)
    message(STATUS "apple scicoslab command-line does not function, please run builder.sce using the ScicosLab app before packaging with cmake")
else()
    list(APPEND TOOLBOX_DEPS "toolbox-build-stamp")
endif()

add_custom_command(OUTPUT "toolbox-build-stamp"
    COMMAND "${CMAKE_COMMAND}" -E chdir "${CMAKE_BINARY_DIR}/arktoolbox-scicos" 
        ${SCICOSLAB_SCILAB_PROGRAM} "-nb" "-nwni" "-e" "\"exec('builder.sce');exit\""
    COMMAND "${CMAKE_COMMAND}" -E touch toolbox-build-stamp
    DEPENDS arktoolbox
    )
add_custom_target(toolbox ALL DEPENDS ${TOOLBOX_DEPS})

configure_file(src/scicos/loadscicos.sce.in ${CMAKE_BINARY_DIR}/arktoolbox-scicos/scicos/loadscicos.sce)
configure_file(src/scicos/buildscicos.sce.in ${CMAKE_BINARY_DIR}/arktoolbox-scicos/scicos/buildscicos.sce)
configure_file(src/VERSION.in ${CMAKE_BINARY_DIR}/arktoolbox-scicos/VERSION)

