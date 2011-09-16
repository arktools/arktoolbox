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
    void getVehicleHeading(double* deltaBearing, double* deltaV, double vehSpeed, double vehBearing, double obstSpeed, double obstBearing, double desiredBearing, double bearingLim1, double bearingLim2, bool outsideLimits); 

    void checkAngle(double* alpha) {
        if(*alpha < -M_PI)
            *alpha += 2*M_PI;
        else if (*alpha > M_PI)
            *alpha -= 2*M_PI;
    }


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
            /*
               basic guidance to waypoint
               double psiW;
               double c;
               vincentys(lat, lon, commandedLat, commandedLon, &c, &psiW);
             */


            double dLon = commandedLon - lon;
            double y = sin(dLon) * cos(commandedLat);	            
            double x = cos(lat)*sin(commandedLat) - sin(lat)*cos(commandedLat)*cos(dLon);
            double c = sqrt(x*x + y*y);
            double psiW = atan2(y,x);


            // The separation window defines the radius that the vehicle will
            // attempt to clear. The hard window is the radius inside which
            // the vehicle will turn 90 degrees to clear.
            double separationWindow = 0.000075;

            /*
               basic safety zone collision avoidance
               double dC;
               double psiC;
               vincentys(lat, lon, obstacleLat, obstacleLon, &dC, &psiC);
             */


            double dLatC = obstacleLat-lat;
            double dLonC = obstacleLon-lon;
            double yC = sin(dLonC) * cos(obstacleLat);
            double xC = cos(lat)*sin(obstacleLat) - sin(lat)*cos(obstacleLat)*cos(dLonC);
            double dC = sqrt(xC*xC + yC*yC); // distance to collision
            double psiC = atan2(yC, xC);


            double commandPsi = psiW;
            double deltaPsi = 0;
            double deltaV = 0;
            double desiredPsi = 0;
            double lowerLimit;
            double upperLimit;
            double outsideLimits;

            // Only act if obstacles that are close
            if (dC < separationWindow * 25) {

                // Find the velocity vector of the vehicle relative to the obstacle.
                double relativeVel_x = commandedSpeed * cos(commandPsi) - obstacleSpeed * cos(obstaclePsi);                
                double relativeVel_y = commandedSpeed * sin(commandPsi) - obstacleSpeed * sin(obstaclePsi);
                double relativeVel_psi = atan2(relativeVel_y, relativeVel_x);

                double alpha = relativeVel_psi - psiC;
                checkAngle(&alpha);
                // Find the desired bearing of the relative velocity vector

                if (dC < separationWindow) {
                    // If the separation window has been violated, the relative velocity should be perpendicular
                    // to the collision course bearing.

                    // If the vehicle is already heading away, just have it go directly away
                    if( (alpha < -M_PI/2) || (alpha > M_PI/2)) {
                        desiredPsi = relativeVel_psi;
                    } else {

                        if(alpha < 0) {
                            desiredPsi = psiC - M_PI/2;
                        } else {
                            desiredPsi = psiC + M_PI/2;
                        }
                    }

                    checkAngle(&desiredPsi);
                    lowerLimit = desiredPsi - M_PI/12;
                    upperLimit = desiredPsi + M_PI/12;
                    outsideLimits = false;
                    checkAngle(&lowerLimit);
                    checkAngle(&upperLimit);

                } else {
                    double beta = asin(separationWindow/dC);
                    double gamma = 0;

                    // Get the desired bearing (needed so that the velocity can be modified if needed)
                    if(abs(alpha) < beta) {
                        if(alpha < 0) {
                            gamma = alpha -beta;
                        } else {
                            gamma = beta - alpha;
                        }
                    } else {
                        gamma = 0;
                    }

                    desiredPsi = relativeVel_psi + gamma;
                    checkAngle(&desiredPsi);
                    lowerLimit = psiC - beta;
                    upperLimit = psiC + beta;
                    outsideLimits = true;
                    checkAngle(&lowerLimit);
                    checkAngle(&upperLimit);
                }

                getVehicleHeading(&deltaPsi, &deltaV, Vt, commandPsi, obstacleSpeed, obstaclePsi, desiredPsi, lowerLimit, upperLimit, outsideLimits);
            }

            // output
            eH = commandedAlt - alt;
            eV = commandedSpeed - Vt;//+ deltaV- Vt;
            eR = 0 - R;
            ePhi = 0 - phi;

            ePsi = commandPsi - psi;// + deltaPsi;
            checkAngle(&ePsi);
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

#define NUM_BEARING_CALCS 18 // Must be an even number
void getVehicleHeading(double* deltaBearing, double* deltaV, double vehSpeed, double vehBearing, double obstSpeed, double obstBearing, double desiredBearing, double bearingLim1, double bearingLim2, bool outsideLimits) {

    double resBearing;

    *deltaBearing = 0;
    *deltaV = 0;

    for(int i = 0; i < NUM_BEARING_CALCS; i++){

        for(int j = i;;) {
            *deltaBearing = j * M_PI/NUM_BEARING_CALCS;
            resBearing = atan2(vehSpeed*sin(vehBearing+*deltaBearing)-obstSpeed*sin(obstBearing), vehSpeed*cos(vehBearing+*deltaBearing)-obstSpeed*cos(obstBearing));
            if(outsideLimits) {

                if (bearingLim1 < bearingLim2) {
                    if( (resBearing < bearingLim1) || (resBearing > bearingLim2)) {
                        return;
                    }
                } else {
                    if( (resBearing < bearingLim2) || (resBearing > bearingLim1)){
                        return;                
                    }
                }
            } else {
                if ( (resBearing > bearingLim1) && (resBearing < bearingLim2)) {
                    return;
                }
                if( bearingLim2 < bearingLim1) {
                    if ( (resBearing > bearingLim1) || (resBearing < bearingLim2)) {
                        return;
                    }
                }
            }

            if(j > 0)
                j *= -1;
            else
                break;
        }
    }

    // If execution reaches here, the desired resultant bearing cannot be created with a constant vehicle velocity
    // Set the resultant vector to be the desired direction with a non-trivial magnitude and adjust the vehicle's
    // velocity and bearing to match it.
    double vx = obstSpeed * cos(obstBearing) + cos(desiredBearing);
    double vy = obstSpeed * sin(obstBearing) + sin(desiredBearing);
    *deltaBearing = atan2(vy,vx) - vehBearing;
    *deltaV = sqrt(vx*vx + vy*vy) - vehSpeed;
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

        if (std::isnan(cos2SigmaM)) {
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
