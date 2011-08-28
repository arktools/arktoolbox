/*sci_euler2Dcm.cpp
 * Copyright (C) James Goppert 2011 
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
 *
 * u1: phi, theta, psi
 *
 * y1: C_bn  (from navigation system to body system)
 *
 */

#include <iostream>
#include <string>
#include <cstdlib>
#include "math/GpsIns.hpp"
#include "utilities.hpp"
#include <stdexcept>

extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"
#include <stdio.h>

void sci_euler2Dcm(scicos_block *block, scicos::enumScicosFlags flag)
{

    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * y1=(double*)GetOutPortPtrs(block,1);

    // alias names
    double & phi = u1[0];
    double & theta = u1[1];
    double & psi = u1[2];

    // note: column major in scicoslab
    double & c11 = y1[0];
    double & c21 = y1[1];
    double & c31 = y1[2];
    double & c12 = y1[3];
    double & c22 = y1[4];
    double & c32 = y1[5];
    double & c13 = y1[6];
    double & c23 = y1[7];
    double & c33 = y1[8];

    //handle flags
    if (flag==scicos::computeOutput)
    {
        double cosPhi = cos(phi), sinPhi = sin(phi);
        double cosTheta = cos(theta), sinTheta = sin(theta);
        double cosPsi = cos(psi), sinPsi = sin(psi);

        // Lewis/Stevens Aircraft Control and Simulationpg. 26
        c11 = cosTheta*cosPsi;
        c21 = -cosPhi*sinPsi + sinPhi*sinTheta*cosPsi;
        c31 = sinPhi*sinPsi + cosPhi*sinTheta*cosPsi;

        c12 = cosTheta*sinPsi;
        c22 = cosPhi*cosPsi + sinPhi*sinTheta*sinPsi;
        c32 = -sinPhi*cosPsi + cosPhi*sinTheta*sinPsi;

        c13 = -sinTheta;
        c23 = sinPhi*cosTheta;
        c33 = cosPhi*cosTheta;
    }
    else if (flag==scicos::terminate)
    {
    }
    else if (flag==scicos::initialize || flag==scicos::reinitialize)
    {
    }
    else
    {
        std::cout << "unhandled block flag: " << flag << std::endl;
    }
}

} // extern c

// vim:ts=4:sw=4:expandtab
