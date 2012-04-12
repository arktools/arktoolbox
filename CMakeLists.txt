project (arktoolbox C CXX)

# Requried cmake version
cmake_minimum_required (VERSION 2.8)
set(PROJECT_VERSION_MAJOR "0")
set(PROJECT_VERSION_MINOR "9")
set(PROJECT_VERSION_PATCH "1")
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(PROJECT_CONTACT_EMAIL james.goppert@gmail.com)
set(PROJECT_CONTACT_VENDOR arktools)
set(LIBRARY_VERSION ${PROJECT_VERSION})
set(LIBRARY_SOVERSION "0.0.0")

# third party library version
set(ARKOSG_REQUIRED_VERSION             0.3.0)
set(ARKCOMM_REQUIRED_VERSION            0.1.8)
set(ARKMATH_REQUIRED_VERSION            0.2.7)
set(ARKHANGAR_REQUIRED_VERSION          1.3.0)
set(JSBSIM_REQUIRED_VERSION             1.0.0.113) 
set(SCICOSLAB_REQUIRED_VERSION          4.4.1) 
set(OPENSCENEGRAPH_REQUIRED_VERSION     2.8.3) 
set(BOOST_REQUIRED_VERSION              1.42.0) 
set(SIMGEAR_REQUIRED_VERSION            2.7.0) 
set(PLIB_REQUIRED_VERSION               1.8.5) 

# tags
set(ARKOSG_TAG      e31f22c0b8584f7d0fd01405a68560049f94dfe2)
set(ARKCOMM_TAG     877f135c3bf1b76215c7f3426d1e1df964e9ad9e)
set(ARKMATH_TAG     445935e60aeaa3dd97df085a8907f464e77ed47c)
set(ARKHANGAR_TAG   4a0633892be6f9993d2dfe86b969c9ab93ebc87e)
set(JSBSIM_TAG      3cd13dd303f5c0be3511762841cdb9e67e6d26ea)
set(SIMGEAR_TAG     9ab31e0d88ef2a09f6a8dd33837ba547366151fa)

# md5 check sums
set(PLIB_MD5        47a6fbf63668c1eed631024038b2ea90)

# options
option(WITH_BUILD_DEPS "Build dependencies." ON)
option(WITH_PREFER_STATIC "Build preferring static linking." ON)
option(WITH_ARKOSG "Build arkosg graphics." ON)
option(WITH_JOYSTICK "Build joystick support." ON)
option(WITH_LAPACK "Use lapack libraries." OFF)
option(WITH_WARNINGS "Enable warnings." OFF)
option(WITH_TESTING "Enable testing." OFF)

# options to cmake
# when building dependencies
set(RECURSE_OPTIONS_LIST
    WITH_BUILD_DEPS
    WITH_PREFER_STATIC
    WITH_ARKOSG
    WITH_JOYSTICK
    WITH_LAPACK
    WITH_WARNINGS
    WITH_TESTING
    CMAKE_TOOLCHAIN_FILE
    CMAKE_INSTALL_PREFIX
    EP_BASE_DIR
)

# variables
set(ROOT_THREAD TRUE CACHE INTERNAL "Is this the top level of the recursion?")

# modules
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake
    ${CMAKE_SOURCE_DIR}/cmake/arkcmake
    )
if (WITH_LAPACK)
    include(language_support_v2)
    enable_language(Fortran)
endif()
include(DefineCMakeDefaults)
include(DefineCompilerFlags)
include(BundleUtilities)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckLibraryExists)
#include(CheckTypeSize)
#include(CheckPrototypeExists)
#include(CheckCXXSourceCompiles)
#include(CheckCSourceCompiles)
include(ExternalProjectWithFilename)
include(GlobCopyTracked)
enable_testing()
include(CTest)

# external projects find path
if(NOT EP_BASE_DIR)
    set(EP_BASE_DIR "${CMAKE_BINARY_DIR}/CMakeExternals")
endif()
set_property(DIRECTORY PROPERTY EP_BASE ${EP_BASE_DIR})
set(EP_INSTALL_DIR "${EP_BASE_DIR}/Install")

# prefer opt local directory for libs on apple
if(APPLE)
    list(APPEND CMAKE_FIND_ROOT_PATH "/opt/local/include")
    set(CMAKE_MODULE_SUFFIX ".so")
else()
    set(CMAKE_MODULE_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
endif()

list(APPEND CMAKE_FIND_ROOT_PATH ${EP_INSTALL_DIR})

# warnings
if (WITH_WARNINGS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99 -pedantic")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wshadow -Wmissing-prototypes -Wdeclaration-after-statement")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wunused -Wfloat-equal -Wpointer-arith -Wwrite-strings -Wformat-security")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wmissing-format-attribute")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wshadow")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wunused -Wfloat-equal -Wpointer-arith -Wwrite-strings -Wformat-security")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wmissing-format-attribute")
endif()

# spawn new cmake to build deps
if (WITH_BUILD_DEPS AND ROOT_THREAD)
    set(CMAKE_RECURSE_ARGS "-DROOT_THREAD=FALSE")
    foreach(OPT ${RECURSE_OPTIONS_LIST})
        list(APPEND CMAKE_RECURSE_ARGS "-D${OPT}=${${OPT}}")
    endforeach()
    execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} ${CMAKE_RECURSE_ARGS}
        RESULT_VARIABLE ERROR)
    if (ERROR)
        message(FATAL_ERROR "error, recursing loop returned error code: ${ERROR}")
    endif()
    message("** Making dependencies")
    if("${RECURSE_THREADS}" STREQUAL "")
        set(RECURSE_THREADS "1")
    endif()
    execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} "-j${RECURSE_THREADS}" "-f${CMAKE_BINARY_DIR}/Makefile")
    message("** Configuring ${PROJECT_NAME}")
endif()

# add wine to find path
if (MINGW)
    list(APPEND CMAKE_FIND_ROOT_PATH "$ENV{HOME}/.wine/drive_c")
endif()

# prefer static packages if building static library
message("** Finding libraries")
if (WITH_PREFER_STATIC)
    set(BOOST_USE_STATIC_LIBS ON)
    # prefer static libs
    if(WIN32)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif()
endif()

# find libraries with cmake modules
set(REQUIRED_IF_ROOT_THREAD)
if (ROOT_THREAD)
    set(REQUIRED_IF_ROOT_THREAD "REQUIRED")
endif()
find_package(ScicosLab REQUIRED ${SCICOSLAB_REQUIRED_VERSION})
if (MSVC)
    set(Boost_USE_MULITHREADED ON)
    find_package(Boost ${BOOST_REQUIRED_VERSION} COMPONENTS thread system REQUIRED)
elseif(MINGW)
    find_package(Boost ${BOOST_REQUIRED_VERSION} COMPONENTS thread_win32-mt system-mt REQUIRED)
else()
    find_package(Boost ${BOOST_REQUIRED_VERSION} COMPONENTS thread-mt system-mt REQUIRED)
endif()
if (WITH_LAPACK)
    find_package(LAPACK REQUIRED)
endif()
if (WITH_ARKOSG)
    find_package(OpenSceneGraph ${OPENSCENEGRAPH_REQUIRED_VERSION} REQUIRED COMPONENTS osgViewer osgUtil osgDB osgGA osgManipulator)

    # find osg plugins
    find_package(OsgPlugin ${OPENSCENEGRAPH_REQUIRED_VERSION} REQUIRED COMPONENTS ac rgb)

    find_package(OpenGL REQUIRED)
    find_package(ArkOsg ${ARKOSG_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
endif()
find_package(ArkComm ${ARKCOMM_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(ArkMath ${ARKMATH_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(ArkHangar ${ARKHANGAR_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(JSBSim ${JSBSIM_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD})
find_package(SimGear ${SIMGEAR_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD} COMPONENTS io props xml structure misc debug magvar)
if (WITH_JOYSTICK)
    find_package(PLIB ${PLIB_REQUIRED_VERSION} ${REQUIRED_IF_ROOT_THREAD} COMPONENTS js ul)
endif()

# build dependencies
if (WITH_BUILD_DEPS AND (NOT ROOT_THREAD) )
    message("** Configuring dependencies")

    # add external projects 
    set(CMAKE_EP_DEFAULT_ARGS
        -DEP_BASE_DIR=${EP_BASE_DIR}
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DWITH_BUILD_DEPS=${WITH_BUILD_DEPS}
        -DCMAKE_FIND_ROOT=${CMAKE_FIND_ROOT}
        )

    if (NOT SIMGEAR_FOUND)
        ExternalProjectWithFilename_Add(simgear
            URL http://gitorious.org/fg/jgopperts-simgear/archive-tarball/${SIMGEAR_TAG}
            FILENAME jgoppert-jgopperts-simgear-mingw-fix.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS} "-DSIMGEAR_HEADLESS=ON" "-DENABLE_TESTS=OFF"
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${E_INSTALL_DIR}
            TIMEOUT 100
           )
    endif()

    if (NOT JSBSIM_FOUND)
        ExternalProjectWithFilename_Add(jsbsim
            URL http://nodeload.github.com/arktools/jsbsim/tarball/${JSBSIM_TAG}
            FILENAME jsbsim-${JSBSIM_TAG}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
            )
        if (NOT SIMGEAR_FOUND)
            add_dependencies(jsbsim simgear)
        endif()
    endif()

    if (WITH_ARKOSG AND (NOT ARKOSG_FOUND))
        ExternalProjectWithFilename_Add(arkosg
            URL http://nodeload.github.com/arktools/arkosg/tarball/${ARKOSG_TAG}
            FILENAME arkosg-${ARKOSG_TAG}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
        )
    endif()

    if (NOT ARKHANGAR_FOUND)
        ExternalProjectWithFilename_Add(arkhangar
            URL http://nodeload.github.com/arktools/arkhangar/tarball/${ARKHANGAR_TAG}
            FILENAME arkhangar-${ARKHANGAR_TAG}.tar.gz 
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
        )
    endif()

    if (NOT ARKMATH_FOUND)
        ExternalProjectWithFilename_Add(arkmath
            URL http://nodeload.github.com/arktools/arkmath/tarball/${ARKMATH_TAG}
            FILENAME arkmath-${ARKMATH_TAG}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS} "-DWITH_LAPACK=${WITH_LAPACK}"
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
           )
    endif()

    if (NOT ARKCOMM_FOUND)
        ExternalProjectWithFilename_Add(arkcomm
            URL http://nodeload.github.com/arktools/arkcomm/tarball/${ARKCOMM_TAG}
            FILENAME arkcomm-${ARKCOMM_TAG}.tar.gz
            CMAKE_ARGS ${CMAKE_EP_DEFAULT_ARGS}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
           )
        if (NOT SIMGEAR_FOUND)
            add_dependencies(arkcomm simgear)
        endif()
    endif()

    if (WITH_JOYSTICK AND (NOT PLIB_FOUND))
        set(PLIB_CONFIG
            "--prefix=${CMAKE_INSTALL_PREFIX}"
            "--disable-fnt"
            "--disable-pw"
            "--disable-net"
            "--disable-pw"
            "--disable-pui"
            "--disable-sg"
            "--disable-psl"
            "--disable-sl"
            "--disable-ssgaux"
            "--disable-ssg"
            "--disable-puaux"
            )
        if (MINGW)
            set(PLIB_CONFIG
                "--host=i686-pc-mingw32"
                "--build=i386-linux"
                "--prefix=${CMAKE_INSTALL_PREFIX}")
        else()
        endif()
        ExternalProjectWithFilename_Add(plib
            URL http://plib.sourceforge.net/dist/plib-${PLIB_REQUIRED_VERSION}.tar.gz
            FILENAME plib-${PLIB_MD5}.tar.gz
            URL_MD5 ${PLIB_MD5}
            CONFIGURE_COMMAND ./configure ${PLIB_CONFIG}
            BUILD_COMMAND ${CMAKE_MAKE_COMMAND}
            INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} DESTDIR=${EP_INSTALL_DIR} install
            INSTALL_DIR ${EP_INSTALL_DIR}
            BUILD_IN_SOURCE 1
           )
    endif()

    # terminate non root cmake thread
    return()
endif()

# configure
#check_include_files(string.h HAVE_STRING_H)
#check_function_exists(memcopy HAVE_MEMCOPY)
#check_symbol_exists(LC_MESSAGES "locale.h" HAVE_LC_MESSAGES) 
#check_library_exists(arkosg  attachNode "" HAVE_ARKOSG)

# config files
configure_file(config.h.in config.h)

# build settings
if(UNIX)
    set(PROFILING_FLAGS "-fprofile-arcs -ftest-coverage")
    set(CMAKE_C_FLAGS_PROFILING "${CMAKE_C_FLAGS_DEBUG} ${PROFILING_FLAGS}" CACHE STRING "Profiling Compiler Flags")
    set(CMAKE_CXX_FLAGS_PROFILING "${CMAKE_CXX_FLAGS_DEBUG} ${PROFILING_FLAGS}" CACHE STRING "Profiling Compiler Flags")
    set(CMAKE_SHARED_LINKER_FLAGS_PROFILING "${PROFILING_FLAGS}" CACHE STRING "Profiling Linker Flags")
    set(CMAKE_MODULE_LINKER_FLAGS_PROFILING "${PROFILING_FLAGS}" CACHE STRING "Profiling Linker Flags")
    set(CMAKE_EXEC_LINKER_FLAGS_PROFILING "${PROFILING_FLAGS}" CACHE STRING "Profiling Linker Flags")
endif()
add_definitions(-DBOOST_FILESYSTEM_VERSION=2)
set(ARKSCICOS_LIBRARIES ${SIMGEAR_LIBRARIES})
if(WITH_PREFER_STATIC OR MINGW)
    add_definitions(-DOSG_LIBRARY_STATIC)
endif()
if(WITH_ARKOSG)
    list(APPEND ARKSCICOS_LIBRARIES ${OSGPLUGIN_LIBRARIES})
endif()
if(MINGW)
    add_definitions(-D_WIN32_WINNT=0x0501)
    list(APPEND ARKSCICOS_LIBRARIES 
        ${SCICOSLAB_LIBRARIES})
elseif(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "ppc;i386;x86_64" CACHE STRING "Build architectures for OSX" FORCE)
    set(CMAKE_EXE_LINKER_FLAGS "-framework cocoa -framework carbon")
    set(CMAKE_SHARED_LINKER_FLAGS "-framework cocoa -framework carbon")
    set(CMAKE_MODULE_LINKER_FLAGS "-framework cocoa -framework carbon -undefined suppress -flat_namespace")
endif()

add_subdirectory(arktoolbox)

# install
set(ARKSCICOS_CONTRIB_DIR ${SCICOSLAB_CONTRIB_DIR})
if (WIN32)
    set(ARKSCICOS_CONTRIB_DIR "/contrib")
endif()
install(DIRECTORY "${PROJECT_BINARY_DIR}/arktoolbox-scicos"
    DESTINATION ${ARKSCICOS_CONTRIB_DIR}
    COMPONENT scicos
    PATTERN "*.git*" EXCLUDE
    PATTERN "*.cvs*" EXCLUDE
    )
install(DIRECTORY "${PROJECT_SOURCE_DIR}/xcos"
    DESTINATION ${ARKSCICOS_CONTRIB_DIR}
    COMPONENT xcos
    PATTERN "*.git*" EXCLUDE
    PATTERN "*.cvs*" EXCLUDE
    )

# tests
if (WITH_TESTING)
    if (WITH_JOYSTICK)
        add_executable(joystick src/js_demo.cxx)
        target_link_libraries(joystick ${PLIB_LIBRARIES})
    endif()
endif()

# packaging
if (WIN32)
    # set NSIS image, nsis bug requuires atleast one file with 4 slashes to install correctly
    #set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\/cmake/arktoolbox-nsis.bmp")
    #set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/cmake/arktoolbox.ico")
    #set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/cmake/arktoolbox.ico")
    set(CPACK_NSIS_INSTALL_ROOT "C:\\\\Program Files\\\\scicoslab-4.4.1")
    set(CPACK_NSIS_PACKAGE_NAME "${PROJECT_NAME} ${PROJECT_VERSION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "")
endif()
configure_file("COPYING" "COPYING.txt" COPYONLY) # adding file extensions
configure_file("README" "README.txt" COPYONLY)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_BINARY_DIR}/COPYING.txt")
set(CPACK_RESOURCE_FILE_README "${CMAKE_BINARY_DIR}/README.txt")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CPACK_RESOURCE_FILE_README}")
set(CPACK_RESOURCE_FILE_WELCOME "${CMAKE_SOURCE_DIR}/cmake/WELCOME.txt")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "autonomous robotics kit scicoslab toolbox")
set(CPACK_PACKAGE_VENDOR ${PROJECT_CONTACT_VENDOR})
set(CPACK_PACKAGE_CONTACT "${PROJECT_CONTACT_EMAIL}")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_SET_DESTDIR TRUE)
set(CPACK_COMPONENTS_GROUPING "ALL_COMPONENTS_IN_ONE")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libstdc++6, libgcc1, libc6")
if (WITH_ARKOSG)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS}, libgl1-mesa-glx")
endif()
set(CPACK_PACKAGE_EXECUTABLES
    #"command" "Description"
    )
include(CPack)
# vim:sw=4:ts=4:expandtab
