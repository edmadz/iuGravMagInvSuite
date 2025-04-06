function out=fillHoles(Zg)

[nx,ny] = size(Zg);

a=0.1;
T_row=floor(a*nx);
T_col=floor(a*ny);

out=Zg;

while(sum(double(isnan(out(:))))>0)
    %interpolate all the columns
    for y_=1:ny
        Z=out(:,y_);
        numNaN = sum(double(isnan(Z)));
        if(numNaN<=T_col)
            Z(isnan(Z)) = interp1(find(~isnan(Z)), Z(~isnan(Z)), find(isnan(Z)),'linear');
        end
        out(:,y_)=Z;
    end
    
    %interpolate all the lines
    for x_=1:nx
        Z=out(x_,:);
        numNaN = sum(double(isnan(Z)));
        if(numNaN<=T_row) %Just interpolate if the number of NaN was lower than 10% of row elements
            Z(isnan(Z)) = interp1(find(~isnan(Z)), Z(~isnan(Z)), find(isnan(Z)),'linear');
        end
        out(x_,:)=Z;
    end
    
    a=a+0.02;
    T_row=floor(a*nx);
    T_col=floor(a*ny);
end