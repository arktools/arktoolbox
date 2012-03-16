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

# find the include directory
find_path(_JSBSIM_INCLUDE_DIR
	NAMES jsbsim/initialization/FGTrimmer.h
    )

# find the library
find_library(_JSBSIM_LIBRARY
	NAMES jsbsim
    )

# find the data directory
find_path(JSBSIM_DATADIR
	NAMES jsbsim/aircraft/737/737.xml
    PATH_SUFFIXES share
    )

# read the version
if (EXISTS ${_JSBSIM_INCLUDE_DIR}/jsbsim/config.h)
    file(READ ${_JSBSIM_INCLUDE_DIR}/jsbsim/config.h JSBSIM_CONFIG_FILE)
    string(REGEX MATCH "#define JSBSIM_VERSION[ ]+\"([0-9]\\.[0-9]\\.[0-9])\""
        JSBSIM_VERSION_MATCH ${JSBSIM_CONFIG_FILE})
    set(JSBSIM_VERSION ${CMAKE_MATCH_1})
endif()

# handle arguments
set(JSBSIM_INCLUDE_DIRS ${_JSBSIM_INCLUDE_DIR} ${_JSBSIM_INCLUDE_DIR}/jsbsim)
set(JSBSIM_LIBRARIES ${_JSBSIM_LIBRARY})
find_package_handle_standard_args(JSBSim
    REQUIRED_VARS JSBSIM_LIBRARIES JSBSIM_INCLUDE_DIRS JSBSIM_DATADIR 
    VERSION_VAR JSBSIM_VERSION
    )
