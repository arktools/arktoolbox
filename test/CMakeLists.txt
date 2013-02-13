include_directories(${CMAKE_SOURCE_DIR}/src)
link_libraries(support)

add_executable(osgTest
    osgTest.cpp
    )
