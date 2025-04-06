function GUIgridData

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIgridData_ = figure('Name','Grid Data',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUIgridData_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUIgridData_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------

minX_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Minimum coordinate in easting direction.',...
    'Position',[0.3 0.725 0.14 0.08]);

maxX_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Maximum coordinate in easting direction.',...
    'Position',[0.47 0.725 0.14 0.08]);

spaceX_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Interpolation cell width.',...
    'Position',[0.64 0.725 0.14 0.08],...
    'CallBack',@spaceX_callBack);

nodesX_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Number of grid dots in easting direction.',...
    'Position',[0.81 0.725 0.14 0.08],...
    'CallBack',@nodesX_callBack);

minY_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Minimum coordinate in northing direction.',...
    'Position',[0.3 0.625 0.14 0.08]);

maxY_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Maximum coordinate in northing direction.',...
    'Position',[0.47 0.625 0.14 0.08]);

spaceY_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Interpolation cell height.',...
    'Position',[0.64 0.625 0.14 0.08],...
    'CallBack',@spaceY_callBack);

nodesY_ = uicontrol(GUIgridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Number of grid dots in northing direction.',...
    'Position',[0.81 0.625 0.14 0.08],...
    'CallBack',@nodesY_callBack);

colorDist = uicontrol(GUIgridData_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.525 0.32 0.08]);

coordConversion = uicontrol(GUIgridData_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.63 0.525 0.32 0.08]);

interpolador = uicontrol(GUIgridData_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Bilinear','Bicubic','Nearest Neighbor','Natural Neighbor'},...
    'TooltipString','Interpolation method.',...
    'fontUnits','normalized',...
    'position',[0.3 0.425 0.65 0.08]);

%--------------------------------------------------------------------------

uicontrol(GUIgridData_,'Style','pushbutton',...
    'units','normalized',...
    'String','Interpolate',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@interpolation_callBack);

%--------------------------------------------------------------------------

uicontrol(GUIgridData_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUIgridData_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUIgridData_);
set(GUIgridData_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
dataInterpolated = 'n';
set(GUIgridData_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z] = loadScatteredData(Fullpath);

minX = min(X); maxX = max(X);
minY = min(Y); maxY = max(Y);

set(minX_,'String',num2str(minX))
set(maxX_,'String',num2str(maxX))
set(minY_,'String',num2str(minY))
set(maxY_,'String',num2str(maxY))

nodesX = 100;
nodesY = 100;

set(nodesX_,'String',num2str(nodesX))
set(nodesY_,'String',num2str(nodesY))

spaceX = (maxX-minX)/(nodesX-1);
spaceY = (maxY-minY)/(nodesY-1);
set(spaceX_,'String',num2str(spaceX))
set(spaceY_,'String',num2str(spaceY))

set(inputFile_path,'String',num2str(Fullpath))

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.minX = minX;
handles.maxX = maxX;
handles.minY = minY;
handles.maxY = maxY;
handles.spaceX = spaceX;
handles.spaceY = spaceY;
handles.nodesX = nodesX;
handles.nodesY = nodesY;
dataLoaded = 'y';
%Update de handle structure
guidata(GUIgridData_,handles);
end

function spaceX_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);
minX = handles.minX;
maxX = handles.maxX;

nodesX = round((maxX-minX)/str2double(spaceX_.String)) + 1;
set(nodesX_,'String',num2str(nodesX))

handles.nodesX = nodesX;
%Update de handle structure
guidata(GUIgridData_,handles);
end

function spaceY_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);
minY = handles.minY;
maxY = handles.maxY;

nodesY = round((maxY-minY)/str2double(spaceY_.String)) + 1;
set(nodesY_,'String',num2str(nodesY))

handles.nodesY = nodesY;
%Update de handle structure
guidata(GUIgridData_,handles);
end

function nodesX_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);
minX = handles.minX;
maxX = handles.maxX;

spaceX = round((maxX-minX)/(str2double(nodesX_.String)-1));
set(spaceX_,'String',num2str(spaceX))

handles.spaceX = spaceX;
%Update de handle structure
guidata(GUIgridData_,handles);
end

function nodesY_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);
minY = handles.minY;
maxY = handles.maxY;

spaceY = round((maxY-minY)/(str2double(nodesY_.String)-1));
set(spaceY_,'String',num2str(spaceY))

handles.spaceY = spaceY;
%Update de handle structure
guidata(GUIgridData_,handles);
end

%GRID THE DATASET
function interpolation_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);

if(dataLoaded == 'y')
    X = handles.X;
    Y = handles.Y;
    Z = handles.Z;
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    nodesX = str2double(get(nodesX_,'String'));
    nodesY = str2double(get(nodesY_,'String'));
    
    x = linspace(minX,maxX,nodesX);
    y = linspace(minY,maxY,nodesY);
    
    [Xg,Yg] = meshgrid(x,y);
    
    selection = get(interpolador,'Value');
    
    switch selection
        case 1
            Zg = griddata(X,Y,Z,Xg,Yg,'linear');
        case 2
            Zg = griddata(X,Y,Z,Xg,Yg,'cubic');
        case 3
            Zg = griddata(X,Y,Z,Xg,Yg,'nearest');
        case 4
            Zg = griddata(X,Y,Z,Xg,Yg,'natural');
    end
    
    plotInterpolatedMap(682,700,Xg,Yg,Zg,...
        get(colorDist,'Value'),get(coordConversion,'Value'))
    
    handles.Xg = Xg;
    handles.Yg = Yg;
    handles.Zg = Zg;
    dataInterpolated = 'y';
else
    msgbox('Load some data before trying to interpolate.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIgridData_,handles);
end

%SET THE OUTPUT DATASET PATH
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridData_);

if(dataInterpolated == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    inputFile = handles.Zg;
    
    outputFile = matrix2xyz(Xg,Yg,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%6s %6s %14s\r\n','X','Y','Z');
    fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile));
    fclose(fid);
else
    msgbox('Interpolate the data before trying to save it.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIgridData_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function plotInterpolatedMap(figWidth__,figHeight__,Xg,Yg,Zg,colorDist_,coordConversion_)
    [posX_,posY_,figWidth__,figHeight__]=centralizeWindow(figWidth__,figHeight__);
    
    figure('units','pixel','position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg,Yg,Zg)
    shading interp
    [row,col]=size(Zg);
    if(colorDist_==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','equalized');
    else
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','linear');
    end
    colormap(cmapChanged)
    c=colorbar;
    set(get(c,'Label'),'String','Quantity (Unit)')
    set(get(c,'Label'),'FontWeight','bold')
    
    if(coordConversion_==1) %show coordinates in its original units
        d = 1;
        labelX = 'Easting (units)';
        labelY = 'Northing (units)';
    elseif(coordConversion_==2) %Convert coordinate from m to km
        d = 1000;
        labelX = 'Easting (km)';
        labelY = 'Northing (km)';
    elseif(coordConversion_==3) %Convert coordinate from m to m
        d = 1;
        labelX = 'Easting (m)';
        labelY = 'Northing (m)';
    elseif(coordConversion_==4) %Convert coordinate from km to m
        d = 1/1000;
        labelX = 'Easting (m)';
        labelY = 'Northing (m)';
    elseif(coordConversion_==5) %Convert coordinate from km to km
        d = 1;
        labelX = 'Easting (km)';
        labelY = 'Northing (km)';
    end
    
    xlabel(labelX)
    ylabel(labelY)
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    set(gca,'Box','on')
    set(gca,'Xlim',[minX maxX])
    set(gca,'Ylim',[minY maxY])
    set(gca,'YTickLabelRotation',90)
    Y_coord = linspace(minY,maxY,5);
    set(gca,'YTick',Y_coord)
    Y_coord_ = prepCoord(Y_coord./d);
    set(gca,'YTickLabel',Y_coord_)
    X_coord = linspace(minX,maxX,5);
    set(gca,'XTick',X_coord)
    X_coord_ = prepCoord(X_coord./d);
    set(gca,'XTickLabel',X_coord_)
    set(gca,'fontSize',17)
    axis image
end

%COPY THE GUI DATA TO MATLAB WORKSPACE
function copy2MATLABworkspace(varargin)
    data = guidata(gcf);
    if(~isempty(data))
        name = get(gcf,'Name');
        names = strsplit(name);
        name = strjoin(names,'_');
        name = [name,'_GUI_variables'];
        assignin('base',name,data)
    else
        msgbox('There are no variables associated with this GUI.','Warn','warn','modal')
        return
    end
end

end