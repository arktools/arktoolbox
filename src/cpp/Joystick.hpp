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

#include <string.h>		// plib/js.h should really include this !!!!!!
#include <plib/js.h>
#include <stdexcept>
#include <iostream>

class Joystick {
public:
    Joystick(int portNumber);
    void read(double * y);
    int getNumAxes();
    int getPortNumber();
    bool getEnabled();
private:
    static bool _jsInitialized;
    bool _enabled;;
    jsJoystick * _joystick;
    int _portNumber;
    void checkJoystick();
    void setPortNumber(int portNumber);
};

// vim:ts=4:sw=4
