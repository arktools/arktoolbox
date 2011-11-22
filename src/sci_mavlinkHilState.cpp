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

                static float g0 = 9.81;

                double timeStamp = get_scicos_time();

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
                int16_t vz = u[11]*1e2;

                int16_t xacc = u[12]*1e3/g0;
                int16_t yacc = u[13]*1e3/g0;
                int16_t zacc = u[14]*1e3/g0;

                mavlink_msg_hil_state_send(chan,timeStamp,
                                           roll,pitch,yaw,
                                           rollRate,pitchRate,yawRate,
                                           lat,lon,alt,
                                           vx,vy,vz,
                                           xacc,yacc,zacc);

                // receive messages
                mavlink_message_t msg;
                mavlink_status_t status;

                while(comm_get_available(MAVLINK_COMM_0))
                {
                    uint8_t c = comm_receive_ch(MAVLINK_COMM_0);

                    // try to get new message
                    if(mavlink_parse_char(MAVLINK_COMM_0,c,&msg,&status))
                    {
                        switch(msg.msgid)
                        {

                        // this packet seems to me more constrictive so I
                        // recommend using rc channels scaled instead
                        case MAVLINK_MSG_ID_HIL_CONTROLS:
                        {
                            //std::cout << "receiving hil controls packet" << std::endl;
                            mavlink_hil_controls_t packet;
                            mavlink_msg_hil_controls_decode(&msg,&packet);
                            y[0] = packet.roll_ailerons;
                            y[1] = packet.pitch_elevator;
                            y[2] = packet.yaw_rudder;
                            y[3] = packet.throttle;
                            y[4] = packet.mode;
                            y[5] = packet.nav_mode;
                            y[6] = 0;
                            y[7] = 0;
                            break;
                        }

                        case MAVLINK_MSG_ID_RC_CHANNELS_SCALED:
                        {
                            //std::cout << "receiving rc channels scaled packet" << std::endl;
                            mavlink_rc_channels_scaled_t packet;
                            mavlink_msg_rc_channels_scaled_decode(&msg,&packet);
                            y[0] = packet.chan1_scaled/1.0e4;
                            y[1] = packet.chan2_scaled/1.0e4;
                            y[2] = packet.chan3_scaled/1.0e4;
                            y[3] = packet.chan4_scaled/1.0e4;
                            y[4] = packet.chan5_scaled/1.0e4;
                            y[5] = packet.chan6_scaled/1.0e4;
                            y[6] = packet.chan7_scaled/1.0e4;
                            y[7] = packet.chan8_scaled/1.0e4;
                            break;
                        } 

                        } // switch msgid

                    } // still parsing

                    // update packet drop counter
                    packet_drops += status.packet_rx_drop_count;

                } // packets available
            } // port exists
        } // compute output
    }
} // extern c

// vim:ts=4:sw=4:expandtab
