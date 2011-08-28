/* sci_navigationEquations.cpp
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
 *  u1: U,V,W 
 *  u2: phi,theta,psi 
 * Output:
 *  y1: vN,vE,vD
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

void sci_navigationEquations(scicos_block *block, scicos::enumScicosFlags flag)
{
    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * u2=(double*)GetInPortPtrs(block,2);
    double * y1=(double*)GetOutPortPtrs(block,1);

    double * rpar=block->rpar;
    int * ipar=block->ipar;

    // aliases
    double & U     = u1[0];
    double & V     = u1[1];
    double & W     = u1[2];

    double & phi   = u2[0];
    double & theta = u2[1];
    double & psi   = u2[2];

    // sizes
    int nY = 3;

    // matrices
    using namespace boost::numeric::ublas;

    //handle flags
    if (flag==scicos::computeOutput)
    {
        matrix<double,column_major, shallow_array_adaptor<double> > 
            v_n(nY,1,shallow_array_adaptor<double>(nY,y1));
        const double cosPhi = cos(phi);
        const double sinPhi = sin(phi);
        const double cosTheta = cos(theta);
        const double sinTheta = sin(theta);
        const double cosPsi = cos(psi);
        const double sinPsi = sin(psi);
        #include "dynamics/navigationEquations.hpp"
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
