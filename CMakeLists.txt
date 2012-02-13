project (arkscicos)

# Requried cmake version
cmake_minimum_required (VERSION 2.8.2)
set(APPLICATION_VERSION_MAJOR "0")
set(APPLICATION_VERSION_MINOR "4")
set(APPLICATION_VERSION_PATCH "0")
set(LIBRARY_SOVERSION "0.0.0")
set(ARKOSG_VERSION "0.1.7")
set(ARKMATH_VERSION "81ee2f2")
set(ARKCOMM_VERSION "7a5e0f8")
set(JSBSIM_VERSION "1.0.0.101")
set(ARKHANGAR_VERSION "0.1.0")

# modules
set(CMAKE_MODULE_PATH
	${CMAKE_SOURCE_DIR}/cmake
	${CMAKE_SOURCE_DIR}/cmake/arkcmake
)
include(FindARKOSG)
include(FindARKMATH)
include(FindARKCOMM)
include(FindJSBSIM)
include(FindARKHANGAR)

# use common setup
include(CommonSetup)
set(LIBRARY_VERSION ${APPLICATION_VERSION})

# cpack
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "arkTools scicoslab toolbox")
set(CPACK_PACKAGE_VENDOR "arkTools")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "james.goppert@gmail.com")
set(CPACK_PACKAGE_CONTACT "james.goppert@gmail.com")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING.txt")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.txt")
set(CPACK_PACKAGE_VERSION_MAJOR "${APPLICATION_VERSION_MAJOR}") 
set(CPACK_PACKAGE_VERSION_MINOR "${APPLICATION_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${APPLICATION_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_SOURCE_IGNORE_FILES ${CPACK_SOURCE_IGNORE_FILES}
    /.git/;/build/;~$;.*\\\\.bin$;.*\\\\.swp$)
set(CPACK_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

if(WIN32)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_SOURCE_GENERATOR "ZIP")
elseif(APPLE)
    set(CPACK_GENERATOR "PackageMaker")
    set(CPACK_SOURCE_GENERATOR "TGZ")
elseif(UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_SOURCE_GENERATOR "TGZ")
else()
    message(FATAL_ERROR "unknown operating system")
endif()
include(CPack)

# settings
option(WITH_ARKOSG "Enable osg graphics windows" OFF)
option(WITH_LAPACK "Use lapack libraries" OFF)

# enable languages
enable_language(C)
enable_language(CXX)

# find libraries with cmake modules
find_package(SCICOSLAB REQUIRED)
find_package(Boost 1.42 REQUIRED COMPONENTS thread-mt system-mt)

if (WITH_LAPACK)
    find_package(LAPACK)
endif()

find_package(ARKCOMM)
if (NOT ARKCOMM_FOUND)
    build_arkcomm(${ARKCOMM_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
endif()

find_package(ARKMATH)
if (NOT ARKMATH_FOUND)
    build_arkmath(${ARKMATH_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
endif()

if (WITH_ARKOSG)
    find_package(OpenSceneGraph 2.8.0 REQUIRED COMPONENTS osgGA osgDB osgUtil osgViewer)
    find_package(ARKOSG ${ARKOSG_VERSION})
    if (NOT ARKOSG_FOUND)
        build_arkosg(${ARKOSG_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
    endif()
endif()

find_package(ARKHANGAR)
if (NOT ARKHANGAR_FOUND)
    build_arkhangar(${ARKHANGAR_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
endif()

find_package(JSBSIM)
if (NOT JSBSIM_FOUND)
    build_jsbsim(${JSBSIM_VERSION} ${EP_BASE_DIR} ${EP_INSTALL_PREFIX} ${EP_DATADIR})
endif()

# initialize list of libraries to build with
set(ARKSCICOS_LIBRARIES "")

# install data files
install(DIRECTORY "${PROJECT_SOURCE_DIR}/projects" DESTINATION share/${PROJECT_NAME} PATTERN "*.git*" EXCLUDE)
install(DIRECTORY "${PROJECT_SOURCE_DIR}/arkscicos-toolbox"
    DESTINATION ${SCICOSLAB_CONTRIB_DIR}
    PATTERN "*.git*" EXCLUDE)

# install required dependencies from external projects
install(DIRECTORY ${EP_BASE_DIR}/${EP_INSTALL_PREFIX} DESTINATION ${CMAKE_INSTALL_PREFIX})

# pkgconfig
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc)
install(FILES
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.pc
    DESTINATION lib/pkgconfig
    )

# subdirectories
add_subdirectory(src)

# vim:sw=4:ts=4:expandtab
