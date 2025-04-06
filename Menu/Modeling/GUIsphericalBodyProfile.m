function GUIsphericalBodyProfile

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIsphericalBodyProfile_ = figure('Menubar','none',...
    'Name','Two-Dimension Forward Modeling of Spherical Body',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

optionPanel = uipanel(GUIsphericalBodyProfile_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

Xo_ = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Initial profile value in meters.',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.925 0.3 0.036]);

Xf_ = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Final profile value in meters.',...
    'units','normalized',...
    'String','5000',...
    'fontUnits','normalized',...
    'position',[0.35 0.925 0.3 0.036]);

stations_ = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Number of stations.',...
    'units','normalized',...
    'String','500',...
    'fontUnits','normalized',...
    'position',[0.67 0.925 0.3 0.036]);

coordX = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','X coordinate of center of spherical body in meters.',...
    'units','normalized',...
    'String','2500',...
    'fontUnits','normalized',...
    'position',[0.03 0.875 0.46 0.036]);

coordZ = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Z coordinate of center of spherical body in meters.',...
    'units','normalized',...
    'String','200',...
    'fontUnits','normalized',...
    'position',[0.51 0.875 0.46 0.036]);

radius = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Spherical body radius in meters.',...
    'units','normalized',...
    'String','50',...
    'fontUnits','normalized',...
    'position',[0.03 0.825 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Display Model',...
    'fontUnits','normalized',...
    'Tag','Mag',...
    'position',[0.03 0.775 0.944 0.036],...
    'CallBack',@showModel_callBack);

magComp = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Bx','Bz','Bt'},...
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
    'position',[0.03 0.175 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Magnetic Anomaly',...
    'fontUnits','normalized',...
    'Tag','Mag',...
    'position',[0.03 0.125 0.944 0.036],...
    'CallBack',@computeAnomaly_callBack);

dens = uicontrol(optionPanel,'Style','edit',...
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
graphPanel = uipanel(GUIsphericalBodyProfile_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

sourcesGraph = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.07 0.1 0.88 0.38]);
set(sourcesGraph.XAxis,'Visible','off');
set(sourcesGraph.YAxis,'Visible','off');

anomalyGraph = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.07 0.57 0.88 0.38]);
set(anomalyGraph.XAxis,'Visible','off');
set(anomalyGraph.YAxis,'Visible','off');

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIsphericalBodyProfile_,'label','File');
uimenu(file,'Label','Save Profile...','Accelerator','P','CallBack',@saveProfile_callBack);

topo = uimenu(GUIsphericalBodyProfile_,'label','Topography');
uimenu(topo,'Label','Load Topography','Accelerator','T','CallBack',@loadTopo_callBack);

topoLoaded = 'n';
set(GUIsphericalBodyProfile_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%LOAD TOPOGRAPHY PROFILE
function loadTopo_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

data = importdata(Fullpath);

if (isstruct(data))
    dado = data.data;
    X = dado(:,1);
    Topo = dado(:,2);
else
    dado = data;
    X = dado(:,1);
    Topo = dado(:,2);
end

set(Xo_,'String',num2str(min(X)))
set(Xf_,'String',num2str(max(X)))
set(stations_,'String',num2str(length(X)))
set(coordX,'String',num2str((min(X)+max(X))/2))

handles.X = X;
handles.Topo = Topo;
topoLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%DISPLAY MODEL
function showModel_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

coordX_ = str2double(get(coordX,'String'));
coordZ_ = str2double(get(coordZ,'String'));
xo_ = str2double(get(Xo_,'String'));
xf_ = str2double(get(Xf_,'String'));
stations = str2double(get(stations_,'String'));
R = str2double(get(radius,'String'));

x_ = linspace(xo_,xf_,stations);

X_C=coordX_-R; Z_C=-coordZ_-R; D=R*2;

displayModel(X_C,Z_C,D)

if(topoLoaded == 'y')
    hold on
    x_ = handles.X;
    t_ = handles.Topo;
    plot(x_,t_,'-k')
    axis([min(x_) max(x_) Z_C+(0.1*Z_C) max(t_)*1.1])
else
    hold on
    width__ = max(x_)-min(x_);
    height__ = width__*208/906;
    
    plot(x_,zeros(size(x_)),'-k')
    axis([min(x_) max(x_) 10-height__ 10])
end

%Update de handle structure
guidata(hObject,handles);
end

%CALCULATE THE 2D (PROFILE) GRAVIMETRIC ANOMALY OF A SPHERICAL BODY
function computeAnomaly_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

xo_ = str2double(get(Xo_,'String'));
xf_ = str2double(get(Xf_,'String'));
stations = str2double(get(stations_,'String'));
x_ = linspace(xo_,xf_,stations);

coordX_ = str2double(get(coordX,'String'));
coordZ_ = str2double(get(coordZ,'String'));
R = str2double(get(radius,'String'));
Dens_ = str2double(get(dens,'String'));
Suscept_ = str2double(get(sucept_,'String'));
FieldStrength_ = str2double(get(fieldStrength_,'String'));
I = deg2rad(str2double(get(I_,'String')));

if(topoLoaded == 'y')
    t_ = handles.Topo;
    t_ = t_';
else
    t_ = zeros(size(x_));
end

G = 6.67408*(10^(-11));

Anom = zeros(1,length(x_));

if(strcmp(get(hObject,'Tag'),'Grav'))
    for y=1:length(x_)
        Anom(1,y) = 1/sqrt((x_(1,y)-coordX_)^2+(t_(1,y)-coordZ_)^2);
    end
    M = (10^5)*(4/3)*pi*G*(R^3)*Dens_;
else
    if(get(magComp,'Value')==1)
        for y=1:length(x_)
            x__ = x_(1,y)-coordX_;
            z__ = t_(1,y)-coordZ_;
            r_ = sqrt(x__^2+z__^2);
            Anom(1,y) = (1/r_^5)*((2*x__^2-z__^2)*cos(I)-3*x__*z__*sin(I));
        end
    elseif(get(magComp,'Value')==2)
        for y=1:length(x_)
            x__ = x_(1,y)-coordX_;
            z__ = t_(1,y)-coordZ_;
            r_ = sqrt(x__^2+z__^2);
            Anom(1,y) = (1/r_^5)*((2*z__^2-x__^2)*sin(I)-3*x__*z__*cos(I));
        end
    else
        for y=1:length(x_)
            x__ = x_(1,y)-coordX_;
            z__ = t_(1,y)-coordZ_;
            r_ = sqrt(x__^2+z__^2);
            Anom(1,y) = (1/r_^5)*((3*cos(I)^2-1)*x__^2-6*x__*z__*sin(I)*cos(I)+(3*sin(I)^2-1)*z__^2);
        end
    end
    M = (4/3)*pi*(R^3)*FieldStrength_*Suscept_;
end

Anomaly = M*Anom;

axes(anomalyGraph)
plot(x_,Anomaly,'k','linewidth',1.5)
xlabel('Position (m)')
ylabel('Anomaly Magnitude')
set(anomalyGraph,'FontSize',12)
set(gca,'XLim',[min(x_),max(x_)])
grid on

X_C=coordX_-R; Z_C=-coordZ_-R; D=R*2;
displayModel(X_C,Z_C,D)

if(topoLoaded == 'y')
    hold on
    x_ = handles.X;
    t_ = handles.Topo;
    plot(x_,t_,'-k')
    axis([min(x_) max(x_) Z_C+(0.1*Z_C) max(t_)*1.1])
else
    hold on
    width__ = max(x_)-min(x_);
    height__ = width__*208/906;
    
    plot(x_,zeros(size(x_)),'-k')
    axis([min(x_) max(x_) 10-height__ 10])
end

handles.Anomaly=Anomaly;
handles.x_=x_;
%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH
function saveProfile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);
x_p = handles.x_p;
x_p = x_p';
inputFile = handles.Anomaly;
inputFile = inputFile';

outputFile = cat(2,x_p,inputFile);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return;
end

set(outputFile_path_p,'String',num2str(Fullpath))

fid = fopen(Fullpath,'w+');
fprintf(fid,'%8s %8s\r\n','X','Sphere_grav');
fprintf(fid,'%6.2f %12.8e\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(hObject,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function displayModel(X_C,Z_C,D)
    axes(sourcesGraph)
    
    h = findobj(gca,'type','rectangle');
    if(~isempty(h))
        delete(h)
    end
    
    rectangle('Position',[X_C,Z_C,D,D],...
        'Curvature',[1 1],'facecolor',[.5 .5 .5])
    xlabel('Position (m)')
    ylabel('Depth (m)')
    grid on
    set(get(sourcesGraph,'XAxis'),'Visible','on');
    set(get(sourcesGraph,'YAxis'),'Visible','on');
    set(sourcesGraph,'Box','on')
    set(sourcesGraph,'FontSize',12)
end

end