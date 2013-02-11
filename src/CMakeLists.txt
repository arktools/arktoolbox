add_library(support
    Joystick.cpp
    )

target_link_libraries(support ${PLIB_LIBRARIES})

# copy support library to xcos bin directory
get_target_property(supportPath support LOCATION)
add_custom_command(
    TARGET support POST_BUILD 
    COMMAND ${CMAKE_COMMAND} 
    ARGS -E copy ${supportPath} ${CMAKE_SOURCE_DIR}/xcos/bin
    )
