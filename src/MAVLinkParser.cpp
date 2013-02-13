/*
 * MAVLinkParser.cpp
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
 */

#include "MAVLinkParser.hpp"

void MAVLinkParser::_sendMessage(const mavlink_message_t & msg) {
    uint8_t buf[MAVLINK_MAX_PACKET_LEN];
    uint16_t len = mavlink_msg_to_send_buffer(buf, &msg);
    _comm->write((const char *)buf, len);
}

MAVLinkParser::MAVLinkParser(const uint8_t sysid, const uint8_t compid, const MAV_TYPE type,
        const std::string & device, const uint32_t baudRate) : 
    _system(), _status(), _comm() {
      
    // system
    _system.sysid = sysid;
    _system.compid = compid;
    _system.type = type;

    // start comm
    // throws boost::system::system_error
    _comm = new BufferedAsyncSerial(device,baudRate);
}

MAVLinkParser::~MAVLinkParser() {
    if (_comm)
    {
        delete _comm;
        _comm = NULL;
    }
}

void MAVLinkParser::send(double * u, uint64_t timeStamp) {
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

void MAVLinkParser::receive(double * y) {
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
                    //std::cout << "received message: " << uint32_t(msg.msgid) << std::endl;
                }

            }
        }
    }
}

// vim:ts=4:sw=4:expandtab
