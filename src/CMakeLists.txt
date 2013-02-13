set(CMAKE_SHARED_LINKER_FLAGS "-static-libgcc -static-libstdc++")

link_libraries(
    ${PLIB_LIBRARIES}
    ${Boost_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
    )
include_directories(
    ${PLIB_INCLUDE_DIRS}
    ${Boost_INCLUDE_DIRS}
    )
if (APPLE)
    link_libraries(
        ${COREFOUNDATION_LIBRARY}
        ${IOKIT_LIBRARY}
        )
endif()

set(SUPPORT_HDRS
    Joystick.hpp
    AsyncSerial.hpp
    MAVLinkParser.hpp
    utilities.hpp
    )

set(SUPPORT_SRCS
    Joystick.cpp
    AsyncSerial.cpp
    MAVLinkParser.cpp
    utilities.cpp
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
set(SCILAB_PROGRAM scilab-adv-cli)
add_custom_command(OUTPUT "toolbox-build-stamp"
    COMMAND "${CMAKE_COMMAND}" -E chdir "${CMAKE_SOURCE_DIR}/xcos"
    ${SCILAB_PROGRAM} "-nb" "-nw" "-e" "\"exec('builder.sce');exit\""
    COMMAND "${CMAKE_COMMAND}" -E touch toolbox-build-stamp
    DEPENDS support
    )
add_custom_target(toolbox ALL DEPENDS toolbox-build-stamp)
