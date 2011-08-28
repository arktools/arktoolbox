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
#include "visualization/Viewer.hpp"
#include "visualization/osgUtils.hpp"

using namespace mavsim::visualization;

class VisCar : public Viewer
{
public:

    Car * car;
    VisCar() : car()
    {
		car = new Car; // throws
        osg::Group * root = new Frame(1,"N","E","D");
        if (car) root->addChild(car);
        getCameraManipulator()->setHomePosition(osg::Vec3(-3,3,-3),
                                                osg::Vec3(0,0,0),osg::Vec3(0,0,-1));
        if (root) setSceneData(root);
        setUpViewInWindow(0,0,800,600);
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
        static VisCar * vis=NULL;
        double *u=(double*)GetInPortPtrs(block,1);

        // handle flags
        if (flag==scicos::initialize || flag==scicos::reinitialize)
        {
            std::cout << "initializing" << std::endl;
        }
        else if (flag==scicos::terminate)
        {
            if (vis)
            {
                delete vis;
                vis = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
            if (!vis)
			{
				try
				{
					vis = new VisCar;
				}
				catch (const std::runtime_error & e)
				{
					Coserror((char *)e.what());
				}
			}
			else
			{
				vis->lock();
				vis->car->setEuler(u[0],u[1],u[2]);
				vis->car->setU(u[3],u[4],u[5]);
				vis->unlock();
			}
        }
        else
        {
            std::cout << "unhandled flag: " << flag << std::endl;
        }
    }

}

// vim:ts=4:sw=4
