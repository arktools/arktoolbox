/*
 * sci_gpsIns.cpp
 * Copyright (C) Brandon Wampler 2010 <bwampler@users.sourceforge.net>
 *
 * sci_gpsIns.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_gpsIns.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * x: Longitude, Latitude, Altitude, Roll, Pitch, Yaw, Vn, Ve, Vd
 *
 * u1: fbx, fby, fbz, wbx, wby, wbz
 * u2: Lat, Lon, Alt, roll, pitch, yaw, Vn, Ve, Vd
 *
 * y: x
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

    void sci_gpsIns(scicos_block *block, scicos::enumScicosFlags flag)
    {
		static mavsim::GpsIns* gpsIns = NULL;

		// constants
		bool useGravity = false;

	 	// data
        double * u1=(double*)GetInPortPtrs(block,1);
		double * u2=(double*)GetInPortPtrs(block,2);
        double * xOut=(double*)GetOutPortPtrs(block,1);
        double * rpar=block->rpar;

		// alias names
		double * fbx = &u1[0];
		double * fby = &u1[1];
		double * fbz = &u1[2];
		double * wbx = &u1[3];
		double * wby = &u1[4];
		double * wbz = &u1[5];

		double * lat = &u2[0];
		double * lon = &u2[1];
		double * height = &u2[2];
		double * roll = &u2[3];
		double * pitch = &u2[4];
		double * yaw = &u2[5];
		double * Vn = &u2[6];
		double * Ve = &u2[7];
		double * Vd = &u2[8];

		double * sigmaPos = &rpar[0];
		double * sigmaAlt = &rpar[1];
		double * sigmaVel = &rpar[2];
		double * sigmaAccelG = &rpar[3];
		double * sigmaGyro = &rpar[4];

	
		// make sure you have initialized the block
        if (!gpsIns && flag!=scicos::initialize)
        {
            sci_gpsIns(block,scicos::initialize);
        }

        //handle flags
        if (flag==scicos::initialize || flag==scicos::reinitialize)
        {
            std::cout << "initializing" << std::endl;
            if (!gpsIns)
            {
			
				try
				{
                	gpsIns = new mavsim::GpsIns(*lat,*lon,*height,*roll,*pitch,*yaw,*Vn,*Ve,*Vd,*sigmaPos,*sigmaAlt,*sigmaVel,*sigmaAccelG,*sigmaGyro,useGravity);
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
            if (gpsIns)
            {
                delete gpsIns;
                gpsIns = NULL;
            }
        }
        else if (flag==scicos::updateState)
        {
            std::cout << "updating state" << std::endl;
		
        }
        else if (flag==scicos::computeOutput)
        {
            std::cout << "computing Output" << std::endl;
			if(gpsIns)
			{
				gpsIns->updateAll(*fbx, *fby, *fbz, *wbx, *wby,
						*wbz, *lat, *lon, *height, *Vn, *Ve, *Vd);
				gpsIns->getState(xOut);
			}
        }
        else
        {
            std::cout << "unhandled flag: " << flag << std::endl;
        }

    }

} // extern c

// vim:ts=4:sw=4
