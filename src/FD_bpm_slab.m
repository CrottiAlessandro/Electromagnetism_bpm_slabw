% Electromagnetism course A.Y. 2024/2025
%
% Name: Alessandro 
% Surname: Crotti   
% Registration number: 2149762
%
% FD-Based BPM solving 2D Fresnel equation

close all
clear all
format long

ncl=1.3;        % cladding refractive index
nco=1.495;      % core refractive index
n0=ncl;         % reference refractive index
a=0.25;         % half-width of guiding slab [um]
lambda=1.5;     % wave lenght [um] in vacuum
k0=2*pi/lambda; % wave number in vacuum

niterations=5000; % total number of iterations
zmax=50;          % maximum logitudinal coordinate
deltaz=zmax/niterations;  % longitudinal step
n0alto=100;
j=sqrt(-1);       % imaginary unit

load field.dat; % pre-calculated TE0 mode of the symmetric slab waveguide
xmax=6.4;       % maximum x-coordinate value [um]
dx=2*xmax/256;  % 256 is the number of samples (for FD-BPM it is not mandatory to use a power of 2)
x=-xmax+dx/2:dx:xmax-dx/2; % vector containing sampled x-coordinate values
q=field(:,1);
npt=length(x);  % total number of samples along the transverse direction (256)
xmax=max(x);
deltax=x(2)-x(1); % transverse mesh size
plot(x,q)
q=q';
Q=[];

xk=(2*pi*n0)/lambda;   % wave number in the reference medium

% Elements of the tridiagonal system

A = zeros(1,npt);
A2= zeros(1,npt);
B = zeros(1,npt);
B2 = zeros(1,npt);
C = zeros(1,npt);
C2 = zeros(1,npt);
R = zeros(1,npt);

for i=1:npt
  A(i)=1/(2*xk)*j*0.5*deltaz/(dx.^2);
  A2(i)=-A(i);
  B(i)=1-1/(2*xk)*j.*deltaz/(dx.^2);
  B2(i)=1+1/(2*xk)*j.*deltaz/(dx.^2);
  C(i)=A(i);
  C2(i)=A2(i);
end
%

% Building the refractive index profile

for i=1:npt
  if (abs(x(i))<=a)&(abs(x(i))>=-a)
     guide(i)=nco;
  else
     guide(i)=ncl;
  end
end


% Building the term of the Fresnel equation with refractive index changes

guide=(guide.^2-n0^2)/(2*n0^2);
figure(1);
plot(x,guide./max(guide),x,q),xlabel('x micron')
pause
dist=[];
counter=0;

% Main Loop
for iteration=1:1:niterations
   qprev=q;
   
   
   
   for i=2:npt-1
     R(i)=q(i)*B2(i)+q(i-1)*A2(i)+q(i+1)*C2(i);
   end
   %Neuman Boundary Conditions 
   %B(npt) = 1;
   %C(npt) = 0;
   %B2(npt) = 1;
   %C2(npt) = 0;
   %R(npt) = 0;
   

   %B(1) = 1;
   %C(1) = 0;
   %B2(1) = 1;
   %C2(1) = 0;
   %R(1) = 0;


   % TBC implementation: right border
     arg=q(npt)/q(npt-1);
     kxd=log(arg)/(-j*dx);
     if real(kxd) > 0

        B(npt)=B(npt-1)+C(npt)*exp(-j*kxd*dx);
        R(npt)=q(npt)*B2(npt)+q(npt-1)*A2(npt)+C2(npt)*q(npt)*exp(-j*kxd*dx); 
     else
        R(npt)=q(npt)*B2(npt)+q(npt-1)*A2(npt); 
     end
     
  
     % TBC implementation: left border 
       arg=q(1)/q(2);
       kxd= log(arg)/(-j*dx); 
       if real(kxd)<0
         
         B(1) = B(2) + A(1) * exp(j*kxd*dx); 
         R(1) = q(1)*B2(1) + q(1)*A2(1)*exp(j*kxd*dx) + C2(1)*q(2);
       else
         R(1) = q(1)*B2(1) + q(2)*C2(1);
       end
        
    % propagator through the Crank-Nicholson technique
 
 q=thomas(A,B,C,R,qprev,npt);

 % thin lens law operator
  
  q = q .* exp(-j .* xk .* guide .* deltaz  );
   
%
   if rem(iteration,n0alto)==0 
      counter=counter+1;
	Q=[Q 
	abs(q).^2];
       z=iteration*deltaz;
      dist=[dist z];
      if counter>1
         figure(2),mesh(x,dist,Q),view([-60 70]),xlabel(' x micron'),ylabel('z micron'),zlabel('I')
         set(gca,'ylim',[0 zmax])
         set(gca,'zlim',[0 1])
                  figure(1),plot(x,abs(q).^2)
         set(gca,'ylim',[0 1])
         drawnow 
     end
   end 
   end
% End of the Main Loop

% Final plot

figure(3),contour(x,dist,Q),xlabel('x micron'),ylabel('z micron'),grid

