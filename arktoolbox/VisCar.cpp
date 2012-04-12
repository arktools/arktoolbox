/*
 * VisCar.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * VisCar.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * VisCar.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "VisCar.hpp"

VisCar::VisCar(char* model, char * texture) : car(new arkosg::Car(std::string(model)))
{
    osg::Group * root = new arkosg::Frame(1,"N","E","D");
    root->addChild(new arkosg::Terrain(std::string(texture),osg::Vec3(10,10,0)));
    if (car) root->addChild(car);
    getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                            osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
    if (root) setSceneData(root);
    setUpViewInWindow(0,0,400,400);
    run();
}

VisCar::~VisCar()
{
    setDone(true);
}

void VisCar::update(double * u1, double * u2, double * u3) {
    lock();
    car->setEuler(u1[0],u1[1],u1[2]);
    car->setPositionScalars(u2[0],u2[1],u2[2]);
    car->setU(u3[0],u3[1]);
    unlock();
}

// vi:ts=4:sw=4:expandtab
