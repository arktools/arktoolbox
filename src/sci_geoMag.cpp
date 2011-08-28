/*sci_geoMag.cpp
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
 *  u1: lat lon alt
 * Output:
 *  y1: inclination (rad), decliation(rad), field strength(nT)
 *
 */

#include <iostream>
#include <string>
#include <cstdlib>
#include "utilities.hpp"
#include <config.h>
#include <stdexcept>
#include "navigation/GeoMag.hpp"

extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

void sci_geoMag(scicos_block *block, scicos::enumScicosFlags flag)
{
    static mavsim::GeoMag* geoMag = NULL;
    
    // constants

    // data
    double * u1=(double*)GetInPortPtrs(block,1);
    double * y1=(double*)GetOutPortPtrs(block,1);
    double * rpar=block->rpar;
    int * ipar=block->ipar;

    // aliases
    //
    double & lat   = u1[0];
    double & lon   = u1[1];
    double & alt   = u1[2];
    
    double & dip = y1[0];
    double & dec = y1[1];
    double & H0  = y1[2];

    double & decYear = rpar[0];
    int & nTerms = ipar[0];

    //make sure you have initialized the block
    if(!geoMag && flag!=scicos::initialize)
    {
        sci_geoMag(block,scicos::initialize);
    }
    
    //handle flags
    if (flag==scicos::initialize || flag==scicos::reinitialize)
    {
        std::cout << "initializing" << std::endl;
        if (!geoMag)
        {
            try
            {
                geoMag = new mavsim::GeoMag("DATADIR/WMM.COF",nTerms);
            }
            catch (const std::runtime_error & e)
            {
                Coserror((char *)e.what());
            }
        }
    }
    else if (flag==scicos::terminate)
    {
        std::cout << "terminating" << std::endl;
        if (geoMag)
        {
            delete geoMag;
            geoMag = NULL;
        }
    }
    else if (flag==scicos::updateState)
    {
        //std::cout << "updating state" << std::endl;
    }
    else if (flag==scicos::computeOutput)
    {
        //std::cout << "computing Output" << std::endl;
        if(geoMag)
        {
            geoMag->update(lat*180/M_PI,lon*180/M_PI,alt,decYear);
            dip = geoMag->dip*M_PI/180;
            dec = geoMag->dec*M_PI/180;
            H0  = geoMag->ti;
        }
    }
    else
    {
        std::cout << "unhandled flag: " << flag << std::endl;
    }
}

} // extern c
// vim:ts=4:sw=4:expandtab
