% Electromagnetism course - A.Y. 2024/2025
%
% Name: Alessandro 
% Surname: Crotti   
% Registration number: 2149762
%
% FDM based modal-solver for TM family modes
%
% 
% input section


close all
clear all

lambda = 1;   % wave length in vacuum [um]
nco    = 1.50;   % refractive index of the guiding slab
ncl    = 1.30;   % refractive index of the cladding
lx     = 10.0;   % transverse width [um]
np     = 200;    % samples number
a      = 0.25;   % half width of the guiding slab [um]

% inizializzazione variabili

n02 = zeros(1,np);
A   = zeros(np,np);
x   = zeros(1,np);

k0 = 2*pi/lambda; % wave number in vacuum
dx = lx/np;       % transverse mesh size
hx = 1/dx.^2;     % to be used in the FD equivalent of the spatial second derivative

% building the refractive index profile

for i=1:np
  x(i) = -lx./2 + dx./2 + i.*dx;
  if abs(x(i)) <= a
    n02(i) = nco.^2;
  else
    n02(i) = ncl.^2;
  end
end

% building A matrix

for i=1:np-1
  ikr = i+1;
  kr  = n02(ikr)/(n02(ikr-1)+n02(ikr));
  ikl = i;
  kl = n02(ikl)/(n02(ikl)+n02(ikl+1));
%
  A(i,i+1) = 2.*kr.*hx; % upper diagonal elements
  A(i+1,i) = 2.*kl.*hx; % lower diagonal elements
end

for i=1:np
    
  ir = i;
  if i>=np
    ir=np-1;
  end
  rr = (n02(ir+1)-n02(ir))/(n02(ir+1)+n02(ir));
  %
  il = i;
  if i<=1
    il=2;
  end
  rl = (n02(il-1)-n02(il))/(n02(il-1)+n02(il));
%    
  A(i,i) = -(2.-rr-rl).*hx + (k0^2 * n02(i)) ;% ....complete here; % principal diagonal elements <========================================================================
end

% solving the eigenvalue problem

[V, D] = eig(A);

% post-processing for eliminating spurious solutions


figure(1)
j = 0;
for i=np:-1:1
  beta2 = D(i,i);
  if real(beta2) > 0 %...complete here % eigenvalue must be real and positive for guided modes <========================================================================
    tneff = sqrt(beta2)./k0;  % calculate the effective index
    % if effective index is in between the refractive index of
    % the core and the cladding then is a guided mode
    if ncl <= tneff & tneff <= nco%if .... complete here <========================================================================
       i
       tneff
       j = j + 1;
       neff(j) = tneff;
       norm = max(abs(V(:,i)));
       scale=1.;
       if abs(min(V(:,i))) > abs(max(V(:,i)))
	      scale=-1.;
       end
       plot(x,scale.*V(:,i)./norm,x,sqrt(n02)./nco);
       axis([-lx/2 lx/2 -1 1])
       xlabel('micron');
       ylabel('E_x');
       title(['TM family - ','neff = ',num2str(tneff),'  lambda=',num2str(lambda),'\mu m']);
       grid
      pause
    end
  end
end
