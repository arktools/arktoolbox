include_directories(${SCICOSLAB_INCLUDE_DIRS}
	${JSBSIM_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS}
	${MAVLINK_INCLUDE_DIRS}
	.
	)

set(${PROJECT_NAME}Sources
	definitions.cpp
	sci_mavlinkHilSensor.cpp
	sci_mavlinkHilState.cpp
	sci_mavlinkHilTracker.cpp
	sci_invPend.cpp
	utilities.cpp
	sci_jsbsimTrim.cpp
	sci_jsbsimComm.cpp
	sci_insErrorDynamics.cpp
	sci_insDynamics.cpp
	sci_zeroOrderHold.cpp
	sci_randn.cpp
	sci_geoMag.cpp
	sci_magMeasModel.cpp
	sci_gpsMeasModel.cpp
	sci_quat2EulerDcm.cpp
	sci_waypointGuidance.cpp
	sci_euler2Dcm.cpp
	sci_quadForceMoments.cpp
	sci_eom6Dof.cpp
	sci_navigationEquations.cpp
	)

if (SIMGEAR_FOUND)
	list(APPEND ${PROJECT_NAME}Sources
		sci_flightGearComm.cpp
	)
endif (SIMGEAR_FOUND)

if (LAPACK_FOUND)
	list(APPEND ${PROJECT_NAME}Sources
    	sci_gpsIns.cpp
	)
endif (LAPACK_FOUND)

if (OPENSCENEGRAPH_FOUND)
	list(APPEND ${PROJECT_NAME}Sources
		sci_jet.cpp
		sci_plane.cpp
		sci_car.cpp
		sci_quad.cpp
	)
	include_directories(${OPENSCENEGRAPH_INCLUDE_DIRS})
	link_directories( ${OSG_LIBRARY_DIRS} ) 
endif(OPENSCENEGRAPH_FOUND)

set(CMAKE_C_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_CXX_FLAGS "-Wl,-flat_namespace,-undefined,suppress")
set(CMAKE_LD_FLAGS "-lpthread -Wl,-flat_namespace,-undefined,suppress")

add_library(${PROJECT_NAME} MODULE ${${PROJECT_NAME}Sources})
add_dependencies(${PROJECT_NAME} JSBSIM)

target_link_libraries(${PROJECT_NAME} ${MAVSIM_LIBRARIES} ${JSBSIM_LIBRARIES} ${LAPACK_LIBRARIES} -lpthread)

set_target_properties(${PROJECT_NAME} PROPERTIES VERSION ${LIBRARY_VERSION}
    SOVERSION ${LIBRARY_SOVERSION})

if (UNIX)
	# if using unix add script to see if scicoslab toolbox builds correctly
	add_custom_target(toolbox ALL
		DEPENDS ${PROJECT_NAME}
		COMMAND cd ${PROJECT_SOURCE_DIR}/toolbox && ./build.sh)
endif()

get_target_property(MAVSIM_SCICOS_LOCATION ${PROJECT_NAME} LOCATION)
get_target_property(MAVSIM_COMMUNICATION_LOCATION mavsimCommunication LOCATION)

set(SCICOSLAB_INSTALL_SETTINGS 0)
configure_file(loadscicos.sce.in ${CMAKE_SOURCE_DIR}/toolbox/scicos/loadscicos.sce)
set(SCICOSLAB_INSTALL_SETTINGS 1)
configure_file(loadscicos.sce.in ${CMAKE_CURRENT_BINARY_DIR}/loadscicos.sce)

configure_file(VERSION.in ${CMAKE_SOURCE_DIR}/toolbox/VERSION)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/loadscicos.sce DESTINATION ${SCICOSLAB_CONTRIB_DIR}/toolbox/scicos)

install(TARGETS ${PROJECT_NAME} DESTINATION lib)

install(FILES
    definitions.hpp
    utilities.hpp
	DESTINATION include/arkscicos
    )
