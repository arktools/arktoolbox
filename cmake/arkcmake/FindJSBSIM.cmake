# - Try to find  JSBSIM
# Once done, this will define
#
#  JSBSIM_FOUND - system has jsbsim 
#  JSBSIM_INCLUDE_DIRS - the jsbsim include directories
#  JSBSIM_LIBRARIES - libraries to link to

include(LibFindMacros)
include(MacroCommonPaths)

MacroCommonPaths(JSBSIM)

# Include dir
find_path(JSBSIM_INCLUDE_DIR
    NAMES jsbsim/initialization/FGTrimmer.h
    PATHS ${COMMON_DATA_PATHS_JSBSIM}
)

# data dir
find_path(JSBSIM_DATA_DIR
    NAMES jsbsim/aircraft/aircraft_template.xml
    PATHS ${COMMON_DATA_PATHS_JSBSIM}
)

# Finally the library itself
find_library(JSBSIM_LIBRARY
    NAMES jsbsim JSBSim libjsbsim
    PATHS ${COMMON_LIBRARY_PATHS_JSBSIM}
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(JSBSIM_INCLUDE_DIR_LOCAL ${JSBSIM_INCLUDE_DIR}/jsbsim)
set(JSBSIM_PROCESS_INCLUDES JSBSIM_INCLUDE_DIR_LOCAL)
set(JSBSIM_PROCESS_LIBS JSBSIM_LIBRARY JSBSIM_LIBRARIES)

libfind_process(JSBSIM)
