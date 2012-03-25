/*sci_sailboatForceMoments.cpp
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
 * Input:
 *  u1: winchPosition, rudderPosition
 *  u2: windSpeed, windDirection
 *  u3: U,W,thetai,wy,V,phi,wx,psi,wz
 *  u4: sailPosition
 *
 * Output:
 *  y1: sailPosition, rudderPosition
 *  y2: F_b
 *  y3: M_b
 *  y4: alpha, apparentWindDir, LRudder, DRudder, apparentWindSpeed, relativeCourseOverGround
 *  y5: sailPositionRate
 *
 */

#define BOOST_UBLAS_SHALLOW_ARRAY_ADAPTOR 1

#include <iostream>
#include <string>
#include <cstdlib>
#include "utilities.hpp"
#include <stdexcept>

#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>

extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

void sci_sailboatForceMoments(scicos_block *block, scicos::enumScicosFlags flag)
{
    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);
    double * u3=(double*)GetInPortPtrs(block,3);
    double * u4=(double*)GetInPortPtrs(block,4);
    double * y1=(double*)GetOutPortPtrs(block,1);
    double * y2=(double*)GetOutPortPtrs(block,2);
    double * y3=(double*)GetOutPortPtrs(block,3);
    double * y4=(double*)GetOutPortPtrs(block,4);
    double * y5=(double*)GetOutPortPtrs(block,5);
    double * y6=(double*)GetOutPortPtrs(block,6);
    double * y7=(double*)GetOutPortPtrs(block,7);
    double * rpar=(double*)GetRparPtrs(block);

    // input
    double winchPosition = u1[0]; // m/s
    double rudderPosition = u1[1]; // rad

    // wind
    double windSpeed = u2[0]; // m/s
    double windDir = u2[1]; // rad

    // state variables
    double U = u3[0]; // m/s
    double W = u3[1]; // m/s
    double theta = u3[2]; // rad
    double wy = u3[3]; // rad/s
    double V = u3[4]; // m/s
    double phi= u3[5]; // rad
    double wx = u3[6]; // rad/s
    double psi = u3[7]; // rad
    double wz = u3[8]; // rad/s

    // sail position
    double sailPosition = u4[0];

    //handle flags
    if (flag==scicos::computeOutput)
    {
        // environment constants
        double rho = rpar[0]; // 1.225; // density of air, kg/m^3
        double rhoW = rpar[1]; //1000; // density of water, kg/m^3

        // sail constants
        double s = rpar[2]; // 1; // area of sail, m^2
        double cD0 =rpar[3]; // 0.1; // zero order sail drag polar coefficient
        double cD2 =rpar[4]; // 0.01; // 2nd order sail drag polar coefficient
        double cLAlpha =rpar[5]; // 2*M_PI; // lift curve slope for sail
        double alphaStall =rpar[6]; // 20*M_PI/180; // stall angle of attack for sail
        double xSail =rpar[7]; // 0.2; // distance mast to sail center of effort, m
        double dSail =rpar[8]; // 0.3; // distance from center of mass to mast, m

        // rudder constants
        double xRudder =rpar[9]; // 0.5; // distance from center of mass to rudder, m
        double cD0Rudder =rpar[10]; // 0.1; // zero order rudder drag polar coefficient
        double cD2Rudder =rpar[11]; // 0.01; // zero order rudder drag polar coefficient
        double sRudder =rpar[12]; // 0.05; // area of rudder, m^2
        double alphaRudderStall =rpar[13]; // 20*M_PI/180; // rudder stall angle, rad
        double cLAlphaRudder =rpar[14]; // 2; // rudder lift curve slope

        // hull constants
        double sWater =rpar[15]; // 1; // wetted area of boat, m^2
        double cDWater =rpar[16]; // 0.03; // drag coefficient, need to measure (can adjust using top speed)
        double cWaterRot =rpar[17]; // 5; // coefficient of damping for spinning in the water

        // local variables
        double F_b[3] = {0,0,0}; // force in the body frame
        double M_b[3] = {0,0,0}; // moment in the body frame
        unsigned int i = 0; // counter

        // sail lift/ drag
        double apparentWind[2] = {0,0};
        double relativeWindDir = windDir - psi;
        while (relativeWindDir > M_PI) relativeWindDir = relativeWindDir - 2*M_PI;
        while (relativeWindDir < -M_PI) relativeWindDir = relativeWindDir + 2*M_PI;
        apparentWind[0] = windSpeed*cos(relativeWindDir) - U;
        apparentWind[1] = windSpeed*sin(relativeWindDir) -V;
        double apparentWindSpeed =sqrt(apparentWind[0]*apparentWind[0] + apparentWind[1]*apparentWind[1]);
        double apparentWindDir = atan2(apparentWind[1],apparentWind[0]);
        double alpha =  apparentWindDir -sailPosition;
        while (alpha > M_PI) alpha = alpha - 2*M_PI;
        while (alpha < -M_PI) alpha = alpha + 2*M_PI;
        double cL = cLAlpha*alpha;
        if  (alpha > alphaStall) cL = cLAlpha*alphaStall;
        else if (alpha < -alphaStall) cL = -cLAlpha*alphaStall;
        double cD = cD0 + cD2*cL*cL;
        double q = 0.5*rho*apparentWindSpeed*apparentWindSpeed;
        double L  = cL*q*s;
        double D = cD*q*s;

        // water drag
        double groundSpeed =sqrt(U*U+V*V);
        double relativeCourseOverGround = atan2(V,U);
        double apparentWaterVelocityAtRudder[2] = {0,0};
        apparentWaterVelocityAtRudder[0] = -U;
        apparentWaterVelocityAtRudder[1] = -V; // + xRudder*wz;
        double apparentWaterSpeedAtRudder =sqrt(apparentWaterVelocityAtRudder[0]*apparentWaterVelocityAtRudder[0] + 
            apparentWaterVelocityAtRudder[1]*apparentWaterVelocityAtRudder[1]);
        double apparentWaterDirAtRudder = atan2(apparentWaterVelocityAtRudder[1],apparentWaterVelocityAtRudder[0]);
        double qWater = 0.5*rhoW*groundSpeed*groundSpeed; // wz has no effect at cm so using ground speed
        double DWater = cDWater*qWater*sWater;

        // rudder lift/ drag
        double alphaRudder = apparentWaterDirAtRudder - rudderPosition;
        while (alphaRudder > M_PI) alphaRudder = alphaRudder - 2*M_PI;
        while (alphaRudder < -M_PI) alphaRudder = alphaRudder + 2*M_PI;
        double cLRudder = cLAlphaRudder*alphaRudder;
        if  (alphaRudder > alphaRudderStall) cLRudder = cLAlphaRudder*alphaRudderStall;
        else if (alphaRudder < -alphaRudderStall) cLRudder = -cLAlphaRudder*alphaRudderStall;
        double cDRudder = cD0Rudder + cD2Rudder*cLRudder*cLRudder;
        double qWaterRudder = 0.5*rhoW*apparentWaterSpeedAtRudder*apparentWaterSpeedAtRudder; // wz has effect
        double LRudder  = cLRudder*qWaterRudder*sRudder;
        double DRudder = cDRudder*qWaterRudder*sRudder;

        // hull spin damping
        double WaterDamp = -cWaterRot*wz;
        if (wz <0) WaterDamp = -WaterDamp;

        // rudder moment
        double MRudder = (LRudder*cos(rudderPosition) + DRudder * sin(rudderPosition))*xRudder;

        // sail moment
        double MSail = L*(-cos(sailPosition)*(dSail - xSail*cos(sailPosition))+sin(sailPosition)*xSail*cos(sailPosition)); 
            + D*(-sin(sailPosition)*(dSail-xSail*cos(sailPosition))-xSail*cos(sailPosition)*cos(sailPosition));

        // sum of forces
        F_b[0] = L*sin(sailPosition) - D*cos(sailPosition) - DWater*cos(relativeCourseOverGround) + LRudder*sin(rudderPosition) - DRudder*cos(rudderPosition);
        F_b[1] = 0; // assume no side silp
        F_b[2] = 0; // assuming fixed in water

        // sum of moments
        M_b[0] = 0;
        M_b[1] = 0;
        M_b[2] = MSail + MRudder + WaterDamp;

        // sail dynamics
        double JSail = 0.1;
        double winchMoment =  100*(fabs(sailPosition)-winchPosition*90*M_PI/180);
        if (winchMoment < 0)  winchMoment = 0; // can't push
        if (sailPosition > 0) winchMoment = -winchMoment;

        double sailPositionRate = (L*xSail +winchMoment) / JSail;

        // output assignment
        y1[0] = sailPosition;
        y1[1] = rudderPosition;

        for(i=0;i<3;i=i+1) {
            y2[i] = F_b[i];
            y3[i] = M_b[i];
        }
        y4[0] = alpha;
        y4[1] = apparentWindDir;
        y4[2] = LRudder;
        y4[3] = DRudder;
        y4[4] = apparentWindSpeed;
        y4[5] = relativeCourseOverGround;

        y5[0] = sailPositionRate;
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
