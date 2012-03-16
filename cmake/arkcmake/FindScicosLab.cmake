# - Try to find  SCICOSLAB
# Once done, this will define
#
#  SCICOSLAB_FOUND - system has scicoslab 
#  SCICOSLAB_INCLUDE_DIRS - the scicoslab include directories
#  SCICOSLAB_CONTRIB_DIR - the scicoslab contrib directory

# macros
include(FindPackageHandleStandardArgs)

set(_SCICOSLAB_EXTRA_SEARCH_PATHS
    /usr/local
    /opt/local
    )

set(_SCICOSLAB_GUESS_SUFFIXES
    scicoslab-gtk-4.4b7
    scicoslab-gtk-4.4
    scicoslab-gtk-4.4.1
    )
foreach(_SCICOSLAB_GUESS_SUFFIX ${_SCICOSLAB_GUESS_SUFFIXES})
    list(APPEND _SCICOSLAB_GUESS_SUFFIXES lib/${_SCICOSLAB_GUESS_SUFFIX})
endforeach()

# find scicos
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

# ScicosLab Root
find_path(_SCICOSLAB_ROOT
    NAMES routines/scicos/scicos_block4.h
    PATHS ${_SCICOSLAB_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES ${_SCICOSLAB_GUESS_SUFFIXES}
    )

# Include dir
find_path(_SCICOSLAB_INCLUDE_DIR
    NAMES scicos/scicos_block4.h
    PATHS ${_SCICOSLAB_ROOT}
    PATH_SUFFIXES routines
    NO_CMAKE_PATH
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_SYSTEM_PATH
    )

# Contrib dir
find_path(SCICOSLAB_CONTRIB_DIR
    NAMES loader.sce
    PATHS ${_SCICOSLAB_ROOT}
    PATH_SUFFIXES contrib
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
endif()

# handle arguments
set(SCICOSLAB_INCLUDE_DIRS ${_SCICOSLAB_INCLUDE_DIR})
find_package_handle_standard_args(ScicosLab
    REQUIRED_VARS SCICOSLAB_INCLUDE_DIRS SCICOSLAB_CONTRIB_DIR 
    VERSION_VAR SCICOSLAB_VERSION
    )
# vim:ts=4:sw=4:expandtab
