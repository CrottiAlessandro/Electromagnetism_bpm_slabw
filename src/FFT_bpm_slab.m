% Electromagnetism course A.Y. 2024/2025
%
% Name: Alessandro 
% Surname: Crotti   
% Registration number: 2149762
%
%
% FFT-Based BPM solving 2D Fresnel equation

close all
clear all
format long

ncl=1.3;      % cladding refractive index
nco=1.495;    % core refractive index
n0=ncl;       % reference refractive index
a=0.25;       % half-width of guiding slab [um]
lam=1.5;      % wave lenght [um] in vacuum
k0=2*pi/lam;  % wave number in vacuum
niterations=5000;
zmax=50;      % maximum z-distance value [um]
deltaz=zmax/niterations; % longitudinal step
njump=250;  % 
j=sqrt(-1); % imaginary unit
load field.dat; % pre-calculated TE0 mode of the symmetric slab waveguide
xmax=6.4;       % maximum x-coordinate value [um]
dx=2*xmax/256;  % 256 is the number of samples along the transverse direction and must be a power of 2 for the FFT algorithm
x=-xmax+dx/2:dx:xmax-dx/2; % due to the even number of transverse samples, the waveguide may be not perfectly centered, here is centered
q=field(:,1);
npt=length(x); % the totalnumber of transverse samples (256)
xmax=max(x);
deltax=x(2)-x(1); % same as dx
plot(x,q)
q=q';
Q=[];

xk=(2*pi*n0)/lam;  % wave number in the reference medium

% building the spatial frequencies
indfreq=-npt/2:1:npt/2-1; % also here due to the even number of trasverse samples (256), the spatial frequency indexes vector has an offset
kx=(pi./xmax).*indfreq;   % vector containing discrete spatial frequencies values

% propagator in the Fourier domain
prop=-(1/(2*xk)).*(kx.^2);

% Building the refractive index profile
for i=1:npt
  if (abs(x(i))<=a)&(abs(x(i))>=-a)
     guide(i)=nco;
  else
     guide(i)=ncl;
  end
end

% Building the term of the Fresnel equation with refractive index changes
guide = (guide.^2 - n0^2) / (2 * n0^2);% complete here; <========================================================================
figure(1);
plot(x,guide./max(guide),x,q),xlabel('x micron')
pause
dist=[];
counter=0;

% Main Loop
for iteration=1:1:niterations
%
% passing in the Fourier domain, executing the Propagator and returning
% in the spatial domain
   qs=fftshift(fft(q));
   fact=-j.*prop.*deltaz;
   qs=exp(fact).*qs;
   q=ifft(fftshift(qs));
% thin lens law operator
   q = q .* exp(-j * xk * deltaz * guide);%q = q .* exp(-j * k0 * deltaz * guide); % complete here;     <========================================================================

% saving field intensities profile
   if rem(iteration,njump)==0 
      counter=counter+1;
	Q=[Q 
	abs(q).^2];
       z=iteration*deltaz;
       dist=[dist z];
      if counter>1
         figure(2),mesh(x,dist,Q),view([-60 70]),xlabel(' x micron'),ylabel('z micron'),zlabel('I')
         set(gca,'ylim',[0 zmax])
         set(gca,'zlim',[0 1])
         drawnow 
      end
   end 
end
% End of the Main Loop

% Final plot

figure(3),contour(x,dist,Q),xlabel('x micron'),ylabel('z micron'),grid

