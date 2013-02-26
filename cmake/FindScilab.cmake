# - Try to find  SCILAB
# Once done, this will define
#
#  SCILAB_FOUND - system has scilab 
#  SCILAB_INCLUDE_DIRS - the scilab include directories
#  SCILAB_CONTRIB_DIR - the scilab contrib directory
#  SCILAB_LIBRARIES - the scilab library to link against, only on win
#  SCILAB_ADV_CLI - the scilab program

# macros
include(FindPackageHandleStandardArgs)

set(_SCILAB_EXTRA_SEARCH_PATHS
    /home/jgoppert
    /usr/local
    /opt/local
    /Program\ Files
    )

# find scilab app on mac
if (APPLE)
    execute_process(COMMAND mdfind "kMDItemKind == Application && kMDItemDisplayName == scilab*"
        COMMAND head -1
        RESULT_VARIABLE RESULT
        OUTPUT_VARIABLE _SCILAB_APP
        ERROR_VARIABLE ERROR_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (RESULT) 
        MESSAGE(FATAL_ERROR "Could not locate 'Scilab.app' - ${ERROR_MESSAGE}")
    endif (RESULT)
    list(APPEND _SCILAB_EXTRA_SEARCH_PATHS ${_SCILAB_APP}/Contents/MacOS)
endif()

# root directory
find_path(_SCILAB_ROOT
    NAMES include/scilab/version.h
    PATHS ${_SCILAB_EXTRA_SEARCH_PATHS}
    )

# include directory
find_path(_SCILAB_INCLUDE_DIR
    NAMES scilab/version.h 
    PATHS ${_SCILAB_ROOT}
    PATH_SUFFIXES include
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# contrib directory
find_path(_SCILAB_CONTRIB_DIR
    NAMES loader.sce
    PATHS ${_SCILAB_ROOT}
    PATH_SUFFIXES share/scilab/contrib
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

find_library(_SCILAB_LIBRARY
    NAMES libscilab
    PATHS ${_SCILAB_ROOT}
    PATH_SUFFIXES lib/scilab
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# scilab program
if (WIN32)
    set(_SCILAB_SCILAB_NAMES cscilex.exe)
else()
    set(_SCILAB_SCILAB_NAMES scilab)
endif()
find_program(_SCILAB_ADV_CLI
    NAMES scilab-adv-cli
    PATHS ${_SCILAB_ROOT}
    PATH_SUFFIXES bin
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# read the version
if (EXISTS ${_SCILAB_ROOT}/include/scilab/version.h)
    file(READ ${_SCILAB_ROOT}/include/scilab/version.h _SCILAB_CONFIG_FILE)

    string(REGEX MATCH "SCI_VERSION_MAJOR[ \t]+([0-9]+)"
        _SCILAB_VERSION_MATCH ${_SCILAB_CONFIG_FILE})
    set(_SCILAB_VERSION_MAJOR ${CMAKE_MATCH_1})

    string(REGEX MATCH ".*SCI_VERSION_MINOR[ \t]+([0-9]+)"
        _SCILAB_VERSION_MATCH ${_SCILAB_CONFIG_FILE})
    set(_SCILAB_VERSION_MINOR ${CMAKE_MATCH_1})

    string(REGEX MATCH ".*SCI_VERSION_MAINTENANCE[ \t]+([0-9]+)"
        _SCILAB_VERSION_MATCH ${_SCILAB_CONFIG_FILE})
    set(_SCILAB_VERSION_MAINTENANCE ${CMAKE_MATCH_1})

    if ("${_SCILAB_VERSION_MAJOR}" STREQUAL "" OR 
        "${_SCILAB_VERSION_MINOR}" STREQUAL "" OR 
        "${_SCILAB_VERSION_MAINTENANCE}" STREQUAL "") 
        message(WARNING "could not find scilab version")
        set(SCILAB_VERSION "")
    else()
        set(SCILAB_VERSION "${_SCILAB_VERSION_MAJOR}.${_SCILAB_VERSION_MINOR}.${_SCILAB_VERSION_MAINTENANCE}")
    endif()
else()
    set(SCILAB_VERSION "")
endif()

# set output variables
set(SCILAB_INCLUDE_DIRS ${_SCILAB_INCLUDE_DIR})
set(SCILAB_LIBRARIES ${_SCILAB_SCICOS_LIBRARY})
set(SCILAB_ADV_CLI ${_SCILAB_ADV_CLI})
set(SCILAB_CONTRIB_DIR ${_SCILAB_CONTRIB_DIR})

# handle wine overrides on output variables
string(REGEX MATCH ".*/\\.wine/drive_c/(.*)" _SCILAB_SCILAB_WINE_MATCH ${_SCILAB_ROOT})
if (NOT "${_SCILAB_SCILAB_WINE_MATCH}" STREQUAL "")
    #message(STATUS "detected wine version of scilab")
    set(SCILAB_ADV_CLI "wine" "${_SCILAB_ADV_CLI}")
    set(SCILAB_CONTRIB_DIR "C:\${CMAKE_MATCH_1}")
endif()

# handle arguments
set(_SCILAB_REQUIRED_VARS
    SCILAB_ADV_CLI
    SCILAB_INCLUDE_DIRS
    SCILAB_CONTRIB_DIR
    SCILAB_VERSION
    )
if (WIN32)
    list(INSERT _SCILAB_REQUIRED_VARS 0 SCILAB_SCICOS_LIBRARIES)
endif()
find_package_handle_standard_args(Scilab
    REQUIRED_VARS ${_SCILAB_REQUIRED_VARS}
    VERSION_VAR SCILAB_VERSION
    )
# vim:ts=4:sw=4:expandtab
