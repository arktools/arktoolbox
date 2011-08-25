# - Try to find  BOOSTNUMERICBINDINGS
# Once done, this will define
#
#  BOOSTNUMERICBINDINGS_FOUND - system has scicoslab 
#  BOOSTNUMERICBINDINGS_INCLUDE_DIRS - the scicoslab include directories

include(LibFindMacros)

# Include dir
find_path(BOOSTNUMERICBINDINGS_INCLUDE_DIR
	NAMES lapack/lapack.h
	PATHS 
  		/usr/include/boost/numeric/bindings
  		/usr/local/include/boost/numeric/bindings
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(BOOSTNUMERICBINDINGS_PROCESS_INCLUDES BOOSTNUMERICBINDINGS_INCLUDE_DIR)
libfind_process(BOOSTNUMERICBINDINGS)
