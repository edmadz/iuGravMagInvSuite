function [xi,yi,d,a] = extractProfile(Xg,Yg,Zg,x,y,N,interpMethod)

if(length(x)==2) %single line
    xi=linspace(x(1),x(end),N);
    yi=linspace(y(1),y(end),N);
    d=zeros(size(xi));
    for i=1:(N-1)
        delta(i)=sqrt((xi(i)-xi(i+1))^2+(yi(i)-yi(i+1)).^2);
        d(i+1)=sum(delta(1:i));
    end
else %polyline
    M=length(x)-1;
    for j=1:M
        D_(j)=sqrt((x(j)-x(j+1))^2+(y(j)-y(j+1))^2);
    end
    D_tot=sum(D_);
    xi=[]; yi=[];
    for j=1:M
        x_=linspace(x(j),x(j+1),round((N*D_(j))/D_tot)+1);
        xi=[xi,x_(1:end-1)];
        y_=linspace(y(j),y(j+1),round((N*D_(j))/D_tot)+1);
        yi=[yi,y_(1:end-1)];
    end
    %figure;plot(x,y,'o',xi,yi,'*')
    d=zeros(size(xi));
    if(mod(length(x),2)==1)
        M_=N-1;
    else
        M_=N-2;
    end
    for i=1:M_
        delta(i)=sqrt((xi(i)-xi(i+1))^2+(yi(i)-yi(i+1)).^2);
        d(i+1)=sum(delta(1:i));
    end
    
    if(mod(length(x),2)==1)
        xi=xi';
        yi=yi';
        d=d';
    else
        xi=xi(1:end-1)';
        yi=yi(1:end-1)';
        d=d(1:end-1)';
    end
end

if(interpMethod==1)
    a=interp2(Xg,Yg,Zg,xi,yi,'linear');
elseif(interpMethod==2)
    a=interp2(Xg,Yg,Zg,xi,yi,'spline');
else
    a=interp2(Xg,Yg,Zg,xi,yi,'cubic');
end

end