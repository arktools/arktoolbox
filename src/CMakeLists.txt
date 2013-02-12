set(SUPPORT_HDRS
    Joystick.hpp
    )

set(SUPPORT_SRCS
    Joystick.cpp
    )

add_library(support
    ${SUPPORT_HDRS}
    ${SUPPORT_SRCS}
    )

target_link_libraries(support ${PLIB_LIBRARIES})

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
