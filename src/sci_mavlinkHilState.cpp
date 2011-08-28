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
 */

#include "utilities.hpp"
#include "communication/AsyncSerial.hpp"
#include <iostream>
#include <stdexcept>

// mavlink system definition and headers
#include "mavlink_types.h"
#include "communication/asio_mavlink_bridge.h"
#include "common/mavlink.h"

BufferedAsyncSerial * mavlink_comm_0_port = NULL;

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
        if (flag==scicos::initialize || flag==scicos::reinitialize)
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
            // channel
            mavlink_channel_t chan = MAVLINK_COMM_0;

			// loop rates
			// TODO: clean this up to use scicos events w/ timers
            static int attitudeRate = 50;
            static int positionRate = 10;
            static int airspeedRate = 1;

			// initial times
            double scicosTime = get_scicos_time();
            static double attitudeTimeStamp = scicosTime;
            static double positionTimeStamp = scicosTime;
            static double  airspeedTimeStamp = scicosTime;

			// send airspeed message
            if (scicosTime - airspeedTimeStamp > 1.0/airspeedRate)
            {
                airspeedTimeStamp = scicosTime;

				// airspeed (true velocity m/s)
            	float Vt = u[0];
                //double rawPress = 1;
                //double airspeed = 1;

                //mavlink_msg_raw_pressure_send(chan,timeStamp,airspeed,rawPress,0);
            }
            else if (scicosTime  - airspeedTimeStamp < 0)
                airspeedTimeStamp = scicosTime;

            // send attitude message
            if (scicosTime - attitudeTimeStamp > 1.0/attitudeRate)
            {
                attitudeTimeStamp = scicosTime;

				// attitude states (rad)
				float roll = u[1];
				float pitch = u[2];
				float yaw = u[3];

				// body rates
				float rollRate = u[4];
				float pitchRate = u[5];
				float yawRate = u[6];

                mavlink_msg_attitude_send(chan,attitudeTimeStamp,roll,pitch,yaw,
						rollRate,pitchRate,yawRate);
            }
            else if (scicosTime  - attitudeTimeStamp < 0)
                attitudeTimeStamp = scicosTime;

 		            // send gps mesage
            if (scicosTime - positionTimeStamp > 1.0/positionRate)
            {
                positionTimeStamp = scicosTime;

                // gps
                double cog = u[7];
                double sog = u[8];
                double lat = u[9]*rad2deg;
                double lon = u[10]*rad2deg;
                double alt = u[11];

                //double rawPress = 1;
                //double airspeed = 1;

                mavlink_msg_gps_raw_send(chan,positionTimeStamp,1,lat,lon,alt,2,10,sog,cog);
                //mavlink_msg_raw_pressure_send(chan,timeStamp,airspeed,rawPress,0);
            }
            else if (scicosTime  - positionTimeStamp < 0)
                positionTimeStamp = scicosTime;

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
                    case MAVLINK_MSG_ID_RC_CHANNELS_SCALED:
                    {
						//std::cout << "receiving messages" << std::endl;
        				mavlink_rc_channels_scaled_t rc_channels;
                        mavlink_msg_rc_channels_scaled_decode(&msg,&rc_channels);
                        y[0] = rc_channels.chan1_scaled/10000.0f;
                        y[1] = rc_channels.chan2_scaled/10000.0f;
                        y[2] = rc_channels.chan3_scaled/10000.0f;
                        y[3] = rc_channels.chan4_scaled/10000.0f;
                        y[4] = rc_channels.chan5_scaled/10000.0f;
                        y[5] = rc_channels.chan6_scaled/10000.0f;
                        y[6] = rc_channels.chan7_scaled/10000.0f;
                        y[7] = rc_channels.chan8_scaled/10000.0f;
                        break;
                    }
                }

                // update packet drop counter
                packet_drops += status.packet_rx_drop_count;
            }
        }
   	 }
  }

} // extern c

// vim:ts=4:sw=4
