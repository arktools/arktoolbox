extern "C"
{

#include "definitions.hpp"
#include <scicos/scicos_block4.h>
#include <math.h>



    void sci_invPend(scicos_block *block, scicos::enumScicosFlags flag)
    {
        // constants
        double g=9.81;

        // parameters
        double *Par=(double*)GetRparPtrs(block);
        const double & M=Par[0];
        const double & m=Par[1];
        const double & l=Par[2];
        const double & ph=Par[3];

        // input
        const double & th= ((double*)GetInPortPtrs(block,1))[0];
        const double & thd= ((double*)GetInPortPtrs(block,2))[0];
        const double & u= ((double*)GetInPortPtrs(block,3))[0];

        // output
        double & zdd=((double*)GetOutPortPtrs(block,1))[0];
        double & thdd=((double*)GetOutPortPtrs(block,2))[0];

        // equations of motion
        double delta=M*m*l*l+m*m*l*l*pow(sin(th-ph),2);
        zdd=(m*l*l*(m*l*thd*thd*sin(th-ph)+u-(M+m)*g*sin(ph))-m*m*l*l*g*sin(th)*
             cos(th-ph))/delta;
        thdd=(-m*l*cos(th-ph)*(m*l*thd*thd*sin(th-ph)+u-(M+m)*g*sin(ph))+(M+m)*
              m*g*l*sin(th))/delta;
    }

}
