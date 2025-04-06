function [mx,my,mz]=dircos(I,D)

mx=cos(I)*cos(D);
my=cos(I)*sin(D);
mz=sin(I);

end