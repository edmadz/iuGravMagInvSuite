function dt=mag(a,b,h,x,y,teta,I0,D0,I,D,j0,fi,i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adds 0.1% of the lesser edge length to the prism vertices coordinates
% to avoid singularities when a field point is located at the
% as the prism vertice. Insert the "%"s before the next three lines if you
% don't want this option
vi=min([abs(a(2)-a(1)),abs(b(2)-b(1)),abs(h(2)-h(1))]);
a=a+0.001*vi;
b=b+0.001*vi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the constants depending on the declination, inclination and
% magnetization (induced and remanent) which are used in the anomaly
% calculation.

% Direction cosines for the Earth field.
p=cos(I)*cos(D-teta);
q=cos(I)*sin(D-teta);
r=sin(I);

% Direction cosines for the remanent field.
pr=cos(I0)*cos(D0-teta);
qr=cos(I0)*sin(D0-teta);
rr=sin(I0);

% Components of the total magnetization.
NS=j0*p+fi*pr;
EW=j0*q+fi*qr;
V=j0*r+fi*rr;

% Inclination and declination of the total magnetization.
DT=atan2(EW,NS);
IT=atan2(V,sqrt(EW^2+NS^2));

% Direction cosines for the total magentization.
L=cos(IT)*cos(DT-teta);
M=cos(IT)*sin(DT-teta);
N=sin(IT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finds the coordinate of the centers of the prisms and shifts the prims
% centers coordinates to zero.
ac=(a(2)+a(1))/2;
bc=(b(2)+b(1))/2;
a=a-ac;
b=b-bc;
x=x-ac;
y=y-bc;
% Rotates the prisms (strike) by an angle theta, provided by the user. 
[x y]=rotat(x,y,teta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the magnetic anomalies using the formula (3) of Bhaskara Rao
% & Ramesh Babu (1991), using the functions "F" (below described) and the
% constants "G".

G1=(M*r+N*q);
G2=(L*r+N*p);
G3=(L*q+M*p);
G4=(N*r-M*q);
G5=(N*r-L*p);


dt=G1.*log(F1(alfa(1,a,x),alfa(2,a,x),a,b,x,y,h))+...
    G2.*log(F2(betta(1,b,y),betta(2,b,y),a,b,x,y,h))+...
    G3.*log(F3(h(1),h(2),a,b,x,y,h))+...
    G4.*F4(alfa(1,a,x),alfa(2,a,x),betta(1,b,y),betta(2,b,y),h,a,b,x,y)+...
    G5.*F5(alfa(1,a,x),alfa(2,a,x),betta(1,b,y),betta(2,b,y),h,a,b,x,y);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions "F" of Bhaskara Rao & Ramesh Babu (1991).

function F1=F1(v1,v2,a,b,x,y,h)

F1=(R(1,1,2,a,b,x,y,h)+v1).*(R(2,1,1,a,b,x,y,h)+v2).*(R(1,2,1,a,b,x,y,h)+v1).*...
    (R(2,2,2,a,b,x,y,h)+v2)./(((R(1,1,1,a,b,x,y,h)+v1).*(R(2,1,2,a,b,x,y,h)+v2).*...
    (R(1,2,2,a,b,x,y,h)+v1).*(R(2,2,1,a,b,x,y,h)+v2)));

return

function F2=F2(v1,v2,a,b,x,y,h)

F2=(R(1,1,2,a,b,x,y,h)+v1).*(R(2,1,1,a,b,x,y,h)+v1).*(R(1,2,1,a,b,x,y,h)+v2).*...
    (R(2,2,2,a,b,x,y,h)+v2)./(((R(1,1,1,a,b,x,y,h)+v1).*(R(2,1,2,a,b,x,y,h)+v1).*...
    (R(1,2,2,a,b,x,y,h)+v2).*(R(2,2,1,a,b,x,y,h)+v2)));

function F3=F3(v1,v2,a,b,x,y,h)

F3=(R(1,1,2,a,b,x,y,h)+v2).*(R(2,1,1,a,b,x,y,h)+v1).*(R(1,2,1,a,b,x,y,h)+v1).*...
    (R(2,2,2,a,b,x,y,h)+v2)./(((R(1,1,1,a,b,x,y,h)+v1).*(R(2,1,2,a,b,x,y,h)+v2).*...
    (R(1,2,2,a,b,x,y,h)+v2).*(R(2,2,1,a,b,x,y,h)+v1)));

return

function F4=F4(v1,v2,w1,w2,h,a,b,x,y)

F4=atan(v2.*h(2)./(R(2,2,2,a,b,x,y,h).*w2))-atan(v1.*h(2)./(R(1,2,2,a,b,x,y,h).*w2))...
    -atan(v2.*h(2)./(R(2,1,2,a,b,x,y,h).*w1))+atan(v1.*h(2)./(R(1,1,2,a,b,x,y,h).*w1))...
    -atan(v2.*h(1)./(R(2,2,1,a,b,x,y,h).*w2))+atan(v1.*h(1)./(R(1,2,1,a,b,x,y,h).*w2))...
    +atan(v2.*h(1)./(R(2,1,1,a,b,x,y,h).*w1))-atan(v1.*h(1)./(R(1,1,1,a,b,x,y,h).*w1));

return

function F5=F5(v1,v2,w1,w2,h,a,b,x,y)

F5=atan(w2.*h(2)./(R(2,2,2,a,b,x,y,h).*v2))-atan(w2.*h(2)./(R(1,2,2,a,b,x,y,h).*v1))...
    -atan(w1.*h(2)./(R(2,1,2,a,b,x,y,h).*v2))+atan(w1.*h(2)./(R(1,1,2,a,b,x,y,h).*v1))...
    -atan(w2.*h(1)./(R(2,2,1,a,b,x,y,h).*v2))+atan(w2.*h(1)./(R(1,2,1,a,b,x,y,h).*v1))...
    +atan(w1.*h(1)./(R(2,1,1,a,b,x,y,h).*v2))-atan(w1.*h(1)./(R(1,1,1,a,b,x,y,h).*v1));

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rotates the coordinates system by an angle theta.

function [xr yr]=rotat(x,y,teta)

xr=x.*cos(teta)+y.*sin(teta);
yr=-x.*sin(teta)+y.*cos(teta);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the distances used in the functions "F". (Bhaskara Rao,
% Ramesh Babu (1991) and Plouff (1976).

function R=R(i,j,k,a,b,x,y,h)

R=sqrt(alfa(i,a,x).^2+betta(j,b,y).^2+h(k).^2);

return

function alfa=alfa(i,a,x)

alfa=a(i)-x;

return

function betta=betta(i,b,y)

betta=b(i)-y;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
