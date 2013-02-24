/*
 * block_mavlink.cpp
 * Copyright (C) James Goppert 2013 <jgoppert@users.sourceforge.net>
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
 * input
 *
 *  // attitude states (rad)
 *  [1] roll
 *  [2] pitch
 *  [3] yaw
 *
 *  // body rates
 *  [4] rollRate
 *  [5] pitchRate
 *  [6] yawRate
 *
 *  // position
 *  [7] lat
 *  [8] lon
 *  [9] alt
 *
 *  // velocity
 *  [10] vn
 *  [11] ve
 *  [12] vd
 *
 *  // acceleration
 *  [13] xacc
 *  [14] yacc
 *  [15] zacc
 *
 *
 * output
 *
 * (option 1, recommended)
 * // rc channels scaled
 *  [1] ch1
 *  [2] ch2
 *  [3] ch3
 *  [4] ch4
 *  [5] ch5
 *  [6] ch6
 *  [7] ch7
 *  [8] ch8
 *
 * (option 2, not recommended, more constrictive, not 
 * supported by ArduPilotOne)
 * // hil controls packet
 *  [1] roll
 *  [2] pitch
 *  [3] yaw
 *  [4] throttle
 *  [5] mode
 *  [6] nav_mode
 *  [7] 0
 *  [8] 0
 *
 */

#include "arktools/utilities.hpp"
#include "arktools/MAVLinkParser.hpp"

extern "C"
{

#include <scicos_block4.h>
#include <scicos.h>
#include <Scierror.h>
#include <math.h>

void block_mavlink(scicos_block *block, scicos_flag flag)
{

    // data
    double * u=GetRealInPortPtrs(block,1);
    double * y=GetRealOutPortPtrs(block,1);
    int * ipar=block->ipar;
    void ** work = &GetWorkPtrs(block);
    int & evtFlag = GetNevIn(block);

    // compute flags
    int evtFlagReceive = evtPortNumToFlag(1);
    int evtFlagSend = evtPortNumToFlag(2);

    MAVLinkParser * mavlink = NULL;

    static char * device;
    static int baudRate;
    static char ** stringArray;
    static int * intArray;
    static int count = 0;

    static uint16_t packet_drops = 0;

    //handle flags
    if (flag == Initialization)
    {
        if (mavlink == NULL)
        {
            getIpars(1,1,ipar,&stringArray,&intArray);
            device = stringArray[0];
            baudRate = intArray[0];
            try
            {
                mavlink = new MAVLinkParser(0,0,device,baudRate);
            }
            catch(const std::exception & e)
            {
                Scierror(999, "%s", e.what());
            }
        }
        *work = (void *)mavlink;
    }
    else if (flag == Ending)
    {
        mavlink = (MAVLinkParser *)*work;
        if (mavlink)
        {
            delete mavlink;
            mavlink = NULL;
        }
    }
    else if (flag == OutputUpdate)
    {
        mavlink = (MAVLinkParser *)*work;
        uint64_t t =  get_scicos_time()*1e6;
        if (mavlink) {
            //if (evtFlag & evtFlagSend) { 
            mavlink->send(u,t);
            //}
            //if (evtFlag & evtFlagReceive) {
            mavlink->receive(y);
            //}
        }
    } // compute output
}

} // extern c

// vim:ts=4:sw=4:expandtab
