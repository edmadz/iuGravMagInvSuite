% **************************************************************
% Potensoft - Gravity and Magnetic Data Mapping, Processing,
% Modeling and Filtering Software
% Tested using Matlab 7.6 Release 2008b under Windows XP
% ***********************************************************
%           AUTHORS
% G.R.J. Cooper & D.R. Cowan
% ***********************************************************
% Function : taper2d
% Performs grid expansion and grid filling
% **************************************************************

function gt=taper2d(g,npts,nr,nc,rdiff,cdiff)
% Merge edges to the value opposite using a cubic spline

gt=zeros(npts);
gt(rdiff+1:rdiff+nr,cdiff+1:cdiff+nc)=g;
gp=g(:,1:3);
[gpx1,~]=gradient(gp);  % sides
gp=g(:,nc-2:nc);
[gpx2,~]=gradient(gp);
x1=0;
x2=(2*cdiff)+1;
x=[1 1 0 0;x1 x2 1 1; x1^2 x2^2 2*x1 2*x2; x1^3 x2^3 3*x1^2 3*x2^2];
for I=1:nr
    y=[g(I,nc) g(I,1) gpx2(I,3) gpx1(I,1)];
    c=y/x;
    for J=1:cdiff
        gt(I+rdiff,J)=c(1)+(J+cdiff)*c(2)+c(3)*(J+cdiff)^2+c(4)*(J+cdiff)^3;
        gt(I+rdiff,J+nc+cdiff)=c(1)+J*c(2)+c(3)*J^2+c(4)*J^3;
    end
end

gp=g(1:3,:);
[~,gpx1]=gradient(gp);  % top and bottom
gp=g(nr-2:nr,:);
[~,gpx2]=gradient(gp);
x1=0; x2=(2*rdiff)+1;
x=[1 1 0 0;x1 x2 1 1; x1^2 x2^2 2*x1 2*x2; x1^3 x2^3 3*x1^2 3*x2^2];
for J=1:nc
    y=[g(nr,J) g(1,J) gpx2(3,J) gpx1(1,J)];
    c=y/x;
    for I=1:rdiff
        gt(I,J+cdiff)=c(1)+(I+rdiff)*c(2)+c(3)*(I+rdiff)^2+c(4)*(I+rdiff)^3;
        gt(I+rdiff+nr,J+cdiff)=c(1)+I*c(2)+c(3)*I^2+c(4)*I^3;
    end
end

for I=rdiff+nr+1:npts % Corners
    for J=cdiff+nc+1:npts
        if (I-nr-rdiff)>(J-nc-cdiff)
            gt(I,J)=gt(I,nc+cdiff);
        else
            gt(I,J)=gt(nr+rdiff,J);
        end
    end
end

for I=1:rdiff
    for J=1:cdiff
        if I>J
            gt(I,J)=gt(rdiff+1,J);
        else
            gt(I,J)=gt(I,cdiff+1);
        end
    end
end

for I=1:rdiff % bottom right
    for J=cdiff+nc+1:npts
        if I>(npts-J)
            gt(I,J)=gt(rdiff+1,J);
        else
            gt(I,J)=gt(I,cdiff+nc);
        end
    end
end

for I=rdiff+nr+1:npts % top left
    for J=1:cdiff
        if (npts-I)>J
            gt(I,J)=gt(rdiff+nr,J);
        else
            gt(I,J)=gt(I,cdiff+1);
        end
    end
end
