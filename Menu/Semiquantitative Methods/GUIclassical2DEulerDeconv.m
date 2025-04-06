function GUIclassical2DEulerDeconv

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIclassical2DEulerDeconv_ = figure('Menubar','none',...
    'Name','2D Standard Euler Deconvolution',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------

parameters = uipanel(GUIclassical2DEulerDeconv_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

N = uicontrol(parameters,'Style','edit',...
    'TooltipString','Structural index.',...
    'Units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.03 0.925 0.944 0.036]);

WS = uicontrol(parameters,'Style','edit',...
    'TooltipString','Window size.',...
    'Units','normalized',...
    'String','10',...
    'fontUnits','normalized',...
    'position',[0.03 0.875 0.944 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','Perform Euler Deconvolution',...
    'fontUnits','normalized',...
    'position',[0.03 0.825 0.944 0.036],...
    'Callback',@bidimensionalEulerDeconv_callback);

showWindow = uicontrol(parameters,'Style','togglebutton',...
    'Units','normalized',...
    'String','Show Window Location',...
    'fontUnits','normalized',...
    'Value',0,...
    'tooltipstring','Display the data window over the anomaly profile.',...
    'position',[0.03 0.775 0.944 0.036],...
    'Callback',@showWindowLocation_callback);

moveLeft = uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','<',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.03 0.725 0.45 0.036],...
    'Callback',@moveWindowToLeft_callback);

moveRight = uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','>',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.52 0.725 0.45 0.036],...
    'Callback',@moveWindowToRight_callback);

uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','Show Derivative Components',...
    'fontUnits','normalized',...
    'position',[0.03 0.675 0.944 0.036],...
    'Callback',@showDerivativeComponents_callback);

minY_anomalyGraph = uicontrol(parameters,'Style','edit',...
    'Units','normalized',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.03 0.375 0.45 0.036],...
    'Callback',@moveWindowToLeft_callback);

maxY_anomalyGraph = uicontrol(parameters,'Style','edit',...
    'Units','normalized',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.52 0.375 0.45 0.036],...
    'Callback',@moveWindowToRight_callback);

uicontrol(parameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Update Limits',...
    'fontUnits','normalized',...
    'position',[0.03 0.325 0.944 0.036],...
    'Callback',@applyLimits2AnomalyGraph_callback);

minY_eulerGraph = uicontrol(parameters,'Style','edit',...
    'Units','normalized',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.03 0.275 0.45 0.036]);

maxY_eulerGraph = uicontrol(parameters,'Style','edit',...
    'Units','normalized',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.52 0.275 0.45 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Update Limits',...
    'fontUnits','normalized',...
    'position',[0.03 0.225 0.944 0.036],...
    'Callback',@applyLimits2EulerGraph_callback);

imageFileFormat = uicontrol(parameters,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'png','jpeg','jpg','tiff'},...
    'fontUnits','normalized',...
    'TooltipString','Image file format.',...
    'position',[0.03 0.165 0.944 0.036]);

DPI_=uicontrol(parameters,'Style','edit',...
    'units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'TooltipString','Dots per inch.',...
    'position',[0.03 0.115 0.944 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Export Workspace as Image',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'CallBack',@exportWorkspaceAsImage_callBack);
%--------------------------------------------------------------------------
graphPanel = uipanel(GUIclassical2DEulerDeconv_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

AnomProfile = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.56 0.88 0.39]);

eulerSolutionsProfile = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.08 0.88 0.39]);

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIclassical2DEulerDeconv_,'label','File');
uimenu(file,'Label','Load profile...','Accelerator','O','CallBack',@loadProfile_callBack);
uimenu(file,'Label','Save solutions...','Accelerator','S','CallBack',@saveFile_callBack);
uimenu(file,'Label','Reset graphs','Accelerator','R','Separator','on',...
    'CallBack',@resetGraphs_callBack);

elevation = uimenu(GUIclassical2DEulerDeconv_,'label','Elevation');
uimenu(elevation,'Label','Load topography...','Accelerator','T','CallBack',@loadTopo_callBack);
uimenu(elevation,'Label','Load gps altimetry...','Accelerator','D','CallBack',@loadGPSalt_callBack);

dataLoaded = 'n';
eulerPerformed = 'n';
topoLoaded = 'n';
gpsAltLoaded = 'n';
set(GUIclassical2DEulerDeconv_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%LOAD THE DATA PROFILE
function loadProfile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[X,profile]=loadProfileEulerDeconvolution(Fullpath);

%Find the sample rate
step = X(2)-X(1);

axes(AnomProfile)
anomaly = plot(X,profile,'-k','linewidth',2);
xlim([min(X) max(X)])
if(min(profile)<0 && max(profile)<0)
    ylim([min(profile)+min(profile)*0.05 max(profile)-max(profile)*0.5])
elseif(min(profile)<0 && max(profile)>0)
    ylim([min(profile)+min(profile)*0.05 max(profile)+max(profile)*0.5])
elseif(min(profile)>0 && max(profile)>0)
    ylim([min(profile)-min(profile)*0.05 max(profile)+max(profile)*0.5])
end
set(AnomProfile,'XGrid','on')
set(AnomProfile,'YGrid','on')
set(AnomProfile,'fontSize',12)
xlabel('Position (m)')
ylabel('Anomaly Magnitude')

yl = get(AnomProfile,'YLim');
set(minY_anomalyGraph,'String',num2str(yl(1)))
set(maxY_anomalyGraph,'String',num2str(yl(2)))
set(minY_anomalyGraph,'Enable','on')
set(maxY_anomalyGraph,'Enable','on')

handles.step = step;
handles.X = X;
handles.profile = profile;
handles.FileName = FileName;
handles.anomaly = anomaly;
dataLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%LOAD THE TOPOGRAPHY PROFILE
function loadTopo_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Load Topography...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[X,topo]=loadProfileEulerDeconvolution(Fullpath);

topoPlot = findobj(eulerSolutionsProfile,'Tag','topo');
if(~isempty(topoPlot))
    delete(topoPlot)
end

if(gpsAltLoaded=='y')
    axes(eulerSolutionsProfile)
    hold on
    plot(X,topo,'-k','linewidth',2,'Tag','topo');
    xlabel('Position (m)')
    ylabel('Depth (m)')
    set(eulerSolutionsProfile,'XGrid','on')
    set(eulerSolutionsProfile,'YGrid','on')
    set(eulerSolutionsProfile,'Box','on')
    set(eulerSolutionsProfile,'fontSize',12)
    set(eulerSolutionsProfile,'XLim',[min(X) max(X)])
    set(eulerSolutionsProfile,'YLim',[-500 max(topo)*1.2])
else
    axes(eulerSolutionsProfile)
    plot(X,topo,'-k','linewidth',2,'Tag','topo');
    xlabel('Position (m)')
    ylabel('Depth (m)')
    set(eulerSolutionsProfile,'XGrid','on')
    set(eulerSolutionsProfile,'YGrid','on')
    set(eulerSolutionsProfile,'Box','on')
    set(eulerSolutionsProfile,'fontSize',12)
    set(eulerSolutionsProfile,'XLim',[min(X) max(X)])
    set(eulerSolutionsProfile,'YLim',[-500 max(topo)*1.2])
    hold on
    plot(X,zeros(size(X)),'b--')
    hold off
end

yl = get(eulerSolutionsProfile,'YLim');
set(minY_eulerGraph,'String',num2str(yl(1)))
set(maxY_eulerGraph,'String',num2str(yl(2)))
set(minY_eulerGraph,'Enable','on')
set(maxY_eulerGraph,'Enable','on')

handles.topo = topo;
topoLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%LOAD DRAPE PROFILE
function loadGPSalt_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Load gps altimetry...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[X,gpsAlt]=loadProfileEulerDeconvolution(Fullpath);

gpsPlot = findobj(eulerSolutionsProfile,'Tag','gps');
if(~isempty(gpsPlot))
    delete(gpsPlot)
end

if(topoLoaded=='y')
    axes(eulerSolutionsProfile)
    hold on
    plot(X,gpsAlt,'--b','linewidth',2,'Tag','gps')
    xlabel('Position (m)')
    ylabel('Depth (m)')
    set(gca,'XGrid','on')
    set(gca,'YGrid','on')
    set(gca,'Box','on')
    set(gca,'fontSize',12)
    set(eulerSolutionsProfile,'XLim',[min(X) max(X)])
    set(eulerSolutionsProfile,'YLim',[-500 max(gpsAlt)*1.2])
else
    axes(eulerSolutionsProfile)
    plot(X,gpsAlt,'--b','linewidth',2,'Tag','gps')
    xlabel('Position (m)')
    ylabel('Depth (m)')
    set(gca,'XGrid','on')
    set(gca,'YGrid','on')
    set(gca,'Box','on')
    set(gca,'fontSize',12)
    set(eulerSolutionsProfile,'XLim',[min(X) max(X)])
    set(eulerSolutionsProfile,'YLim',[-500 max(gpsAlt)*1.2])
    hold on
    plot(X,zeros(size(X)),'b--')
    hold off
end

yl = get(eulerSolutionsProfile,'YLim');
set(minY_eulerGraph,'String',num2str(yl(1)))
set(maxY_eulerGraph,'String',num2str(yl(2)))
set(minY_eulerGraph,'Enable','on')
set(maxY_eulerGraph,'Enable','on')

handles.gpsAlt = gpsAlt;
gpsAltLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%RESET GRAPHS
function resetGraphs_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

L = findobj(gca,'Type','line');
if(~isempty(L))
    delete(L)
end

S = findobj(gca,'Type','scatter');
if(~isempty(S))
    delete(S)
end

set(gca,'XLim',[0 1])
set(gca,'YLim',[0 1])
xlabel(gca,'')
ylabel(gca,'')

set(minY_anomalyGraph,'String','')
set(maxY_anomalyGraph,'String','')
set(minY_anomalyGraph,'Enable','off')
set(maxY_anomalyGraph,'Enable','off')
set(minY_eulerGraph,'String','')
set(maxY_eulerGraph,'String','')
set(minY_eulerGraph,'Enable','off')
set(maxY_eulerGraph,'Enable','off')

topoLoaded = 'n';
gpsAltLoaded = 'n';

%Update de handle structure
guidata(hObject,handles);
end

%CHANGE THE VERTICAL LIMITS OF THE ANOMALY GRAPH
function applyLimits2AnomalyGraph_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    yl_min = str2double(get(minY_anomalyGraph,'String'));
    yl_max = str2double(get(maxY_anomalyGraph,'String'));
    
    set(AnomProfile,'YLim',[yl_min,yl_max])
else
    msgbox('Load some data before trying to the vertical limits of the anomaly graph.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%CHANGE THE VERTICAL LIMITS OF THE EULER GRAPH
function applyLimits2EulerGraph_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    yl_min = str2double(get(minY_eulerGraph,'String'));
    yl_max = str2double(get(maxY_eulerGraph,'String'));
    
    set(eulerSolutionsProfile,'YLim',[yl_min,yl_max])
else
    msgbox('Load some data before trying to the vertical limits of the anomaly graph.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW THE WINDOW LOCATION
function showWindowLocation_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed == 'y')
    step = handles.step;
    X = handles.X;
    profile = handles.profile;
    anomaly = handles.anomaly;
    xEul = handles.xEul;
    zEul = handles.zEul;
    
    WS_ = str2double(get(WS,'String'));
    
    if(topoLoaded=='y')
        topo = handles.topo;
    end
    
    if(gpsAltLoaded=='y')
        gpsAlt = handles.gpsAlt;
    end
    
    if(get(showWindow,'Value')==1)
        set(moveLeft,'Enable','on')
        set(moveRight,'Enable','on')
    else
        set(moveLeft,'Enable','off')
        set(moveRight,'Enable','off')
    end
    
    %Build the window
    x_window = linspace(min(X),(min(X)+(WS_-1)*step),WS_);
    if(max(profile)>0)
        y_window = (max(profile)+(0.25)*max(profile))*ones(1,WS_);
    elseif(max(profile)<0)
        y_window = (max(profile)-(0.25)*max(profile))*ones(1,WS_);
    end
    axes(AnomProfile)
    delete(anomaly)
    anomaly = plot(X,profile,'-k','linewidth',2);
    xlabel('Position (m)')
    ylabel('Anomaly Magnitude')
    set(AnomProfile,'fontsize',12)
    hold on
    WL = scatter(x_window,y_window,4,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0]);
    xlim([min(X) max(X)])
    if(min(profile)<0 && max(profile)<0)
        ylim([min(profile)+min(profile)*0.05 max(profile)-max(profile)*0.5])
    elseif(min(profile)<0 && max(profile)>0)
        ylim([min(profile)+min(profile)*0.05 max(profile)+max(profile)*0.5])
    elseif(min(profile)>0 && max(profile)>0)
        ylim([min(profile)-min(profile)*0.05 max(profile)+max(profile)*0.5])
    end
    set(AnomProfile,'XGrid','on')
    set(AnomProfile,'YGrid','on')
    hold off
    
    if(get(showWindow,'Value') == 0)
        axes(AnomProfile)
        WL = findobj('type','scatter');
        WL = WL(1);
        delete(WL)
        singleSolution = findobj(eulerSolutionsProfile,'type','scatter');
        delete(singleSolution)
        
        axes(eulerSolutionsProfile)
        if(topoLoaded=='y')
            plot(X,topo,'-k','linewidth',2); hold on
            plot(X,gpsAlt,'--b','linewidth',2)
            plot(X,zeros(size(X)),'b--'); hold off
        end
        hold on
        scatter(xEul,zEul,20,'ko','filled');
        hold off
        xlim([min(X) max(X)]);
        if(topoLoaded=='y')
            ylim([-500 max(gpsAlt).*1.2])
        else
            ylim([min(zEul) 0])
        end
        xlabel('Position (m)')
        ylabel('Depth (m)')
        set(eulerSolutionsProfile,'fontsize',12)
        set(eulerSolutionsProfile,'XGrid','on')
        set(eulerSolutionsProfile,'YGrid','on')
    end
    
    W_loc = 1;
    handles.W_loc = W_loc;
    handles.anomaly = anomaly;
    handles.x_window = x_window;
    handles.y_window = y_window;
    handles.WL = WL;
else
    msgbox('Compute the euler solutions before trying to show the window.','Warn','warn')
    set(showWindow,'Value',1)
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%MOVE THE WINDOW LOCATION TO THE RIGHT
function moveWindowToRight_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed=='y')
    x_window = handles.x_window;
    y_window = handles.y_window;
    xEul = handles.xEul;
    zEul = handles.zEul;
    WL = handles.WL;
    X = handles.X;
    profile = handles.profile;
    step = handles.step;
    anomaly = handles.anomaly;
    W_loc = handles.W_loc;
    
    if(x_window(end)<max(X))
        x_window = x_window+step;
    else
        return
    end
    
    delete(WL)
    delete(anomaly)
    axes(AnomProfile)
    anomaly = plot(X,profile,'-k','linewidth',2);
    xlabel('Position (m)')
    ylabel('Anomaly Magnitude')
    set(AnomProfile,'fontsize',12)
    hold on
    WL = scatter(x_window,y_window,4,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0]);
    xlim([min(X) max(X)])
    if(min(profile)<0 && max(profile)<0)
        ylim([min(profile)+min(profile)*0.05 max(profile)-max(profile)*0.5])
    elseif(min(profile)<0 && max(profile)>0)
        ylim([min(profile)+min(profile)*0.05 max(profile)+max(profile)*0.5])
    elseif(min(profile)>0 && max(profile)>0)
        ylim([min(profile)-min(profile)*0.05 max(profile)+max(profile)*0.5])
    end
    set(AnomProfile,'XGrid','on')
    set(AnomProfile,'YGrid','on')
    hold off
    
    %----------------
    if(W_loc<=length(profile))
        W_loc = W_loc + 1;
    else
        return
    end
    
    axes(eulerSolutionsProfile)
    hold on
    scatter(xEul(W_loc),zEul(W_loc),'ro','LineWidth',0.6)
    set(eulerSolutionsProfile,'XGrid','on')
    set(eulerSolutionsProfile,'YGrid','on')
    hold off
    %----------------
    
    handles.anomaly = anomaly;
    handles.x_window = x_window;
    handles.y_window = y_window;
    handles.WL = WL;
    handles.W_loc = W_loc;
else
    msgbox('Perform the euler deconvolution before try to move the window.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%MOVE THE WINDOW LOCATION TO THE LEFT
function moveWindowToLeft_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed=='y')
    x_window = handles.x_window;
    y_window = handles.y_window;
    xEul = handles.xEul;
    zEul = handles.zEul;
    WL = handles.WL;
    X = handles.X;
    profile = handles.profile;
    step = handles.step;
    anomaly = handles.anomaly;
    W_loc = handles.W_loc;
    
    if(x_window(1)==min(X))
        return
    else
        x_window = x_window-step;
    end
    
    delete(WL)
    delete(anomaly)
    axes(AnomProfile)
    anomaly = plot(X,profile,'-k','linewidth',2);
    xlabel('Profile Direction [m]')
    ylabel('Anomaly Magnitude')
    set(AnomProfile,'fontsize',12)
    hold on
    WL = scatter(x_window,y_window,4,'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[0 0 0]);
    xlim([min(X) max(X)])
    if(min(profile)<0 && max(profile)<0)
        ylim([min(profile)+min(profile)*0.05 max(profile)-max(profile)*0.5])
    elseif(min(profile)<0 && max(profile)>0)
        ylim([min(profile)+min(profile)*0.05 max(profile)+max(profile)*0.5])
    elseif(min(profile)>0 && max(profile)>0)
        ylim([min(profile)-min(profile)*0.05 max(profile)+max(profile)*0.5])
    end
    set(AnomProfile,'XGrid','on')
    set(AnomProfile,'YGrid','on')
    hold off
    
    %----------------
    if(W_loc>=1)
        W_loc = W_loc - 1;
    else
        return
    end
    
    axes(eulerSolutionsProfile)
    hold on
    scatter(xEul(W_loc),zEul(W_loc),'go','LineWidth',0.6)
    set(eulerSolutionsProfile,'XGrid','on')
    set(eulerSolutionsProfile,'YGrid','on')
    hold off
    %----------------
    
    handles.anomaly = anomaly;
    handles.x_window = x_window;
    handles.y_window = y_window;
    handles.WL = WL;
    handles.W_loc = W_loc;
else
    msgbox('Perform the euler deconvolution before try to move the window.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW THE DERIVATIVE COMPONENTES
function showDerivativeComponents_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    X = handles.X;
    profile = handles.profile;
    
    Mx = difference1D(X',profile');
    [~,Mz] = differentiate1D(X',profile');
    
    figWidth__=1100;
    figHeight__=450;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('NumberTitle','off','Name','Depth Solution Histogram',...
        'units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    subplot(2,1,1)
    plot(X,Mx,'-k','linewidth',2);
    xlim([min(X) max(X)])
    ylim([min(Mx)*1.5 max(Mx)*1.5])
    set(gca,'XGrid','on')
    set(gca,'YGrid','on')
    title('X Derivative Component')
    xlabel('Position (m)')
    subplot(2,1,2)
    plot(X,Mz,'-k','linewidth',2);
    xlim([min(X) max(X)])
    ylim([min(Mz)*1.5 max(Mz)*1.5])
    set(gca,'XGrid','on')
    set(gca,'YGrid','on')
    title('Z Derivative Component')
    xlabel('Position (m)')
else
   msgbox('Load some data before trying to display the magnetic profile data derivatives.','Warn','warn','modal')
   return
end

%Update de handle structure
guidata(hObject,handles);
end

%PERFORM THE 2D EULER DECONVOLUTION
function bidimensionalEulerDeconv_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    X = handles.X;
    profile = handles.profile;
    
    N_ = str2double(get(N,'String'));
    WS_ = str2double(get(WS,'String'));
    
    if(topoLoaded=='y' && gpsAltLoaded=='y')
        topo = handles.topo;
        gpsAlt = handles.gpsAlt;
    elseif(gpsAltLoaded=='y')
        gpsAlt = handles.gpsAlt;
    elseif(topoLoaded=='y')
        topo = handles.topo;
    end
    
    set(showWindow,'Value',0)
    
    Mx = difference1D(X',profile');
    Mx = Mx';
    [~,Mz] = differentiate1D(X',profile');
    Mz = Mz';
    
    xEul = zeros(size(Mx));
    zEul = zeros(size(Mz));
    B = zeros(size(Mz));
    
    NN = N_*ones(ceil(WS_),1);
    n = length(X);
    
    for x_ = 1:n-WS_+1
        iw = x_:x_+WS_-1;
        
        A = [Mx(iw) Mz(iw) NN];
        d = X(iw).*Mx(iw) + N_.*profile(iw);
        sol = A\d;
        
        xEul(x_) = sol(1);
        zEul(x_) = sol(2);
        B(x_) = sol(2);
    end
    
    %Discount the flyght heigh
    if(gpsAltLoaded=='y')
        gpsAlt = handles.gpsAlt;
        measuringHeight = interp1(X,gpsAlt,xEul);
        zEul = measuringHeight-zEul;
    elseif(topoLoaded=='y')
        topo = handles.topo;
        measuringHeight = interp1(X,topo,xEul);
        zEul = measuringHeight-zEul;
    else
        zEul = -zEul;
    end
    
    %Delete the solutions above the topography surface
    if(topoLoaded=='y')
        X_topo_polygon = [X;X(end);X(1)];
        Z_topo_polygon = [topo;min(zEul);min(zEul)];
        
        in = inpolygon(xEul,zEul,X_topo_polygon,Z_topo_polygon);
        
        xEul = xEul(in);
        zEul = zEul(in);
    else
        xEul(zEul>0)=[];
        zEul(zEul>0)=[];
    end
    
    axes(eulerSolutionsProfile)
    m_=findobj('type','scatter'); delete(m_)
    hold on
    scatter(xEul,zEul,20,'ko','filled')
    colormap jet
    set(gca,'Box','on')
    hold off
    xlim([min(X) max(X)]);
    if(topoLoaded=='y')
        ylim([-500 max(gpsAlt).*1.2])
    else
        ylim([min(zEul) 0])
    end
    xlabel('Position (m)')
    ylabel('Depth (m)')
    set(eulerSolutionsProfile,'fontsize',12)
    set(eulerSolutionsProfile.XAxis,'Visible','on');
    set(eulerSolutionsProfile.YAxis,'Visible','on');
    set(eulerSolutionsProfile,'XGrid','on')
    set(eulerSolutionsProfile,'YGrid','on')
    
    handles.xEul = xEul;
    handles.zEul = zEul;
    handles.B = B;
    eulerPerformed = 'y';
else
    msgbox('Load some data before trying to perform the Euler deconvolution.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH
function saveFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);
xEul = handles.xEul;
zEul = handles.zEul;
B = handles.B;

outputFile = cat(2,xEul,zEul);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

fid = fopen(Fullpath,'w+');
fprintf(fid,'%6s %6s\r\n','X','DEPTH');
fprintf(fid,'%12.4f %12.4f\r\n',outputFile');
fclose(fid);

%Update de handle structure
guidata(hObject,handles);
end

%EXPORT WORKSPACE AS IMAGE
function exportWorkspaceAsImage_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Save Image...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

msg=msgbox('Wait a moment!','Warn','warn');

format_=get(imageFileFormat,'String');
imageF = char(strcat('-d',format_(get(imageFileFormat,'Value'))));
dpi_ = strcat('-r',get(DPI_,'String'));
fName = strsplit(FileName,'.');
ImagePath = char(strcat(PathName,fName(1)));

map_width = 1030;
map_heigth = 736;
aspectX = map_width/map_width;
aspectY = map_heigth/map_width;

fig = figure('Position',[500,500,1000*aspectX,1000*aspectY],'Visible','off');
h = copyobj(graphPanel,fig);
set(h,'Position',[0.02 0.02 0.96 0.96],'BorderType','none')

print(fig,ImagePath,imageF,dpi_)
delete(fig)

delete(msg)
msgbox('Map Exported!','Warn','warn')

%Update de handle structure
guidata(hObject,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTION
%--------------------------------------------------------------------------

function [position,value]=loadProfileEulerDeconvolution(Fullpath)
    data = importdata(Fullpath);

    if (isstruct(data))
        dado = data.data;
        position = dado(:,1);
        value = dado(:,2);
    else
        dado = data;
        position = dado(:,1);
        value = dado(:,2);
    end
end

end