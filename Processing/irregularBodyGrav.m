function grav_z = irregularBodyGrav(xv,zv,xst,zst,dens)

% Computhe the vertical component of gravitational acceleration due to a
% polygon in a two-dimensional space (X,Z), or equivalently, due to an
% infinitely-long polygonal cylinder striking in the Y direction in a
% three-dimensional space (X,Y,Z)
% 
%                                                from: Won & Bevis(1987)
% INPUT ARGUMENTS
%   xst        Vector containing the horizontal station coordinates.
%   zst        Vector containing the vertical station coordinates.
%   xv         Vector containing the horizontal coordinates of the polygon
%              vertices.
%   zv         Vector containing the vertical coordinates of the polygon
%              vertices.
%   dens       Polygon density
% OUTPUT ARGUMENTS
%   grav_z     Vector containing the vertical component of gravitational
%              acceleration due to an irregular cross-section 2D body

nVerts = length(xv);
stations = length(zst);

%kg/m^3
con=13.3464*10^(-8);
grav_z=zeros(1,stations);

for is=1:stations
    grav=0.000;
    gz=0.000;
    for ic=1:nVerts
        %translate origin
        x1=xv(ic)-xst(is);
        z1=zv(ic)-zst(is);
        if(ic==nVerts)
            x2=xv(1)-xst(is);
            z2=zv(1)-zst(is);
        else
            x2=xv(ic+1)-xst(is);
            z2=zv(ic+1)-zst(is);
        end
        
        %CASE 01
        if(x1==0.000 && z1==0.000)
            gz=0.000;
            break
        else
            theta_1 = atan2(z1,x1);
        end
        
        %CASE 02
        if(x2==0.000 && z2==0.000)
            gz=0.000;
            break
        else
            theta_2 = atan2(z2,x2);
        end
        
        %CASE 03
        if(dsign(1,z1) ~= dsign(1,z2))
            test = x1.*z2 - x2.*z1;
            if(test>0.000)
                if(z1>=0.000)
                    theta_2 = theta_2+2*pi;
                end
            elseif(test<0.000)
                if(z2>=0.000)
                    theta_1 = theta_1+2*pi;
                end
            else
                break
            end
        end
        
        t12=theta_1-theta_2;
        z21=z2-z1;
        x21=x2-x1;
        xz1=x1.^2+z1.^2;
        xz2=x2.^2+z2.^2;
        
        if(x21==0.000)
            gz=(0.5)*x1*log(xz2/xz1);
        else
            gz=x21*(x1*z2-x2*z1)*(t12+0.5*(z21/x21)*log(xz2/xz1))/(x21*x21+z21*z21);
        end
        
        grav=grav+gz;
    end
    grav_z(is)=-1*con*dens*grav;
end

%convert grav anomaly from mm/s^2 to mgals
grav_z = grav_z.*10^(2);