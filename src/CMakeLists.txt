configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

include_directories(
    ${PROJECT_SOURCE_DIR}/src 
    ${PROJECT_BINARY_DIR}/src
	${SCICOSLAB_INCLUDE_DIRS}
	${JSBSIM_INCLUDE_DIRS} 
	${Boost_INCLUDE_DIRS}
	${MAVLINK_INCLUDE_DIRS}
	${ARKCOMM_INCLUDE_DIRS}
	${ARKMATH_INCLUDE_DIRS}
	${ARKOSG_INCLUDE_DIRS}
	${CMAKE_BINARY_DIR}/src
	.
	)

if (OPENSCENEGRAPH_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${OPENSCENEGRAPH_LIBRARIES})
endif()
if (LAPACK_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${LAPACK_LIBRARIES})
endif()
if (JSBSIM_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${JSBSIM_LIBRARIES})
endif()
if (Boost_FOUND)
    list(APPEND ARKSCICOS_LIBRARIES ${Boost_LIBRARIES})
endif()

set(${PROJECT_NAME}Sources "")
set(SCICOSLAB_BLOCKS "")

if(ARKCOMM_FOUND)
	list(APPEND ARKSCICOS_LIBRARIES ${ARKCOMM_LIBRARIES})
    if (SIMGEAR_FOUND AND PLIB_FOUND)
	    message(STATUS "building flightgear blocks")
	    list(APPEND ARKSCICOS_LIBRARIES ${SIMGEAR_LIBRARIES} ${PLIB_LIBRARY})
		list(APPEND SCICOSLAB_BLOCKS "simgearBlocks")
		list(APPEND ${PROJECT_NAME}Sources sci_flightGearComm.cpp)
	endif()
	message(STATUS "building mavlink blocks")
	list(APPEND SCICOSLAB_BLOCKS "mavlinkBlocks")
	list(APPEND ${PROJECT_NAME}Sources
		sci_mavlinkHilSensor.cpp
		sci_mavlinkHilState.cpp
		sci_mavlinkHilTracker.cpp
	)
endif()

if(ARKMATH_FOUND)
	message(STATUS "building arkmath blocks")
	list(APPEND SCICOSLAB_BLOCKS "mathBlocks")
	list(APPEND ARKSCICOS_LIBRARIES ${ARKMATH_LIBRARIES})
	list(APPEND SCICOSLAB_BLOCKS "mathBlocks")
	list(APPEND ${PROJECT_NAME}Sources
		sci_euler2Dcm.cpp
		sci_waypointGuidance.cpp
		sci_quat2EulerDcm.cpp
		sci_insErrorDynamics.cpp
		sci_insDynamics.cpp
		sci_geoMag.cpp
		sci_magMeasModel.cpp
		sci_gpsMeasModel.cpp
		sci_eom6Dof.cpp
		sci_navigationEquations.cpp
		definitions.cpp
		sci_invPend.cpp
		utilities.cpp
		sci_zeroOrderHold.cpp
		sci_randn.cpp
		sci_quadForceMoments.cpp
	)
	if (LAPACK_FOUND)
	    message(STATUS "building lapack blocks")
		list(APPEND ARKSCICOS_LIBRARIES ${ARKMATH_LIBRARIES})
		list(APPEND SCICOSLAB_BLOCKS "lapackBlocks")
		list(APPEND ${PROJECT_NAME}Sources
			sci_gpsIns.cpp
		)
	endif()
endif()

if(ARKOSG_FOUND AND OPENSCENEGRAPH_FOUND)
	message(STATUS "building arkosg blocks")
	list(APPEND ARKSCICOS_LIBRARIES ${ARKOSG_LIBRARIES})
	list(APPEND SCICOSLAB_BLOCKS "osgBlocks")
	list(APPEND ${PROJECT_NAME}Sources
		sci_jet.cpp
		sci_plane.cpp
		sci_car.cpp
		sci_quad.cpp
		sci_vector.cpp
	)
endif()

if(JSBSIM_FOUND)
	message(STATUS "building jsbsimBlocks")
	list(APPEND SCICOSLAB_BLOCKS "jsbsimBlocks")
	list(APPEND ${PROJECT_NAME}Sources
		sci_jsbsimTrim.cpp
		sci_jsbsimComm.cpp
	)
endif()

set(CMAKE_C_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_CXX_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_LD_FLAGS "-lpthread -Wl,-flat_namespace,-undefined,suppress")

add_library(${PROJECT_NAME} MODULE ${${PROJECT_NAME}Sources})
add_dependencies(${PROJECT_NAME} mavlink jsbsim arkosg arkmath arkcomm)

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
configure_file(loadscicos.sce.in ${CMAKE_SOURCE_DIR}/arkscicos-toolbox/scicos/loadscicos.sce)
set(SCICOSLAB_INSTALL_SETTINGS 1)
configure_file(loadscicos.sce.in ${CMAKE_CURRENT_BINARY_DIR}/loadscicos.sce)

configure_file(VERSION.in ${CMAKE_SOURCE_DIR}/arkscicos-toolbox/VERSION)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/loadscicos.sce DESTINATION
	${SCICOSLAB_CONTRIB_DIR}/arkscicos-toolbox/scicos)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)

install(FILES
    definitions.hpp
    utilities.hpp
	DESTINATION include/arkscicos
    )
