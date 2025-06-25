% Electromagnetism course - A.Y. 2024/2025
%
% Name: Alessandro 
% Surname: Crotti   
% Registration number: 2149762
%
% FDM based modal-solver for TE family modes
%
% 
% input section

close all
clear all

lambda = 0.5;   % wave length in vacuum [um]
nco    = 1.50;   % refractive index of the guiding slab
ncl    = 1.30;   % refractive index of the cladding
lx     = 10.0;   % transverse width [um]
np     = 200;    % samples number
a      = 0.25;   % half width of the guiding slab [um]

k0 = 2*pi/lambda; % wave number in vacuum
dx = lx/np;       % transverse mesh size
hx = 1/dx.^2;     % to be used in FD equivalent of the second spatial derivative
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
  A(i,i+1) = hx; % upper diagonal elements
  A(i+1,i) = hx; % lower diagonal elements
end

for i=1:np
  A(i,i) = (k0^2 * n02(i)) - 2*hx;%....complete here; % principal diagonal elements <========================================================================
end

% solving the eigenvalue problem

[V, D] = eig(A);

%  post-processing for eliminating spurious solutions

j = 0;
for i=np:-1:1
  beta2 = D(i,i);
  if real(beta2) > 0 %  ... complete here % eigenvalue must be real and positive for guided modes <========================================================================
    tneff = sqrt(beta2)./k0; % calculate the effective index
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
       ylabel('E_y');
       title(['TE family - ','neff = ',num2str(tneff),'  lambda=',num2str(lambda),'\mu m']);
       grid
      pause
    end
  end
end


