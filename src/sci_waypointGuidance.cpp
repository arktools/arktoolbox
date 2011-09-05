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
        double & commandedLat   = u1[0];
        double & commandedLon   = u1[1];
        double & commandedAlt   = u1[2];
        double & commandedSpeed = u1[3];

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

        double & obstacleLat   = u3[0];
        double & obstacleLon   = u3[1];
        double & obstacleAlt   = u3[2];
        double & obstacleSpeed = u3[3];
        double & obstaclePsi   = u3[4];

        double & eH     = y1[0];
        double & eV     = y1[1];
        double & eR     = y1[2];
        double & ePsi   = y1[3];
        double & ePhi   = y1[4];

        //handle flags
        if (flag==scicos::computeOutput)
        {
            // basic guidance to waypoint
            double psiW;
            double c;
            vincentys(lat, lon, commandedLat, commandedLon, &c, &psiW);

            /*
               double y = sin(dLon) * cos(commandedLat);	
               double x = cos(lat)*sin(commandedLat) - sin(lat)*cos(commandedLat)*cos(dLon);
               double c = sqrt(x*x + y*y);
               double ihat_v = x/c;
               double jhat_v = y/c;
               double psiW = atan2(y,x);
             */

            // The separation window defines the radius that the vehicle will
            // attempt to clear. The hard window is the radius inside which
            // the vehicle will turn 90 degrees to clear.
            double separationWindow = 100;

            // basic safety zone collision avoidance
            double dC;
            double psiC;
            vincentys(lat, lon, obstacleLat, obstacleLon, &dC, &psiC);

            /*
               double dLatC = obstacleLat-lat;
               double dLonC = obstacleLon-lon;
               double yC = sin(dLonC) * cos(obstacleLat);
               double xC = cos(lat)*sin(obstacleLat) - sin(lat)*cos(obstacleLat)*cos(dLonC)
               double dC = sqrt(xC*xC + yC*yC); // distance to collision
             */

            double commandPsi = psiW;
            // Ignore obstacles that are far away
            if (dC > 10000) {
                commandPsi = psiW;
            } else {

                // Find the velocity vector of the vehicle relative to the obstacle.
                double relativeVel_x = commandedSpeed * cos(commandPsi) - obstacleSpeed * cos(psiC);
                double relativeVel_y = commandedSpeed * sin(commandPsi) - obstacleSpeed * sin(psiC);

                double relativeVel_psi = atan2(relativeVel_y, relativeVel_x);

                // The separation distance has been violated
                double beta;
                if (dC < separationWindow) {
                    beta = M_PI;
                } else {
                    beta = asin(separationWindow/dC);
                }

                double gamma = 0;

                // Get the difference between a collision course bearing and the
                // current relative bearing.
                double alpha = relativeVel_psi - psiC;
                if (alpha < -M_PI) {
                    alpha += 2*M_PI;
                } else if (alpha > M_PI) {
                    alpha -= 2*M_PI;
                }

                double relativeVel_commandPsi = relativeVel_psi;
                // If the vehicle is on a course that would violate separation
                if (abs(alpha) < beta) {

                    if(alpha < 0) {
                        gamma = alpha - beta;
                    } else {
                        gamma = beta - alpha;
                    }

                    // shift the bearing of the relative velocity vector by gamma
                    relativeVel_commandPsi += gamma;
                    if(relativeVel_commandPsi > M_PI) {
                        relativeVel_commandPsi -= 2*M_PI;
                    } else if (relativeVel_commandPsi < -M_PI) {
                        relativeVel_commandPsi += 2*M_PI;
                    }


                    // Take the commanded relative velocity direction and determine the vehicle velocity direction

                    // The regions for which the tangent of relativeVel_commandPsi is well defined
                    if ( ((relativeVel_commandPsi > -M_PI/4) && (relativeVel_commandPsi < M_PI/4)) ||
                            (relativeVel_commandPsi > 3*M_PI/4) || (relativeVel_commandPsi < -3*M_PI/4)) {

                        double d = tan(relativeVel_commandPsi);
                        double c = obstacleSpeed / Vt * (cos(relativeVel_commandPsi)*d - sin(relativeVel_commandPsi))
                            / sqrt(1 + d*d);

                        if (c > 1) {
                            commandPsi = -M_PI/2;
                        } else if (c < -1) {
                            commandPsi = M_PI/2;
                        } else {
                            commandPsi = asin(c);
                        }
                        if (d < 0) {
                            commandPsi += M_PI;
                        }
                        commandPsi += relativeVel_commandPsi;
                    }
                    // The regions for which the cotanget of relativeVel_commandPsi is well defined
                    else {

                        double d = -1*tan(relativeVel_commandPsi + M_PI/2); // cotangent
                        double c = obstacleSpeed / Vt * (cos(relativeVel_commandPsi) - d*sin(relativeVel_commandPsi))
                            / sqrt(1 + d*d);

                        if (c > 1) {
                            commandPsi = -M_PI/2;
                        } else if (c < -1) {
                            commandPsi = M_PI/2;
                        } else {
                            commandPsi = asin(c);
                        }
                        if (d < 0) {
                            commandPsi += M_PI;
                        }
                        commandPsi += relativeVel_commandPsi;
                    }
                } else {
                    commandPsi = psiW;
                }
            }

            // output
            eH = commandedAlt - alt;
            eV = commandedSpeed - Vt;
            eR = 0 - R;
            ePhi = 0 - phi;

            ePsi = commandPsi - psi;
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
