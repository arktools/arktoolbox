/*
 * VisSailboat.h
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_sailboat.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_sailboat.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
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

#ifndef VISSAILBOAT_H
#define VISSAILBOAT_H

#include "config.h"

#ifdef WITH_ARKOSG

#include <iostream>
#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"
#include "definitions.hpp"
#include "utilities.hpp"

using namespace arkosg;

class VisSailboat : public Viewer
{
public:

    Sailboat * sailboat;
    VisSailboat(char * model, char * texture) : sailboat(new Sailboat(std::string(model)))
    {
        osg::Group * root = new Frame(1,"N","E","D");
        root->addChild(new Terrain(std::string(texture),osg::Vec3(10,10,0)));
        if (sailboat) root->addChild(sailboat);
        getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                                osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
        if (root) setSceneData(root);
        setUpViewInWindow(0,0,400,400);
        run();
    }
    ~VisSailboat()
    {
        setDone(true);
    }
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
    void update(double * u1, double * u2, double * u2) {
        lock();
        sailboat->setEuler(u1[0],u1[1],u1[2]);
        sailboat->setPositionScalars(u2[0],u2[1],u2[2]);
        sailboat->setU(u3[0],u3[1]);
        unlock();
    }
};

#endif // VISSAILBOAT_H
