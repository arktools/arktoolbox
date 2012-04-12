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
#include <arkcomm/AsyncSerial.hpp>
#include <mavlink/v1.0/common/mavlink.h>

class MAVLinkHilState {

private:

    // private attributes
    
    mavlink_system_t _system;
    mavlink_status_t _status;
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
    MAVLinkHilState(const uint8_t sysid, const uint8_t compid, const MAV_TYPE type,
            const std::string & device, const uint32_t baudRate) : 
        _system(), _status(), _comm() {
          
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

    ~MAVLinkHilState() {
        if (_comm)
        {
            delete _comm;
            _comm = NULL;
        }
    }
    
    void send(double * u, uint64_t timeStamp) {

        // attitude states (rad)
        float roll = u[0];
        float pitch = u[1];
        float yaw = u[2];

        // body rates
        float rollRate = u[3];
        float pitchRate = u[4];
        float yawRate = u[5];

        // position
        int32_t lat = u[6]*_rad2deg*1e7;
        int32_t lon = u[7]*_rad2deg*1e7;
        int16_t alt = u[8]*1e3;

        int16_t vx = u[9]*1e2;
        int16_t vy = u[10]*1e2;
        int16_t vz = u[11]*1e2;

        int16_t xacc = u[12]*1e3/_g0;
        int16_t yacc = u[13]*1e3/_g0;
        int16_t zacc = u[14]*1e3/_g0;

        mavlink_message_t msg;
        mavlink_msg_hil_state_pack(_system.sysid, _system.compid, &msg, 
            timeStamp,
            roll,pitch,yaw,
            rollRate,pitchRate,yawRate,
            lat,lon,alt,
            vx,vy,vz,
            xacc,yacc,zacc);
        _sendMessage(msg);
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

    void sci_mavlinkHilState(scicos_block *block, scicos::enumScicosFlags flag)
    {

        // data
        double * u=GetRealInPortPtrs(block,1);
        double * y=GetRealOutPortPtrs(block,1);
        int * ipar=block->ipar;
        void ** work = GetPtrWorkPtrs(block);
        int & evtFlag = GetNevIn(block);

        // compute flags
        int evtFlagReceive = scicos::evtPortNumToFlag(0);
        int evtFlagSend = scicos::evtPortNumToFlag(1);

        MAVLinkHilState * mavlink = NULL;

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
                    mavlink = new MAVLinkHilState(0,0,MAV_TYPE_GENERIC,device,baudRate);
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
            mavlink = (MAVLinkHilState *)*work;
            if (mavlink)
            {
                delete mavlink;
                mavlink = NULL;
            }
        }
        else if (flag==scicos::computeOutput)
        {
            mavlink = (MAVLinkHilState *)*work;
            uint64_t t =  get_scicos_time()*1e6;
            if (mavlink) {
                if (evtFlag & evtFlagSend) { 
                    mavlink->send(u,t);
                }
                if (evtFlag & evtFlagReceive) {
                    mavlink->receive(y);
                }
            }
        } // compute output
    }
} // extern c

// vim:ts=4:sw=4:expandtab
