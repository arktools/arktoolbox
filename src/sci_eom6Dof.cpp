/*sci_eom6Dof.cpp
 * Copyright (C) James Goppert Nicholas Metaxas 2011 
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
 * Input: 
 *  u1: F_b(0,0) , F_b(1,0) , F_b(2,0) 
 *  u2: M_b(0,0) , M_b(1,0) , M_b(2,0)
 *  u3: m, Jx, Jy, Jz, Jxy, Jxz, Jyz 
 *
 *  u4: (wind mode)
 *      1: Vt
 *      2: alpha
 *      3: theta
 *      4: wy
 *      5: beta
 *      6: phi
 *      7: wx
 *      8: psi
 *      9: wz 
 *
 *  u4: (body mode)
 *      1: U
 *      2: W
 *      3: theta
 *      4: wy
 *      5: V
 *      6: phi
 *      7: wx
 *      8: psi
 *      9: wz 
 *
 * Output:
 *  y1: (state derivative)
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

//void sci_windDynamics(scicos_block *block, scicos::enumScicosFlags flag)
void sci_eom6Dof(scicos_block *block, scicos::enumScicosFlags flag)
{
    enum frameEnum {WIND_DYNAMICS=0,BODY_DYNAMICS=1};
    
    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);
    double * u3=(double*)GetInPortPtrs(block,3);
    double * u4=(double*)GetInPortPtrs(block,4);
    double * y1=(double*)GetOutPortPtrs(block,1);

    double * rpar=block->rpar;
    int * ipar=block->ipar;

    // aliases

    int & frame = ipar[0];
  
    // matrices
    int nY = 9;
    using namespace boost::numeric::ublas;
    matrix<double,column_major, shallow_array_adaptor<double> > F_b_(3,1,shallow_array_adaptor<double>(3,u1));
    matrix<double,column_major, shallow_array_adaptor<double> > M_b_(3,1,shallow_array_adaptor<double>(3,u2));
  
    // mass/inertia params
    double & m       = u3[0];
    double & Jx      = u3[1];
    double & Jy      = u3[2];
    double & Jz      = u3[3];
    double & Jxy     = u3[4];
    double & Jxz     = u3[5];
    double & Jyz     = u3[6];

    // sizes
    //handle flags
    if (flag==scicos::computeOutput)
    {
  
        if (frame == WIND_DYNAMICS)
        {    
            double & Vt      = u4[0];
            double & alpha   = u4[1];
            double & theta   = u4[2];
            double & wy      = u4[3];
            double & beta    = u4[4];
            double & phi     = u4[5];
            double & wx      = u4[6];
            double & psi     = u4[7];
            double & wz      = u4[8];

            const double cosAlpha = cos(alpha);
            const double sinAlpha = sin(alpha);
            const double cosBeta = sin(beta);
            const double sinBeta = cos(beta);
            const double sinPhi = sin(phi);
            const double cosPhi = cos(phi);
            const double sinTheta = sin(theta);
            const double cosTheta = cos(theta);
            const double tanTheta = tan(theta);
            const double JxyJxy = Jxy*Jxy;
            const double JxzJxz = Jxz*Jxz;
            const double JyzJyz = Jyz*Jyz;
                     
            matrix<double,column_major, shallow_array_adaptor<double> > d_x_wind(nY,1,shallow_array_adaptor<double>(nY,y1));

            #include "dynamics/windDynamics.hpp"
        }
        else if (frame == BODY_DYNAMICS)
        {
            double & U       = u4[0];
            double & W       = u4[1];
            double & theta   = u4[2];
            double & wy      = u4[3];
            double & V       = u4[4];
            double & phi     = u4[5];
            double & wx      = u4[6];
            double & psi     = u4[7];
            double & wz      = u4[8];

            const double sinPhi = sin(phi);
            const double cosPhi = cos(phi);
            const double sinTheta = sin(theta);
            const double cosTheta = cos(theta);
            const double tanTheta = tan(theta);
            const double JxyJxy = Jxy*Jxy;
            const double JxzJxz = Jxz*Jxz;
            const double JyzJyz = Jyz*Jyz;

            matrix<double,column_major, shallow_array_adaptor<double> > d_x_body(nY,1,shallow_array_adaptor<double>(nY,y1));

            #include "dynamics/dynamicsBodyFrame.hpp"
        }
        else if (flag==scicos::terminate)
        {
        }
    }
    else if (flag==scicos::initialize || flag==scicos::reinitialize)
    {
    }
    else
    {
        //std::cout << "unhandled block flag: " << flag << std::endl;
    }
}

} // extern c

// vim:ts=4:sw=4:expandtab
