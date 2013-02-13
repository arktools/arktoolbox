set(CMAKE_SHARED_LINKER_FLAGS "-static-libgcc -static-libstdc++")

link_directories(
    ${OPENSCENEGRAPH_LIBRARY_DIRS}
    ) 

link_libraries(
    ${PLIB_LIBRARIES}
    ${Boost_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
    ${OSGPLUGIN_LIBRARIES}
    ${OPENSCENEGRAPH_LIBRARIES}
    ${OPENGL_LIBRARIES}
    )
if (WIN32)
    link_libraries(lcms lzma)
endif()

include_directories(
    ${PLIB_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    ${OPENSCENEGRAPH_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    )
if (APPLE)
    link_libraries(
        ${COREFOUNDATION_LIBRARY}
        ${IOKIT_LIBRARY}
        )
elseif(UNIX)
    link_libraries(rt Xrandr)
endif()

set(SUPPORT_HDRS
    Joystick.hpp
    AsyncSerial.hpp
    MAVLinkParser.hpp
    utilities.hpp
    Viewer.hpp
    osgUtils.hpp
    )

set(SUPPORT_SRCS
    Joystick.cpp
    AsyncSerial.cpp
    MAVLinkParser.cpp
    utilities.cpp
    terrain.cpp
    Viewer.cpp
    osgUtils.cpp
    )

add_library(support SHARED
    ${SUPPORT_HDRS}
    ${SUPPORT_SRCS}
    )

# copy support library to xcos bin directory
get_target_property(supportPath support LOCATION)

add_custom_command(
    TARGET support POST_BUILD 
    COMMAND ${CMAKE_COMMAND} 
    ARGS -E copy ${supportPath} ${CMAKE_SOURCE_DIR}/xcos/support/bin
    )

# copy headers to xcos include directory
foreach(HDR ${SUPPORT_HDRS})
    add_custom_command(
        TARGET support POST_BUILD 
        COMMAND ${CMAKE_COMMAND} 
        ARGS -E copy_if_different
        ${CMAKE_CURRENT_SOURCE_DIR}/${HDR}
        ${CMAKE_SOURCE_DIR}/xcos/support/include/${HDR}
        )
endforeach()

# call scilab to finalize toolbox build
if (NOT SCILAB_ADV_CLI STREQUAL "SCILAB_ADV_CLI-NOTFOUND")
    add_custom_command(OUTPUT "toolbox-build-stamp"
        COMMAND "${CMAKE_COMMAND}" -E chdir "${CMAKE_SOURCE_DIR}/xcos"
        ${SCILAB_ADV_CLI} "-nb" "-nw" "-e" "\"exec('builder.sce');exit\""
        COMMAND "${CMAKE_COMMAND}" -E touch toolbox-build-stamp
        DEPENDS support
        )
endif()
add_custom_target(toolbox ALL DEPENDS toolbox-build-stamp)
