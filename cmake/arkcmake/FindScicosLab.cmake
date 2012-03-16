# - Try to find  SCICOSLAB
# Once done, this will define
#
#  SCICOSLAB_FOUND - system has scicoslab 
#  SCICOSLAB_INCLUDE_DIRS - the scicoslab include directories
#  SCICOSLAB_CONTRIB_DIR - the scicoslab contrib directory

# macros
include(FindPackageHandleStandardArgs)

# find scicos
if (APPLE)
    execute_process(COMMAND mdfind "kMDItemKind == Application && kMDItemDisplayName == ScicosLabGtk"
        COMMAND head -1
        RESULT_VARIABLE RESULT
        OUTPUT_VARIABLE SCICOS_APP_BUNDLE
        ERROR_VARIABLE ERROR_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (RESULT) 
        MESSAGE(FATAL_ERROR "Could not locate 'ScicosLabGtk.app' - ${ERROR_MESSAGE}")
    endif (RESULT)
    execute_process(COMMAND find ${SCICOS_APP_BUNDLE} -name routines
        COMMAND head -1
        RESULT_VARIABLE RESULT
        OUTPUT_VARIABLE _SCICOSLAB_GUESS_INCLUDE_DIRS
        ERROR_VARIABLE ERROR_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (RESULT) 
        MESSAGE(FATAL_ERROR "Could not locate 'scicos_block4.h' in ScicosLabGtk.app - ${ERROR_MESSAGE}")
    endif (RESULT)  
    execute_process(COMMAND find ${SCICOS_APP_BUNDLE} -name contrib 
        COMMAND head -1
        RESULT_VARIABLE RESULT
        OUTPUT_VARIABLE _SCICOSLAB_GUESS_CONTRIB_DIRS
        ERROR_VARIABLE ERROR_MESSAGE
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (RESULT) 
        MESSAGE(FATAL_ERROR "Could not locate 'loader.sce' in ScicosLabGtk.app - ${ERROR_MESSAGE}")
    endif (RESULT)  
elseif(UNIX)
    set(_SCICOSLAB_GUESS_INCLUDE_DIRS
        /usr/lib/scicoslab-gtk-4.4b7/routines
        /usr/lib/scicoslab-gtk-4.4/routines
        /usr/lib/scicoslab-gtk-4.4.1/routines
        )
	set(_SCICOSLAB_GUESS_CONTRIB_DIRS
		/usr/lib/scicoslab-gtk-4.4b7/contrib
		/usr/lib/scicoslab-gtk-4.4/contrib
		/usr/lib/scicoslab-gtk-4.4.1/contrib
	)
elseif(WIN32)
    #TODO
    set(_SCICOSLAB_GUESS_INCLUDE_DIRS
    )
    #TODO
	set(_SCICOSLAB_GUESS_CONTRIB_DIRS
	)
endif()

# Include dir
find_path(_SCICOSLAB_INCLUDE_DIR
  NAMES scicos/scicos_block4.h
  PATHS ${_SCICOSLAB_GUESS_INCLUDE_DIRS}
)

# Contrib dir
find_path(SCICOSLAB_CONTRIB_DIR
  NAMES loader.sce
  PATHS ${_SCICOSLAB_GUESS_CONTRIB_DIRS}
)

# handle arguments
set(SCICOSLAB_INCLUDE_DIRS ${_SCICOSLAB_INCLUDE_DIR})
find_package_handle_standard_args(ScicosLab
    REQUIRED_VARS SCICOSLAB_CONTRIB_DIR SCICOSLAB_INCLUDE_DIRS
    VERSION_VAR OSGPLUGIN_VERSION
    )
# vim:ts=4:sw=4:expandtab
