/*
 * MAVLinkParser.hpp
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

#ifndef _ARKTOOLBOX_MAVLINKPARSER_HPP
#define _ARKTOOLBOX_MAVLINKPARSER_HPP

#include "AsyncSerial.hpp"
#include <iostream>
#include <stdexcept>

// mavlink system definition and headers
#include <mavlink/v1.0/common/mavlink.h>

class MAVLinkParser {

private:

    // private attributes
    
    mavlink_system_t _system;
    mavlink_status_t _status;
    BufferedAsyncSerial * _comm;
    static const double _rad2deg = 180.0/3.14159;
    static const double _g0 = 9.81;

    // private methods
    
    // send a mavlink message to the comm port
    void _sendMessage(const mavlink_message_t & msg);

public:
    MAVLinkParser(const uint8_t sysid, const uint8_t compid, const MAV_TYPE type,
            const std::string & device, const uint32_t baudRate);
    ~MAVLinkParser();
    void send(double * u, uint64_t timeStamp);
    void receive(double * y);
};

#endif // _ARKTOOLBOX_MAVLINKPARSER_HPP

// vim:ts=4:sw=4:expandtab
