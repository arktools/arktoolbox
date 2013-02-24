/*
 * block_osg.cpp
 * Copyright (C) James Goppert 2013 <jgoppert@users.sourceforge.net>
 *
 * This file is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <iostream>

#include "arktools/Viewer.hpp"
#include "arktools/osgUtils.hpp"
#include "arktools/utilities.hpp"

extern "C"
{

#include <scicos_block4.h>
#include <Scierror.h>
#include <math.h>

void block_osg(scicos_block *block, scicos_flag flag)
{
    // definitions
    double *u1=(double*)GetInPortPtrs(block,1);
    double *u2=(double*)GetInPortPtrs(block,2);
    double *u3=(double*)GetInPortPtrs(block,3);

    void ** work =  &GetWorkPtrs(block);
    VisCar * vis = NULL;
    int * ipar=block->ipar;
    char ** stringArray;
    int * intArray;
    getIpars(2,0,ipar,&stringArray,&intArray);
    char * dataPath = stringArray[0];

    // handle flags
    if (flag == Initialization)
    {
        try
        {
            vis = new VisCar(dataPath);
        }
        catch (const std::runtime_error & e)
        {
            std::cout << "exception: " << e.what() << std::endl;
            Scierror(999, "%s", e.what());
            return;
        }
        *work = (void *)vis;
    }
    else if (flag == Ending)
    {
        vis = (VisCar *)*work;
        if (vis)
        {
            delete vis;
            vis = NULL;
        }
    }
    else if (flag == OutputUpdate)
    {
        vis = (VisCar *)*work;
        if (vis)
        {
            vis->lock();
            vis->car->setEuler(u1[0],u1[1],u1[2]);
            vis->car->setPositionScalars(u2[0],u2[1],u2[2]);
            vis->car->setU(u3[0],u3[1]);
            vis->unlock();
        }
    }
    else
    {
        //std::cout << "unhandled flag: " << flag << std::endl;
    }
}

} // extern C

// vim:ts=4:sw=4:expandtab
