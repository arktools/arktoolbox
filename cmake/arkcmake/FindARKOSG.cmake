# - Try to find  ARKOSG
# Once done, this will define
#
#  ARKOSG_FOUND - system has scicoslab 
#  ARKOSG_INCLUDE_DIRS - the scicoslab include directories
#  ARKOSG_LIBRARIES - libraries to link to

include(LibFindMacros)

# Include dir
find_path(ARKOSG_INCLUDE_DIR
	NAMES initialization/FGTrimmer.h
	PATHS 
		/usr/include/arkOsg
		/usr/local/include/arkOsg
)

# Finally the library itself
find_library(ARKOSG_LIBRARY
	NAMES
		arkOsg
	PATHS 
		/usr/lib 
		/usr/local/lib
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(ARKOSG_PROCESS_INCLUDES ARKOSG_INCLUDE_DIR)
set(ARKOSG_PROCESS_LIBS ARKOSG_LIBRARY ARKOSG_LIBRARIES)
libfind_process(ARKOSG)
