/*
 * block_joystick.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
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
 *
 * y: vector of axis values
 */

#include "arktools/Joystick.hpp"

extern "C"
{

#include <scicos_block4.h>
#include <Scierror.h>
#include <math.h>

void block_joystick(scicos_block *block, scicos_flag flag)
{
    // data
    double *y=(double*)GetOutPortPtrs(block,1);
    void ** work = & GetWorkPtrs(block);
    int * ipar=block->ipar;
    int * intArray;
    int portNumber = ipar[0];
    Joystick * joystick = NULL;

    //handle flags
    if (flag == Initialization)
    {
        //std::cout << "initializing" << std::endl;
        try
        {
            // initialize
            joystick = new Joystick(portNumber);
        }
        catch (const std::exception & e)
        {
            std::cout << "exception: " << e.what() << std::endl;
            Scierror(999, "%s", e.what());
            return;
        }
        catch (...)
        {
            Scierror(999, "unknown error");
            return;
        }
        *work = (void *)joystick;
    }
    else if (flag == Ending)
    {
        //std::cout << "terminating" << std::endl;
        joystick = (Joystick *)*work;
        if (joystick)
        {
            delete joystick;
            joystick = NULL;
        }
    }
    else if (flag == OutputUpdate)
    {
        //std::cout << "computing output" << std::endl;
        joystick = (Joystick *)*work;
        try {
            joystick->read(y);
        } catch (const std::exception & e)
        {
            std::cout << "exception: " << e.what() << std::endl;
            Scierror(999, "%s", e.what());
            return;
        }
        catch (...)
        {
            Scierror(999, "unknown error");
            return;
        }
    }
    else
    {
        //std::cout << "unhandled flag: " << flag << std::endl;
    }
}

} // extern c

// vim:ts=4:sw=4
