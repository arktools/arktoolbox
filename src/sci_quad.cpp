/*
 * sci_quad.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_quad.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_quad.cpp is distributed in the hope that it will be useful, but
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
 * 	1: F motor (rad/s)
 * 	2: B motor (rad/s)
 * 	3: L motor (rad/s)
 * 	4: R motor (rad/s)
 */


#include <iostream>
#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"
#include "config.h"

using namespace mavsim::visualization;

class VisQuad : public Viewer
{
public:

    Quad * quad;
    VisQuad() : quad(new Quad(std::string(ARKOSG_DATA_DIR)+"/models/arducopter.ac"))
    {
        osg::Group * root = new Frame(1,"N","E","D");
        if (quad) root->addChild(quad);
        getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                                osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
        if (root) setSceneData(root);
        setUpViewInWindow(0,0,400,400);
        run();
    }
    ~VisQuad()
    {
        setDone(true);
    }
};

extern "C"
{

#include "definitions.hpp"
#include <scicos/scicos_block4.h>
#include <math.h>

    void sci_quad(scicos_block *block, scicos::enumScicosFlags flag)
    {
        // definitions
        double *u1=(double*)GetInPortPtrs(block,1);
        double *u2=(double*)GetInPortPtrs(block,2);
        double *u3=(double*)GetInPortPtrs(block,3);
        void ** work =  GetPtrWorkPtrs(block);
		VisQuad * vis = NULL;

 		// handle flags
        if (flag==scicos::initialize)
        {
			try
			{
				vis = new VisQuad;
			}
			catch (const std::runtime_error & e)
			{
				std::cout << "exception: " << e.what() << std::endl;
				Coserror((char *)e.what());
	 			return;
			}
			*work = (void *)vis;
		}
        else if (flag==scicos::terminate)
        {
			vis = (VisQuad *)*work;
            if (vis)
            {
				delete vis;
                vis = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
			vis = (VisQuad *)*work;
			if (vis)
			{
				vis->lock();
				vis->quad->setEuler(u1[0],u1[1],u1[2]);
				vis->quad->setPositionScalars(u2[0],u2[1],u2[2]);
				vis->quad->setU(u3[0],u3[1],u3[2],u3[3]);
				vis->unlock();
			}
        }
        else
        {
            //std::cout << "unhandled flag: " << flag << std::endl;
        }
    }

}

// vim:ts=4:sw=4
