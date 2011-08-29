/*sci_waypointGuidance.cpp
 * Copyright (C) Alan Kim, James Goppert 2011 
 * 
 * This file is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file  is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * u1: lat, lon, alt, velocity (destination)
 * u2: x 
 * u3: lat, lon, alt, velocity, heading (obstacle)
 *
 * Out1 = eH, eV, eR, ePsi, ePhi
 *
 */

#include <iostream>
#include <string>
#include <cstdlib>
#include "arkmath/GpsIns.hpp"
#include "utilities.hpp"
#include <stdexcept>

extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

void sci_waypointGuidance(scicos_block *block, scicos::enumScicosFlags flag)
{

    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);
    double * u3=(double*)GetInPortPtrs(block,3);
    double * y1=(double*)GetOutPortPtrs(block,1);

    // alias names
    double & lat2   = u1[0];
    double & lon2   = u1[1];
    double & alt2   = u1[2];
    double & Vt2    = u1[3];

    double & Vt     = u2[0];
    double & alpha  = u2[1];
    double & theta  = u2[2];
    double & Q      = u2[3];
    double & alt    = u2[4];
    double & beta   = u2[5];
    double & phi    = u2[6];
    double & P      = u2[7];
    double & R      = u2[8];
    double & psi    = u2[9];
    double & lon1   = u2[10];
    double & lat1   = u2[11];

    double & lat3   = u3[0];
    double & lon3   = u3[1];
    double & alt3   = u3[2];
    double & Vt3    = u3[3];
    double & psi3   = u3[4];

    double & eH     = y1[0];
    double & eV     = y1[1];
    double & eR     = y1[2];
    double & ePsi   = y1[3];
    double & ePhi   = y1[4];

    //handle flags
    if (flag==scicos::computeOutput)
    {
        // basic guidance to waypoint
        double dLat = lat2-lat1;
        double dLon = lon2-lon1;
        double y = sin(dLon) * cos(lat2);
        double x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(dLon);
        double psiB = atan2(y,x);

        // basic safety zone collision avoidance
        double rC = 10; // collision avoidance window, 10 meters
        double Vc = Vt3 - Vt;
        double dLatC = lat3-lat1;
        double dLonC = lon3-lon1;
        double yC = sin(dLonC) * cos(lat3);
        double xC = cos(lat1)*sin(lat3) - sin(lat1)*cos(lat3)*cos(dLon);
        double dC = sqrt(xC*xC + yC*yC); // distance to collision
        double psiBC = atan2(yC,xC);  // bearing to vehicle
        double alpha = psiBC - psi3;
        double beta = 0;
        if (dC < 1e-6) {
            beta = 0;
        } else {
            beta = asin(rC/dC);
        }
        double gamma = beta - alpha;

        // output
        eH = alt2 - alt;
        eV = /*sqrt(Vt*Vt + (Vc*Vc*sin(gamma)*sin(gamma))) + */ Vt2 - Vt;
        eR = 0 - R;
        ePhi = 0 - phi;
        
        ePsi = psiB /*+ atan2(Vc*sin(gamma),Vt)*/- psi;
        if (ePsi > M_PI) ePsi -= 2*M_PI;
        else if (ePsi < -M_PI) ePsi += 2*M_PI;
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
