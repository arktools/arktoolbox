# - Try to find  BOOSTNUMERICBINDINGS
# Once done, this will define
#
#  BOOSTNUMERICBINDINGS_FOUND - system has scicoslab 
#  BOOSTNUMERICBINDINGS_INCLUDE_DIRS - the scicoslab include directories

include(LibFindMacros)
include(MacroCommonPaths)

MacroCommonPaths(BOOSTNUMERICBINDINGS)

# Include dir
find_path(BOOSTNUMERICBINDINGS_INCLUDE_DIR
    NAMES boost/numeric/bindings/lapack/lapack.h
    PATHS ${COMMON_INCLUDE_PATHS_BOOSTNUMERICBINDINGS}
)

# Set the include dir variables and the libraries and let libfind_process do the rest.
# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(BOOSTNUMERICBINDINGS_PROCESS_INCLUDES BOOSTNUMERICBINDINGS_INCLUDE_DIR)
libfind_process(BOOSTNUMERICBINDINGS)

macro(build_boostnumericbindings TAG EP_BASE_DIR ARGS)
    ExternalProject_Add(boost-numeric-bindings
        GIT_REPOSITORY "http://git.tiker.net/trees/boost-numeric-bindings.git"
        GIT_TAG ${BOOSTNUMERICBINDINGS_TAG}
        BUILD_IN_SOURCE 1
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
        INSTALL_COMMAND ${CMAKE_COMMAND} -E  copy_directory boost ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}/include/boost
    )
endmacro()
