% Subroutine differentiate compute the frequency domain derivatives using
% the following steps:
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
%   Xg -         Input horizontal coordinate matrix.
%   Yg -         Input vertical coordinate matrix.
%   Zg -         Input field matrix.
%   direction -  Derivative direction (e.g. 'x','y','z').
%   expansion -  Percent grid expansion (e.g. 25%).
%
%OUTPUT PARAMETERS:
%
%   diff_ -      Derivative of input matrix Zg.
%                   #if the direction is 'x', diff_=Dx;
%                   #if the direction is 'y', diff_=Dy;
%                   #if the direction is 'z', diff_=Dz;
%
%EXAMPLE:
% [X,Y,Z,Xg,Yg,Zg]=OpenFile('MAG.xyz')
% Dx=differentiate(Xg,Yg,Zg,'x',25)
% figure;pcolor(Dx);colormap jet;shading interp;axis image;title('Horizontal Derivative')

function diff_=differentiate(Xg,Yg,Zg,direction,expansion)

[nr,nc]=size(Zg);
[cell_dx,cell_dy] = find_cell_size(Xg,Yg);
nanmask=generateNaNmask(Zg);
exp = expansion/100;

if(nr>nc)
    b=round(nc*exp);
else
    b=round(nr*exp);
end

a=3;

Zg_prepared = padding2D(Zg,a,b,1,'n');

[kx,ky]=generateWavenumber(Zg_prepared);

% Apply the frequency response filter according to the specified direction
% [x, y or z]
if direction == 'x'
    filter=(1i.*kx);
    denominator = cell_dx;
elseif direction == 'y'
    filter=(1i.*ky);
    denominator = cell_dy;
elseif direction == 'z'
    filter=((kx.^2+ky.^2)).^(1/2);
    denominator = cell_dx;
end

% Compute the derivative
ft=fftshift(fft2(Zg_prepared));
fzf=ifft2(ifftshift(filter.*ft));
diff_=real(fzf(b+1:end-b,b+1:end-b))./denominator;
diff_=nanmask.*diff_;