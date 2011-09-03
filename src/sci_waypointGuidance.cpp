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

#define EARTH_RAD 6378.137

void sci_waypointGuidance(scicos_block *block, scicos::enumScicosFlags flag)
{

    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);
    double * u3=(double*)GetInPortPtrs(block,3);
    double * y1=(double*)GetOutPortPtrs(block,1);

    // alias names
    double & lat1   = u1[0];
    double & lon1   = u1[1];
    double & alt1   = u1[2];
    double & Vt1    = u1[3];

    double & Vt     = u2[0];
    double & alpha  = u2[1];
    double & theta  = u2[2];
    double & Q      = u2[3];
    double & beta   = u2[4];
    double & phi    = u2[5];
    double & P      = u2[6];
    double & psi    = u2[7];
    double & R      = u2[8];
    double & lat    = u2[9];
    double & lon    = u2[10];
    double & alt    = u2[11];

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
        double dLat = lat1-lat;
        double dLon = lon1-lon;
        double y = sin(dLon) * cos(lat1);	
        double x = cos(lat)*sin(lat1) - sin(lat)*cos(lat1)*cos(dLon);
	    double c = sqrt(x*x + y*y);
    	double ihat_v = x/c;
	    double jhat_v = y/c;
        double psi1 = atan2(y,x);

        // basic safety zone collision avoidance
        double rC = 10; // collision avoidance window, 10 meters
        double Vc = Vt3 - Vt;
        double dLatC = lat3-lat;
        double dLonC = lon3-lon;
        double yC = sin(dLonC) * cos(lat3);
        double xC = cos(lat)*sin(lat3) - sin(lat)*cos(lat3)*cos(dLon);
        double dC = sqrt(xC*xC + yC*yC); // distance to collision

        double deltaV;
        double deltaPsi;
        // Ignore obstacles farther than 10 km away
    	if (dC > -1) {
        	deltaV = 0;
        	deltaPsi = 0;
        } else {

        	double psiC = acos(xC/dC);
	        if(yC < 0) {
            	psiC = -1 * psiC;
        	}

        	double ihat_c = cos(psi3);
        	double jhat_c = sin(psi3);

        	// Get the velocity vector of the vehicle relative to the obstacle
        	double velx_vrelc = (Vt * ihat_v ) - (Vt3 * ihat_c);
        	double vely_vrelc = (Vt * jhat_v) - (Vt3 * jhat_c);
        	double velmag_vrelc = sqrt(velx_vrelc*velx_vrelc + vely_vrelc*vely_vrelc);

        	// Get bearing of the relative velocity of the vehicle
        	double psi_vrelc = acos(velx_vrelc / velmag_vrelc);
        	if(vely_vrelc < 0) {
        		psi_vrelc *= -1;
        	}

        	// Get the difference between a collision cource bearing and the
        	// current bearing
        	double alpha = psi_vrelc - psiC;
        	if (alpha < -1*M_PI) {
        		alpha += 2*M_PI;
        	} else if (alpha > M_PI) {
        		alpha -= 2*M_PI;
        	}

        	double velx_vrelc_new;
        	double vely_vrelc_new;
        	// Case where the separation distance is not already violated.
        	if (dC > rC) {
        		// Get the magnitude difference between a collision course
        		// bearing and a bearing that maintains separation.
        		double beta = asin(rC/dC);
        		double gamma;
		
        		// The vehicle is not on a collision cource
        		if(abs(alpha) > beta) {
        			gamma = 0;
        		} else {
        			if(alpha < 0) {
        				gamma = -1 * alpha - beta;
        			} else {
        				gamma = beta - alpha;
        			}
        		}

        		// shift the bearing of the relative velocity vector by gamma
        		psi_vrelc += gamma;
        		velx_vrelc_new = cos(psi_vrelc);
        		vely_vrelc_new = sin(psi_vrelc);
        	} 
        	// The case where the separation is already violated
        	else {
		        // The new relative velocity vector should point directly
        		// away from the obstacle.
		        velx_vrelc_new = cos(-1*psiC);
        		velx_vrelc_new = sin(-1*psiC);
        	}

        	// The unit vector of the desired relative velocity has now been determined.
        	// Using this, the new bearing of the vehicle needs to be determined to
        	// create the relative velocity in that direction while the magnitude of
        	// the vehicles velocity remains constant.

        	double psiv;
        	double d,e;
        	double vnew = Vt;
        	// If the bearing is in the regions where the tangent of that angle is defined.
        	if ((psi_vrelc > -1 * M_PI/4 && psi_vrelc < M_PI / 4) || (psi_vrelc > 3 * M_PI / 4 || psi_vrelc < -3*M_PI/4)) {

        		d = tan(psi_vrelc);
		        e = (d*cos(psi3)-sin(psi3)) / sqrt(1+d*d);
        		if(abs (e) > 1) {
		        	vnew = Vt3 * e;
        		}
        		psiv = asin(Vt3/vnew*e) + psi_vrelc - M_PI;
        	}
        	else {

        		// take the cotangent (phase shifted tangent)
        		d = tan(M_PI_2 - psi_vrelc);
        		e = (cos(psi3)-d*sin(psi3))/sqrt(1+d*d);
        		if (abs(e) > 1) {
		        	vnew = Vt3*e;
        		}
		        psiv = asin(Vt3/vnew * e) + psi_vrelc - M_PI;

        	}
        }

        // output
        eH = alt1 - alt;
        eV = /*sqrt(Vt*Vt + (Vc*Vc*sin(gamma)*sin(gamma))) + */ Vt1 - Vt;
        eR = 0 - R;
        ePhi = 0 - phi;
        
        ePsi = psi1 /*+ atan2(Vc*sin(gamma),Vt)*/- psi;
        if(ePsi > M_PI) {
            ePsi -= 2*M_PI;
        } else if(ePsi < M_PI) {
            ePsi += 2*M_PI;
        }
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
