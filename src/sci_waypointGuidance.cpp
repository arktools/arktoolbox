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


void vincentys(double, double, double, double,double*, double*); 


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
        double psi1;
	    double c;
        vincentys(lat, lon, lat1, lon1, &c, &psi1);

        /*
        double y = sin(dLon) * cos(lat1);	
        double x = cos(lat)*sin(lat1) - sin(lat)*cos(lat1)*cos(dLon);
	    double c = sqrt(x*x + y*y);
    	double ihat_v = x/c;
	    double jhat_v = y/c;
        double psi1 = atan2(y,x);
        */

        // basic safety zone collision avoidance
        double rC = 10; // collision avoidance window, 10 meters
        double dC;
        double psiC;
        vincentys(lat, lon, lat3, lon3, &dC, &psiC);

        /*
        double rC = 10; // collision avoidance window, 10 meters
        double Vc = Vt3 - Vt;
        double dLatC = lat3-lat;
        double dLonC = lon3-lon;
        double yC = sin(dLonC) * cos(lat3);
        double xC = cos(lat)*sin(lat3) - sin(lat)*cos(lat3)*cos(dLon);
        double dC = sqrt(xC*xC + yC*yC); // distance to collision
        */

        double deltaV;
        double deltaPsi;
        // Ignore obstacles that are far away
    	if (dC > 1000) {
        	deltaV = 0;
        	deltaPsi = 0;
        } else {

        	// Get the velocity vector of the vehicle relative to the obstacle
        	double velx_vrelc = (Vt * sin(psi1) ) - (Vt3 * sin(psi3));
        	double vely_vrelc = (Vt * cos(psi1)) - (Vt3 * cos(psi3));
        	double velmag_vrelc = sqrt(velx_vrelc*velx_vrelc + vely_vrelc*vely_vrelc);

        	// Get the angle of the relative velocity of the vehicle
        	double psi_vrelc = atan2(vely_vrelc, velx_vrelc);

        	// Get the difference between a collision course bearing and the
        	// current bearing. (psiC is bearing from North, psi_vrelc is angle
            // from the horizontal, so it has been shifted))
        	double alpha = psi_vrelc - (psiC + M_PI/2);
        	if (alpha < -1*M_PI) {
        		alpha += 2*M_PI;
        	} else if (alpha > M_PI) {
        		alpha -= 2*M_PI;
        	}

        	double velx_vrelc_new;
        	double vely_vrelc_new;
            double beta = asin(rC/dC);
            double gamma = 0;

            // If the vehicle is on a course that would violate separation
            if (fabs(alpha) < beta) {

            	// Case where the separation distance is not already violated.
            	if (dC > rC) {
        		    if(alpha < 0) {
            		    gamma = -1 * alpha - beta;
            		} else {
            			gamma = beta - alpha;
        	   		}

            		// shift the bearing of the relative velocity vector by gamma
            		psi_vrelc += gamma;
                    if(psi_vrelc > M_PI) {
                        psi_vrelc -= 2*M_PI;
                    } else if (psi_vrelc < -M_PI) {
                        psi_vrelc += 2*M_PI;
                    }

        	    	velx_vrelc_new = cos(psi_vrelc);
        		    vely_vrelc_new = sin(psi_vrelc);
            	} 
            	// The case where the separation is already violated
            	else {
		            // The new relative velocity vector should point directly
        		    // away from the obstacle.
    		        velx_vrelc_new = cos(-1*(psiC+ M_PI/2));
            		vely_vrelc_new = sin(-1*(psiC + M_PI/2));
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
            		} else {
                        vnew = Vt;
                    }
        	    	psiv = asin(Vt3/vnew*e) + psi_vrelc;
            	}
            	else {

            		// take the cotangent (phase shifted tangent)
        	    	d = tan(M_PI_2 - psi_vrelc);
        		    e = (cos(psi3)-d*sin(psi3))/sqrt(1+d*d);
            		if (abs(e) > 1) {
	    	        	vnew = Vt3*e;
            		} else {
                        vnew = Vt;
                    }
    		        psiv = asin(Vt3/vnew * e) + psi_vrelc;

            	}

                deltaV = vnew - Vt;
                deltaPsi = psi - psiv;
                if(deltaPsi > M_PI){
                    deltaPsi -= 2*M_PI;
                } else if (deltaPsi < -M_PI) {
                    deltaPsi += 2*M_PI;
                }
            }
            // The vehcile is not on a collision course
            else {
                deltaV = 0;
                deltaPsi = 0;
            }

        }


        // output
        eH = alt1 - alt;
        eV = /*sqrt(Vt*Vt + (Vc*Vc*sin(gamma)*sin(gamma))) + */ Vt1 + deltaV - Vt;
        eR = 0 - R;
        ePhi = 0 - phi;
        
        ePsi = psi1 + deltaPsi - psi; /*+ atan2(Vc*sin(gamma),Vt)*/
        
        ePsi = fmod(ePsi, 2*M_PI);
        if(ePsi > M_PI) {
            ePsi -= 2*M_PI;
        } else if(ePsi < -M_PI) {
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

}


#define MAJOR_AXIS_LENGTH 6378137.0
#define MINOR_AXIS_LENGTH 6356752.3142
#define FLATTENING ( 1 / 298.257223563)
#define ITERATION_LIMIT 100

void vincentys(double lat1, double lon1, double lat2, double lon2,
		double *distance, double *bearing) {

	int iterationCount = 0;
	double   L;
	double   U1;
    double   U2;
	double   lambda;
	double   sigma;
	double   sinSigma;
    double   cosSigma;
    double   sinLambda;
    double   cosLambda;
    double   sinU1;
    double   sinU2;
    double   cosU1;
    double   cosU2;
	double   sinAlpha;
    double   cosSquaredAlpha;
	double   cos2SigmaM;
	double   C;
	double   A;
    double   B;
	double   uSquared;
	double   deltaSigma;
    double   lambdaP;
    double   rad;
    
	L = lon2 - lon1;

    U1  = atan((1 - FLATTENING) * tan(lat1));
    U2  = atan((1 - FLATTENING) * tan(lat2));
    
    sinU1 = sin(U1);
    sinU2 = sin(U2);
    cosU1 = cos(U1);
    cosU2 = cos(U2);

	lambda = L;

	do {
        sinLambda = sin(lambda);
        cosLambda = cos(lambda);
        
        sinSigma = sqrt(
            (cosU2 * sinLambda) *
            (cosU2 * sinLambda) +
            (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
            (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda)
            );
            
        if (sinSigma == 0) {
            *distance = -1;
            return;
        }
        
        cosSigma = (sinU1 * sinU2) +
            (cosU1 * cosU2 * cosLambda);
            
        sigma = atan2(sinSigma, cosSigma);
        
        sinAlpha        = cosU1 * cosU2 * sinLambda / sinSigma;
        cosSquaredAlpha = 1 - sinAlpha * sinAlpha;
        
        cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSquaredAlpha;
        
        if (isnan(cos2SigmaM)) {
            cos2SigmaM = 0;
        }
        
        C = (FLATTENING / 16 * cosSquaredAlpha) *
            (4 + FLATTENING *
                (4 - 3 * cosSquaredAlpha)
            );
            
        lambdaP = lambda;
        lambda  = L +
            (1 - C) *
            FLATTENING * sinAlpha *
                (sigma + C * sinSigma *
                    (cos2SigmaM + C * cosSigma *
                        (-1 + 2 * cos2SigmaM * cos2SigmaM)
                    )
                );
        
    } while ( (fabs(lambda - lambdaP) > .000000000001) &&
              (++iterationCount       < ITERATION_LIMIT));
                 
    if (iterationCount == ITERATION_LIMIT) {
        *distance = -1;
        return;
    }

    uSquared = cosSquaredAlpha *
            (MAJOR_AXIS_LENGTH * MAJOR_AXIS_LENGTH - MINOR_AXIS_LENGTH * MINOR_AXIS_LENGTH) /
            (MINOR_AXIS_LENGTH * MINOR_AXIS_LENGTH);
            
    A = 1 + uSquared / 16384 *
        (4096 + uSquared *
            (-768 + uSquared *
                (320 - 175 * uSquared)
            )
         );
    
    B = uSquared / 1024 *
        (256 + uSquared *
            (-128 + uSquared *
                (74 - 47 * uSquared)
            )
        );
        
    deltaSigma = B * sinSigma *
        (cos2SigmaM + B / 4 *
            (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
            B / 6 * cos2SigmaM * 
            (-3 + 4 * sinSigma * sinSigma) *
            (-3 + 4 * cos2SigmaM * cos2SigmaM))
        );
        
    *distance = MINOR_AXIS_LENGTH * A * (sigma - deltaSigma);
    
    *distance = ((int) ( (*distance) * 1000)) / 1000.0;
    
    *bearing = atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda);
}






 // extern c
// vim:ts=4:sw=4:expandtab
