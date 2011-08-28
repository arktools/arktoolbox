/*
 * sci_jsbsimComm.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_jsbsimComm.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_jsbsimComm.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * x: Vt, Alpha, Theta, Q, Alt, Beta, Phi, P, R, Psi, Longitude, Latitude,
 * 		Rpm0,RPM1,RPM2,RPM3 (dependent on number of engines) (if prop), PropPitch (if prop)
 *
 * u: Throttle, Aileron, Elevator, Rudder
 * 
 * y: x
 *
 */

#include "FGFDMExec.h"
#include "models/FGFCS.h"
#include "math/FGStateSpace.h"
#include <iostream>
#include <string>
#include <cstdlib>
#include "input_output/FGPropertyManager.h"
#include "input_output/flightGearIO.h"
#include "utilities.hpp"
#include <stdexcept>

namespace JSBSim
{

class JSBSimComm
{
public:
    JSBSimComm(char * root, char * aircraftPath, char * enginePath,
               char * systemsPath, char * modelName,
               double * x0, double * u0, int debugLevel,
               bool enableFlightGearComm, char * flightGearHost, int flightGearPort) :
        prop(), fdm(&prop), ss(fdm), socket()
    {
        std::cout << "initializing JSBSim" << std::endl;
        fdm.SetDebugLevel(debugLevel);
		
        if (!fdm.LoadModel(
            std::string(root)+std::string(aircraftPath),
            std::string(root)+std::string(enginePath),
            std::string(root)+std::string(systemsPath),
            std::string(modelName),false))
		{
			throw std::runtime_error("unable to load model: " + std::string(root)+std::string(aircraftPath));
		}

        if (enableFlightGearComm)
        {
            std::cout << "initializing FlightGear communication" << std::endl;
            socket = new FGfdmSocket(flightGearHost,flightGearPort,FGfdmSocket::ptUDP);
			if (!socket) throw std::runtime_error("unable to open FlightGear socket");
        }

        // defaults
        bool variablePropPitch = false;

        // get propulsion pointer to determine type/ etc.
        FGEngine * engine0 = fdm.GetPropulsion()->GetEngine(0);
        FGThruster * thruster0 = engine0->GetThruster();

        // longitudinal states
        ss.x.add(new FGStateSpace::Vt);
        ss.x.add(new FGStateSpace::Alpha);
        ss.x.add(new FGStateSpace::Theta);
        ss.x.add(new FGStateSpace::Q);
        ss.x.add(new FGStateSpace::Alt);

        // lateral states
        ss.x.add(new FGStateSpace::Beta);
        ss.x.add(new FGStateSpace::Phi);
        ss.x.add(new FGStateSpace::P);
        ss.x.add(new FGStateSpace::R);
        ss.x.add(new FGStateSpace::Psi);

        // nav states
        ss.x.add(new FGStateSpace::Longitude);
        ss.x.add(new FGStateSpace::Latitude);

        // propulsion states
		if (thruster0->GetType()==FGThruster::ttPropeller)
		{
			ss.x.add(new FGStateSpace::Rpm0);
			if (variablePropPitch) ss.x.add(new FGStateSpace::PropPitch);
			int numEngines = fdm.GetPropulsion()->GetNumEngines();
			if (numEngines>1) ss.x.add(new FGStateSpace::Rpm1);
			if (numEngines>2) ss.x.add(new FGStateSpace::Rpm2);
			if (numEngines>3) ss.x.add(new FGStateSpace::Rpm3);
		}

        // input
        ss.u.add(new FGStateSpace::ThrottleCmd);
        ss.u.add(new FGStateSpace::DaCmd);
        ss.u.add(new FGStateSpace::DeCmd);
        ss.u.add(new FGStateSpace::DrCmd);

        // state feedback
        ss.y.add(new FGStateSpace::Latitude);
		ss.y.add(new FGStateSpace::Longitude);
		ss.y.add(new FGStateSpace::Alt);
		ss.y.add(new FGStateSpace::COG);
		ss.y.add(new FGStateSpace::VGround);
		ss.y.add(new FGStateSpace::AccelX);
		ss.y.add(new FGStateSpace::AccelY);
		ss.y.add(new FGStateSpace::AccelZ);
		ss.y.add(new FGStateSpace::Pi);
		ss.y.add(new FGStateSpace::Qi);
		ss.y.add(new FGStateSpace::Ri);
		ss.y.add(new FGStateSpace::Vn);
		ss.y.add(new FGStateSpace::Ve);
		ss.y.add(new FGStateSpace::Vd);


        // turn on propulsion
        fdm.GetPropulsion()->InitRunning(-1);

        // set initial conditions
        ss.x.set(x0);
        ss.u.set(u0);
    }
    virtual ~JSBSimComm()
    {
        if (socket) delete socket;
    }
    void sendToFlightGear()
    {
        FGNetFDM netFdm;
        JSBSim2FlightGearNetFDM(fdm,netFdm);
        if (socket) socket->Send((char *)(& netFdm), sizeof(netFdm));
        //std::cout << ss << std::endl;
        //std::cout << ss.x.getDeriv() << std::endl;
    }
public:
    FGPropertyManager prop;
    FGFDMExec fdm;
    FGStateSpace ss;
    FGfdmSocket * socket;
};

} // JSBSim

extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

    void sci_jsbsimComm(scicos_block *block, scicos::enumScicosFlags flag)
    {
        static JSBSim::JSBSimComm * comm = NULL;
        static JSBSim::FGPropertyManager propManager;
        static char * root, * modelName, * aircraftPath, * enginePath,
               * systemsPath, * flightGearHost;
        static int debugLevel;
        static int enableFlightGearComm, flightGearPort;
        static char ** stringArray;
        static int * intArray;

        // data
        double *u=(double*)GetInPortPtrs(block,1);
        double *xOut=(double*)GetOutPortPtrs(block,1);
        double *y=(double*)GetOutPortPtrs(block,2);
        double *x=(double*)GetState(block);
        double *xd=(double*)GetDerState(block);
        int * ipar=block->ipar;

        // make sure you have initialized the block
        if (!comm && flag!=scicos::initialize)
        {
            sci_jsbsimComm(block,scicos::initialize);
        }

        //handle flags
        if (flag==scicos::initialize || flag==scicos::reinitialize)
        {
            if (!comm)
            {
                getIpars(6,3,ipar,&stringArray,&intArray);
                root = stringArray[0];
                aircraftPath = stringArray[1];
                enginePath = stringArray[2];
                systemsPath = stringArray[3];
                modelName = stringArray[4];
                flightGearHost=stringArray[5];
                debugLevel = intArray[0];
                enableFlightGearComm = intArray[1];
                flightGearPort = intArray[2];
				try
				{
                	comm = new JSBSim::JSBSimComm(root,aircraftPath,enginePath,systemsPath,modelName,x,u,debugLevel,
                    	enableFlightGearComm,flightGearHost,flightGearPort);
				}
				catch (const std::runtime_error & e)
				{
					Coserror((char *)e.what());
				}
            }
        }
        else if (flag==scicos::terminate)
        {
            if (comm)
            {
                delete comm;
                comm = NULL;
            }
        }
        else if (flag==scicos::updateState)
        {
            //std::cout << "updating state" << std::endl;
            comm->ss.u.set(u);
            comm->ss.x.set(x);
            if (enableFlightGearComm==1)
            {
                comm->sendToFlightGear();
            }
        }
        else if (flag==scicos::computeDeriv)
        {
            //std::cout << "computing deriv" << std::endl;
            comm->ss.x.getDeriv(xd);
        }
        else if (flag==scicos::computeOutput)
        {
            //std::cout << "computing output" << std::endl;
            sci_jsbsimComm(block,scicos::updateState);
            comm->ss.x.get(xOut);
            comm->ss.y.get(y);
        }
        else
        {
            std::cout << "unhandled flag: " << flag << std::endl;
        }
    }

} // extern c

// vim:ts=4:sw=4
