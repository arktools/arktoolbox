/*
 * sci_joystick.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_joystick.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_joystick.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * y: vector of axis values
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef HAVE_WINDOWS_H
#  include <windows.h>                     
#endif

#include <string.h>		// plib/js.h should really include this !!!!!!
#include <plib/js.h>
#include <stdexcept>
#include <iostream>

class Joystick {
public:
    Joystick(int portNumber) : _joystick(NULL), _portNumber(0), _enabled(false) {

        // set the port number
        setPortNumber(portNumber);

        // initialize js library 
        if (!_jsInitialized) {
            jsInit();
            _jsInitialized = true;
        }

        // allocate joystick
        _joystick = new jsJoystick(getPortNumber());
        _enabled = true;

        // check if joystick is functional
        checkJoystick();
    }
    void read(double * y) {

        // return if joystick not enabled
        if (!getEnabled()) return;

        // check joystick is functional
        checkJoystick();

        // read value
        int buttons = 0;
        float * values = new float[getNumAxes()]();
        _joystick->read ( &buttons, values);
        for (int i=0; i<getNumAxes();i++) {
            y[i] = values[i];
        }
    }
    int getNumAxes() {
        return _joystick->getNumAxes();
    }
    int getPortNumber() {
        return _portNumber;
    }
    bool getEnabled() {
        return _enabled;
    }
private:
    static bool _jsInitialized;
    bool _enabled;;
    jsJoystick * _joystick;
    int _portNumber;
    void checkJoystick() {
        char message[50];
        // check joystick is functional
        if (!_joystick) {
            sprintf(message,"failed to allocate joystick #%i",_portNumber);
            _enabled = false;
            throw std::runtime_error(message);
            return;
        } else if(_joystick->notWorking()) {
            sprintf(message,"unable to connect to joystick #%i",_portNumber);
            _enabled = false;
            std::cout << message << std::endl;
            // this is not an error, so diagrams w/o joystick can still run
            return;
        }
    }
    void setPortNumber(int portNumber) {
        if (portNumber<0) {
            char message[50];
            sprintf(message,"joystick port number cannot be negative, attempted to set to: %i",portNumber);
            _portNumber = 0;
            throw std::runtime_error(message);
            return;
        }
        _portNumber = portNumber;
    }
};
bool Joystick::_jsInitialized = false;


extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

    void sci_joystick(scicos_block *block, scicos::enumScicosFlags flag)
    {
        // data
        double *y=(double*)GetOutPortPtrs(block,1);
        void ** work = GetPtrWorkPtrs(block);
        int * ipar=block->ipar;
        int * intArray;
        int portNumber = ipar[0];
        Joystick * joystick = NULL;

        //handle flags
        if (flag==scicos::initialize)
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
                Coserror((char *)e.what());
                return;
            }
            catch (...)
            {
                Coserror((char *)"unknown error");
                return;
            }
            *work = (void *)joystick;
        }
        else if (flag==scicos::terminate)
        {
            //std::cout << "terminating" << std::endl;
            joystick = (Joystick *)*work;
            if (joystick)
            {
                delete joystick;
                joystick = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
            //std::cout << "computing output" << std::endl;
            joystick = (Joystick *)*work;
            try {
                joystick->read(y);
            } catch (const std::exception & e)
            {
                std::cout << "exception: " << e.what() << std::endl;
                Coserror((char *)e.what());
                return;
            }
            catch (...)
            {
                Coserror((char *)"unknown error");
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



// vim:ts=4:sw=4
