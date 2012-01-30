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
 * x: Vt, Alpha, Theta, Q, Alt, Beta, Phi, P, Psi, R, Longitude, Latitude,
 * 		Rpm0,RPM1,RPM2,RPM3 (dependent on number of engines) (if prop), PropPitch (if prop)
 *
 * u: Throttle, Aileron, Elevator, Rudder
 *
 * y: x
 *
 */

#include "jsbsim/FGFDMExec.h"
#include "jsbsim/models/FGFCS.h"
#include "jsbsim/models/FGOutput.h"
#include "jsbsim/math/FGStateSpace.h"
#include <iostream>
#include <string>
#include <cstdlib>
#include "input_output/FGPropertyManager.h"
#include "input_output/FGfdmSocket.h"
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
        prop(), fdm(&prop), ss(&fdm), socket()
    {
        //std::cout << "initializing JSBSim" << std::endl;
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
            socket = new FGOutput(&fdm);
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

        // lateral states
        ss.x.add(new FGStateSpace::Beta);
        ss.x.add(new FGStateSpace::Phi);
        ss.x.add(new FGStateSpace::P);
        ss.x.add(new FGStateSpace::Psi);
        ss.x.add(new FGStateSpace::R);

        // nav states
        ss.x.add(new FGStateSpace::Latitude);
        ss.x.add(new FGStateSpace::Longitude);
        ss.x.add(new FGStateSpace::Alt);

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
        ss.y.add(new FGStateSpace::P);
        ss.y.add(new FGStateSpace::Q);
        ss.y.add(new FGStateSpace::R);
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
        if (socket) socket->FlightGearSocketOutput();
    }
public:
    FGPropertyManager prop;
    FGFDMExec fdm;
    FGStateSpace ss;
    FGOutput * socket;
};

} // JSBSim

extern "C"
{

#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

    void sci_jsbsimComm(scicos_block *block, scicos::enumScicosFlags flag)
    {
        // data
        double *u=(double*)GetInPortPtrs(block,1);
        double *xOut=(double*)GetOutPortPtrs(block,1);
        double *y=(double*)GetOutPortPtrs(block,2);
        double *x=(double*)GetState(block);
        double *xd=(double*)GetDerState(block);
        void ** work = GetPtrWorkPtrs(block);
        JSBSim::JSBSimComm * comm = NULL;
        int * ipar=block->ipar;
        char ** stringArray;
        int * intArray;
        getIpars(6,3,ipar,&stringArray,&intArray);
        char * root = stringArray[0];
        char * aircraftPath = stringArray[1];
        char * enginePath = stringArray[2];
        char * systemsPath = stringArray[3];
        char * modelName = stringArray[4];
        char * flightGearHost=stringArray[5];
        int debugLevel = intArray[0];
        int enableFlightGearComm = intArray[1];
        int flightGearPort = intArray[2];

        //handle flags
        if (flag==scicos::initialize)
        {
            //std::cout << "initializing" << std::endl;
            try
            {

                comm = new JSBSim::JSBSimComm(root,aircraftPath,enginePath,systemsPath,modelName,x,u,debugLevel,
                                              enableFlightGearComm,flightGearHost,flightGearPort);
            }
            catch (const std::runtime_error & e)
            {
                std::cout << "exception: " << e.what() << std::endl;
                Coserror((char *)e.what());
                return;
            }
            *work = (void *)comm;
        }
        else if (flag==scicos::terminate)
        {
            //std::cout << "terminating" << std::endl;
            comm = (JSBSim::JSBSimComm *)*work;
            if (comm)
            {
                delete comm;
                comm = NULL;
            }
        }
        else if (flag==scicos::updateState)
        {
            //std::cout << "updating state" << std::endl;
            comm = (JSBSim::JSBSimComm *)*work;
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
            comm = (JSBSim::JSBSimComm *)*work;
            comm->ss.x.getDeriv(xd);
        }
        else if (flag==scicos::computeOutput)
        {
            //std::cout << "computing output" << std::endl;
            comm = (JSBSim::JSBSimComm *)*work;
            sci_jsbsimComm(block,scicos::updateState);
            comm->ss.x.get(xOut);
            comm->ss.y.get(y);
        }
        else
        {
            //std::cout << "unhandled flag: " << flag << std::endl;
        }
    }

} // extern c

// vim:ts=4:sw=4
