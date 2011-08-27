# - Try to find  JSBSIM
# Once done, this will define
#
#  JSBSIM_FOUND - system has scicoslab 
#  JSBSIM_INCLUDE_DIRS - the scicoslab include directories
#  JSBSIM_LIBRARIES - libraries to link to

include(LibFindMacros)

# Include dir
find_path(JSBSIM_INCLUDE_DIR
	NAMES initialization/FGTrimmer.h
	PATHS 
		/usr/include/JSBSim
		/usr/include/jsbsim
		/usr/local/include/JSBSim
		/usr/local/include/jsbsim
)

# Finally the library itself
find_library(JSBSIM_LIBRARY
	NAMES
		jsbsim
		JSBSim
	PATHS 
		/usr/lib 
		/usr/local/lib
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(JSBSIM_PROCESS_INCLUDES JSBSIM_INCLUDE_DIR)
set(JSBSIM_PROCESS_LIBS JSBSIM_LIBRARY JSBSIM_LIBRARIES)
libfind_process(JSBSIM)
