/*
 * sci_mavlinkHilSensor.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * sci_mavlinkHilSensor.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sci_mavlinkHilSensor.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "utilities.hpp"
#include <iostream>
#include <stdexcept>
#include "mavlink_types.h"
#include "communication/asio_mavlink_bridge.h"
#include "common/mavlink.h"

BufferedAsyncSerial * mavlink_comm_1_port;

extern "C"
{
#include <scicos/scicos_block4.h>
#include <math.h>
#include "definitions.hpp"

    static const double rad2deg = 180.0/3.14159;

    void sci_mavlinkHilSensor(scicos_block *block, scicos::enumScicosFlags flag)
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
            if (mavlink_comm_1_port == NULL)
            {
                getIpars(1,1,ipar,&stringArray,&intArray);
                device = stringArray[0];
                baudRate = intArray[0];
                try
                {
                    mavlink_comm_1_port = new BufferedAsyncSerial(device,baudRate);
                }
                catch(const boost::system::system_error & e)
                {
                    Coserror((char *)e.what());
                }
            }
        }
        else if (flag==scicos::terminate)
        {
            if (mavlink_comm_1_port)
            {
                delete mavlink_comm_1_port;
                mavlink_comm_1_port = NULL;
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
            mavlink_channel_t chan = MAVLINK_COMM_1;

			// loop rates
			// TODO: cleanup to use scicos timers
            static int imuRate = 50;
            static int gpsRate = 1;

            //std::cout << "a:\t" << ax << "\t" << ay << "\t" << az << std::endl;
            //std::cout << "g:\t" << gx << "\t" << gy << "\t" << gz << std::endl;
            //std::cout << "m:\t" << mx << "\t" << my << "\t" << mz << std::endl;

            double scicosTime = get_scicos_time();
            static double imuTimeStamp = scicosTime;
            static double gpsTimeStamp = scicosTime;
            uint64_t timeStamp = scicosTime*1e6;

            //std::cout << "dt imu: " << scicosTime - imuTimeStamp << std::endl;
            //std::cout << "imu period: " << 1.0/imuRate << std::endl;
            //std::cout << "dt gps: " << scicosTime - gpsTimeStamp << std::endl;
            //std::cout << "gps period: " << 1.0/imuRate << std::endl;

            // send imu message
            if (scicosTime - imuTimeStamp > 1.0/imuRate)
            {
				// accelerometer in milli g's
				int16_t ax = u[0]*1000/9.81;
				int16_t ay = u[1]*1000/9.81;
				int16_t az = u[2]*1000/9.81;

				// gyros
				int16_t gx = u[3]*1000;
				int16_t gy = u[4]*1000;
				int16_t gz = u[5]*1000;

				// magnetometer
				int16_t mx = u[6]*1000;
				int16_t my = u[7]*1000;
				int16_t mz = u[8]*1000;

                mavlink_msg_raw_imu_send(chan,timeStamp,ax,ay,az,gx,gy,gz,mx,my,mz);
                imuTimeStamp = scicosTime;
            }
            else if (scicosTime  - imuTimeStamp < 0)
                imuTimeStamp = scicosTime;

            // send gps mesage
            if (scicosTime - gpsTimeStamp > 1.0/gpsRate)
            {
                // gps
                double cog = u[9];
                double sog = u[10];
                double lat = u[11]*rad2deg;
                double lon = u[12]*rad2deg;
                double alt = u[13];

                //double rawPress = 1;
                //double airspeed = 1;

                mavlink_msg_gps_raw_send(chan,timeStamp,1,lat,lon,alt,2,10,sog,cog);
                //mavlink_msg_raw_pressure_send(chan,timeStamp,airspeed,rawPress,0);
                gpsTimeStamp = scicosTime;
            }
            else if (scicosTime  - gpsTimeStamp < 0)
                gpsTimeStamp = scicosTime;

            // receive messages
            mavlink_message_t msg;
            mavlink_status_t status;

            while(comm_get_available(MAVLINK_COMM_1))
            {
                uint8_t c = comm_receive_ch(MAVLINK_COMM_1);

                // try to get new message
                if(mavlink_parse_char(MAVLINK_COMM_1,c,&msg,&status))
                {
                    switch(msg.msgid)
                    {
                    case MAVLINK_MSG_ID_RC_CHANNELS_SCALED:
                    {
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
					case MAVLINK_MSG_ID_GLOBAL_POSITION:
					{
						mavlink_global_position_t global_position;
						mavlink_msg_global_position_decode(&msg,&global_position);
                        y[8] = global_position.lat;
                        y[9] = global_position.lon;
                        y[10] = global_position.alt;
                        y[11] = global_position.vx;
                        y[12] = global_position.vy;
                        y[13] = global_position.vz;
                        break;
                    }
					case MAVLINK_MSG_ID_ATTITUDE:
					{
						mavlink_attitude_t attitude;
						mavlink_msg_attitude_decode(&msg,&attitude);
                        y[14] = attitude.roll;
                        y[15] = attitude.pitch;
                        y[16] = attitude.yaw;
                        y[17] = attitude.rollspeed;
                        y[18] = attitude.pitchspeed;
                        y[19] = attitude.yawspeed;
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
