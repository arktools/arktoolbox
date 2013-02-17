cmake_minimum_required(VERSION 2.8)

project(arktoolbox CXX)

# modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(CPack)
enable_testing()

# find packages
find_package(ARKTOOLS REQUIRED)

# find xcos compile program
find_program(SCILAB_ADV_CLI scilab-adv-cli)
if (${SCILAB_ADV_CLI} STREQUAL "SCILAB_ADV_CLI-NOTFOUND")
    message(FATAL_ERROR "Couldn't find scilab-adv-cli")
endif()

# install arktools to xcos toolbox
set(XCOS_ROOT ${CMAKE_SOURCE_DIR}/xcos/)
file(COPY ${ARKTOOLS_DATADIR}/arktools DESTINATION ${XCOS_ROOT}/support/share)
file(COPY ${ARKTOOLS_INCLUDE_DIRS}/arktools DESTINATION ${XCOS_ROOT}/support/include)
file(COPY ${ARKTOOLS_LIBRARIES} DESTINATION ${XCOS_ROOT}/support/lib)

# build xcos toolbox
file(GLOB_RECURSE XCOS_SRCS ${XCOS_ROOT} "*.sci" "*.sce" "*.*cos" "*.txt" "*.xml")
#message(STATUS "XCOS_SRCS: ${XCOS_SRCS}")
set(XCOS_ARKTOOLS_LIB ${XCOS_ROOT}/src/cpp/libarktoolbox_cpp${CMAKE_SHARED_LIBRARY_SUFFIX})
add_custom_command(OUTPUT ${XCOS_ARKTOOLS_LIB} COMMAND 
    ${CMAKE_COMMAND} -E chdir ${XCOS_ROOT}
    ${SCILAB_ADV_CLI} -nb -nw -e "\"exec('builder.sce');exit\""
    DEPENDS ${XCOS_SRCS})
add_custom_target(xcos_toolbox ALL DEPENDS ${XCOS_ARKTOOLS_LIB})

# install xcos toolbox
install(DIRECTORY ${XCOS_ROOT} DESTINATION ".")
