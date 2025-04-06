% fillGaps expands the input data and fill the gaps or holes in the data by
% interpolation
%
% Zg           - input matrix
% methods      - 2 and 5 are good interpolation methods for rtp filtering
%              - 1 is good for differentiation filtering
% exp          - is the percent expansion of input grid Zg

function [out,cdiff,rdiff]=fillGaps(Zg,method,exp)

[nx,ny] = size(Zg);
npts_c=ny+floor(ny*exp);
npts_r=nx+floor(nx*exp);
cdiff=floor((npts_c-ny)/2);
rdiff=floor((npts_r-nx)/2);

NaN_Hor_Slice=NaN(rdiff,ny);
Zg_=cat(1,NaN_Hor_Slice,Zg,NaN_Hor_Slice);
NaN_Vert_Slice=NaN(nx+2*rdiff,cdiff);
Zg=cat(2,NaN_Vert_Slice,Zg_,NaN_Vert_Slice);

out = inpaint_nans(Zg,method);