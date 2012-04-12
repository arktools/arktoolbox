/*
 * VisSailboat.hpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * VisSailboat.hpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * VisSailboat.hpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef VISSAILBOAT_H
#define VISSAILBOAT_H

#include <iostream>
#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"

class VisSailboat : public arkosg::Viewer
{
public:
    arkosg::Sailboat * sailboat;
    VisSailboat(char * model, char * texture);
    ~VisSailboat();
    /**
     * update function
     *
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
     * 	1: sail (rad/s)
     * 	2: rudder (rad/s)
     */
    void update(double * u1, double * u2, double * u3);
};

#endif // VISSAILBOAT_H
