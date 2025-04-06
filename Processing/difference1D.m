function Dx=difference1D(X,Z)

N=length(X);
dx=X(1,2)-X(1,1);

for i=1:N
    if(i==1)
        Dx(i)=(Z(i+1)-Z(i))/dx;
    elseif(i==N)
        Dx(i)=(Z(i)-Z(i-1))/dx;
    else
        Dx(i)=(Z(i+1)-Z(i-1))/(2*dx);
    end
end