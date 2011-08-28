link_directories(${ARKOSG_LIBRARY_DIRS})
include_directories(${ARKOSG_INCLUDE_DIRS})
link_libraries()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

set(${PROJECT_NAME}Source
	test.cpp
	)

set(${PROJECT_NAME}Headers
	test.hpp
	)

add_library(${PROJECT_NAME} ${${PROJECT_NAME}Source})

add_dependencies(${PROJECT_NAME} arkosg arkcomm arkmath)

set_target_properties(${PROJECT_NAME} PROPERTIES VERSION ${LIBRARY_VERSION}
	SOVERSION ${LIBRARY_SOVERSION})

install(TARGETS ${PROJECT_NAME} DESTINATION lib EXPORT ${PROJECT_NAME}-targets)
install(EXPORT ${PROJECT_NAME}-targets DESTINATION lib/${PROJECT_NAME})
install(FILES ${arkScicosHeaders} DESTINATION include/${PROJECT_NAME})
