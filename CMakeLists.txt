cmake_minimum_required(VERSION 2.8)

project(arktoolbox)

set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 0)
set(CPACK_PACKAGE_VERSION_PATCH 0)
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_GENERATOR "ZIP")
set(CPACK_SOURCE_GENERATOR "ZIP")
include(CPack)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

find_package(PLIB 1.8.5 COMPONENTS js)

add_subdirectory(src)

install(DIRECTORY "${PROJECT_SOURCE_DIR}/xcos/"
    DESTINATION "."
    COMPONENT xcos
    PATTERN "*.git*" EXCLUDE
    )
