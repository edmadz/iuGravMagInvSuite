function GUIfaultModel

clc
clear
warning('off','all')

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIfaultModel_ = figure('Name','2D Contact Model Forward Modeling',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

%--------------------------------------------------------------------------

parameters = uipanel(GUIfaultModel_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

MinX = uicontrol(parameters,'Style','edit',...
    'TooltipString','Minimum value of the horizontal extent.',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.93 0.944 0.036]);

MaxX = uicontrol(parameters,'Style','edit',...
    'TooltipString','Maximum value of the horizontal extent.',...
    'units','normalized',...
    'String','1000',...
    'fontUnits','normalized',...
    'position',[0.03 0.88 0.944 0.036]);

Station = uicontrol(parameters,'Style','edit',...
    'TooltipString','Number of stations.',...
    'units','normalized',...
    'String','500',...
    'fontUnits','normalized',...
    'position',[0.03 0.83 0.944 0.036]);

CoordX = uicontrol(parameters,'Style','edit',...
    'TooltipString','Horizontal coordinate of the dyke.',...
    'units','normalized',...
    'String','500',...
    'fontUnits','normalized',...
    'position',[0.03 0.78 0.944 0.036]);

CoordZ1 = uicontrol(parameters,'Style','edit',...
    'TooltipString','Depth to the top of the contact.',...
    'units','normalized',...
    'String','100',...
    'fontUnits','normalized',...
    'position',[0.03 0.73 0.944 0.036]);

CoordZ2 = uicontrol(parameters,'Style','edit',...
    'TooltipString','Depth to the bottom of the contact.',...
    'units','normalized',...
    'String','200',...
    'fontUnits','normalized',...
    'position',[0.03 0.68 0.944 0.036]);

dip_ = uicontrol(parameters,'Style','edit',...
    'TooltipString','Dip.',...
    'units','normalized',...
    'String','90',...
    'fontUnits','normalized',...
    'position',[0.03 0.63 0.944 0.036]);

strike_ = uicontrol(parameters,'Style','edit',...
    'TooltipString','Strike.',...
    'units','normalized',...
    'String','90',...
    'fontUnits','normalized',...
    'position',[0.03 0.58 0.944 0.036]);

H = uicontrol(parameters,'Style','edit',...
    'TooltipString','Stregth of geomagnetic field.',...
    'units','normalized',...
    'String','23000',...
    'fontUnits','normalized',...
    'position',[0.03 0.53 0.944 0.036]);

I_e = uicontrol(parameters,'Style','edit',...
    'TooltipString','Field inclination.',...
    'units','normalized',...
    'String','90',...
    'fontUnits','normalized',...
    'position',[0.03 0.48 0.944 0.036]);

k = uicontrol(parameters,'Style','edit',...
    'TooltipString','Susceptibility contrast.',...
    'units','normalized',...
    'String','0.0276',...
    'fontUnits','normalized',...
    'position',[0.03 0.43 0.944 0.036]);

% uicontrol(parameters,'Style','pushbutton',...
%     'units','normalized',...
%     'String','Show 3D Plan View',...
%     'fontUnits','normalized',...
%     'position',[0.03 0.13 0.944 0.036],...
%     'CallBack',@planView_callBack);

uicontrol(parameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Calculate the Magnetic Anomaly',...
    'fontUnits','normalized',...
    'position',[0.03 0.08 0.944 0.036],...
    'CallBack',@MagAnom_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIfaultModel_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graphAnomaly = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.07 0.55 0.88 0.4]);
set(graphAnomaly.XAxis,'Visible','off');
set(graphAnomaly.YAxis,'Visible','off');

graphSources = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.07 0.1 0.88 0.35]);
set(graphSources.XAxis,'Visible','off');
set(graphSources.YAxis,'Visible','off');

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIfaultModel_,'label','File');

uimenu(file,'Label','Save Anomaly...','Accelerator','S','CallBack',@saveFile_callBack);

anomalyGenerated = 'n';
h_1=[];
h_2=[];
h_3=[];
set(GUIfaultModel_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%CALCULATE THE MAGNETIC ANOMALY OF FAULT MODEL
function MagAnom_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

x0 = str2double(get(MinX,'String'));
xf = str2double(get(MaxX,'String'));
stations = str2double(get(Station,'String'));
X = str2double(get(CoordX,'String'));
Z_1 = str2double(get(CoordZ1,'String'));
Z_2 = str2double(get(CoordZ2,'String'));
dip = deg2rad(str2double(get(dip_,'String')));
theta = dip-deg2rad(180);
alpha = deg2rad(str2double(get(strike_,'String')));
H_ = str2double(get(H,'String'));
H_ = (H_*(10^(7)))/(4*pi*(10^(10)));
phi = degtorad(str2double(get(I_e,'String')));
i = 90;
k_ = str2double(get(k,'String'));

x = linspace(x0,xf,stations);
n = length(x);

J = H_/k_; %Intensity of effective magnetization
J_ = J*sqrt(1-((cos(alpha))^2)*(cos(i))^2); 

phi_ = phi-atan(sin(alpha)*cot(i));

for x_=1:n
    if(Z_1==0 && X==0)
        theta_1 = pi/2;
    elseif(Z_1==0 && X~=0)
        theta_1 = (pi/2)*(1+((X-x(x_))/abs(X-x(x_))));
    else
        theta_1 = (pi/2)+atan((X-x(x_))/Z_1);
    end
    theta_2 = (pi/2)+atan(((X-x(x_))+((Z_2-Z_1)*cot(theta)))/Z_2);
    r_1 = sqrt((X-x(x_))^2+(Z_1)^2);
    r_2 = sqrt(((X-x(x_))+(Z_2-Z_1)*cot(theta))^2+(Z_2)^2);
    delta_T(x_) = 2*J_*sin(theta)*(cos(theta+phi_)*(theta_1-theta_2)+sin(theta+phi_)*log(r_2/r_1));
end

axes(graphAnomaly)
plot(x,delta_T,'k','LineWidth',1.5)
xlabel('Profile Direction')
ylabel('Magnetic Anomaly [nT]')
set(gca,'FontSize',12)

x_extent = max(x)-min(x);
thikness = Z_2-Z_1;
x_f_left=[X-(thikness/tan(dip)),X-2*(thikness/tan(dip)),X-(10000*x_extent),X-(10000*x_extent)];
y_f_left=[-Z_2,-Z_2-thikness,-Z_2-thikness,-Z_2];

coefficients = polyfit([X-(thikness/tan(dip)),X-2*(thikness/tan(dip))],[-Z_2,-Z_2-thikness],1);
a = coefficients(1);
b = coefficients(2);
if(a>10^15) % vertical fault
    x_f=[X X];
    y_f=[-100000 0];
else
    y_f=[-100000 0];
    x_f=[(-100000-b)/a (0-b)/a];
end

x_f_right=[X,X+(10000*x_extent),X+(10000*x_extent),X-(thikness/tan(dip))];
y_f_right=[-Z_1,-Z_1,-Z_2,-Z_2];
axes(graphSources)
if(~isempty(h_1))
    delete(h_1)
    delete(h_2)
    delete(h_3)
end
h_1=patch(x_f_right,y_f_right,[.5 .5 .5]); hold on
h_2=patch(x_f_left,y_f_left,[.5 .5 .5]);
h_3=line(x_f,y_f,'Color','red','LineStyle','--','LineWidth',1.5);
hold off
xlabel('Profile Direction')
ylabel('Depth [m]')
legend([h_1,h_3],'Faulted Horizon','Fault Plane')
xlim([min(x) max(x)])
ylim([1.5*(-Z_2-thikness) 0])
set(gca,'FontSize',12)

set(graphSources.XAxis,'Visible','on');
set(graphSources.YAxis,'Visible','on');
set(gca,'Box','on')

handles.delta_T = delta_T;
handles.DimX = x;
anomalyGenerated = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function saveFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(anomalyGenerated=='y')
    DimX = handles.DimX;
    DimX = DimX';
    inputFile = handles.delta_T;
    inputFile = inputFile';
    
    outputFile = cat(2,DimX,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return;
    end
    
    outputFile_path.String=num2str(Fullpath);
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%8s %8s\r\n','X','Dique_mag');
    fprintf(fid,'%6.2f %12.8e\r\n',transpose(outputFile));
    fclose(fid);
else
    msgbox('Generate the magnetic anomaly before trying to save the output file.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

end