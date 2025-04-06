function GUIirregularCrossSectionBody

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIirregularCrossSectionBody_ = figure('Name','Forward Modeling of Irregular Cross-Section Body',...
    'Menubar','none',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Resize','on',...
    'Tag','GMFree');
%--------------------------------------------------------------------------

inputParameters = uipanel(GUIirregularCrossSectionBody_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

B_ = uicontrol(inputParameters,'Style','edit',...
    'TooltipString','Magnetic field intensity [nT].',...
    'units','normalized',...
    'String','57000',...
    'fontUnits','normalized',...
    'position',[0.03 0.955 0.944 0.036]);

table = uitable(inputParameters,...
    'units','normalized',...
    'Data','',...
    'ColumnEditable',true,...
    'Position',[0.03 0.64 0.94 0.3]);

anomMode = uicontrol(inputParameters,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Show Both Anomalies','Show Grav Anomaly','Show Mag Anomaly'},...
    'fontUnits','normalized',...
    'Value',1,...
    'position',[0.03 0.105 0.944 0.036],...
    'CallBack',@anomalyMode_callBack);

uicontrol(inputParameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Anomalies',...
    'fontUnits','normalized',...
    'position',[0.03 0.055 0.944 0.036],...
    'CallBack',@computeTheAnomalies_callBack);

%--------------------------------------------------------------------------

graphPanel = uipanel(GUIirregularCrossSectionBody_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

magAnomalyGraph = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.71 0.9 0.25]);

gravAnomalyGraph = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.395 0.9 0.25]);

modelGraph = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.08 0.9 0.25]);

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file_ = uimenu(GUIirregularCrossSectionBody_,'label','File');
uimenu(file_,'Label','Load Measured Data Profile...',...
    'Accelerator','O',...
    'CallBack',@OpenFile_callBack);
uimenu(file_,'Label','Save Manetic Anomaly Profile...',...
    'Accelerator','M','Separator','on',...
    'CallBack',@saveMag_callBack);
uimenu(file_,'Label','Save Gravity Anomaly Profile...',...
    'Accelerator','G',...
    'CallBack',@saveGrav_callBack);

Model_ = uimenu(GUIirregularCrossSectionBody_,'label','Model');
uimenu(Model_,'Label','Set Model Based on Data','CallBack',@setModelBasedOnData_callBack);
uimenu(Model_,'Label','Set Generic Model','CallBack',@setGenericModel_callBack);
tgbtn = uimenu(Model_,'Label','Show the Actual Borders of Model Limits',...
    'Separator','on','Checked','off',...
    'CallBack',@actualModelLim_callBack);

View_ = uimenu(GUIirregularCrossSectionBody_,'label','View');
uimenu(View_,'Label','Set View','CallBack',@setView_callBack);

MeasuredData_ = uimenu(GUIirregularCrossSectionBody_,'label','Measured Data');
uimenu(MeasuredData_,'Label','Load Measured Gravity Data...','CallBack',@loadMeasuredGrav_callBack);
uimenu(MeasuredData_,'Label','Load Measured Magnetic Data...','CallBack',@loadMeasuredMag_callBack);

topographicData_ = uimenu(GUIirregularCrossSectionBody_,'label','Topography');
uimenu(topographicData_,'Label','Load Topography...','CallBack',@loadTopo_callBack);

altmetricData_ = uimenu(GUIirregularCrossSectionBody_,'label','Altmetry');
uimenu(altmetricData_,'Label','Load Altmetry...','CallBack',@loadGPS_callBack);

%--------------------------------------------------------------------------
%UITOOLBAR
%--------------------------------------------------------------------------

currentPath = pwd;
whatPCPlatform = computer('arch');
whatPCPlatform = whatPCPlatform(1:3);
if(strcmp(whatPCPlatform,'win'))
    newBodyIcon = imread(strcat(currentPath,'\images\GM_Free\newBody.png'));
elseif(strcmp(whatPCPlatform,'gln'))
    newBodyIcon = imread(strcat(currentPath,'/images/GM_Free/newBody.png'));
end
stdToolbar = findall(GUIirregularCrossSectionBody_,'Type','uitoolbar');
uitoggletool(stdToolbar,'Separator','on',...
    'CData',newBodyIcon,...
    'State','off',...
    'TooltipString','New Body',...
    'ClickedCallback',@newBody_callBack);

dens_ = zeros(1);
suscept_ = zeros(1);
inc_ = zeros(1);
strike__ = zeros(1);
workspaceSet = 0;
topoLoaded = 0;
fpLoaded = 0;
plotGrav = 1;
plotMag = 1;

set(GUIirregularCrossSectionBody_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%LOAD MEASURED MAG
function loadMeasuredMag_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Choose one file');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

data = importdata(Fullpath);

if (isstruct(data))
    Data_ = data.data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_MAG = Data_(:,1);
        Z_MAG = Data_(:,2);
    end
else
    Data_ = data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_MAG = Data_(:,1);
        Z_MAG = Data_(:,2);
    end
end

%plot measured mag
axes(magAnomalyGraph)
scatter(X_MAG,Z_MAG,8,'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[1 0 0])
xlim([min(X_MAG) max(X_MAG)])
ylim([min(Z_MAG) max(Z_MAG)])

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%LOAD MEASURED GRAV
function loadMeasuredGrav_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

%Open a dialog box and store the data file path
[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Choose one file');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end
%Import the choosen data
data = importdata(Fullpath);
%Tests whether the data is a matrix or struct
if (isstruct(data))
    Data_ = data.data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_GRAV = Data_(:,1);
        Z_GRAV = Data_(:,2);
    end
else
    Data_ = data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_GRAV = Data_(:,1);
        Z_GRAV = Data_(:,2);
    end
end

%plot measured grav
axes(gravAnomalyGraph)
scatter(X_GRAV,Z_GRAV,8,'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[0 0 1])
xlim([min(X_GRAV) max(X_GRAV)])
ylim([min(Z_GRAV) max(Z_GRAV)])

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%LOAD TOPOGRAPHY
function loadTopo_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

%Open a dialog box and store the data file path
[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Choose one file');
Fullpath = [PathName FileName];
if (sum(Fullpath)== 0)
    return
end
%Import the choosen data
data = importdata(Fullpath);
%Tests whether the data is a matrix or struct
if (isstruct(data))
    Data_ = data.data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_TOPO = Data_(:,1);
        Z_TOPO = Data_(:,2);
    end
else
    Data_ = data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_TOPO = Data_(:,1);
        Z_TOPO = Data_(:,2);
    end
end

%Super sample the topography vector

%plot topography
axes(modelGraph)
plot(X_TOPO,Z_TOPO,'k-','linewidth',2)
hold on
plot(X_TOPO,Z_TOPO+30,'kv','MarkerSize',2)
xlim([min(X_TOPO) max(X_TOPO)])
plot([min(X_TOPO) max(X_TOPO)],[0 0],'g--')
ylim([-500 max(Z_TOPO)*2])
legend('Topography','Stations')
xlabel('Profile direction [meters]')
ylabel('Depth [meters]')
set(modelGraph,'XGrid','on')
set(modelGraph,'YGrid','on')
hold off

handles.X_TOPO = X_TOPO;
handles.Z_TOPO = Z_TOPO;
topoLoaded = 1;
fpLoaded = 0;
%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%LOAD GPS ALTIMETRY
function loadGPS_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

%Open a dialog box and store the data file path
[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Choose one file');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end
%Import the choosen data
data = importdata(Fullpath);
%Tests whether the data is a matrix or struct
if (isstruct(data))
    Data_ = data.data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_GPS = Data_(:,1);
        Z_GPS = Data_(:,2);
    end
else
    Data_ = data;
    [~,colData] = size(Data_);
    if(colData~=2)
        msgbox('The data you trying to open has more or less than two columns.','Warn','warn')
        return
    elseif(colData==2)
        X_GPS = Data_(:,1);
        Z_GPS = Data_(:,2);
    end
end

%plot GPS profile
axes(modelGraph)
plot(X_GPS,Z_GPS,'k--')
xlim([min(X_GPS) max(X_GPS)])
hold on
plot([min(X_GPS) max(X_GPS)],[0 0],'r--')
ylim([-500 max(Z_GPS)*2])

handles.X_GPS = X_GPS;
handles.Z_GPS = Z_GPS;
fpLoaded = 1;
topoLoaded = 0;
%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%SET MODEL BASED ON REAL DATA
function setModelBasedOnData_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

GUImodelBasedOnData



%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%SET GENERIC MODEL
function setGenericModel_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

GUIwsParameters
h = findobj(gcf,'Tag','WSparameters');
waitfor(h,'Visible','off')
if ~isempty(h)
    GUIwsParametersData = guidata(h);
    
    minX = GUIwsParametersData.minX;
    maxX = GUIwsParametersData.maxX;
    minY = GUIwsParametersData.minY;
    maxY = GUIwsParametersData.maxY;
    borderMinX = GUIwsParametersData.borderMinX;
    borderMaxX = GUIwsParametersData.borderMaxX;
    stations = GUIwsParametersData.stations;
    
    set(magAnomalyGraph,'XLim',[minX maxX])
    set(gravAnomalyGraph,'XLim',[minX maxX])
    set(modelGraph,'XLim',[borderMinX borderMaxX])
    
    plotGenericModel(minX,maxX,minY,maxY,stations)
    
    handles.minX = GUIwsParametersData.minX;
    handles.maxX = GUIwsParametersData.maxX;
    handles.minY = GUIwsParametersData.minY;
    handles.maxY = GUIwsParametersData.maxY;
    handles.stations = GUIwsParametersData.stations;
    handles.borderMinX = GUIwsParametersData.borderMinX;
    handles.borderMaxX = GUIwsParametersData.borderMaxX;
    
    workspaceSet = 1;
    deleteInvisibleGUI
end

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%SHOW THE ACTUAL HORIZONTAL LIMITS OF MODEL
function actualModelLim_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

if(strcmp(get(tgbtn,'Checked'),'off'))
    set(tgbtn,'Checked','on')
else
    set(tgbtn,'Checked','off')
end

if(strcmp(get(tgbtn,'Checked'),'on'))
    if(topoLoaded==1)
        X_TOPO = handles.X_TOPO;
        Z_TOPO = handles.Z_TOPO;
        Xmin_=min(X_TOPO)-(max(X_TOPO)-min(X_TOPO))*2;
        Xmax_=max(X_TOPO)+(max(X_TOPO)-min(X_TOPO))*2;
        Ymin_=-500;
        Ymax_=max(Z_TOPO)*2;
        set(modelGraph,'XLim',[Xmin_ Xmax_])
        set(modelGraph,'YLim',[Ymin_ Ymax_])
    elseif(fpLoaded==1)
        X_GPS = handles.X_GPS;
        Z_GPS = handles.Z_GPS;
        Xmin_=min(X_GPS)-(max(X_GPS)-min(X_GPS))*2;
        Xmax_=max(X_GPS)+(max(X_GPS)-min(X_GPS))*2;
        Ymin_=-500;
        Ymax_=max(Z_GPS)*2;
        set(modelGraph,'XLim',[Xmin_ Xmax_])
        set(modelGraph,'YLim',[Ymin_ Ymax_])
    elseif(workspaceSet==1)
        Xmin_ = handles.borderMinX;
        Xmax_ = handles.borderMaxX;
        Ymin_ = handles.minY;
        Ymax_ = handles.maxY;
        set(modelGraph,'XLim',[Xmin_ Xmax_])
        set(modelGraph,'YLim',[Ymin_-abs(Ymax_*0.1) Ymax_])
    else
        set(tgbtn,'Checked','off')
    end
else
    if(topoLoaded==1)
        X_TOPO = handles.X_TOPO;
        Z_TOPO = handles.Z_TOPO;
        Xmin_=min(X_TOPO);
        Xmax_=max(X_TOPO);
        Ymin_=-500;
        Ymax_=max(Z_TOPO)*2;
        set(modelGraph,'XLim',[Xmin_ Xmax_])
        set(modelGraph,'YLim',[Ymin_ Ymax_])
    elseif(fpLoaded==1)
        X_GPS = handles.X_GPS;
        Z_GPS = handles.Z_GPS;
        Xmin_=min(X_GPS);
        Xmax_=max(X_GPS);
        Ymin_=-500;
        Ymax_=max(Z_GPS)*2;
        set(modelGraph,'XLim',[Xmin_ Xmax_])
        set(modelGraph,'YLim',[Ymin_ Ymax_])
    elseif(workspaceSet==1)
        Xmin_ = handles.minX;
        Xmax_ = handles.maxX;
        Ymin_ = handles.minY;
        Ymax_ = handles.maxY;
        set(modelGraph,'XLim',[Xmin_ Xmax_])
        set(modelGraph,'YLim',[Ymin_-abs(Ymax_*0.1) Ymax_])
    else
        set(tgbtn,'Checked','off')
    end
end

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%ANOMALY MODE
        %MODE 1: SHOW BOTH MAG AND GRAV ANOMALY PROFILES
        %MODE 2: SHOW ONLY GRAV ANOMALY PROFILE
        %MODE 3: SHOW ONLY MAG ANOMALY PROFILE
function anomalyMode_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

if(get(anomMode,'Value')==1) %show both anomalies
    %tests if there's calculated mag anomaly plotted in magGraph
    axes(magAnomalyGraph)
    mag_ = findobj(gca,'type','line');
    axes(gravAnomalyGraph)
    grav_ = findobj(gca,'type','line');
    set(mag_,'Visible','on')
    set(grav_,'Visible','on')
    set(magAnomalyGraph,'position',[0.07 0.71 0.9 0.25])
    set(gravAnomalyGraph,'position',[0.07 0.395 0.9 0.25])
    set(modelGraph,'position',[0.07 0.08 0.9 0.25])
    
    set(gravAnomalyGraph,'Visible','on')
    set(magAnomalyGraph,'Visible','on')
    plotGrav = 1;
    plotMag = 1;
elseif(get(anomMode,'Value')==2) %show only grav anomaly
    %tests if there's calculated mag anomaly plotted in magGraph
    axes(magAnomalyGraph)
    mag_ = findobj(gca,'type','line');
    axes(gravAnomalyGraph)
    grav_ = findobj(gca,'type','line');
    set(mag_,'Visible','off')
    set(grav_,'Visible','on')
    %Change the size of the graphs
    set(gravAnomalyGraph,'position',[0.07 0.56 0.9 0.4])
    set(modelGraph,'position',[0.07 0.08 0.9 0.4])
    
    set(magAnomalyGraph,'Visible','off')
    set(gravAnomalyGraph,'Visible','on')
    plotGrav = 1;
    plotMag = 0;
elseif(get(anomMode,'Value')==3) %show only mag anomaly
    %tests if there's calculated grav anomaly plotted in gravGraph
    axes(gravAnomalyGraph)
    grav_ = findobj(gca,'type','line');
    axes(magAnomalyGraph)
    mag_ = findobj(gca,'type','line');
    set(mag_,'Visible','on')
    set(grav_,'Visible','off')
    %Change the size of the graphs
    set(magAnomalyGraph,'position',[0.07 0.56 0.9 0.4])
    set(modelGraph,'position',[0.07 0.08 0.9 0.4])
    
    set(magAnomalyGraph,'Visible','on')
    set(gravAnomalyGraph,'Visible','off')
    plotGrav = 0;
    plotMag = 1;
end

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%ADD NEW BODY
function newBody_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

GUIbodyParameters
h = findobj(gcf,'Tag','bodyParameters');
waitfor(h,'Visible','off')

if ~isempty(h)
    GUIbodyParametersData = guidata(h);
    
    if(workspaceSet==1)
        Xmin__ = handles.minX;
        Xmax__ = handles.maxX;
        Ymin_ = handles.minY;
        Ymax_ = handles.maxY;
        
        axes(modelGraph)
        impoly;
        
        if(fpLoaded==0 && topoLoaded==0)
            set(modelGraph,'XLim',[Xmin__ Xmax__])
            set(modelGraph,'YLim',[Ymin_-abs(Ymax_*0.1) Ymax_])
        end
        
        nBodies = length(findobj('tag','impoly'));
        
        dens_(nBodies,1) = GUIbodyParametersData.dens;
        suscept_(nBodies,1) = GUIbodyParametersData.suscept;
        inc_(nBodies,1) = GUIbodyParametersData.I_;
        strike__(nBodies,1) = GUIbodyParametersData.strike_;
        
        %FILL THE TABLE WITH BODY PARAMETERS
        data=cell(nBodies,5);
        for i=1:nBodies
            rName(i)={strcat('Body: 0',num2str(i))};
            a(i)=true;
            data(i,1)={dens_(i)};
            data(i,2)={suscept_(i)};
            data(i,3)={inc_(i)};
            data(i,4)={strike__(i)};
            data(i,5)={a(i)};
        end
        
        set(table,'RowName',rName)
        set(table,'ColumnName',{'Density','Susceptibility','Inclination','Strike','State'})
        set(table,'Data',data)
    else
        msgbox('Setup the model area limits before trying to generate a source.','Warn','warn')
    end
    deleteInvisibleGUI
end

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%CALCULATE THE GRAVITY AND MAGNETIC CONTRIBUTIONS OF THE BODY USING
%WON & BEVIS(1987) APPROACH
function computeTheAnomalies_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);

%GET THE TABLE CONTENT REFERRED TO BODY PARAMETERS
data_=get(table,'Data');
dens_=data_(:,1); dens_=cell2mat(dens_);
suscept_=data_(:,2); suscept_=cell2mat(suscept_);
inc_=data_(:,3); inc_=cell2mat(inc_);
strike__=data_(:,4); strike__=cell2mat(strike__);
state=data_(:,5); state=cell2mat(state)';
%DELETE THOSE BODIES WHOSE STATE ARE UNCHECKED
dens_(state==0)=0;
suscept_(state==0)=0;
nBodies_ = length(dens_);

if(~isempty(dens_))
    if(fpLoaded==1)
        xst = handles.X_FP;
        zst = handles.Z_FP;
    elseif(topoLoaded==1)
        xst = handles.X_TOPO;
        zst = handles.Z_TOPO;
    else
        minX = handles.minX;
        maxX = handles.maxX;
        stations = handles.stations;
        xst = linspace(minX,maxX,stations);
        zst = ones(1,stations);
    end
    %STRENGTH OF GEOMAGNETIC FIELD
    B=str2double(get(B_,'String'));
    
    axes(modelGraph)
    h = findobj('tag','impoly');
    h = flipud(h);
    set(h((state==0)),'Visible','off')
    set(h((state==1)),'Visible','on')
    %nBodies_ = length(h);
    sumAnomalyGrav = zeros(1,length(xst),nBodies_);
    sumAnomalyMag_z = zeros(1,length(xst),nBodies_);
    sumAnomalyMag_x = zeros(1,length(xst),nBodies_);
    sumAnomalyMag_t = zeros(1,length(xst),nBodies_);
    
    %LOOP THAT COMPUTE THE ANOMALIES DUE TO GEOLOGIC MODEL BODIES
    for kk=1:nBodies_
        body = h(kk);
        api = iptgetapi(body);
        vert = api.getPosition();
        %Delete identical vertices of the polygon
        %vert = unique(vert,'rows');
        xv = vert(:,1);
        zv = -vert(:,2);
        %Convert polygon contour to counter-clockwise vertex ordering
        [xv,zv] = poly2ccw(xv,zv);
        
        sumAnomalyGrav(:,:,kk)=irregularBodyGrav(xv,zv,xst,zst,dens_(kk));
        [Z_,X_,T_]=irregularBodyMag(xv,zv,xst,zst,B,inc_(kk),strike__(kk),suscept_(kk));
        sumAnomalyMag_z(:,:,kk)=Z_;
        sumAnomalyMag_x(:,:,kk)=X_;
        sumAnomalyMag_t(:,:,kk)=T_;
    end
    
    GRAV=sum(sumAnomalyGrav,3);
    MAG_Z=sum(sumAnomalyMag_z,3);
    MAG_X=sum(sumAnomalyMag_x,3);
    MAG_T=sum(sumAnomalyMag_t,3);
    
    %PLOT THE GRAVITY ANOMALY--------------------------------------------------
    axes(gravAnomalyGraph)
    %tests if there's a measured gravity data plotted
    h_ = findobj(gca,'type','scatter');
    
    if(plotGrav == 1)
        if(length(h_)==1) %there's measured gravity data plotted
            X_GRAV = get(h_,'XData');
            Z_GRAV = get(h_,'YData');
            
            plot(xst,GRAV,'b-','LineWidth',2)
            xlim([min(xst) max(xst)])
            hold on
            scatter(gravAnomalyGraph,X_GRAV,Z_GRAV,8,'MarkerEdgeColor',[0 0 0],...
                'MarkerFaceColor',[0 0 1],...
                'LineWidth',0.5)
            legend('Calculated','Measured')
            ylabel('Grav Anomaly [mGal]')
            if(min(Z_GRAV)==max(Z_GRAV))
                ylim([min(Z_GRAV)-20 max(Z_GRAV)+20])
            elseif(min(Z_GRAV)>=0)
                ylim([min(Z_GRAV)-min(Z_GRAV)*0.5 max(Z_GRAV)*1.5])
            else
                ylim([min(Z_GRAV)+min(Z_GRAV)*0.5 max(Z_GRAV)*1.5])
            end
            set(gravAnomalyGraph,'XGrid','on')
            set(gravAnomalyGraph,'YGrid','on')
            hold off
        else
            plot(xst,GRAV,'b-','LineWidth',2)
            xlim([min(xst) max(xst)])
            if(min(GRAV)==max(GRAV))
                ylim([min(GRAV)-20 max(GRAV)+20])
            elseif(min(GRAV)>=0)
                ylim([min(GRAV)-min(GRAV)*0.5 max(GRAV)*1.5])
            else
                ylim([min(GRAV)+min(GRAV)*0.5 max(GRAV)*1.5])
            end
            legend('Calculated')
            ylabel('Grav Anomaly [mGal]')
            set(gravAnomalyGraph,'XGrid','on')
            set(gravAnomalyGraph,'YGrid','on')
        end
    end
    %PLOT THE MAGNETIC ANOMALY-------------------------------------------------
    axes(magAnomalyGraph)
    %tests if there's a measured magnetic data plotted
    h_ = findobj(gca,'type','scatter');
    
    if(plotMag == 1)
        if(length(h_)==1) %there's measured magnetic data plotted
            X_MAG = get(h_,'XData');
            Z_MAG = get(h_,'YData');
            
            plot(xst,MAG_Z,'r-','LineWidth',2)
            xlim([min(xst) max(xst)])
            hold on
            scatter(magAnomalyGraph,X_MAG,Z_MAG,8,'MarkerEdgeColor',[0 0 0],...
                'MarkerFaceColor',[1 0 0],...
                'LineWidth',0.5)
            legend('Calculated','Measured')
            ylabel('Mag Anomaly [nT]')
            if(min(Z_MAG)==max(Z_MAG))
                ylim([min(Z_MAG)-20 max(Z_MAG)+20])
            elseif(min(Z_MAG)>=0)
                ylim([min(Z_MAG)-min(Z_MAG)*0.5 max(Z_MAG)*1.5])
            else
                ylim([min(Z_MAG)+min(Z_MAG)*0.5 max(Z_MAG)*1.5])
            end
            set(magAnomalyGraph,'XGrid','on')
            set(magAnomalyGraph,'YGrid','on')
            hold off
        else
            plot(xst,MAG_Z,'r-','LineWidth',2)
            xlim([min(xst) max(xst)])
            if(min(MAG_Z)==max(MAG_Z))
                ylim([min(MAG_Z)-20 max(MAG_Z)+20])
            elseif(min(MAG_Z)>=0)
                ylim([min(MAG_Z)-min(MAG_Z)*0.5 max(MAG_Z)*1.5])
            else
                ylim([min(MAG_Z)+min(MAG_Z)*0.5 max(MAG_Z)*1.5])
            end
            legend('Calculated')
            ylabel('Mag Anomaly [nT]')
            set(magAnomalyGraph,'XGrid','on')
            set(magAnomalyGraph,'YGrid','on')
        end
    end
    
    handles.xst = xst;
    handles.GRAV = GRAV;
    handles.MAG_Z = MAG_Z;
    handles.MAG_X = MAG_X;
    handles.MAG_T = MAG_T;
else
    msgbox('Create some body before trying to generate the anomalies.','Warn','warn')
    return
end
%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%SAVE GRAVIMETRIC ANOMALY
function saveGrav_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);
xst = handles.xst;
xst = xst';
inputFile = handles.GRAV;
inputFile = inputFile';

outputFile = cat(2,xst,inputFile);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

fid = fopen(Fullpath,'w+');
fprintf(fid,'%8s %8s\r\n','X','GRAV');
fprintf(fid,'%6.2f %12.8e\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%SAVE MAGNETIC ANOMALY
function saveMag_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIirregularCrossSectionBody_);
xst = handles.xst;
xst = xst';
inputFile = handles.MAG_T;
inputFile = inputFile';

outputFile = cat(2,xst,inputFile);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return;
end

fid = fopen(Fullpath,'w+');
fprintf(fid,'%8s %8s\r\n','X','MAG_T');
fprintf(fid,'%6.2f %12.8e\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(GUIirregularCrossSectionBody_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function deleteInvisibleGUI()
    ocultFIG = findobj('Type','figure','-and','Visible','off');
    if(~isempty(ocultFIG))
        delete(ocultFIG)
    end
end

function plotGenericModel(minX,maxX,minY,maxY,stations)
    axes(modelGraph)
    plot([minX maxX],[0 0],'k-','LineWidth',2)
    hold on
    plot(linspace(minX,maxX,stations),...
        ones(1,stations),'kv','MarkerSize',2)
    plot([minX minX],[minY maxY],'r--','LineWidth',1)
    plot([maxX maxX],[minY maxY],'r--','LineWidth',1)
    xlabel('Position (meters)')
    ylabel('Depth (meters)')
    set(gca,'Ydir','reverse')
    set(gca,'FontSize',12)
    hold off
    set(modelGraph,'XGrid','on')
    set(modelGraph,'YGrid','on')
    set(modelGraph,'XLim',[minX maxX])
    set(modelGraph,'YLim',[minY-abs(maxY*0.1) maxY])
end

end