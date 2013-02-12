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

#include "Joystick.hpp"

Joystick::Joystick(int portNumber) : _joystick(NULL), _portNumber(0), _enabled(false) {

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

void Joystick::read(double * y) {

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

int Joystick::getNumAxes() {
    return _joystick->getNumAxes();
}

int Joystick::getPortNumber() {
    return _portNumber;
}

bool Joystick::getEnabled() {
    return _enabled;
}

void Joystick::checkJoystick() {
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

void Joystick::setPortNumber(int portNumber) {
    if (portNumber<0) {
        char message[50];
        sprintf(message,"joystick port number cannot be negative, attempted to set to: %i",portNumber);
        _portNumber = 0;
        throw std::runtime_error(message);
        return;
    }
    _portNumber = portNumber;
}

bool Joystick::_jsInitialized = false;

// vim:ts=4:sw=4
