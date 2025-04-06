function [x,y]=gridOutline(Xg,Yg,Zg)

%Expand the input matrices by a factor of 'a' in both directions

minX = min(Xg(:)); maxX = max(Xg(:));
minY = min(Yg(:)); maxY = max(Yg(:));

[row,col] = size(Zg);

a = 2;
Zg_=padarray(Zg,[a a],NaN,'both');
Zg_(~isnan(Zg_))=1;
Zg_(isnan(Zg_))=0;

dx = Xg(1,2)-Xg(1,1);
dy = Yg(2,1)-Yg(1,1);

[Xg_,Yg_]=meshgrid(linspace(minX-a*dx,maxX+a*dx,col+2*a),...
    linspace(minY-a*dy,maxY+a*dy,row+2*a));

b=[0.9999,0.9999];
f=figure;
[C,~]=contour(Xg_,Yg_,Zg_,b);
delete(f)

x=C(1,:);
y=C(2,:);

xv = [minX,maxX,maxX,minX];
yv = [minY,minY,maxY,maxY];
in=inpolygon(x,y,xv,yv);
x = x(in);
y = y(in);