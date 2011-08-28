/*sci_quat2EulerDcm.cpp
 * Copyright (C) Alan Kim, James Goppert 2011 
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
 * u1: a, b, c, d (quaternion)
 * u2: wx, wy, wz (body angular rates)
 *
 * y1: C_nb
 * y2: euler
 * y3: eulerRates
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

void sci_quat2EulerDcm(scicos_block *block, scicos::enumScicosFlags flag)
{

    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);

    double * y1=(double*)GetOutPortPtrs(block,1);
    double * y2=(double*)GetOutPortPtrs(block,2);
    double * y3=(double*)GetOutPortPtrs(block,3);

    // alias names
    double & a0 = u1[0];
    double & b0 = u1[1];
    double & c0 = u1[2];
    double & d0 = u1[3];

    double & wx = u2[0];
    double & wy = u2[1];
    double & wz = u2[2];

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

    double & phi = y2[0];
    double & theta = y2[1];
    double & psi = y2[2];

    double & phiRate = y3[0];
    double & thetaRate = y3[1];
    double & psiRate = y3[2];

    //handle flags
    if (flag==scicos::computeOutput)
    {
        // normalize quaternions
        // this is a bit paranoid and can be ignored if you trust the user
        const double qNorm = sqrt(a0*a0+b0*b0+c0*c0+d0*d0); 
        const double a = a0/qNorm;
        const double b = b0/qNorm;
        const double c = c0/qNorm;
        const double d = d0/qNorm;

        const double aa = a*a;
        const double bb = b*b;
        const double cc = c*c;
        const double dd = d*d;

        static const double gimbalLockTol = 1e-3;
        static const double normalTol = 1e-3;
        static const double pi_2 = M_PI/2;

        c11 = aa+bb-cc-dd;
        c21 = 2*(b*c+a*d);
        c31 = 2*(b*d-a*c);
        c12 = 2*(b*c-a*d);
        c22 = aa-bb+cc-dd;
        c32 = 2*(c*d+a*b);
        c13 = 2*(b*d+a*c);
        c23 = 2*(c*d-a*b);
        c33 = aa-bb-cc+dd;

        // calculate theta (pitch)
        if (c31>1) theta = -pi_2;
        else if (c31<-1) theta = pi_2;
        else theta = asin(-c31);

        // if pitch is close to - 90 deg
        if ( theta < gimbalLockTol - M_PI/2)
        {
            phi = 0;
            psi = atan2(c23 + c12,c13 - c22);
            phiRate = 0;
            psiRate = wx;
        }
        // if pitch is clost to 90 deg
        else if ( theta > M_PI/2 - gimbalLockTol)
        {   
            phi = 0;
            psi = atan2(c23 - c12,c13 + c22);
            phiRate = 0;
            psiRate = -wx;
        }
        else
        {
            phi = atan2(c32,c33);
            psi = atan2(c21,c11);
            phiRate = (wy*sin(phi) + wz*cos(phi))*tan(theta) + wx;
            psiRate = (wy*sin(phi) + wz*cos(phi))/cos(theta);
        }

        // make psi 0 -> 2*pi
        if (psi < 0) psi += 2*M_PI;

        // euler rates
        thetaRate = (wy*cos(phi) - wz*sin(phi));

        // debug
        //printf("phi\t:\t%f\n",phi);
        //printf("theta\t:\t%f\n",theta);
        //printf("psi\t:\t%f\n",psi);
        //printf("phiRate\t:\t%f\n",phiRate);
        //printf("thetaRate\t:\t%f\n",thetaRate);
        //printf("psiRate\t:\t%f\n",psiRate);
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
