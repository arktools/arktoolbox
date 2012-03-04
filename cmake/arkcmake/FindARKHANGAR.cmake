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
find_path(ARKHANGAR_DATA_DIR
    NAMES arkhangar/aircraft/easystar/easystar-windtunnel.xml
    PATHS ${COMMON_DATA_PATHS_ARKHANGAR}
)

# NOTE: Singular variables for this library, plural for libraries this this lib depends on.
set(ARKHANGAR_PROCESS_INCLUDES ARKHANGAR_INCLUDE_DIR)
libfind_process(ARKHANGAR)
