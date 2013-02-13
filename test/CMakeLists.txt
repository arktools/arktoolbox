include_directories(${CMAKE_SOURCE_DIR}/src)
link_libraries(support)

add_executable(osgTest
    osgTest.cpp
    )

add_test(OsgTest ${CMAKE_CURRENT_BINARY_DIR}/osgTest ${CMAKE_SOURCE_DIR}/data)
