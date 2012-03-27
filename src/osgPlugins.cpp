/*
 * osgPlugins.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * Viewer.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Viewer.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Static linking of OSG needs special macros
#ifdef OSG_LIBRARY_STATIC
#include <osgDB/Registry>
#include <osgViewer/Viewer>

USE_OSGPLUGIN(ac);
USE_OSGPLUGIN(rgb);

#if defined(__APPLE__) 
    USE_GRAPICSWINDOW_IMPLEMENTATION(Cocoa) 
#else 
    USE_GRAPHICSWINDOW() 
#endif 

#endif

// vim:ts=4:sw=4
