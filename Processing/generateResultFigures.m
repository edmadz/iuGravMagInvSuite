function [fig1,fig2]=generateResultFigures(w,h,Xg,Yg,Zg,Zg_transformed,Dist_1,Dist_2,cm_1,cm_2,ConvCoord)

if(ConvCoord==1) %show coordinates in its original units
    d = 1;
    labelX = 'Easting (units)';
    labelY = 'Northing (units)';
elseif(ConvCoord==2) %Convert coordinate from m to km
    d = 1000;
    labelX = 'Easting (km)';
    labelY = 'Northing (km)';
elseif(ConvCoord==3) %Convert coordinate from m to m
    d = 1;
    labelX = 'Easting (m)';
    labelY = 'Northing (m)';
elseif(ConvCoord==4) %Convert coordinate from km to m
    d = 1/1000;
    labelX = 'Easting (m)';
    labelY = 'Northing (m)';
elseif(ConvCoord==5) %Convert coordinate from km to km
    d = 1;
    labelX = 'Easting (km)';
    labelY = 'Northing (km)';
end

Xg = Xg./d;
Yg = Yg./d;

minX = min(Xg(:)); maxX = max(Xg(:));
minY = min(Yg(:)); maxY = max(Yg(:));

[r_Zg,c_Zg]=size(Zg);
[r_Zgt,c_Zgt]=size(Zg_transformed);

if(r_Zg==r_Zgt && c_Zg==c_Zgt)
    Xg_ = Xg;
    Yg_ = Yg;
else
    [Xg_,Yg_] = meshgrid(linspace(minX,maxX,c_Zgt),...
        linspace(minY,maxY,r_Zgt));
end

figWidth__=w;
figHeight__=h;
Pix_SS = get(0,'screensize');
W = Pix_SS(3);
H = Pix_SS(4);
posX_ = W/2 - figWidth__-8;
posY_ = H/2 - figHeight__/2;

fig1=figure('units','pixel',...
    'position',[posX_ posY_ figWidth__ figHeight__],...
    'Tag','fig_');
pcolor(Xg,Yg,Zg)
[row,col]=size(Zg);
if(Dist_1==1)
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),cm_1,'equalized');
    colormap(cmapChanged)
else
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),cm_1,'linear');
    colormap(cmapChanged)
end
shading interp
c=colorbar;
set(get(c,'Label'),'String','Quantity (Unit)')
set(get(c,'Label'),'FontWeight','bold')
title('Input Map')
xlabel(labelX,'FontWeight','bold')
ylabel(labelY,'FontWeight','bold')
axis image
set(gca,'Xlim',[minX maxX])
set(gca,'Ylim',[minY maxY])
set(gca,'YTickLabelRotation',90)
Y_coord = linspace(minY,maxY,5);
set(gca,'YTick',Y_coord)
Y_coord_ = prepCoord(Y_coord);
set(gca,'YTickLabel',Y_coord_)
X_coord = linspace(minX,maxX,5);
set(gca,'XTick',X_coord)
X_coord_ = prepCoord(X_coord);
set(gca,'XTickLabel',X_coord_)
set(gca,'FontSize',17)
set(gca,'Box','on')

posX_ = W/2+8;
fig2=figure('units','pixel',...
    'position',[posX_ posY_ figWidth__ figHeight__],...
    'Tag','fig_');
pcolor(Xg_,Yg_,Zg_transformed)
[row,col]=size(Zg_transformed);
if(Dist_2==1)
    cmapChanged = colormaps(reshape(Zg_transformed,[row*col,1]),cm_2,'equalized');
    colormap(cmapChanged)
else
    cmapChanged = colormaps(reshape(Zg_transformed,[row*col,1]),cm_2,'linear');
    colormap(cmapChanged)
end
shading interp
c=colorbar;
set(get(c,'Label'),'String','Quantity (Unit)')
set(get(c,'Label'),'FontWeight','bold')
title('Processed Map')
xlabel(labelX,'FontWeight','bold')
ylabel(labelY,'FontWeight','bold')
axis image
set(gca,'Xlim',[minX maxX])
set(gca,'Ylim',[minY maxY])
set(gca,'YTickLabelRotation',90)
Y_coord = linspace(minY,maxY,5);
set(gca,'YTick',Y_coord)
Y_coord_ = prepCoord(Y_coord);
set(gca,'YTickLabel',Y_coord_)
X_coord = linspace(minX,maxX,5);
set(gca,'XTick',X_coord)
X_coord_ = prepCoord(X_coord);
set(gca,'XTickLabel',X_coord_)
set(gca,'FontSize',17)
set(gca,'Box','on')

end