/*
 * sci_car.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_car.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_car.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include <iostream>
#include "arkosg/Viewer.hpp"
#include "arkosg/osgUtils.hpp"
#include "config.h"

using namespace arkosg;

class VisCar : public Viewer
{
public:

    Car * car;
    VisCar() : car(new Car(std::string(ARKOSG_DATA_DIR)+"/models/rcTruck.ac"))
    {
        osg::Group * root = new Frame(1,"N","E","D");
        if (car) root->addChild(car);
        getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                                osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
        if (root) setSceneData(root);
        setUpViewInWindow(0,0,400,400);
        run();
    }
    ~VisCar()
    {
        setDone(true);
    }
};

extern "C"
{

#include "definitions.hpp"
#include <scicos/scicos_block4.h>
#include <math.h>

    void sci_car(scicos_block *block, scicos::enumScicosFlags flag)
    {
        // definitions
        double *u=(double*)GetInPortPtrs(block,1);
		void ** work =  GetPtrWorkPtrs(block);
		VisCar * vis = NULL;


        // handle flags
        if (flag==scicos::initialize)
        {
			try
			{
				vis = new VisCar;
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
			vis = (VisCar *)*work;
            if (vis)
            {
				delete vis;
                vis = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
			vis = (VisCar *)*work;
            if (vis)
			{
				vis->lock();
				vis->car->setEuler(u[0],u[1],u[2]);
				vis->car->setU(u[3],u[4],u[5]);
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
