# - Try to find  SIMGEAR
# Once done, this will define
#
#  SIMGEAR_FOUND - system has scicoslab 
#  SIMGEAR_INCLUDE_DIRS - the scicoslab include directories
#  SIMGEAR_LIBRARIES - libraries to link to

include(LibFindMacros)

# Include dir
find_path(SIMGEAR_INCLUDE_DIR
	NAMES version.h
	PATHS 
  		/usr/include/simgear
  		/usr/local/include/simgear
)

# Finally the library itself
find_library(SIMGEAR_LIBRARY
	NAMES sgio
	PATHS 
		/usr/lib 
		/usr/local/lib
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(SIMGEAR_PROCESS_INCLUDES SIMGEAR_INCLUDE_DIR)
set(SIMGEAR_PROCESS_LIBS SIMGEAR_LIBRARY SIMGEAR_LIBRARIES)
libfind_process(SIMGEAR)
