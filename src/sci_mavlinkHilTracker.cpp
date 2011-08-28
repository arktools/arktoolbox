/*
 * sci_mavlinkHilTracker.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_mavlinkHilTracker.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_mavlinkHilTracker.cpp is distributed in the hope that it will be useful, but
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
	
BufferedAsyncSerial * mavlink_comm_2_port = NULL;

extern "C"
{
#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

    static const double rad2deg = 180.0/3.14159;

    void sci_mavlinkHilTracker(scicos_block *block, scicos::enumScicosFlags flag)
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
            if (mavlink_comm_2_port == NULL)
            {
                getIpars(1,1,ipar,&stringArray,&intArray);
                device = stringArray[0];
                baudRate = intArray[0];
                try
                {
                    mavlink_comm_2_port = new BufferedAsyncSerial(device,baudRate);
                }
                catch(const boost::system::system_error & e)
                {
                    Coserror((char *)e.what());
                }
            }
        }
        else if (flag==scicos::terminate)
        {
            if (mavlink_comm_2_port)
            {
                delete mavlink_comm_2_port;
                mavlink_comm_2_port = NULL;
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
            mavlink_channel_t chan = MAVLINK_COMM_2;

			// loop rates
			// TODO: clean this up to use scicos events w/ timers
            static int positionRate = 10;

			// initial times
            double scicosTime = get_scicos_time();
            static double positionTimeStamp = scicosTime;
 		    
			// send global position
            if (scicosTime - positionTimeStamp > 1.0/positionRate)
            {
                positionTimeStamp = scicosTime;

                // gps
                double lat = u[0]*rad2deg;
                double lon = u[1]*rad2deg;
                double alt = u[2];
                double vN = u[3];
                double vE = u[4];
                double vD = u[5];

                mavlink_msg_global_position_send(chan,positionTimeStamp,lat,lon,alt,vN,vE,vD);
				//std::cout << "sending global position" << std::endl;
            }
            else if (scicosTime  - positionTimeStamp < 0)
                positionTimeStamp = scicosTime;

            // receive messages
            mavlink_message_t msg;
            mavlink_status_t status;

            while(comm_get_available(MAVLINK_COMM_2))
            {
				//std::cout << "serial available" << std::endl;
                uint8_t c = comm_receive_ch(MAVLINK_COMM_2);

                // try to get new message
                if(mavlink_parse_char(MAVLINK_COMM_2,c,&msg,&status))
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
