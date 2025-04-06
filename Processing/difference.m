% Subroutine difference compute the space domain horizontal derivatives
% using the following steps:
%   (1) Prepare the input data;
%       (1.1) If there are holes in the input data matrix (NaN/Dummies)
%       these holes are filled by interpolation;
%       (1.2) The hole indexes are stored to be applied on the output data.
%       (1.3) The input data borders are expanded followed by interpolation
%       in order to simulate periodicity
%   (2) Calculate the horizontal derivative using finite difference;
%   (3) Recover the initial matrix size;
%
%INPUT PARAMETERS:
%
%   Xg -         Input horizontal coordinate matrix.
%   Yg -         Input vertical coordinate matrix.
%   Zg -         Input field matrix.
%   direction -  Derivative direction (e.g. 'x','y','z').
%   expansion -  Percent grid expansion (e.g. 25%).
%
%OUTPUT PARAMETERS:
%
%   diff_ -      Derivative of input matrix Zg.
%                   #if the direction is 'x', diff_=Dx;
%                   #if the direction is 'y', diff_=Dy;
%
%EXAMPLE:
% [X,Y,Z,Xg,Yg,Zg]=OpenFile('MAG.xyz')
% Dx=difference(Xg,Yg,Zg,'x',25)
% figure;pcolor(Dx);colormap jet;shading interp;axis image;title('Horizontal Derivative')

function diff_=difference(Xg,Yg,Zg,direction,expansion)

[nr,nc] = size(Zg);
[cell_dx,cell_dy] = find_cell_size(Xg,Yg);
nanmask=generateNaNmask(Zg);
exp = expansion/100;

if(nr>nc)
    b=round(nc*exp);
else
    b=round(nr*exp);
end

a=3;

[Zg] = padding2D(Zg,a,b,3,'n');

[row,col] = size(Zg);
%--------------------------------------------------------------------------
diff_=zeros(size(Zg));
if(direction=='x') % Loop for differentiation in x
    ddx = cell_dx;
    for x=1:row
        for y=1:col
            if(y==1)
                diff_(x,y)=(Zg(x,y+1)-Zg(x,y))/ddx;
            elseif(y==col)
                diff_(x,y)=(Zg(x,y)-Zg(x,y-1))/ddx;
            else
                diff_(x,y)=((Zg(x,y+1)-Zg(x,y))+(Zg(x,y)-Zg(x,y-1)))/(2*ddx);
            end
        end
    end
elseif(direction=='y') % Loop for differentiation in y
    ddy = cell_dy;
    for y=1:col
        for x=1:row
            if(x==1)
                diff_(x,y)=(Zg(x+1,y)-Zg(x,y))/ddy;
            elseif(x==row)
                diff_(x,y)=(Zg(x,y)-Zg(x-1,y))/ddy;
            else
                diff_(x,y)=((Zg(x+1,y)-Zg(x,y))+(Zg(x,y)-Zg(x-1,y)))/(2*ddy);
            end
        end
    end
end

% Recover the origional size of the input matrix
diff_=diff_(b+1:end-b,b+1:end-b);
diff_=diff_.*nanmask;