# - Try to find  arktools
# Once done, this will define
#
#  ARKTOOLS_FOUND        : library found
#  ARKTOOLS_INCLUDE_DIRS : include directories
#  ARKTOOLS_LIBRARIES    : libraries to link to
#  ARKTOOLS_DATADIR      : data directory 
#  ARKTOOLS_VERSION      : version

# macros
include(FindPackageHandleStandardArgs)

set(_ARKTOOLS_EXTRA_SEARCH_PATHS
    /usr/local
    /opt/local
    )

# find the include directory
find_path(_ARKTOOLS_INCLUDE_DIR
	NAMES arktools/osgUtils.hpp
    PATHS ${_ARKTOOLS_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES include
    )

# find the library
find_library(_ARKTOOLS_LIBRARY
	NAMES arktools_core
    PATHS ${_ARKTOOLS_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES lib
    )

# find the data directory
find_path(ARKTOOLS_DATADIR
	NAMES arktools/images/ocean.rgb
    PATHS ${_ARKTOOLS_EXTRA_SEARCH_PATHS}
    PATH_SUFFIXES share
    )

# read the version
if (EXISTS ${_ARKTOOLS_INCLUDE_DIR}/arktools/config.h)
    file(READ ${_ARKTOOLS_INCLUDE_DIR}/arktools/config.h ARKTOOLS_CONFIG_FILE)
    string(REGEX MATCH "#define ARKTOOLS_VERSION[ ]+\"(([0-9]+\\.)+[0-9]+)\""
        _ARKTOOLS_VERSION_MATCH ${ARKTOOLS_CONFIG_FILE})
    set(ARKTOOLS_VERSION ${CMAKE_MATCH_1})
else()
    set(ARKTOOLS_VERSION "")
endif()

# handle arguments
set(ARKTOOLS_INCLUDE_DIRS ${_ARKTOOLS_INCLUDE_DIR})
set(ARKTOOLS_LIBRARIES ${_ARKTOOLS_LIBRARY})
find_package_handle_standard_args(arktools
    REQUIRED_VARS ARKTOOLS_LIBRARIES ARKTOOLS_INCLUDE_DIRS ARKTOOLS_DATADIR ARKTOOLS_VERSION
    VERSION_VAR ARKTOOLS_VERSION
    )
