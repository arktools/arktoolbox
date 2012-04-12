/*
 * sci_vector.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_vector.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_vector.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "config.h"

#ifdef WITH_ARKOSG

#include <iostream>
#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"

using namespace arkosg;

class VisVector : public Viewer
{
public:
    VisVector() : _vector(new Vector3(osg::Vec3(0,0,0),osg::Vec3(0,0,0)))
    {
        osg::Group * root = new Frame(1,"N","E","D");
        root->addChild(_vector);
        getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                                osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
        setSceneData(root);
        setUpViewInWindow(0,0,800,600);
        run();
    }
    void set(double x, double y, double z) {
        lock();
        _vector->set(osg::Vec3(0,0,0),osg::Vec3(x,y,z));
        unlock();
    }
    ~VisVector()
    {
        setDone(true);
    }
private:
    Vector3 * _vector;
};

extern "C"
{

#include "definitions.hpp"
#include <scicos/scicos_block4.h>
#include <math.h>

    void sci_vector(scicos_block *block, scicos::enumScicosFlags flag)
    {
        // definitions
        double *u1=(double*)GetInPortPtrs(block,1);
        void ** work =  GetPtrWorkPtrs(block);
        VisVector * vis;

        // aliases
        double & x = u1[0];
        double & y = u1[1];
        double & z = u1[2];

        // handle flags
        if (flag==scicos::initialize)
        {
            try
            {
                vis = new VisVector;
            }
            catch (const std::runtime_error & e)
            {
                Coserror((char *)e.what());
                set_block_error(-16);
                return;
            }
            *work = (void *)vis;
        }
        else if (flag==scicos::terminate)
        {
            vis = (VisVector *)*work;
            if (vis)
            {
                delete vis;
                vis = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
            vis = (VisVector *)*work;
            if (vis) {
                vis->set(x,y,z);
            }
        }
        else
        {
            //std::cout << "unhandled flag: " << flag << std::endl;
        }
    }

}

# else // WITH_ARKOSG

extern "C"
{

#include <scicos/scicos_block4.h>
#include "definitions.hpp"
    void sci_vector(scicos_block *block, scicos::enumScicosFlags flag) {}
}

#endif // WITH_ARKOSG

// vim:ts=4:sw=4
