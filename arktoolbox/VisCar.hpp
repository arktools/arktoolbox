/*
 * VisCar.hpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * VisCar.hpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * VisCar.hpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ARKTOOLBOX_VISCAR_H
#define ARKTOOLBOX_VISCAR_H

#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"

class VisCar : public arkosg::Viewer
{
public:
    arkosg::Car * car;
    VisCar(char* model, char * texture);
    ~VisCar();
    /**
     *
     * u1:
     * 	1: roll (rad)
     * 	2: pitch (rad)
     * 	3: yaw( rad)
     *
     * u2:
     *	1: xN (distance)
     * 	2: xE (distance)
     * 	3: xD (distance)
     *
     * u3:
     *	1: Throttle (0 -> 1)
     * 	2: Steering (-1 -> 1) 
     */
    void update(double * u1, double * u2, double * u3);
};

#endif // ARKTOOLBOX_VISCAR_H

// vi:ts=4:sw=4:expandtab
