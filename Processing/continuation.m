% Subroutine continuation upward/downward continue the input data by the
% following steps:
%   (1) Prepare the input data;
%       (1.1) If there are holes in the input data matrix (NaN/Dummies)
%       these holes are filled by interpolation;
%       (1.2) The hole indexes are stored to be applied on the output data.
%       (1.3) The input data borders are expanded followed by interpolation
%       in order to simulate periodicity
%   (2) Generate the frequency response of upward or downward continuation;
%   (3) Fourier transform the prepared input matrix;
%   (4) Multiple the Fourier transformed input matrix by filter related to
%       the corresponding continuation filter;
%   (5) Inverse Fourier transform product.
%
%INPUT PARAMETERS:
%
%   Xg -         Easting coordinate matrix.
%   Yg -         Northing coordinate matrix.
%   Zg -         Input field matrix.
%   heigth -     Elevation to continue (e.g. 100).
%                obs.: If the sample distance is in meters the heigth
%                parameter will also.
%   type -       Type of continuation.
%                   #'u' for upward;
%                   #'d' for downward;
%   cellsize -   Interpolation cell (distance between two consecultive
%                samples).
%   expansion -  Percent grid expansion (e.g. 25%).
%
%OUTPUT PARAMETERS:
%
%   cf -         Upward/Downward continued data.
%                   #if the type is 'u', cf=upward continued field;
%                   #if the type is 'd', diff_=downward continued field;
%
%EXAMPLE:
% [X,Y,Z,Xg,Yg,Zg]=OpenFile('MAG.xyz')
% [cellsize,~]=find_cell_size(Xg,Yg);
% cf=continuation(Zg,100,'u',cellsize,25)
% figure;pcolor(cf);colormap jet;shading interp;axis image;title('Upward Continued Field by h=100')

function cf=continuation(Xg,Yg,Zg,heigth,type,cellsize,expansion)

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
kx=((2*pi*(length(F1)/2)/(length(F1)-1))*F1); %kx(kx==0)=0.0000000000000001;
ky=((2*pi*(length(F2)/2)/(length(F2)-1))*F2); %ky(ky==0)=0.0000000000000001;

% Apply the frequency response filter related to the continuation of the
% field
if(type=='u')
    H=-heigth/cellsize;
    e=2.718281828459045235360287;
    filter_1=e.^(H.*sqrt(kx.^2+ky.^2));
    
    ft=fftshift(fft2(Zg_prepared));
    
    fzf=ifft2(ifftshift(filter_1.*ft));
    cf=real(fzf(b+1:end-b,b+1:end-b));
    cf=cf.*nanmask;
elseif(type=='d')
    H=heigth/cellsize;
    e=2.718281828459045235360287;
    k=sqrt(kx.^2+ky.^2);
    filter_1=(e.^(H.*k));
    filter_2=1./((1i.*k).^2);
    filter_2(isinf(filter_2))=0;
    filter = filter_1.*filter_2;
    
    %plotZg(kx,ky,filter_1,'pcolor','eq');return
    
    diff_x=Zg_prepared;
    diff_y=Zg_prepared;
    for i=1:2
        diff_x=difference(Xg,Yg,diff_x,'x',exp);
        diff_y=difference(Xg,Yg,diff_y,'y',exp);
    end
    [cell_dx,cell_dy]=find_cell_size(Xg,Yg);
    diff_x=diff_x*((cell_dx).^2);
    diff_y=diff_y*((cell_dy).^2);
    diff_=(diff_x+diff_y);
    
    ft=fftshift(fft2(diff_));
    
    fzf=ifft2(ifftshift(filter.*ft));
    cf=real(fzf(b+1:end-b,b+1:end-b));
    cf=cf.*nanmask;
end