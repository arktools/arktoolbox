/*
 * sci_mavlinkHilState.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_mavlinkHilState.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_mavlinkHilState.cpp is distributed in the hope that it will be useful, but
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
 *  [1] roll
 *  [2] pitch
 *  [3] yaw
 *  [4] throttle
 *  [5] mode
 *  [6] nav_mode
 *
 */

#include "utilities.hpp"
#include "arkcomm/AsyncSerial.hpp"
#include <iostream>
#include <stdexcept>

// mavlink system definition and headers
#include "mavlink/mavlink_types.h"
#include "arkcomm/asio_mavlink_bridge.h"
#include "mavlink/common/mavlink.h"

extern "C"
{
#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

    static const double rad2deg = 180.0/3.14159;

    void sci_mavlinkHilState(scicos_block *block, scicos::enumScicosFlags flag)
    {

        // data
        double * u=GetRealInPortPtrs(block,1);
        double * y=GetRealOutPortPtrs(block,1);
        int * ipar=block->ipar;

        static char * device;
        static int baudRate;
        static char ** stringArray;
        static int * intArray;
        static int count = 0;

        static uint16_t packet_drops = 0;

        //handle flags
        if (flag==scicos::initialize)
        {
            if (mavlink_comm_0_port == NULL)
            {
                getIpars(1,1,ipar,&stringArray,&intArray);
                device = stringArray[0];
                baudRate = intArray[0];
                try
                {
                    mavlink_comm_0_port = new BufferedAsyncSerial(device,baudRate);
                }
                catch(const boost::system::system_error & e)
                {
                    Coserror((char *)e.what());
                }
            }
        }
        else if (flag==scicos::terminate)
        {
            if (mavlink_comm_0_port)
            {
                delete mavlink_comm_0_port;
                mavlink_comm_0_port = NULL;
            }
        }
        else if (flag==scicos::updateState)
        {
        }
        else if (flag==scicos::computeDeriv)
        {
        }
        else if (flag==scicos::computeOutput)
        {
            if (mavlink_comm_0_port) 
            {
                // channel
                mavlink_channel_t chan = MAVLINK_COMM_0;

                // loop rates
                // TODO: clean this up to use scicos events w/ timers
                static int hilRate = 50;

                static float g0 = 9.81;

                // initial times
                double scicosTime = get_scicos_time();
                static double hilTimeStamp = scicosTime;

                // send attitude message
                if (scicosTime - hilTimeStamp > 1.0/hilRate)
                {
                    std::cout << "sending hil" << std::endl;
                    hilTimeStamp = scicosTime;

                    // attitude states (rad)
                    float roll = u[0];
                    float pitch = u[1];
                    float yaw = u[2];

                    // body rates
                    float rollRate = u[3];
                    float pitchRate = u[4];
                    float yawRate = u[5];

                    // position
                    int32_t lat = u[6]*rad2deg*1e7;
                    int32_t lon = u[7]*rad2deg*1e7;
                    int16_t alt = u[8]*1e3;

                    int16_t vx = u[9]*1e2;
                    int16_t vy = u[10]*1e2;
                    int16_t vz = -u[11]*1e2;

                    int16_t xacc = u[12]*1e3/g0;
                    int16_t yacc = u[13]*1e3/g0;
                    int16_t zacc = u[14]*1e3/g0;

                    mavlink_msg_hil_state_send(chan,hilTimeStamp,
                                               roll,pitch,yaw,
                                               rollRate,pitchRate,yawRate,
                                               lat,lon,alt,
                                               vx,vy,vz,
                                               xacc,yacc,zacc);
                }
                else if (scicosTime  - hilTimeStamp < 0)
                    hilTimeStamp = scicosTime;
            }

            // receive messages
            mavlink_message_t msg;
            mavlink_status_t status;

            while(comm_get_available(MAVLINK_COMM_0))
            {
                uint8_t c = comm_receive_ch(MAVLINK_COMM_0);

                // try to get new message
                if(mavlink_parse_char(MAVLINK_COMM_0,c,&msg,&status))
                {
                    std::cout << "receiving hil" << std::endl;
                    switch(msg.msgid)
                    {

                    case MAVLINK_MSG_ID_HIL_CONTROLS:
                    {
                        //std::cout << "receiving messages" << std::endl;
                        mavlink_hil_controls_t hil_controls;
                        mavlink_msg_hil_controls_decode(&msg,&hil_controls);
                        y[0] = hil_controls.roll_ailerons;
                        y[1] = hil_controls.pitch_elevator;
                        y[2] = hil_controls.yaw_rudder;
                        y[3] = hil_controls.throttle;
                        y[4] = hil_controls.mode;
                        y[5] = hil_controls.nav_mode;
                        break;
                    }

                    }
                }

                // update packet drop counter
                packet_drops += status.packet_rx_drop_count;
            }
        }
    }
} // extern c

// vim:ts=4:sw=4:expandtab
