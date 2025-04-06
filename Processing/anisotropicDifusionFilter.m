% Subroutine anisotropicDifusionFilter apply the anisotropic diffusion
% filter using the following steps:
%   (1) Calculate the horizontal derivatives Dx and Dy;
%   (2) Calculate the diffusion tensor D from the structure matrix S;
%   (3) Apply the diffusion tensor to the input dataset;
%
%INPUT PARAMETERS:
%
%   Xg -         Input horizontal coordinate matrix.
%   Yg -         Input vertical coordinate matrix.
%   Zg -         Input field matrix.
%   expansion -  Percent grid expansion (e.g. 25%).
%   n         -  Number of time steps.
%   delT      -  Time step size.
%
%OUTPUT PARAMETERS:
%
%   out -        Zg after the difusion filter applied.
%
%EXAMPLE:
% [X,Y,Z,Xg,Yg,Zg]=OpenFile('MAG.xyz')
% Zg_ = anisotropicDifusionFilter(Xg,Yg,Zg,25,200,1)
% figure;pcolor(Zg_);colormap jet;shading interp;axis image;title('Zg after ADF')

function out = anisotropicDifusionFilter(Xg,Yg,Zg,expansion,n,delT)

nanmask=generateNaNmask(Zg);
[dx,dy]=find_cell_size(Xg,Yg);

a=3;

Zg = padding2D(Zg,a,0,3,'n');

Dx = difference(Xg,Yg,Zg,'x',expansion);
Dy = difference(Xg,Yg,Zg,'y',expansion);

Dx = Dx*dx;
Dy = Dy*dy;

Dx_p_Dx = Dx.*Dx;
Dx_p_Dy = Dx.*Dy;
Dy_p_Dx = Dy.*Dx;
Dy_p_Dy = Dy.*Dy;

[r,c]=size(Zg);

for i=1:r
    for j=1:c
        S=[Dx_p_Dx(i,j),Dx_p_Dy(i,j);...
            Dy_p_Dx(i,j),Dy_p_Dy(i,j)];
        d = eig(S);
        [~,idx_1]=min(d);
        [~,idx_2]=max(d);
        d(idx_1)=1;
        d(idx_2)=0;
        D=diag(d);
        M=D*[Dx(i,j);Dy(i,j)];
        M_1(i,j)=M(1);
        M_2(i,j)=M(2);
    end
end

A = delT*divergence(Xg,Yg,M_1,M_2);

out = Zg;
for k=1:n
    out = out+A;
end

out = out.*nanmask;

end