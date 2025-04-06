function [mag_z,mag_x,mag_t] = irregularBodyMag(xv,zv,xst,zst,B,I,strike,suscept)

% Computhe the magnetic anomaly at one or more stations due to an infinite
% polygonal cylinder magnetized by the earth's magnetic field. The cylinder
% strikes parallel to the Y-axis, and has a polygonal cross-section in the
% X,Z plane. The anomalous magnetic field strength depends on X and Z, but
% not on Y.
% 
%                                                from: Won & Bevis(1987)
% INPUT ARGUMENTS
%   xst        Vector containing the horizontal station coordinates.
%   zst        Vector containing the vertical station coordinates.
%   xv         Vector containing the horizontal coordinates of the polygon
%              vertices.
%   zv         Vector containing the vertical coordinates of the polygon
%              vertices.
%   B          The earth's total magnetic field strength.
%   I          The inclination of the earth's magnetic field (degrees).
%   strike     The strike of the cylinder (in degrees) measured
%              counter-clockwise (looking down) from magnetic north to the
%              negative Y-axis.
%   suscept    The magnetic susceptibility of the cylinder in emu, or
%              4pi*susceptibility given in SI units.
% OUTPUT ARGUMENTS
%   mag_z      Vector containing the vertical magnetic anomaly at each
%              station
%   mag_x      Vector containing the horizontal magnetic anomaly at each
%              station
%   mag_t      Vector containing the total magnetic anomaly at each station

nVerts = length(xv);
stations = length(zst);

c1=sin(deg2rad(I));
c2=sin(deg2rad(strike))*cos(deg2rad(I));
c3=2*suscept*B;

mag_z=zeros(1,stations);
mag_x=zeros(1,stations);
mag_t=zeros(1,stations);

for is=1:stations
    hz=0.000;
    hx=0.000;
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
            hz=0.000;
            hx=0.000;
            break
        else
            theta_1 = atan2(z1,x1);
        end
        
        %CASE 02
        if(x2==0.000 && z2==0.000)
            hz=0.000;
            hx=0.000;
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
        x21s=x21*x21;
        z21s=z21*z21;
        xz12=x1*z2-x2*z1;
        r1s=x1*x1+z1*z1;
        r2s=x2*x2+z2*z2;
        r21s=x21*x21+z21*z21;
        r1n=0.5*(log(r2s/r1s));
        p=(xz12/r21s)*(((x1*x21-z1*z21)/r1s)-((x2*x21-z2*z21)/r2s));
        q=(xz12/r21s)*(((x1*z21+z1*x21)/r1s)-((x2*z21+z2*x21)/r2s));
        
        if(x21==0.000)
            dzz=-p;
            dzx=q-z21s*(r1n/r21s);
            dxz=q;
            dxx=p+z21s*(t12/r21s);
        else
            z21dx21=z21/x21;
            x21z21=x21*z21;
            fz=(t12+(z21dx21*r1n))/r21s;
            fx=((t12*z21dx21)-r1n)/r21s;
            dzz=-p+(x21s*fz);
            dzx=q-(x21z21*fz);
            dxz=q-(x21s*fx);
            dxx=p+(x21z21*fx);
        end
        
        hz=c3*(c1*dzz+c2*dzx)+hz;
        hx=c3*(c1*dxz+c2*dxx)+hx;
    end
    mag_z(is)=hz;
    mag_x(is)=hx;
    mag_t(is)=c1*hz+c2*hx;
end