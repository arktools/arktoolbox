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
#include <arkcomm/AsyncSerial.hpp>
#include <mavlink/v1.0/common/mavlink.h>

class MAVLinkHilSensor {

private:

    // private attributes
    
    mavlink_system_t _system;
    mavlink_status_t _status;
    boost::timer _clock;
    BufferedAsyncSerial * _comm;
    static const double _rad2deg = 180.0/3.14159;
    static const double _g0 = 9.81;

    // private methods
    
    // send a mavlink message to the comm port
    void _sendMessage(const mavlink_message_t & msg) {
        uint8_t buf[MAVLINK_MAX_PACKET_LEN];
        uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
        _comm->write((const char *)buf, len);
    }

public:
    MAVLinkHilSensor(const uint8_t sysid, const uint8_t compid, const MAV_TYPE type,
            const std::string & device, const uint32_t baudRate) : 
        _system(), _status(), _clock(), _comm() {
          
        // system
        _system.sysid = sysid;
        _system.compid = compid;
        _system.type = type;

        // start comm
        try
        {
            _comm = new BufferedAsyncSerial(device,baudRate);
        }
        catch(const boost::system::system_error & e)
        {
            std::cout << "error: " << e.what() << std::endl;
            exit(1);
        }
    }

    ~MAVLinkHilSensor() {
        if (_comm)
        {
            delete _comm;
            _comm = NULL;
        }
    }
    
    void sendImu(double *u) {
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
    }

    void sendGps(double *u) {
        // gps
        double cog = u[9];
        double sog = u[10];
        double lat = u[11]*rad2deg;
        double lon = u[12]*rad2deg;
        double alt = u[13];

        //double rawPress = 1;
        //double airspeed = 1;

        mavlink_msg_gps_raw_send(chan,timeStamp,1,lat,lon,alt,2,10,sog,cog);
    }

    void receive(double * y) {

        // receive messages
        mavlink_message_t msg;
        while(_comm->available())
        {
            uint8_t c = 0;
            if (!_comm->read((char*)&c,1)) return;

            // try to get new message
            if(mavlink_parse_char(MAVLINK_COMM_0,c,&msg,&_status))
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

                    default:
                    {
                        std::cout << "received message: " << uint32_t(msg.msgid) << std::endl;
                    }

                }
            }
        }
    }
};


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
        void ** work = GetPtrWorkPtrs(block);
        MAVLinkHilSensor * mavlink = NULL;

        static char * device;
        static int baudRate;
        static char ** stringArray;
        static int * intArray;
        static int count = 0;

        static uint16_t packet_drops = 0;

        //handle flags
        if (flag==scicos::initialize)
        {
            if (mavlink == NULL)
            {
                getIpars(1,1,ipar,&stringArray,&intArray);
                device = stringArray[0];
                baudRate = intArray[0];
                try
                {
                    mavlink = new MAVLinkHilSensor(0,0,MAV_TYPE_GENERIC,device,baudRate);
                }
                catch(const boost::system::system_error & e)
                {
                    Coserror((char *)e.what());
                }
            }
            *work = (void *)mavlink;
        }
        else if (flag==scicos::terminate)
        {
            mavlink = (MAVLinkHilSensor *)*work;
            if (mavlink)
            {
                delete mavlink;
                mavlink = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
            mavlink = (MAVLinkHilSensor *)*work;
            if (mavlink) 
            {
                mavlink->send(u);
                mavlink->receive(y);
            }
        } // compute output
    }
} // extern c

// vim:ts=4:sw=4:expandtab
