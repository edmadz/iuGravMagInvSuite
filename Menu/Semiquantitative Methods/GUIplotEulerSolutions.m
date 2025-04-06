function GUIplotEulerSolutions

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIplotEulerSolutions_ = figure('Menubar','none',...
    'Name','Plot Euler Solutions',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------
inputParametersPanel = uipanel(GUIplotEulerSolutions_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

minX_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Minimum value of study área in x direction [meters].',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.46 0.036]);

maxX_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Maximum value of study área in x direction [meters].',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.51 0.915 0.46 0.036]);

minY_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Minimum value of study área in y direction [meters].',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.46 0.036]);

maxY_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Maximum value of study área in y direction [meters].',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.51 0.865 0.46 0.036]);

minZ_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Minimum value in z direction [meters].',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.46 0.036]);

maxZ_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Maximum value in z direction [meters].',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.51 0.815 0.46 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Update Study Area Limits',...
    'fontUnits','normalized',...
    'position',[0.03 0.765 0.944 0.036],...
    'CallBack',@updateStudyAreaLimits_callBack);

alphaCh = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Transparency of prismatic bodies.',...
    'units','normalized',...
    'String','0.8',...
    'fontUnits','normalized',...
    'position',[0.03 0.715 0.944 0.036]);

popupColormapType = uicontrol(inputParametersPanel,'Style','popupmenu',...
    'Units','normalized',...
    'String',{''},...
    'Value',1,...
    'fontUnits','normalized',...
    'position',[0.03 0.665 0.944 0.036],...
    'Callback',@setColormap_callBack);

coordConversion = uicontrol(inputParametersPanel,'Style','popupmenu',...
    'Units','normalized',...
    'String',{'Use original units','From m to km','From m to m','From km to m','From km to km'},...
    'Value',1,...
    'fontUnits','normalized',...
    'position',[0.03 0.615 0.944 0.036]);

imageFileFormat = uicontrol(inputParametersPanel,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'png','jpeg','jpg','tiff'},...
    'fontUnits','normalized',...
    'TooltipString','Image file format.',...
    'position',[0.03 0.165 0.944 0.036]);

DPI_=uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'TooltipString','Dots per inch - DPI [Control image resolution].',...
    'position',[0.03 0.115 0.944 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Export Map',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'CallBack',@exportEulerSolutionImage_callBack);
%--------------------------------------------------------------------------
graphPanel = uipanel(GUIplotEulerSolutions_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graphSol = axes(graphPanel,'Units','normalized',...
    'position',[0.1 0.1 0.8 0.8]);
set(graphSol.XAxis,'Visible','off');
set(graphSol.YAxis,'Visible','off');
tbls
%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIplotEulerSolutions_,'label','File');
uimenu(file,'Label','Load Euler Solutions...','Accelerator','E','CallBack',@loadEulerSolutions_callBack);
uimenu(file,'Label','Load Distance R Solutions...','Accelerator','T','CallBack',@loadDistanceRDepthSolutions_callBack);
uimenu(file,'Label','Load Tilt-Depth Solutions...','Accelerator','T','CallBack',@loadTiltDepthSolutions_callBack);
uimenu(file,'Label','Load Signum Transform Solutions...','Accelerator','S','CallBack',@loadSignumSolutions_callBack);

model = uimenu(GUIplotEulerSolutions_,'label','Model');
uimenu(model,'Label','Load Model...','Accelerator','M','CallBack',@loadModel_callBack);

eulerSolutionLoaded = 'n';
distanceRDepthSolutionLoaded = 'n';
tiltDepthSolutionLoaded = 'n';
signumSolutionLoaded = 'n';
modelLoaded = 'n';
set(GUIplotEulerSolutions_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN EULER DEPTH SOLUTION DATASET
function loadEulerSolutions_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

data = importdata(Fullpath);
[x0,y0,z0,WS,N,minX,maxX,minY,maxY,minZ,maxZ]=loadEulerSolutions(data);

colormapSelected = get(popupColormapType,'String');
colormapSelected = char(colormapSelected(get(popupColormapType,'Value')));

if(get(coordConversion,'Value')==1) %use original units
    denominator = 1;
    labelX = 'Easting (units)';
    labelY = 'Northing (units)';
elseif(get(coordConversion,'Value')==2) %from m to km
    denominator = 1000;
    labelX = 'Easting (km)';
    labelY = 'Northing (km)';
elseif(get(coordConversion,'Value')==3) %from m to m
    denominator = 1;
    labelX = 'Easting (m)';
    labelY = 'Northing (m)';
elseif(get(coordConversion,'Value')==4) %from km to m
    denominator = 1/1000;
    labelX = 'Easting (m)';
    labelY = 'Northing (m)';
elseif(get(coordConversion,'Value')==5) %from km to km
    denominator = 1;
    labelX = 'Easting (km)';
    labelY = 'Northing (km)';
end

axes(graphSol)
hold off
scatter3(x0./denominator,y0./denominator,z0./denominator,20,z0./denominator,'filled')
cmapChanged = colormaps(z0,colormapSelected,'linear');
colormap(flipud(cmapChanged))
customColorbar(6,3,17,0,17,'bold','Depth (km)','E')
xlim([minX./denominator maxX./denominator])
ylim([minY./denominator maxY./denominator])
zlim([minZ./denominator maxZ./denominator])
set(gca,'Zdir','reverse')
stringTitle = strcat('EULER DEPTH SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
title(stringTitle)
xlabel(labelX,'FontWeight','bold')
ylabel(labelY,'FontWeight','bold')
zlabel('Depth (km)','FontWeight','bold')
set(gca,'fontSize',17)

widthArea=maxX/denominator-minX/denominator;
heightArea=maxY/denominator-minY/denominator;
if(widthArea>heightArea)
    b=heightArea/widthArea;
    pbaspect([1 b 0.3])
else
    b=widthArea/heightArea;
    pbaspect([b 1 0.3])
end

setCoord(minX/denominator,minY/denominator,widthArea,heightArea,4,4)
view(-22,39)
grid on
grid minor
set(gca,'Box','on')

h = rotate3d;
set(h,'ActionPreCallback','set(gcf,''windowbuttonmotionfcn'',@align_axislabel)')
set(h,'ActionPostCallback','set(gcf,''windowbuttonmotionfcn'','''')')
set(gcf,'ResizeFcn',@align_axislabel)
align_axislabel([],gca)

set(minX_,'String',num2str(minX));
set(maxX_,'String',num2str(maxX));
set(minY_,'String',num2str(minY));
set(maxY_,'String',num2str(maxY));
set(minZ_,'String',num2str(minZ));
set(maxZ_,'String',num2str(maxZ));

handles.N = N;
handles.WS = WS;
handles.minX = minX;
handles.maxX = maxX;
handles.minY = minY;
handles.maxY = maxY;
handles.minZ = minZ;
handles.maxZ = maxZ;
handles.x0 = x0;
handles.y0 = y0;
handles.z0 = z0;
eulerSolutionLoaded = 'y';
modelLoaded = 'n';
%Update de handle structure
guidata(hObject,handles);
end

%OPEN TILT-DEPTH SOLUTION DATASET
function loadTiltDepthSolutions_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

data = importdata(Fullpath);

if (isstruct(data))
    Data_ = data.data;
    [~,colData] = size(Data_);
    if(colData>3)
        msgbox('This data has more or less than three columns.','Warn','warn')
        return
    elseif(colData==3)
        x0 = Data_(1:end-6,1);
        y0 = Data_(1:end-6,2);
        z0 = Data_(1:end-6,3);
        minX = Data_(end-5,1);
        maxX = Data_(end-4,1);
        minY = Data_(end-3,1);
        maxY = Data_(end-2,1);
        minZ = Data_(end-1,1);
        maxZ = Data_(end,1);
    end
else
    Data_ = data;
    [~,colData] = size(Data_);
    if(colData>3)
        msgbox('This data has more or less than three columns.','Warn','warn')
        return
    elseif(colData==3)
        x0 = Data_(1:end-6,1);
        y0 = Data_(1:end-6,2);
        z0 = Data_(1:end-6,3);
        minX = Data_(end-5,1);
        maxX = Data_(end-4,1);
        minY = Data_(end-3,1);
        maxY = Data_(end-2,1);
        minZ = Data_(end-1,1);
        maxZ = Data_(end,1);
    end
end

colormapSelected = get(popupColormapType,'String');
colormapSelected = char(colormapSelected(get(popupColormapType,'Value')));

axes(graphSol)
hold off
scatter3(x0./1000,y0./1000,z0,20,z0,'filled')
cmapChanged = colormaps(z0,colormapSelected,'linear');
colormap(cmapChanged)
cb=colorbar;
title(cb,'Depth [m]')
xlim([minX./1000 maxX./1000])
ylim([minY./1000 maxY./1000])
zlim([minZ maxZ])
% stringTitle = strcat('EULER DEPTH SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
% title(stringTitle)
xlabel('Easting [km]')
ylabel('Northing [km]')
zlabel('Depth [m]')
set(gca,'fontSize',14)
pbaspect([1 1 0.2])
view(-24,27)
grid on
grid minor

set(minX_,'String',num2str(minX));
set(maxX_,'String',num2str(maxX));
set(minY_,'String',num2str(minY));
set(maxY_,'String',num2str(maxY));
set(minZ_,'String',num2str(minZ));
set(maxZ_,'String',num2str(maxZ));

handles.minX = minX;
handles.maxX = maxX;
handles.minY = minY;
handles.maxY = maxY;
handles.minZ = minZ;
handles.maxZ = maxZ;
handles.x0 = x0;
handles.y0 = y0;
handles.z0 = z0;
tiltDepthSolutionLoaded = 'y';
modelLoaded = 'n';
%Update de handle structure
guidata(hObject,handles);
end

%OPEN SIGNUM TRANSFORM DEPTH SOLUTION DATASET
function loadDistanceRDepthSolutions_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

data = importdata(Fullpath);

if (isstruct(data))
    Data_ = data.data;
    [~,colData] = size(Data_);
    if(colData>3)
        msgbox('This data has more or less than three columns.','Warn','warn')
        return
    elseif(colData==3)
        x0 = Data_(1:end-6,1);
        y0 = Data_(1:end-6,2);
        z0 = Data_(1:end-6,3);
        minX = Data_(end-5,1);
        maxX = Data_(end-4,1);
        minY = Data_(end-3,1);
        maxY = Data_(end-2,1);
        minZ = Data_(end-1,1);
        maxZ = Data_(end,1);
    end
else
    Data_ = data;
    [~,colData] = size(Data_);
    if(colData>3)
        msgbox('This data has more or less than three columns.','Warn','warn')
        return
    elseif(colData==3)
        x0 = Data_(1:end-6,1);
        y0 = Data_(1:end-6,2);
        z0 = Data_(1:end-6,3);
        minX = Data_(end-5,1);
        maxX = Data_(end-4,1);
        minY = Data_(end-3,1);
        maxY = Data_(end-2,1);
        minZ = Data_(end-1,1);
        maxZ = Data_(end,1);
    end
end

colormapSelected = get(popupColormapType,'String');
colormapSelected = char(colormapSelected(get(popupColormapType,'Value')));

axes(graphSol)
hold off
scatter3(x0./1000,y0./1000,z0,20,z0,'filled')
cmapChanged = colormaps(z0,colormapSelected,'linear');
colormap(cmapChanged)
cb=colorbar;
title(cb,'Depth [m]')
xlim([minX./1000 maxX./1000])
ylim([minY./1000 maxY./1000])
zlim([minZ maxZ])
% stringTitle = strcat('EULER DEPTH SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
% title(stringTitle)
xlabel('Easting [km]')
ylabel('Northing [km]')
zlabel('Depth [m]')
set(gca,'fontSize',14)
pbaspect([1 1 0.2])
view(-24,27)
grid on
grid minor

set(minX_,'String',num2str(minX));
set(maxX_,'String',num2str(maxX));
set(minY_,'String',num2str(minY));
set(maxY_,'String',num2str(maxY));
set(minZ_,'String',num2str(minZ));
set(maxZ_,'String',num2str(maxZ));

handles.minX = minX;
handles.maxX = maxX;
handles.minY = minY;
handles.maxY = maxY;
handles.minZ = minZ;
handles.maxZ = maxZ;
handles.x0 = x0;
handles.y0 = y0;
handles.z0 = z0;
distanceRDepthSolutionLoaded = 'y';
modelLoaded = 'n';
%Update de handle structure
guidata(hObject,handles);
end

%COMPUTE EULER DECONVOLUTION
function loadModel_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerSolutionLoaded=='y' ||...
        tiltDepthSolutionLoaded=='y' ||...
        signumSolutionLoaded=='y' ||...
        distanceRDepthSolutionLoaded=='y')
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    
    [FileName,PathName] = uigetfile({'*.dat','Data Files (*.dat)'},'Select a model parameters file');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return
    end
    
    [Data_,~]=loadModel(Fullpath);
    
    P=Data_';
    [~,n]=size(P);
    
    denominator = 1000;
    
    width_=P(4,:)./denominator;
    lenght_=P(5,:)./denominator;
    thickness_=P(6,:)./denominator;
    Cx_=P(7,:)./denominator;
    Cy_=P(8,:)./denominator;
    depth_=P(9,:);
    strike_=P(10,:);
    
    alpha = str2double(get(alphaCh,'String'));
    
    p=findobj(graphSol,'type','patch');
    if(~isempty(p))
        delete(p)
    end
    
    axes(graphSol)
    for i_=1:n
        i = [(Cx_(:,i_)-width_(:,i_)/2),(Cy_(:,i_)-lenght_(:,i_)/2),thickness_(:,i_)];
            d = [width_(:,i_),lenght_(:,i_),-thickness_(:,i_)+depth_(:,i_)];
            voxel(i,d,[.83 .83 .83],strike_(i_),alpha)
            hold on
    end
    
    xlim([minX./denominator maxX./denominator])
    ylim([minY./denominator maxY./denominator])
    zlim([0 maxZ./denominator])
    
    handles.width_=width_;
    handles.lenght_=lenght_;
    handles.thickness_=thickness_;
    handles.Cx_=Cx_;
    handles.Cy_=Cy_;
    handles.depth_=depth_;
    handles.strike_=strike_;
    handles.alpha=alpha;
    modelLoaded = 'y';
else
    msgbox('Load an Euler solution file before trying to load the 3D model.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%UPDATE THE LIMITS OF STUDY AREA
function updateStudyAreaLimits_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

minX = str2double(get(minX_,'String'));
maxX = str2double(get(maxX_,'String'));
minY = str2double(get(minY_,'String'));
maxY = str2double(get(maxY_,'String'));
minZ = str2double(get(minZ_,'String'));
maxZ = str2double(get(maxZ_,'String'));

denominator = 1000;

axes(graphSol)
xlim([minX./denominator maxX./denominator])
ylim([minY./denominator maxY./denominator])
zlim([minZ./denominator maxZ./denominator])

%Update de handle structure
guidata(hObject,handles);
end

%UPDATE THE CURRENT COLORMAP
function setColormap_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerSolutionLoaded=='y')
    N = handles.N;
    WS = handles.WS;
end

if(eulerSolutionLoaded=='y' || tiltDepthSolutionLoaded=='y' || signumSolutionLoaded=='y' || distanceRDepthSolutionLoaded=='y')
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    x0 = handles.x0;
    y0 = handles.y0;
    z0 = handles.z0;
    
    colormapSelected = get(popupColormapType,'String');
    colormapSelected = char(colormapSelected(get(popupColormapType,'Value')));
    
    denominator = 1000;
    
    axes(graphSol)
    hold off
    scatter3(x0./denominator,y0./denominator,z0./denominator,20,z0./denominator,'filled')
    cmapChanged = colormaps(z0,colormapSelected,'linear');
    colormap(cmapChanged)
    customColorbar(6,3,17,0,17,'bold','Depth (km)','E')
    xlim([minX./denominator maxX./denominator])
    ylim([minY./denominator maxY./denominator])
    zlim([minZ./denominator maxZ./denominator])
    set(gca,'Zdir','reverse')
    stringTitle = strcat('EULER DEPTH SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
    title(stringTitle)
    xlabel('Easting (km)','FontWeight','bold')
    ylabel('Northing (km)','FontWeight','bold')
    zlabel('Depth (km)','FontWeight','bold')
    set(gca,'fontSize',17)
    pbaspect([1 1 0.4])
    view(-56,17)
    grid on
    grid minor
    set(gca,'Box','on')
    
    if(modelLoaded=='y')
        width_=handles.width_;
        lenght_=handles.lenght_;
        thickness_=handles.thickness_;
        Cx_=handles.Cx_;
        Cy_=handles.Cy_;
        depth_=handles.depth_;
        strike_=handles.strike_;
        alpha=handles.alpha;
        
        n=length(strike_);
        
        axes(graphSol)
        for i_=1:n
            i = [(Cx_(:,i_)-width_(:,i_)/2),(Cy_(:,i_)-lenght_(:,i_)/2),thickness_(:,i_)];
            d = [width_(:,i_),lenght_(:,i_),-thickness_(:,i_)+depth_(:,i_)];
            voxel(i,d,[.83 .83 .83],strike_(i_),alpha)
            xlim([minX./denominator maxX./denominator])
            ylim([minY./denominator maxY./denominator])
            zlim([minZ./denominator maxZ./denominator])
            hold on
        end
    end
    
    handles.colormapSelected = colormapSelected;
else
    colormapSelected = get(popupColormapType,'String');
    colormapSelected = char(colormapSelected(get(popupColormapType,'Value')));
    handles.colormapSelected = colormapSelected;
end

%Update de handle structure
guidata(hObject,handles);
end

%EXPORT THE EULER SOLUTION IN AN IMAGE FORMAT
function exportEulerSolutionImage_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);
z0 = handles.z0;

[FileName,PathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Save Image...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

format_=get(imageFileFormat,'String');
imageF = char(strcat('-d',format_(get(imageFileFormat,'Value'))));
dpi_ = strcat('-r',get(DPI_,'String'));
fName = strsplit(FileName,'.');
ImagePath = char(strcat(PathName,fName(1)));

fig = figure('OuterPosition',[373,142,1080,830],'Visible','off');
ax_new = copyobj(graphSol,fig);

colormapSelected = get(popupColormapType,'String');
colormapSelected = char(colormapSelected(get(popupColormapType,'Value')));

cmapChanged = colormaps(reshape(z0,[length(z0),1]),colormapSelected,'linear');
colormap(fig,cmapChanged)
customColorbar(6,3,17,0,17,'bold','Depth (km)','E')
xlb = get(ax_new,'Xlabel'); set(xlb,'FontWeight','bold')
ylb = get(ax_new,'Ylabel'); set(ylb,'FontWeight','bold')
zlb = get(ax_new,'Zlabel'); set(zlb,'FontWeight','bold')
clb=get(ax_new,'colorbar'); set(clb,'Position',[0.8699 0.1100 0.0201 0.8150])
%set(ax_new,'position',[0.1300 0.1100 0.6750 0.8150])
set(ax_new,'position','default')
txt = get(ax_new,'Title'); set(txt,'String','')

msg1=msgbox('Wait a moment.','Warn','warn');

print(fig,ImagePath,imageF,dpi_)
delete(fig)

delete(msg1)
msgbox('Image Exported.','Warn','warn')

%Update de handle structure
guidata(hObject,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function tbls
    currentF=pwd;
    tblFolder=strcat(currentF,'\tbl');
    tblGeophFolder=strcat(tblFolder,'\geophysics');
    content_=dir(tblGeophFolder);
    N=length(content_);
    tbl_=cell([N-2,1]);
    for i=1:N-2
        t=content_(i+2).name;
        t=strsplit(t,'.');
        tbl_(i,1)={char(t(1))};
    end
    set(popupColormapType,'String',tbl_)
end

function [x0,y0,z0,WS,N,minX,maxX,minY,maxY,minZ,maxZ]=loadEulerSolutions(data)
    if (isstruct(data))
        Data_ = data.data;
        [~,colData] = size(Data_);
        if(colData>3)
            msgbox('This data has more or less than three columns.','Warn','warn')
            return
        elseif(colData==3)
            x0 = Data_(1:end-8,1);
            y0 = Data_(1:end-8,2);
            z0 = Data_(1:end-8,3);
            WS = Data_(end-7,1);
            N = Data_(end-6,1);
            minX = Data_(end-5,1);
            maxX = Data_(end-4,1);
            minY = Data_(end-3,1);
            maxY = Data_(end-2,1);
            minZ = Data_(end-1,1);
            maxZ = Data_(end,1);
        end
    else
        Data_ = data;
        [~,colData] = size(Data_);
        if(colData>3)
            msgbox('This data has more or less than three columns.','Warn','warn')
            return
        elseif(colData==3)
            x0 = Data_(1:end-8,1);
            y0 = Data_(1:end-8,2);
            z0 = Data_(1:end-8,3);
            WS = Data_(end-7,1);
            N = Data_(end-6,1);
            minX = Data_(end-5,1);
            maxX = Data_(end-4,1);
            minY = Data_(end-3,1);
            maxY = Data_(end-2,1);
            minZ = Data_(end-1,1);
            maxZ = Data_(end,1);
        end
    end
end

function [Data_,header2]=loadModel(Fullpath)
    fid = fopen(Fullpath);
    A = fgets(fid);
    i = 0;
    while ischar(A)
        if(i==0)
            [v,~] = sscanf(A,'%s',[1 11]);
            i = i + 1;
            header1 = v(:);
            A = fgets(fid);
        elseif(i==1)
            [v,~] = sscanf(A,'%f',[1 11]);
            i = i + 1;
            Data_1 = v(:);
            A = fgets(fid);
        elseif(i==2)
            [v,~] = sscanf(A,'%s',[1 12]);
            i = i + 1;
            header2 = v(:);
            A = fgets(fid);
        elseif(i>2)
            [v,~] = sscanf(A,'%f',[1 12]);
            i = i + 1;
            Data_(i-3,:) = v(:);
            A = fgets(fid);
        end
    end
end

function setCoord(xLimMin,yLimMin,W,H,nx,ny)
    r_W=W/nx;
    r_H=H/ny;
    
    for i=1:ny-1
        coordY(i)=(yLimMin+i*r_H);
    end
    
    for i=1:nx-1
        coordX(i)=(xLimMin+i*r_W);
    end
    
    set(gca,'XTick',coordX)
    set(gca,'XTickLabel',sprintf('%.0f\n',coordX))
    
    set(gca,'YTick',coordY)
    set(gca,'YTickLabel',sprintf('%.0f\n',coordY))
end

end