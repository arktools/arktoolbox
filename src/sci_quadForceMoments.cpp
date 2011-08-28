/*sci_quadForceMoments.cpp
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
 *  u1: dutycycle_L,dutycycle_R,dutycycle_F,dutycycle_B
 *  u2: KV,rBlade,CT,K_cd_cl,Cd0,s_frame,dm
 *  u2: batVolt,rho
 *  u3: Vt,alpha,beta
 *
 * Output:
 *  y1: F_b
 *  y1: M_b
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

void sci_quadForceMoments(scicos_block *block, scicos::enumScicosFlags flag)
{
    enum ins_mode {INS_FULL_STATE=0,INS_ATT_STATE=1,INS_VP_STATE=2};

    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);
    double * u3=(double*)GetInPortPtrs(block,3);
    double * y1=(double*)GetOutPortPtrs(block,1);
    double * y2=(double*)GetOutPortPtrs(block,1);

       double * rpar=block->rpar;
    int * ipar=block->ipar;

    // aliases
    double & dutycycle_L     = u1[0];
    double & dutycycle_R     = u1[1];
    double & dutycycle_F     = u1[2];
    double & dutycycle_B     = u1[3];

    double & batVolt    = u2[5];
    double & rho        = u2[5];

    double & KV         = u3[0];

    double & Vt         = u2[3];
    double & alpha      = u2[4];
    double & beta       = u2[5];

  
    double & Omega = rpar[0];
    double & Re = rpar[1];
    int & mode = ipar[0];

    // Note that l = lon, and not in the equations but left here
    // for ease of use with full state vector x
    double & a      = u3[0];
    double & b      = u3[1];
    double & c      = u3[2];
    double & d      = u3[3];
    double & Vn     = u3[4];
    double & Ve     = u3[5];
    double & Vd     = u3[6];
    double & L      = u3[7];
    double & l      = u3[8];
    double & alt    = u3[9];

    // sizes
    int nY = 0;
    if (mode == INS_FULL_STATE) nY = 10;
    else if (mode == INS_ATT_STATE) nY = 4;
    else if (mode == INS_VP_STATE) nY = 6;
    else Coserror((char *)"unknown mode for insErrorDynamics block");

    // matrices
    using namespace boost::numeric::ublas;
    matrix<double,column_major, shallow_array_adaptor<double> > f(nY,1,shallow_array_adaptor<double>(nY,y1));

    //handle flags
    if (flag==scicos::computeOutput)
    {
        const double cosL = cos(L);
        const double sinL = sin(L);
        const double tanL = sinL/cosL;
        const double R = Re+alt;
        const double aa=a*a, bb=b*b, cc=c*c, dd=d*d;

        //#include "navigation/ins_dynamics_f_vp.hpp"
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
