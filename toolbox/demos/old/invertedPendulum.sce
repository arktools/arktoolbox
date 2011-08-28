function data=invertedPendulum()
  disp('Inverted Pendulum Controller')
  disp('Parameters')
  data.M=10
  data.m=3
  data.l=3
  data.ph=1
  disp(data)

  disp('Loading Model')
  load('invertedPendulum.cos')
  scs_m=scs_m.objs(1).model.rpar;

  disp('Trimming Model')
  
  // parameters
  derivTol=1e-3; // derivative normal tolerance
  
  //initial values
  X0=[0;0;0;0]
  U0=[12]
  Y0=[0;0]
  
  // indices not fixed
  Indx=[]
  Indu=[1]
  Indy=[1,2]
  
  // indices of derivatives that need not be zero
  Indxp=[]
  
  // load context
  %scicos_context=data
  
  // trim
  [X,U,Y,XP]=steadycos(scs_m,X0,U0,Y0,Indx,Indu,Indy,Indxp);
  if (norm(XP) > derivTol)
    disp('Trim Failed!')
    disp('Derivative Tolerance Exceeded.')
    printf('%f > %f',norm(XP),derivTol)
  end

  disp('Linearizing Model')
  sys=lincos(scs_m,X,U)

  disp('Designing Controller')
  Kc=-ppol(sys.A,sys.B,[-1,-1,-1,-1]);
  Kf=-ppol(sys.A',sys.C',[-2,-2,-2,-2]);Kf=Kf'
  Contr=obscont(sys,Kc,Kf)

  // send controller to scicos
  data.U=U
  data.Contr=Contr
  disp('Done')
  return data
endfunction

%scicos_context=invertedPendulum();
