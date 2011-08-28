/*
 * sci_flightGearComm.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_flightGearComm.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_flightGearComm.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "communication/FlightGearComm.hpp"

extern "C"
{

#include "definitions.hpp"
#include <scicos/scicos_block4.h>
#include <math.h>

    void sci_flightGearComm(scicos_block *block, scicos::enumScicosFlags flag)
    {
        static FlightGearComm * fgComm=NULL;
        static const double kts2fps=1.68780986;

        // definitions
        double *u=(double*)GetInPortPtrs(block,1);
        double *y=(double*)GetOutPortPtrs(block,1);

        // handle flags
        if (flag==scicos::initialize || flag==scicos::reinitialize)
        {
            std::cout << "initializing" << std::endl;
            if (fgComm) delete fgComm; // delete if already allocated
            fgComm = new FlightGearComm("localhost","5500","5501","5502");
        }
        else if (flag==scicos::terminate)
        {
            std::cout << "terminating" << std::endl;
            if (fgComm) delete fgComm; // delete if already allocated
            fgComm=NULL;
        }
        else if (flag==scicos::computeOutput)
        {
            //receive data from flightGear
            fgComm->receive();
            //fgComm->output(); // output to terminal

            // create output vector
            y[0] = fgComm->getFdmRecvBuf().vcas*kts2fps;
            y[1] = fgComm->getFdmRecvBuf().alpha;
            y[2] = fgComm->getFdmRecvBuf().theta;
            y[3] = fgComm->getFdmRecvBuf().thetadot;
            y[4] = fgComm->getFdmRecvBuf().altitude;
            y[5] = fgComm->getFdmRecvBuf().beta;
            y[6] = fgComm->getFdmRecvBuf().phi;
            y[7] = fgComm->getFdmRecvBuf().phidot;
            y[8] = fgComm->getFdmRecvBuf().psidot;
            y[9] = fgComm->getFdmRecvBuf().psi;
            y[10] = fgComm->getFdmRecvBuf().rpm[0];

            // set controls
            fgComm->setCtrlsTransBuf().aileron = u[0];
            fgComm->setCtrlsTransBuf().elevator = u[1];
            fgComm->setCtrlsTransBuf().rudder = -u[2];
            for (int i=0; i<4; i++) fgComm->setCtrlsTransBuf().throttle[i] = u[3];

            // send data to flightGear
            fgComm->send();
        }
        else
        {
            std::cout << "unhandled flag: " << flag << std::endl;
        }
    }

}

// vim:ts=4:sw=4
