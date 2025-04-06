function [kx,ky]=generateWavenumber(Zg)

%Define the vector space
[F1,F2] = freqspace(size(Zg),'meshgrid');
%Create the wavenumber space
kx=((2*pi*(length(F1)/2)/(length(F1)-1))*F1);
ky=((2*pi*(length(F2)/2)/(length(F2)-1))*F2);
%Replace zero values to values close to 0 to avoid singularity
ky(ky==0)=1e-15;
kx(kx==0)=1e-15;

end