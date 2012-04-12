/*
 * VisJet.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * VisJet.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * VisJet.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "VisJet.hpp"
#include <iostream>

VisJet::VisJet(char * modelPath) : jet(new arkosg::Jet(std::string(modelPath)))
{
    osg::Group * root = new arkosg::Frame(15,"N","E","D");
    root->addChild(jet);
    getCameraManipulator()->setHomePosition(osg::Vec3(-30,30,-30),
                                            osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
    setSceneData(root);
    setUpViewInWindow(0,0,400,400);
    run();
}

VisJet::~VisJet()
{
    setDone(true);
}

void VisJet::update(double * u) {
    lock();
    jet->setEuler(u[0],u[1],u[2]);
    jet->setU(u[3],u[4],u[5],u[6]);
    unlock();
}

// vi:ts=4:sw=4:expandtab
