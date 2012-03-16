# - Try to find  ArkMath
# Once done, this will define
#
#  ARKMATH_FOUND        : library found
#  ARKMATH_INCLUDE_DIRS : include directories
#  ARKMATH_LIBRARIES    : libraries to link to
#  ARKMATH_DATADIR      : data directory 
#  ARKMATH_VERSION      : version

# macros
include(FindPackageHandleStandardArgs)

set(_ARKMATH_EXTRA_SEARCH_PATHS
    /usr/local
    /opt/local
    )

# find the include directory
find_path(_ARKMATH_INCLUDE_DIR
	NAMES arkmath/storage_adaptors.hpp
    PATHS ${_ARKMATH_EXTRA_SEARCH_PATHS}
    )

# find the library
find_library(_ARKMATH_LIBRARY
	NAMES arkmath
    PATHS ${_ARKMATH_EXTRA_SEARCH_PATHS}
    )

# find the data directory
find_path(ARKMATH_DATADIR
	NAMES arkmath/data/WMM.COF
    PATH_SUFFIXES share
    PATHS ${_ARKMATH_EXTRA_SEARCH_PATHS}
    )

# read the version
if (EXISTS ${_ARKMATH_INCLUDE_DIR}/arkmath/config.h)
    file(READ ${_ARKMATH_INCLUDE_DIR}/arkmath/config.h ARKMATH_CONFIG_FILE)
    string(REGEX MATCH "#define ARKMATH_VERSION[ ]+\"([0-9]\\.[0-9]\\.[0-9])\""
        ARKMATH_VERSION_MATCH ${ARKMATH_CONFIG_FILE})
    set(ARKMATH_VERSION ${CMAKE_MATCH_1})
endif()

# handle arguments
set(ARKMATH_INCLUDE_DIRS ${_ARKMATH_INCLUDE_DIR})
set(ARKMATH_LIBRARIES ${_ARKMATH_LIBRARY})
find_package_handle_standard_args(ArkMath
    REQUIRED_VARS ARKMATH_LIBRARIES ARKMATH_INCLUDE_DIRS ARKMATH_DATADIR 
    VERSION_VAR ARKMATH_VERSION
    )
