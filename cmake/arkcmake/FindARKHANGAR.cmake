# - Try to find  ARKHANGAR
# Once done, this will define
#
#  ARKHANGAR_FOUND - system has scicoslab 
#  ARKHANGAR_INCLUDE_DIRS - the scicoslab include directories

include(LibFindMacros)
include(MacroCommonPaths)

MacroCommonPaths(ARKHANGAR)

# Include dir
find_path(ARKHANGAR_INCLUDE_DIR
    NAMES arkhangar/aircraft/easystar/easystar-windtunnel.xml
    PATHS ${COMMON_DATA_PATHS_ARKHANGAR}
)

# data dir
find_path(ARKHANGAR_DATA_DIR_SEARCH
    NAMES arkhangar/aircraft/easystar/easystar-windtunnel.xml
    PATHS ${COMMON_DATA_PATHS_ARKHANGAR}
)
set(ARKHANGAR_DATA_DIR ${ARKHANGAR_DATA_DIR_SEARCH}/arkhangar)

# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(ARKHANGAR_PROCESS_INCLUDES ARKHANGAR_INCLUDE_DIR)
libfind_process(ARKHANGAR)

macro(build_arkhangar TAG EP_BASE_DIR CMAKE_MAKE_ARGS)
    list(APPEND CMAKE_ARGS "-DEP_BASE_DIR=${EP_BASE_DIR}")
    ExternalProject_Add(arkhangar
        GIT_REPOSITORY "git://github.com/arktools/arkhangar.git"
        GIT_TAG ${TAG}
        UPDATE_COMMAND ""
        INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
        CMAKE_ARGS ${CMAKE_MAKE_ARGS}
        INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR} install
    )
endmacro()
