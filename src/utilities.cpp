/*
 * utilities.cpp
 * Copyright (C) James Goppert 2010 <james.goppert@gmail.com>
 *
 * utilities.cpp is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * utilities.cpp is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "utilities.hpp"
#include <cstdlib>
#include <cstdio>
#include <cstring>

void getIpars(int nStrings, int nInts, int * ipar, char *** stringArray, int ** intArray)
{
    // allocate memory
    int iInt = 0, iString=0, iStringChar=0;
    *stringArray = (char**)calloc(nStrings+1,sizeof(char*));
    *intArray = (int*)calloc(nInts,sizeof(int));

    // get strings
    while (1)
    {
        // if start of a new string
        if (iStringChar==0)
        {
            int n = ipar[iInt];
            //printf("\nnew string of length : %d\n", n);
            (*stringArray)[iString] = (char *)calloc(n+1, sizeof(char));
            iInt++;
        }

        // read character
        char c = ipar[iInt];
        //printf("iString: %d, iInt: %d, Char: %c\n", iString, iInt, c);

        (*stringArray)[iString][iStringChar] = c;
        //printf("stringArray: %c\n", (*stringArray)[iString][iStringChar]);

        iStringChar++;
        iInt++;

        // check for string completion
        if (c==0)
        {
            iStringChar = 0;
            iString++;
            if (iString >= nStrings) break; // finished
        }
    }
    for (int i=0; i<nInts; i++)
    {
        (*intArray)[i] = ipar[iInt];
        iInt = iInt + 1;
    }
}

int evtPortNumToFlag(int portNum)
{
    if (portNum > 0) return 1 << (portNum-1); //  return the bit flag equivalent
    else return -9; // if port is not there return a value that won't match
}

extern "C"
{
    void cMatrix2FortranVector(double ** cMatrix, const int & rows, const int & cols, double * fVector)
    {
        for (int i=0; i<rows; i++) for (int j=0; j<cols; j++) fVector[i+rows*j] = cMatrix[i][j];
    }

    void allocateCMatrix(double ** cMatrix, const int & rows, const int & cols)
    {
        cMatrix = (double **)malloc(rows*sizeof(double*));
        if(cMatrix == NULL)
        {
            fprintf(stderr, "out of memory\n");
            return;
        }

        for(int i = 0; i < rows; i++)
        {
            cMatrix[i] = (double *)malloc(cols*sizeof(double));
            if(cMatrix[i] == NULL)
            {
                fprintf(stderr, "out of memory\n");
                return;
            }
        }
        memset((void*)cMatrix,0,rows*cols*sizeof(double));
    }

    void freeCMatrix(double ** matrix, const int & nRows, const int & nCols)
    {
        if (!matrix) return;
        for(int i = 0; i < nRows; i++) free(matrix[i]);
        free(matrix);
    }

}

// vim:ts=4:sw=4
