/*
 * VisQuad.hpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * VisQuad.hpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * VisQuad.hpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef VISQUAD_H
#define VISQUAD_H

#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"

class VisQuad : public arkosg::Viewer
{
public:

    arkosg::Quad * quad;
    VisQuad(char * model, char * texture);
    ~VisQuad();
    /**
     * u1:
     * 	1: roll (rad)
     * 	2: pitch (rad)
     * 	3: yaw( rad)
     *
     * u2:
     * 	1: xN (distance)
     * 	2: xE (distance)
     * 	3: xD (distance)
     *
     * u3:
     * 	1: F motor (rad/s)
     * 	2: B motor (rad/s)
     * 	3: L motor (rad/s)
     * 	4: R motor (rad/s)
     */
    void update(double * u1, double * u2, double * u3);
};

#endif // VISQUAD_H

// vi:ts=4:sw=4:expandtab
