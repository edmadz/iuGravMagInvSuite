% Subroutine H_ performs the two-dimensional hilbert transform using the
% following steps:
%   (1) Prepare the input data;
%       (1.1) If there are holes in the input data matrix (NaN/Dummies)
%       these holes are filled by interpolation;
%       (1.2) The hole indexes are stored to be applied on the output data.
%       (1.3) The input data borders are expanded followed by interpolation
%       in order to simulate periodicity
%   (2) Generate the frequency response of Hx and Hy components (maskx and
%       masky);
%   (3) Fourier transform the prepared input matrix;
%   (4) Multiple the Fourier transformed input matrix by maskx;
%   (5) Multiple the Fourier transformed input matrix by masky;
%   (6) Inverse Fourier transform products obtained by two previous steps.
%
%INPUT PARAMETERS:
%
%   Xg -         Input horizontal coordinate matrix.
%   Yg -         Input vertical coordinate matrix.
%   Zg -         Input matrix.
%   expansion -  Percent grid expansion (e.g. 25%).
%   fillMethod - Interpolation method used for fill the gaps and prepare
%                the input matrix. Use 1 (best results), but integer values
%                ranging from 1 to 5 can be used.
%   tappering -  if 'on' a tappering tukey window is applied to prepared
%                data in order to tend the edge values to zero. The window
%                transition zone only affects the interpolated border and
%                the frequency content of input data preserves unaltered.
%
%OUTPUT PARAMETERS:
%
%   Hx -         Horizontal hilbert component.
%   Hy -         Vertical hilbert component.
%
%EXAMPLE:
% [X,Y,Z,Xg,Yg,Zg]=OpenFile('MAG.xyz')
% [Hx,Hy]=H_(Zg,25,1,'on')
% figure;pcolor(Hx);colormap jet;shading interp;axis image;title('Horizontal Hilbert Component')
% figure;pcolor(Hy);colormap jet;shading interp;axis image;title('Vertical Hilbert Component')

function [Hx,Hy]=H_(Xg,Yg,Zg,expansion,fillMethod,tappering)

[nr,nc]=size(Zg);
nanmask=generateNaNmask(Zg);
exp = expansion/100;
[dx,dy]=find_cell_size(Xg,Yg);

if(nr>nc)
    b=round(nc*exp);
else
    b=round(nr*exp);
end

a=3;

if (strcmp(tappering,'off'))
    [Zg_prepared]=padding2D(Zg,a,b,fillMethod,'n');
elseif (strcmp(tappering,'on'))
    [Zg_prepared]=padding2D(Zg,a,b,fillMethod,'y');
end

% Create the wavenumber space
[F1,F2] = freqspace(size(Zg_prepared),'meshgrid');
kx=((2*pi*(length(F1)/2)/(length(F1)-1))*F1);
ky=((2*pi*(length(F2)/2)/(length(F2)-1))*F2);

% Generate the masks related to Hx and Hy hilbert transform components
maskx=(1i.*kx)./sqrt(kx.^2+ky.^2);
maskx(isnan(maskx))=0;
masky=(1i.*ky)./sqrt(kx.^2+ky.^2);
masky(isnan(masky))=0;

ft=fftshift(fft2(Zg_prepared));

% Generate the Hx component
fx=ifft2(ifftshift(maskx.*ft));
Hx=real(fx(b+1:end-b,b+1:end-b));
Hx=(nanmask.*Hx)./dx;

% Generate the Hy component
fy=ifft2(ifftshift(masky.*ft));
Hy=real(fy(b+1:end-b,b+1:end-b));
Hy=(nanmask.*Hy)./dy;

end