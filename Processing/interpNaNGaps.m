function [out,cdiff,rdiff]=interpNaNGaps(Zg,exp)

%Expands the grid
[nx,ny] = size(Zg);
npts_c=ny+floor(ny*exp);
npts_r=nx+floor(nx*exp);
cdiff=floor((npts_c-ny)/2);
rdiff=floor((npts_r-nx)/2);

NaN_Hor_Slice=NaN(rdiff,ny);
Zg_=cat(1,NaN_Hor_Slice,Zg,NaN_Hor_Slice);
NaN_Vert_Slice=NaN(nx+2*rdiff,cdiff);
Zg=cat(2,NaN_Vert_Slice,Zg_,NaN_Vert_Slice);
[nx,ny] = size(Zg);

figure
pcolor(Zg);shading interp;axis image

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
            Z(isnan(Z)) = interp1(find(~isnan(Z)), Z(~isnan(Z)), find(isnan(Z)),'spline');
        end
        out(:,y_)=Z;
    end
    
    %interpolate all the lines
    for x_=1:nx
        Z=out(x_,:);
        numNaN = sum(double(isnan(Z)));
        if(numNaN<=T_row) %Just interpolate if the number of NaN was lower than 10% of row elements
            Z(isnan(Z)) = interp1(find(~isnan(Z)), Z(~isnan(Z)), find(isnan(Z)),'spline');
        end
        out(x_,:)=Z;
    end
    
    a=a+0.02;
    T_row=floor(a*nx);
    T_col=floor(a*ny);
end