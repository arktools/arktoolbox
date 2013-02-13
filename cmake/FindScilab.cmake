# - Try to find  SCILAB
# Once done, this will define
#
#  SCILAB_FOUND - system has scilab 
#  SCILAB_INCLUDE_DIRS - the scilab include directories
#  SCILAB_CONTRIB_DIR - the scilab contrib directory
#  SCILAB_LIBRARIES - the scilab library to link against, only on win
#  SCILAB_PROGRAM - the scilab program

# macros
include(FindPackageHandleStandardArgs)

set(_SCILAB_EXTRA_SEARCH_PATHS
    /usr/local
    /opt/local
    /Program\ Files
    )

set(_SCILAB_GUESS_SUFFIXES "")
foreach(_SCILAB_VERSION ${_SCILAB_VERSIONS})
    list(APPEND _SCILAB_GUESS_SUFFIXES lib/scilab-gtk-${_SCILAB_VERSION})
    list(APPEND _SCILAB_GUESS_SUFFIXES lib/scilab-${_SCILAB_VERSION})
    list(APPEND _SCILAB_GUESS_SUFFIXES scilab-gtk-${_SCILAB_VERSION})
    list(APPEND _SCILAB_GUESS_SUFFIXES scilab-${_SCILAB_VERSION})
endforeach()

# find scilab app on mac
if (APPLE)
    execute_process(COMMAND mdfind "kMDItemKind == Application && kMDItemDisplayName == Scilab"
        COMMAND head -1
        RESULT_VARIABLE RESULT
        OUTPUT_VARIABLE _SCILAB_APP
        ERROR_VARIABLE ERROR_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (RESULT) 
        MESSAGE(FATAL_ERROR "Could not locate 'Scilab.app' - ${ERROR_MESSAGE}")
    endif (RESULT)
    list(APPEND _SCILAB_EXTRA_SEARCH_PATHS ${_SCILAB_APP}/Contents/Resources)
endif()

# include directory
find_path(_SCILAB_INCLUDE_DIR
    NAMES scilab/scicos_block4.h
    PATHS ${_SCILAB_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES include
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# contrib directory
find_path(_SCILAB_CONTRIB_DIR
    NAMES scilab/ACKNOWLEDGEMENTS
    PATHS ${_SCILAB_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES share
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# library
find_library(_SCILAB_LIBRARY
    NAMES libsciscicos
    PATHS ${_SCILAB_ROOT}
    PATH_SUFFIXES bin
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# scilab program
if (WIN32)
    set(_SCILAB_NAMES cscilex.exe)
else()
    set(_SCILAB_NAMES scilab)
endif()
find_program(_SCILAB_PROGRAM
    NAMES ${_SCILAB_NAMES}
    PATHS ${_SCILAB_ROOT}
    PATH_SUFFIXES bin
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# read the version
if (EXISTS ${_SCILAB_ROOT}/config/configuration)
    file(READ ${_SCILAB_ROOT}/config/configuration _SCILAB_CONFIG_FILE)
    string(REGEX MATCH "PACKAGE_VERSION[ \t]+\\:(([0-9]+\\.)+[0-9]+)"
        _SCILAB_VERSION_MATCH ${_SCILAB_CONFIG_FILE})
    set(SCILAB_VERSION ${CMAKE_MATCH_1})
    if ("${SCILAB_VERSION}" STREQUAL "")
        message(WARNING "could not find scilab version, assuming 4.4.1")
        set(SCILAB_VERSION "4.4.1")
    endif()
else()
    set(SCILAB_VERSION "")
endif()

# set output variables
set(SCILAB_INCLUDE_DIRS ${_SCILAB_INCLUDE_DIR})
set(SCILAB_LIBRARIES ${_SCILAB_LIBRARY})
set(SCILAB_PROGRAM ${_SCILAB_PROGRAM})
set(SCILAB_CONTRIB_DIR ${_SCILAB_CONTRIB_DIR})

# handle wine overrides on output variables
string(REGEX MATCH ".*/\\.wine/drive_c/(.*)" _SCILAB_WINE_MATCH ${_SCILAB_ROOT})
if (NOT "${_SCILAB_WINE_MATCH}" STREQUAL "")
    #message(STATUS "detected wine version of scilab")
    set(SCILAB_PROGRAM "wine" "${_SCILAB_PROGRAM}")
    set(SCILAB_CONTRIB_DIR "C:\${CMAKE_MATCH_1}")
endif()

# handle arguments
set(_SCILAB_REQUIRED_VARS
    SCILAB_PROGRAM
    SCILAB_INCLUDE_DIRS
    SCILAB_CONTRIB_DIR
    SCILAB_VERSION
    )
if (WIN32)
    list(INSERT _SCILAB_REQUIRED_VARS 0 SCILAB_LIBRARIES)
endif()
find_package_handle_standard_args(Scilab
    REQUIRED_VARS ${_SCILAB_REQUIRED_VARS}
    VERSION_VAR SCILAB_VERSION
    )
# vim:ts=4:sw=4:expandtab
