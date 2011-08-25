include( ${QT_USE_FILE})
add_definitions(-DUSE_QT4)
link_directories(${OPENSCENEGRAPH_LIBRARY_DIRS} ${QT_LIBRARY_DIRS}) 
include_directories(${OPENSCENEGRAPH_INCLUDE_DIRS}
	${QT_INCLUDE_DIRS} ${OPENGL_INCLUDE_DIR})
link_libraries(${OPENSCENEGRAPH_LIBRARIES} 
	${Boost_LIBRARIES} ${QT_LIBRARIES} ${OPENGL_LIBRARIES})


configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

set(arkScicosSource
	test.cpp
	)

set(arkScicosHeaders
	test.hpp
	)

add_library(arkScicos SHARED ${arkScicosSource})

add_dependencies(arkScicos ARKOSG)

set_target_properties(arkScicos PROPERTIES VERSION ${LIBRARY_VERSION}
	SOVERSION ${LIBRARY_SOVERSION})

install(TARGETS arkScicos DESTINATION lib)
install(FILES ${arkScicosHeaders} DESTINATION include/arkScicos)
