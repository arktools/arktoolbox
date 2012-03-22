# - Try to find  JSBSim
# Once done, this will define
#
#  JSBSIM_FOUND        : library found
#  JSBSIM_INCLUDE_DIRS : include directories
#  JSBSIM_LIBRARIES    : libraries to link to
#  JSBSIM_DATADIR      : data directory 
#  JSBSIM_VERSION      : version

# macros
include(FindPackageHandleStandardArgs)

find_package(SimGear QUIET COMPONENTS io props xml structure misc debug magvar)

set(_JSBSIM_EXTRA_SEARCH_PATHS
    /usr/local
    /opt/local
    )

# find the include directory
find_path(_JSBSIM_INCLUDE_DIR
	NAMES jsbsim/initialization/FGTrimmer.h
    PATHS ${_JSBSIM_EXTRA_SEARCH_PATHS}
    )

# find the library
find_library(_JSBSIM_LIBRARY
	NAMES jsbsim
    PATHS ${_JSBSIM_EXTRA_SEARCH_PATHS}
    )

# find the data directory
find_path(JSBSIM_DATADIR
	NAMES jsbsim/aircraft/737/737.xml
    PATH_SUFFIXES share
    PATHS ${_JSBSIM_EXTRA_SEARCH_PATHS}
    )

# read the version
if (EXISTS ${_JSBSIM_INCLUDE_DIR}/jsbsim/config.h)
    file(READ ${_JSBSIM_INCLUDE_DIR}/jsbsim/config.h _JSBSIM_CONFIG_FILE)
    string(REGEX MATCH "#define JSBSIM_VERSION[ ]+\"(([0-9]+\\.)+[0-9]+)\""
        JSBSIM_VERSION_MATCH ${_JSBSIM_CONFIG_FILE})
    set(JSBSIM_VERSION ${CMAKE_MATCH_1})
else()
    set(JSBSIM_VERSION "")
endif()

# handle arguments
set(JSBSIM_INCLUDE_DIRS ${_JSBSIM_INCLUDE_DIR} ${_JSBSIM_INCLUDE_DIR}/jsbsim)
set(JSBSIM_LIBRARIES ${_JSBSIM_LIBRARY} ${SIMGEAR_LIBRARIES})
find_package_handle_standard_args(JSBSim
    REQUIRED_VARS JSBSIM_LIBRARIES JSBSIM_INCLUDE_DIRS JSBSIM_DATADIR JSBSIM_VERSION
    VERSION_VAR JSBSIM_VERSION
    )
