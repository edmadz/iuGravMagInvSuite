% Subroutine dirCosine compute the direction cosine filter using the
% following steps:
%   (1) Prepare the input data;
%       (1.1) If there are holes in the input data matrix (NaN/Dummies)
%       these holes are filled by interpolation;
%       (1.2) The hole indexes are stored to be applied on the output data.
%       (1.3) The input data borders are expanded followed by interpolation
%       in order to simulate periodicity
%   (2) Generate the frequency response of Dx, Dy, and Dz derivatives;
%   (3) Fourier transform the prepared input matrix;
%   (4) Multiple the Fourier transformed input matrix by filter related to
%       the corresponding derivative direction;
%   (5) Inverse Fourier transform product.
%
%INPUT PARAMETERS:
%
%   Zg -         Input field matrix.
%   type -       Type of direction cosine filter.
%                   #'p' for pass
%                   #'r' for reject
%   azimuth -    Direction in radians to pass or remove.
%   degree -     Filter degree (e.g. 1... 2).
%   expansion -  Percent grid expansion (e.g. 25%).
%
%OUTPUT PARAMETERS:
%
%   dirCos -     Input matrix Zg without or with features in the azimuth
%                direction.
%
%EXAMPLE:
% [X,Y,Z,Xg,Yg,Zg]=OpenFile('MAG.xyz')
% dirCos=dirCosine(Zg,'r',deg2rad(45),1,25)
% figure;pcolor(dirCos);colormap jet;shading interp;axis image
% title('Input data with 45 degrees features rejected')

function dirCos=dirCosine(Zg,type,azimuth,degree,expansion)

[nr,nc]=size(Zg);
nanmask=generateNaNmask(Zg);
exp = expansion/100;

if(nr>nc)
    b=round(nc*exp);
else
    b=round(nr*exp);
end

a=3;

[Zg_prepared] = padding2D(Zg,a,b,1,'y');

% Create the wavenumber space
[F1,F2] = freqspace(size(Zg_prepared),'meshgrid');
kx=((2*pi*(length(F2)/2)/(length(F2)-1))*F2); kx(kx==0)=0.0000000000000001;
ky=((2*pi*(length(F1)/2)/(length(F1)-1))*F1); ky(ky==0)=0.0000000000000001;
theta_ = atan(ky./kx);

if(type=='p')
    filter=abs((cos(azimuth-theta_+(pi/2))).^degree);
elseif(type=='r')
    filter=1-abs((cos(azimuth-theta_+(pi/2))).^degree);
end

ft=fftshift(fft2(Zg_prepared));

fzf=ifft2(ifftshift(filter.*ft));
dirCos=real(fzf(b+1:end-b,b+1:end-b));
dirCos=nanmask.*dirCos;