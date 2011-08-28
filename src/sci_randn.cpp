extern "C" 
{

#include <scicos/scicos_block4.h>
#include <machine.h>
#include <math.h>
extern double C2F(urand)(int * p);
void sci_randn(scicos_block *block,int flag)
{
  double *y;
  double *z;
  int *ipar;
  int ny,my,i,iy;
  double sr,si,tl;
  double *u1;
  double *u2;

  my=GetOutPortRows(block,1);
  ny=GetOutPortCols(block,1);
  ipar=GetIparPtrs(block);
  y=GetRealOutPortPtrs(block,1);
  z=GetDstate(block);
  u1=(double *)GetInPortPtrs(block,1);
  u2=(double *)GetInPortPtrs(block,2);
  if (flag==2||flag==4)
  {if (ipar[0]==0)
       {iy=(int)z[0];
	for (i=0;i<my*ny;i++)
	     {*(z+i+1)=C2F(urand)(&iy);}
       }
   else 
	{iy=(int)z[0];
	 for (i=0;i<my*ny;i++)
	      {do
	         {sr=2.0*C2F(urand)(&iy)-1.0;
		  si=2.0*C2F(urand)(&iy)-1.0;
		  tl=sr*sr+si*si;
		 } while(tl>1.0);
	       z[i+1]= sr*(sqrt(-2.0*log(tl)/tl));}
	  }
    *(z)=iy;
    }

  if (flag==1||flag==6)
      {for (i=0;i<my*ny;i++) *(y+i)=*(u1+i)+*(u2+i)*(*(z+i+1));
      }
}

}
