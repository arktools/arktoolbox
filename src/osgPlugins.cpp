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
//USE_GRAPHICSWINDOW();
// Image formats
USE_OSGPLUGIN(bmp);
USE_OSGPLUGIN(dds);
USE_OSGPLUGIN(hdr);
USE_OSGPLUGIN(pic);
USE_OSGPLUGIN(pnm);
USE_OSGPLUGIN(rgb);
USE_OSGPLUGIN(tga);
#ifdef OSG_JPEG_ENABLED
  USE_OSGPLUGIN(jpeg);
#endif
#ifdef OSG_PNG_ENABLED
  USE_OSGPLUGIN(png);
#endif
#ifdef OSG_TIFF_ENABLED
  USE_OSGPLUGIN(tiff);
#endif
// Model formats
USE_OSGPLUGIN(3ds);
USE_OSGPLUGIN(ac);
USE_OSGPLUGIN(ive);
USE_OSGPLUGIN(osg);
USE_OSGPLUGIN(txf);
#endif

// vim:ts=4:sw=4
