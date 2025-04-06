function output = changeDirOfMeasurement(Zg,I,D,I_new,D_new,expansion)

Zg = Zg';
[nx,ny] = size(Zg);
nanmask=generateNaNmask(Zg);

exp = expansion/100;

if(nx>ny)
    b=round(ny*exp);
else
    b=round(nx*exp);
end

a=3;

[Zg_prepared] = padding2D(Zg,a,b,1,'n');

%Directional cosines
L=cos(I)*cos(D);
R=cos(I)*sin(D);
Q=sin(I);

l=cos(I_new)*cos(D_new);
r=cos(I_new)*sin(D_new);
q=sin(I_new);

[kx,ky]=generateWavenumber(Zg_prepared);

filter = (1i.*l.*kx + 1i.*r.*ky + q.*sqrt(kx.^2+ky.^2))./(1i.*L.*kx + 1i.*R.*ky + Q.*sqrt(kx.^2+ky.^2));

ft=fftshift(fft2(Zg_prepared));
filteredData=ifft2(ifftshift(ft.*filter));
output=real(filteredData(b+1:end-b,b+1:end-b));
output=nanmask.*output;
output = output';