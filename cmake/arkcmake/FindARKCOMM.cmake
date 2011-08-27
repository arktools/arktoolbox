# - Try to find  ARKCOMM
# Once done, this will define
#
#  ARKCOMM_FOUND - system has scicoslab 
#  ARKCOMM_INCLUDE_DIRS - the scicoslab include directories
#  ARKCOMM_LIBRARIES - libraries to link to

include(LibFindMacros)
include(MacroCommonPaths)

MacroCommonPaths(ARKCOMM)

# Include dir
find_path(ARKCOMM_INCLUDE_DIR
	NAMES arkcomm/AsyncSerial.hpp
	PATHS ${COMMON_INCLUDE_PATHS_ARKCOMM}
)

# Finally the library itself
find_library(ARKCOMM_LIBRARY
	NAMES arkcomm
	PATHS ${COMMON_LIBRARY_PATHS_ARKCOMM}
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(ARKCOMM_PROCESS_INCLUDES ARKCOMM_INCLUDE_DIR)
set(ARKCOMM_PROCESS_LIBS ARKCOMM_LIBRARY ARKCOMM_LIBRARIES)
libfind_process(ARKCOMM)
