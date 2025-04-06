function GUIsphericalBodyMap

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIsphericalBodyMap_ = figure('Menubar','none',...
    'Name','Three-Dimension Forward Modeling of Spherical Body',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

optionPanel = uipanel(GUIsphericalBodyMap_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

popupColorDist = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Linear','Histogram Equalized'},...
    'fontUnits','normalized',...
    'position',[0.03 0.925 0.944 0.036]);

xo_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.875 0.3 0.036]);

xf_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','10000',...
    'fontUnits','normalized',...
    'position',[0.35 0.875 0.3 0.036]);

dx_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','50',...
    'fontUnits','normalized',...
    'position',[0.67 0.875 0.3 0.036]);

yo_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.825 0.3 0.036]);

yf_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','10000',...
    'fontUnits','normalized',...
    'position',[0.35 0.825 0.3 0.036]);

dy_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','50',...
    'fontUnits','normalized',...
    'position',[0.67 0.825 0.3 0.036]);

coordX = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','5000',...
    'fontUnits','normalized',...
    'position',[0.03 0.775 0.3 0.036]);

coordY = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','5000',...
    'fontUnits','normalized',...
    'position',[0.35 0.775 0.3 0.036]);

coordZ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','1000',...
    'fontUnits','normalized',...
    'position',[0.67 0.775 0.3 0.036]);

radius_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','700',...
    'fontUnits','normalized',...
    'position',[0.03 0.725 0.944 0.036]);

measuringPoint = uicontrol(optionPanel,'Style','togglebutton',...
    'units','normalized',...
    'String','Do Not Display Measuring Points Grid',...
    'fontUnits','normalized',...
    'position',[0.03 0.675 0.944 0.036],...
    'CallBack',@measuringPoints_callBack);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Model',...
    'fontUnits','normalized',...
    'position',[0.03 0.625 0.944 0.036],...
    'CallBack',@showModel_callBack);

magComp = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Bx','By','Bz'},...
    'fontUnits','normalized',...
    'position',[0.03 0.275 0.944 0.036]);

fieldStrength_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','56000',...
    'tooltipstring','Inducing field strength in nT.',...
    'fontUnits','normalized',...
    'position',[0.03 0.225 0.46 0.036]);

sucept_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','0.0276',...
    'tooltipstring','Magnetic susceptibility in SI.',...
    'fontUnits','normalized',...
    'position',[0.51 0.225 0.46 0.036]);

I_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','90',...
    'tooltipstring','Magnetic inclination in degrees.',...
    'fontUnits','normalized',...
    'position',[0.03 0.175 0.46 0.036]);

D_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'tooltipstring','Magnetic declination in degrees.',...
    'fontUnits','normalized',...
    'position',[0.51 0.175 0.46 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Magnetic Anomaly',...
    'fontUnits','normalized',...
    'Tag','Mag',...
    'position',[0.03 0.125 0.944 0.036],...
    'CallBack',@computeAnomaly_callBack);

dens_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','500',...
    'tooltipstring','Density contrast in g/cm^3.',...
    'fontUnits','normalized',...
    'position',[0.03 0.075 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Gravimetric Anomaly',...
    'fontUnits','normalized',...
    'Tag','Grav',...
    'position',[0.03 0.025 0.944 0.036],...
    'CallBack',@computeAnomaly_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIsphericalBodyMap_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

anomalyGraph = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.15 0.15 0.7 0.7]);
set(get(anomalyGraph,'XAxis'),'Visible','off');
set(get(anomalyGraph,'YAxis'),'Visible','off');

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIsphericalBodyMap_,'label','File');
uimenu(file,'Label','Save Gravimetric Anomaly','Accelerator','G','CallBack',@saveAnomaly_callBack);
uimenu(file,'Label','Save Magnetic Anomaly','Accelerator','M','CallBack',@saveAnomaly_callBack);

topo = uimenu(GUIsphericalBodyMap_,'label','Topography');
uimenu(topo,'Label','Load Topography','Accelerator','T','CallBack',@loadTopo_callBack);

topoLoaded = 'n';
set(GUIsphericalBodyMap_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%SHOW OR HIDE MEASURING POINTS AT MODEL GRAPH
function measuringPoints_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

get(hObject,'Value')

if(get(hObject,'Value')==1)
    set(hObject,'String','Display Measuring Points Grid')
else
    set(hObject,'String','Do Not Display Measuring Points Grid')
end

%Update de handle structure
guidata(hObject,handles);
end

%LOAD TOPOGRAPHY
function loadTopo_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[~,~,~,Xg,Yg,Topo]=OpenFile(Fullpath);

xmin = min(Xg(:)); xmax = max(Xg(:));
ymin = min(Yg(:)); ymax = max(Yg(:));
dx = Xg(1,2)-Xg(1,1); dy = Yg(2,1)-Yg(1,1);
cx = (xmin+xmax)/2; cy = (ymin+ymax)/2;

set(xo_,'String',num2str(xmin))
set(xf_,'String',num2str(xmax))
set(yo_,'String',num2str(ymin))
set(yf_,'String',num2str(ymax))
set(dx_,'String',num2str(dx))
set(dy_,'String',num2str(dy))
set(coordX,'String',num2str(cx))
set(coordY,'String',num2str(cy))

handles.Xg = Xg;
handles.Yg = Yg;
handles.Topo = Topo;
topoLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%SHOW THE MODEL
function showModel_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

coordX_ = str2double(get(coordX,'String'));
coordY_ = str2double(get(coordY,'String'));
coordZ_ = str2double(get(coordZ,'String'));
R = str2double(get(radius_,'String'));

minX_ = str2double(get(xo_,'String'));
maxX_ = str2double(get(xf_,'String'));
minY_ = str2double(get(yo_,'String'));
maxY_ = str2double(get(yf_,'String'));
cell_X = str2double(get(dx_,'String'));
cell_Y = str2double(get(dy_,'String'));

Xnodes = ((maxX_-minX_)/cell_X)+1;
Ynodes = ((maxY_-minY_)/cell_Y)+1;
x_ = linspace(minX_,maxX_,Xnodes);
y_ = linspace(minY_,maxY_,Ynodes);

[Xg,Yg] = meshgrid(x_,y_);

figWidth__=1010;
figHeight__=640;
Pix_SS = get(0,'screensize');
W = Pix_SS(3);
H_ = Pix_SS(4);
posX_ = W/2 - figWidth__/2;
posY_ = H_/2 - figHeight__/2;

figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
[Xs,Ys,Zs] = ellipsoid(coordX_,coordY_,-coordZ_,R,R,R,50);
h = surf(Xs,Ys,Zs);
shading interp
lightangle(0,90)
set(h,'FaceLighting','flat')
set(h,'AmbientStrength',0.3)
set(h,'DiffuseStrength',0.8)
set(h,'SpecularStrength',0)
set(h,'SpecularExponent',25)
set(h,'BackFaceLighting','unlit')
colormap([.7 .7 .7; .7 .7 .7])
xlabel('Easting (m)')
ylabel('Northing (m)')
zlabel('Depth (m)')
axis image
xlim([min(Xg(:)) max(Xg(:))])
ylim([min(Yg(:)) max(Yg(:))])
set(gca,'FontSize',17)
set(gca,'Box','on')
grid on

if(get(measuringPoint,'Value')==1)
    if(topoLoaded == 'y')
        t_ = handles.Topo;
        X = Xg(:); Y = Yg(:); T = t_(:);
        hold on
        scatter3(X,Y,T,2,'k.')
        zlim([(-coordZ_-R)*1.1,max(T)])
    else
        t_=zeros(size(Xg));
        X = Xg(:); Y = Yg(:); T = t_(:);
        hold on
        scatter3(X,Y,T,2,'k.')
        zlim([(-coordZ_-R)*1.1,0])
    end
else
    zlim([(-coordZ_-R)*1.1,0])
end

%Update de handle structure
guidata(hObject,handles);
end

%COMPUTE THE MAGNETIC OR GRAVIMETRIC FIELD ANOMALY DUE TO A SPHERICAL BODY
function computeAnomaly_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

minX_ = str2double(get(xo_,'String'));
maxX_ = str2double(get(xf_,'String'));
minY_ = str2double(get(yo_,'String'));
maxY_ = str2double(get(yf_,'String'));
cell_X = str2double(get(dx_,'String'));
cell_Y = str2double(get(dy_,'String'));

Xnodes = (maxX_-minX_)/cell_X;
Ynodes = (maxY_-minY_)/cell_Y;
x_ = linspace(minX_,maxX_,Xnodes+1);
y_ = linspace(minY_,maxY_,Ynodes+1);

coordX_ = str2double(get(coordX,'String'));
coordY_ = str2double(get(coordY,'String'));
coordZ_ = str2double(get(coordZ,'String'));
R = str2double(get(radius_,'String'));
Dens_ = str2double(get(dens_,'String'));
Suscept_ = str2double(get(sucept_,'String'));
FieldStrength_ = str2double(get(fieldStrength_,'String'));
I = deg2rad(str2double(get(I_,'String')));
D = deg2rad(str2double(get(D_,'String')));

cm = 1e-7;
t2nt = 1e9;
m = cm*t2nt*Suscept_*FieldStrength_;

G = 6.67408*(10^(-11));

[Xg,Yg] = meshgrid(x_,y_);

if(topoLoaded == 'y')
    Topo = handles.Topo;
else
    Topo = zeros(size(Xg));
end

if(strcmp(get(hObject,'Tag'),'Grav'))
    Xvec = Xg(:);
    Yvec = Yg(:);
    Zvec = Topo(:);
    X_ = bsxfun(@minus,Xvec,coordX_);
    Y_ = bsxfun(@minus,Yvec,coordY_);
    Z_ = bsxfun(@minus,Zvec,coordZ_);
    gravAnom = 1./sqrt(X_.^2+Y_.^2+Z_.^2);
    gravAnom = reshape(gravAnom,size(Xg));
    M = (4/3)*pi*(R^3)*Dens_;
    Anomaly = G*M*gravAnom;
    Anomaly = (10^5).*Anomaly;
else
    Xvec = Xg(:);
    Yvec = Yg(:);
    Zvec = Topo(:);
    X_ = bsxfun(@minus,Xvec,coordX_);
    Y_ = bsxfun(@minus,Yvec,coordY_);
    Z_ = bsxfun(@minus,Zvec,coordZ_);
    
    [mx,my,mz]=dircos(I,D);
    
    r2 = X_.^2+Y_.^2+Z_.^2;
    r = sqrt(r2);
    r5 = r.^5;
    dot = X_.*mx+Y_.*my+Z_.*mz;
    moment = 4.*pi.*(R.^3).*m./3;
    
    if(get(magComp,'Value')==1)
        m_comp = moment.*(3.*dot.*X_-r2.*mx)./r5;
    elseif(get(magComp,'Value')==2)
        m_comp = moment.*(3.*dot.*Y_-r2.*my)./r5;
    else
        m_comp = moment.*(3.*dot.*Z_-r2.*mz)./r5;
    end
    
    Anomaly = reshape(m_comp,size(Xg));
end

% Plot the gravity anomaly
axes(anomalyGraph)
surf(Xg,Yg,Anomaly)
view(0,90)
shading interp
[row,col]=size(Anomaly);
if(get(popupColorDist,'Value')==1)
    cmapChanged = colormaps(reshape(Anomaly,[row*col,1]),'clra','linear');
    colormap(cmapChanged)
else
    cmapChanged = colormaps(reshape(Anomaly,[row*col,1]),'clra','equalized');
    colormap(cmapChanged)
end
xlabel('Easting (m)')
ylabel('Northing (m)')
zlabel('Anomaly Magnitude')
if(strcmp(get(hObject,'Tag'),'Grav'))
    title('Gravimetric Anomaly')
else
    if(get(magComp,'Value')==1)
        title('Magnetic Anomaly - B_x component')
    elseif(get(magComp,'Value')==2)
        title('Magnetic Anomaly - B_y component')
    else
        title('Magnetic Anomaly - B_z component')
    end
end
set(anomalyGraph,'FontSize',17)
axis image
xlim([min(Xg(:)) max(Xg(:))])
ylim([min(Yg(:)) max(Yg(:))])
set(anomalyGraph,'Box','on')
grid on

handles.Xg = Xg;
handles.Yg = Yg;
handles.Anomaly = Anomaly;
%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function saveAnomaly_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);
Xg = handles.Xg;
Yg = handles.Yg;
inputFile = handles.Anomaly;

outputFile = matrix2xyz(Xg,Yg,inputFile);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

fid = fopen(Fullpath,'w+');
fprintf(fid,'%6s %6s %14s\r\n','X','Y','Anomaly');
fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(hObject,handles);
end

end