% Subroutine butterworth2D apply a low/high/band-pass/band-stop butterword
% filter using the following steps:
%   (1) Prepare the input data;
%       (1.1) If there are holes in the input data matrix (NaN/Dummies)
%       these holes are filled by interpolation;
%       (1.2) The hole indexes are stored to be applied on the output data.
%       (1.3) The input data borders are expanded followed by interpolation
%       in order to simulate periodicity
%   (2) Apply the filter;
%   (3) Recover the initial matrix size;
%
%INPUT PARAMETERS:
%
%   Zg -          Input field matrix.
%   F_cut1     -  cut-off frequency 1.
%   F_cut2     -  cut-off frequency 2.
%   n -           Filter order.
%   expansion  -  Percent grid expansion (e.g. 25%).
%   filterType -  Filter type (eg. 'lp', 'hp', 'bs', and 'bp').
%
%OUTPUT PARAMETERS:
%
%   filtData   -  Zg after butterworth filter applied.
%   kernel     -  Filter response in the frequency domain.

function [filtData,kernel] = butterworth2D(Zg,F_cut1,F_cut2,n,expansion,filterType)

[nr,nc] = size(Zg);
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
kx=((2*pi*(length(F1)/2)/(length(F1)-1))*F1); kx(kx==0)=0.0000000000000001;
ky=((2*pi*(length(F2)/2)/(length(F2)-1))*F2); ky(ky==0)=0.0000000000000001;
k = sqrt(kx.^2+ky.^2);

if(strcmp(filterType,'lp'))
    BTW_filter = ((1+((k./F_cut1).^(2*n)))).^(-1);
elseif(strcmp(filterType,'hp'))
    BTW_filter = 1 - ((1+((k./F_cut1).^(2*n))).^(-1));
elseif(strcmp(filterType,'bs'))
    LP_butter = ((1+((k./F_cut1).^(2*n)))).^(-1);
    HP_butter = 1 - ((1+((k./F_cut2).^(2*n))).^(-1));
    BTW_filter = LP_butter + HP_butter;
else
    LP_butter = ((1+((k./F_cut1).^(2*n)))).^(-1);
    HP_butter = 1 - ((1+((k./F_cut2).^(2*n))).^(-1));
    BS_butter = LP_butter + HP_butter;
    BTW_filter = 1 - BS_butter;
end

fftInput = fftshift(fft2(Zg_prepared));

filtered_data = BTW_filter.*fftInput;
filtered_data = ifft2(ifftshift(filtered_data));
filtered_data = real(filtered_data(b+1:end-b,b+1:end-b));

kernel = BTW_filter;
filtData = filtered_data.*nanmask;