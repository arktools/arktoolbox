# - Try to find  ARKMATH
# Once done, this will define
#
#  ARKMATH_FOUND - system has scicoslab 
#  ARKMATH_INCLUDE_DIRS - the scicoslab include directories
#  ARKMATH_LIBRARIES - libraries to link to

include(LibFindMacros)
include(MacroCommonPaths)

MacroCommonPaths(ARKMATH)

# Include dir
find_path(ARKMATH_INCLUDE_DIR
	NAMES arkmath/storage_adaptors.hpp
	PATHS ${COMMON_INCLUDE_PATHS_ARKMATH}
)

# Finally the library itself
find_library(ARKMATH_LIBRARY
	NAMES arkmath
	PATHS ${COMMON_LIBRARY_PATHS_ARKMATH}
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(ARKMATH_PROCESS_INCLUDES ARKMATH_INCLUDE_DIR)
set(ARKMATH_PROCESS_LIBS ARKMATH_LIBRARY ARKMATH_LIBRARIES)
libfind_process(ARKMATH)
