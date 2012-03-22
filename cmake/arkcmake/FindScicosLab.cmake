# - Try to find  SCICOSLAB
# Once done, this will define
#
#  SCICOSLAB_FOUND - system has scicoslab 
#  SCICOSLAB_INCLUDE_DIRS - the scicoslab include directories
#  SCICOSLAB_CONTRIB_DIR - the scicoslab contrib directory
#  SCICOSLAB_LIBRARIES - the scicoslab library to link against, only on win
#  SCICOSLAB_SCILAB_PROGRAM - the scilab program

# macros
include(FindPackageHandleStandardArgs)

set(_SCICOSLAB_EXTRA_SEARCH_PATHS
    /usr/local
    /opt/local
    /Program\ Files
    )

set(_SCICOSLAB_VERSIONS
    4.4b7
    4.4
    4.4.1
    )

set(_SCICOSLAB_GUESS_SUFFIXES "")
foreach(_SCICOSLAB_VERSION ${_SCICOSLAB_VERSIONS})
    list(APPEND _SCICOSLAB_GUESS_SUFFIXES lib/scicoslab-gtk-${_SCICOSLAB_VERSION})
    list(APPEND _SCICOSLAB_GUESS_SUFFIXES lib/scicoslab-${_SCICOSLAB_VERSION})
    list(APPEND _SCICOSLAB_GUESS_SUFFIXES scicoslab-gtk-${_SCICOSLAB_VERSION})
    list(APPEND _SCICOSLAB_GUESS_SUFFIXES scicoslab-${_SCICOSLAB_VERSION})
endforeach()

# find scicos app on mac
if (APPLE)
    execute_process(COMMAND mdfind "kMDItemKind == Application && kMDItemDisplayName == ScicosLabGtk"
        COMMAND head -1
        RESULT_VARIABLE RESULT
        OUTPUT_VARIABLE _SCICOSLAB_APP
        ERROR_VARIABLE ERROR_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (RESULT) 
        MESSAGE(FATAL_ERROR "Could not locate 'ScicosLabGtk.app' - ${ERROR_MESSAGE}")
    endif (RESULT)
    list(APPEND _SCICOSLAB_GUESS_SUFFIXES ${_SCICOSLAB_APP})
endif()

# root directory
find_path(_SCICOSLAB_ROOT
    NAMES routines/scicos/scicos_block4.h
    PATHS ${_SCICOSLAB_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES ${_SCICOSLAB_GUESS_SUFFIXES}
    )

# include directory
find_path(_SCICOSLAB_INCLUDE_DIR
    NAMES scicos/scicos_block4.h
    PATHS ${_SCICOSLAB_ROOT}
    PATH_SUFFIXES routines
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# contrib directory
find_path(_SCICOSLAB_CONTRIB_DIR
    NAMES loader.sce
    PATHS ${_SCICOSLAB_ROOT}
    PATH_SUFFIXES contrib
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# library
find_library(_SCICOSLAB_LIBRARY
    NAMES LibScilab
    PATHS ${_SCICOSLAB_ROOT}
    PATH_SUFFIXES bin
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# scicoslab program
if (WIN32)
    set(_SCICOSLAB_SCILAB_NAMES cscilex.exe)
else()
    set(_SCICOSLAB_SCILAB_NAMES scilab)
endif()
find_program(_SCICOSLAB_SCILAB_PROGRAM
    NAMES ${_SCICOSLAB_SCILAB_NAMES}
    PATHS ${_SCICOSLAB_ROOT}
    PATH_SUFFIXES bin
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# read the version
if (EXISTS ${_SCICOSLAB_ROOT}/config/configuration)
    file(READ ${_SCICOSLAB_ROOT}/config/configuration _SCICOSLAB_CONFIG_FILE)
    string(REGEX MATCH "PACKAGE_VERSION[ \t]+\\:(([0-9]+\\.)+[0-9]+)"
        _SCICOSLAB_VERSION_MATCH ${_SCICOSLAB_CONFIG_FILE})
    set(SCICOSLAB_VERSION ${CMAKE_MATCH_1})
else()
    set(SCICOSLAB_VERSION "")
endif()

# set output variables
set(SCICOSLAB_INCLUDE_DIRS ${_SCICOSLAB_INCLUDE_DIR})
set(SCICOSLAB_LIBRARIES ${_SCICOSLAB_LIBRARY})
set(SCICOSLAB_SCILAB_PROGRAM ${_SCICOSLAB_SCILAB_PROGRAM})
set(SCICOSLAB_CONTRIB_DIR ${_SCICOSLAB_CONTRIB_DIR})

# handle wine overrides on output variables
string(REGEX MATCH ".*/\\.wine/drive_c/(.*)" _SCICOSLAB_SCILAB_WINE_MATCH ${_SCICOSLAB_ROOT})
if (NOT "${_SCICOSLAB_SCILAB_WINE_MATCH}" STREQUAL "")
    #message(STATUS "detected wine version of scicoslab")
    set(SCICOSLAB_SCILAB_PROGRAM "wine" "${_SCICOSLAB_SCILAB_PROGRAM}")
    set(SCICOSLAB_CONTRIB_DIR "C:\${CMAKE_MATCH_1}")
endif()

# handle arguments
set(_SCICOSLAB_REQUIRED_VARS
    SCICOSLAB_SCILAB_PROGRAM
    SCICOSLAB_INCLUDE_DIRS
    SCICOSLAB_CONTRIB_DIR
    SCICOSLAB_VERSION
    )
if (WIN32)
    list(INSERT _SCICOSLAB_REQUIRED_VARS 0 SCICOSLAB_LIBRARIES)
endif()
find_package_handle_standard_args(ScicosLab
    REQUIRED_VARS ${_SCICOSLAB_REQUIRED_VARS}
    VERSION_VAR SCICOSLAB_VERSION
    )
# vim:ts=4:sw=4:expandtab
