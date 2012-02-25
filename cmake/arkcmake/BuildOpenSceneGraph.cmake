# - Try to find  OPENSCENEGRAPH
# Once done, this will define
#
#  OPENSCENEGRAPH_FOUND - system has scicoslab 
#  OPENSCENEGRAPH_INCLUDE_DIRS - the scicoslab include directories
#  OPENSCENEGRAPH_LIBRARIES - libraries to link to

include(LibFindMacros)
include(MacroCommonPaths)

MacroCommonPaths(OPENSCENEGRAPH)

macro(build_openscenegraph TAG EP_BASE_DIR CMAKE_ARGS)
    ExternalProject_Add(openscenegraph
        SVN_REPOSITORY "http://www.openscenegraph.org/svn/osg/OpenSceneGraph/tags/OpenSceneGraph-${TAG}"
        UPDATE_COMMAND ""
        INSTALL_DIR ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}
        CMAKE_ARGS ${CMAKE_ARGS}
        INSTALL_COMMAND make DESTDIR=${EP_BASE_DIR} install
       )
    set(OPENSCENEGRAPH_INCLUDE_DIRS ${EP_BASE_DIR}/${CMAKE_INSTALL_PREFIX}/include)
    set(OPENSCENEGRAPH_DATA_DIR ${EP_DATADIR}/${CMAKE_INSTALL_PREFIX}/share/openscenegraph)
    set(OPENSCENEGRAPH_LIBRARIES 
        pthread
        OpenThreads
        osg
        osgDB
        osgFX
        osgGA
        osgSim
        osgText
        osgUtil
        osgParticle
        osgTerrain
        osgWidget
        osgShadow
        osgAnimation
        osgVolume
        osgManipulator
        osgViewer
        )
    set(OPENSCENEGRAPH_FOUND TRUE)
endmacro()
