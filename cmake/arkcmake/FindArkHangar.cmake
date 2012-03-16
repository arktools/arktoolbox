# - Try to find  ArkHangar
# Once done, this will define
#
#  ARKHANGAR_FOUND        : library found
#  ARKHANGAR_DATADIR      : data directory 
#  ARKHANGAR_VERSION      : version

# macros
include(FindPackageHandleStandardArgs)

# find the data directory
find_path(ARKHANGAR_DATADIR
	NAMES arkhangar/VERSION
    PATH_SUFFIXES share
    )

# read the version
if (EXISTS ${ARKHANGAR_DATADIR}/VERSION)
    file(READ ${ARKHANGAR_DATADIR}/VERSION ARKHANGAR_VERSION)
endif()

# handle arguments
find_package_handle_standard_args(ArkHangar
    REQUIRED_VARS ARKHANGAR_DATADIR
    VERSION_VAR ARKHANGAR_VERSION
    )
