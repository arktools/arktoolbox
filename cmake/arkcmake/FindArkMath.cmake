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

# find the include directory
find_path(_ARKMATH_INCLUDE_DIR
	NAMES arkmath/storage_adaptors.hpp
    )

# find the library
find_library(_ARKMATH_LIBRARY
	NAMES arkmath
    )

# find the data directory
find_path(ARKMATH_DATADIR
	NAMES arkmath/data/WMM.COF
    PATH_SUFFIXES share
    )

# read the version
if (EXISTS ${_ARKMATH_INCLUDE_DIR}/VERSION)
    file(READ ${_ARKMATH_INCLUDE_DIR}/VERSION ARKMATH_VERSION)
endif()

# handle arguments
set(ARKMATH_INCLUDE_DIRS ${_ARKMATH_INCLUDE_DIR})
set(ARKMATH_LIBRARIES ${_ARKMATH_LIBRARY})
find_package_handle_standard_args(ArkMath
    REQUIRED_VARS ARKMATH_DATADIR ARKMATH_LIBRARIES ARKMATH_INCLUDE_DIRS
    VERSION_VAR OSGPLUGIN_VERSION
    )
