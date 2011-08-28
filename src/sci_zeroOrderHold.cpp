/*
 * sci_zeroOrderHold.cpp
 * Copyright (C) James Goppert 2010 <jgoppert@users.sourceforge.net>
 *
 * This file free software: you can redistribute it and/or modify it
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

extern "C"

{

#include <scicos/scicos_block4.h>
#include "definitions.hpp"
#include <stdio.h>
#include <string.h>

void sci_zeroOrderHold(scicos_block *block,scicos::enumScicosFlags flag)
{
    // get block data pointers, etc
    double *_z=GetDstate(block);
    double *_u1=GetRealInPortPtrs(block,1);
    double *_u2=GetRealInPortPtrs(block,2);
    double *_y1=GetRealOutPortPtrs(block,1);
    int *_ipar=GetIparPtrs(block);
    int & evtFlag = GetNevIn(block);
    int & evtPortTime = _ipar[0];
    int & evtPortReset = _ipar[1];

    // compute flags
    int evtFlagTime = scicos::evtPortNumToFlag(evtPortTime);
    int evtFlagReset = scicos::evtPortNumToFlag(evtPortReset);
  
    // loop over all rows of data
    int i,j;
    int nRows = GetInPortRows(block,1);
    int nCols = GetInPortCols(block,1);
    size_t nBytes = sizeof(double)*nRows*nCols;
    for(i=0;i<nRows;i++){

        for(j=0;j<nCols;j++){
        
            if (flag ==scicos::computeOutput || flag ==scicos::reinitialize || flag ==scicos::initialize)
                memcpy(_y1,_z,nBytes);

            else if (flag == scicos::updateState)
            {
                // bitwise comparison for flag
                if(evtFlag & evtFlagReset && _u2)
                {
                    memcpy(_z,_u2,nBytes);
                }
                else if(evtFlag & evtFlagTime && _u1)
                {
                    memcpy(_z,_u1,nBytes);
                }
                else
                {
                    printf("\nunhandled event flat %d\n",evtFlag);
                    printf("\nknown flags:\n");
                    printf("\ttime flag: %d\n",evtFlagTime);
                    printf("\ttime flag & event flag: %d\n",evtFlagTime & evtFlag);
                    printf("\treset flag: %d\n",evtFlagReset);
                    printf("\treset flag & event flag: %d\n",evtFlagReset & evtFlag);
                }
            }
            else if (flag == scicos::terminate)
            {
            }
            else
            {
                char msg[50];
                sprintf(msg,"unhandled block flag %d\n",flag);
                Coserror(msg);
            }
        }
    }
}

}

// vim:ts=4:sw=4:expandtab
