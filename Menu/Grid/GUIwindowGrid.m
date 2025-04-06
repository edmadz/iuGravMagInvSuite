function GUIwindowGrid

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

windowGrid_ = figure('Menubar','none',...
    'Visible','off',...
    'Name','Window Grid',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowButtonMotionFcn',@mouseMotion);

%--------------------------------------------------------------------------

optionPanel = uipanel(windowGrid_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

popupDist = uicontrol(optionPanel,'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalization','Linear Distribution'},...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036],...
    'CallBack',@colorDistType_callback);

coordConversion = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.03 0.865 0.944 0.036]);

popupExtractionMode = uicontrol(optionPanel,'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Generate Mask Interatively','Generate Mask from File'},...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.944 0.036],...
    'CallBack',@setExtractionMode_callBack);

popupTypeOfGeometry = uicontrol(optionPanel,'Style','popupmenu',...
    'Units','normalized',...
    'String',{'Rectangle','Polygon','Elipse','Freehand'},...
    'fontUnits','normalized',...
    'Visible','on',...
    'position',[0.03 0.765 0.944 0.036]);

popupTypeOfFile = uicontrol(optionPanel,'Style','popupmenu',...
    'Units','normalized',...
    'String',{'PLY','SHAPEFILE'},...
    'fontUnits','normalized',...
    'Visible','off',...
    'position',[0.03 0.765 0.944 0.036]);

btnDrawGeometry = uicontrol(optionPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Draw Geometry',...
    'fontUnits','normalized',...
    'Visible','on',...
    'position',[0.03 0.715 0.944 0.036],...
    'CallBack',@drawGeometry_callBack);

btnLoadGeometry = uicontrol(optionPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Load Geometry',...
    'fontUnits','normalized',...
    'Visible','off',...
    'position',[0.03 0.715 0.944 0.036],...
    'CallBack',@loadGeometry_callBack);

uicontrol(optionPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Apply Window',...
    'fontUnits','normalized',...
    'position',[0.03 0.05 0.944 0.036],...
    'CallBack',@windowGrid_callBack);

%--------------------------------------------------------------------------

graphPanel = uipanel(windowGrid_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graph = axes(graphPanel,'Units','normalized',...
    'position',[0.05 0.05 0.9 0.9]);
set(get(graph,'XAxis'),'Visible','off');
set(get(graph,'YAxis'),'Visible','off');

xCoord = uicontrol(graphPanel,'Style','edit',...
    'Units','normalized',...
    'ToolTipString','X coordinate of data.',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.76 0 0.12 0.035]);

yCoord = uicontrol(graphPanel,'Style','edit',...
    'Units','normalized',...
    'ToolTipString','Y coordinate of data.',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.88 0 0.12 0.035]);

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(windowGrid_,'label','File');
uimenu(file,'Label','Open File...','Accelerator','O','CallBack',@openFile_callBack);
uimenu(file,'Label','Save Windowed Grid...','Accelerator','S','CallBack',@saveFile_callBack);

outline = uimenu(windowGrid_,'label','Outline');
uimenu(outline,'Label','Save Geometry in ply format...',...
    'Accelerator','P','CallBack',@saveGeometryToPLY_callBack);
uimenu(outline,'Label','Save Geometry in shapefile format...',...
    'Accelerator','Q','CallBack',@saveGeometryToSHAPEFILE_callBack);
uimenu(outline,'Label','Delete Outline Geometries','Separator','on',...
    'Accelerator','G','CallBack',@deleteOutline_callBack);

Cmenu = uicontextmenu(windowGrid_);
set(windowGrid_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

maskedData = 'n';
maskCreated = 'n';
dataLoaded = 'n';
maskType = 'none';
set(windowGrid_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%LOAD INPUT DATASET
function openFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);
[cell_dx,cell_dy]=find_cell_size(Xg,Yg);

axes(graph)
pcolor(Xg,Yg,Zg)
shading interp
if(get(popupDist,'Value')==1)
    cmapChanged = colormaps(Z,'clra','equalized');
else
    cmapChanged = colormaps(Z,'clra','linear');
end
colormap(cmapChanged)
axis image
minX = min(Xg(:)); maxX = max(Xg(:));
minY = min(Yg(:)); maxY = max(Yg(:));
width_data = maxX-minX; heigth_data = maxY-minY;
xlim([minX-0.05*width_data,maxX+0.05*width_data])
ylim([minY-0.05*heigth_data,maxY+0.05*heigth_data])

set(graph,'XTickLabel',[])
set(graph,'YTickLabel',[])
set(graph,'XTick',[])
set(graph,'YTick',[])
set(graph,'XColor',[1 1 1])
set(graph,'YColor',[1 1 1])

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.cell_dx = cell_dx;
handles.cell_dy = cell_dy;
dataLoaded = 'y';
%Update de handle structure
guidata(windowGrid_,handles);
end

%CHANGE THE COLOR DISTRIBUTION OF THE ANOMALY MAP
function colorDistType_callback(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    Z = handles.Z;
    
    axes(graph)
    pcolor(Xg,Yg,Zg)
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(Z,'clra','equalized');
        colormap(cmapChanged)
    else
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
    end
    shading interp
    axis image
    width_data = max(Xg(:))-min(Xg(:));
    heigth_data = max(Yg(:))-min(Yg(:));
    xlim([min(Xg(:))-0.1*width_data,max(Xg(:))+0.1*width_data])
    ylim([min(Yg(:))-0.1*heigth_data,max(Yg(:))+0.1*heigth_data])
    
    set(graph,'XTickLabel',[]);
    set(graph,'YTickLabel',[]);
    set(graph,'XTick',[]);
    set(graph,'YTick',[]);
    set(graph,'Box','on');
end

%Update de handle structure
guidata(windowGrid_,handles);
end

%SET THE POLYGON COORDINATE VERTICES
function setExtractionMode_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(dataLoaded=='y')
    if(get(popupExtractionMode,'Value')==1)
        set(popupTypeOfGeometry,'Visible','on')
        set(btnDrawGeometry,'Visible','on')
        set(popupTypeOfFile,'Visible','off')
        set(btnLoadGeometry,'Visible','off')
    else
        set(popupTypeOfGeometry,'Visible','off')
        set(btnDrawGeometry,'Visible','off')
        set(popupTypeOfFile,'Visible','on')
        set(btnLoadGeometry,'Visible','on')
    end
else
    set(popupExtractionMode,'Value',1)
    msgbox('There''s no input dataset loaded.', 'Warn','warn')
    return
end

%Update de handle structure
guidata(windowGrid_,handles);
end

%GENERATE MASK FROM GEOMETRIES
function drawGeometry_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(dataLoaded=='y')
    if(get(popupTypeOfGeometry,'Value')==1)
        h = imrect;
        set(h,'Tag','imroi')
        setColor(h,'black')
        maskType = 'rectangle';
    elseif(get(popupTypeOfGeometry,'Value')==2)
        h = impoly;
        set(h,'Tag','imroi')
        setColor(h,'black')
        maskType = 'polygon';
    elseif(get(popupTypeOfGeometry,'Value')==3)
        h = imellipse;
        set(h,'Tag','imroi')
        setColor(h,'black')
        maskType = 'elipse';
    else
        h = imfreehand;
        set(h,'Tag','imroi')
        setColor(h,'black')
        maskType = 'freehand';
    end
    
    handles.h = h;
    maskCreated = 'y';
else
    msgbox('There''s no input dataset loaded.','Warn','warn')
    return
end
%Update de handle structure
guidata(windowGrid_,handles);
end

%GENERATE A MASK FROM A FILE
function loadGeometry_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(dataLoaded=='y')
    if(get(popupTypeOfFile,'Value')==1) %PLY FILE
        [FileName,PathName] = uigetfile({'*.ply','Data Files (*.ply)'},'Select File');
        Fullpath = [PathName FileName];
        if (sum(Fullpath)==0)
            return
        end
        
        %get the coordinates of ply file
        [X_coordinates,Y_coordinates]=loadPLY(Fullpath);
        X_coordinates=X_coordinates';
        Y_coordinates=Y_coordinates';
        
        hold on
        plot(graph,cat(1,X_coordinates,X_coordinates(1)),cat(1,Y_coordinates,Y_coordinates(1)),'k-')
        hold off
        
        maskType = 'ply';
        maskCreated = 'y';
        handles.X_coordinates = X_coordinates;
        handles.Y_coordinates = Y_coordinates;
    else
        [FileName,PathName] = uigetfile({'*.shp','Data Files (*.shp)'},'Select File');
        Fullpath = [PathName FileName];
        if (sum(Fullpath)==0)
            return
        end
        
        data = shaperead(Fullpath);
        X_coordinates=({data(:).X}); X_coordinates=cell2mat(X_coordinates);
        Y_coordinates=({data(:).Y}); Y_coordinates=cell2mat(Y_coordinates);
        
        hold on
        plot(graph,[X_coordinates(1:end-1),X_coordinates(1)],[Y_coordinates(1:end-1),Y_coordinates(1)],'k-')
        hold off
        
        maskType = 'shapefile';
        maskCreated = 'y';
        handles.X_coordinates = X_coordinates(1:end-1);
        handles.Y_coordinates = Y_coordinates(1:end-1);
    end
else
    msgbox('There''s no input dataset loaded.','Warn','warn')
    return
end
%Update de handle structure
guidata(windowGrid_,handles);
end

%APPLY THE MASK TO GRID
function windowGrid_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(maskCreated=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    if(strcmp(maskType,'polygon') || strcmp(maskType,'freehand'))
        h = handles.h;
        
        pos = getPosition(h);
        
        x = pos(:,1);
        y = pos(:,2);
    elseif(strcmp(maskType,'rectangle'))
        h = handles.h;
        
        pos = getPosition(h);
        xmin = pos(1);
        ymin = pos(2);
        xmax = xmin + pos(3);
        ymax = ymin + pos(4);
        x = [xmin;xmax;xmax;xmin];
        y = [ymin;ymin;ymax;ymax];
    elseif(strcmp(maskType,'elipse'))
        h = handles.h;
        
        pos = getVertices(h);
        
        x = pos(:,1);
        y = pos(:,2);
    elseif(strcmp(maskType,'ply'))
        x = handles.X_coordinates;
        y = handles.Y_coordinates;
    end
    
    [dx,dy]=find_cell_size(Xg,Yg);
    
    xRect = [min(x) max(x) max(x) min(x)];
    yRect = [min(y) min(y) max(y) max(y)];
    intermediaryMask = inpolygon(Xg,Yg,xRect,yRect);
    Xg_ = Xg(intermediaryMask);
    Yg_ = Yg(intermediaryMask);
    Zg_ = Zg(intermediaryMask);
    
    row_ = round((max(Yg_)-min(Yg_))/dy)+1;
    col_ = round((max(Xg_)-min(Xg_))/dx)+1;
    
    Xg_=reshape(Xg_',[row_,col_]);
    Yg_=reshape(Yg_',[row_,col_]);
    Zg_=reshape(Zg_',[row_,col_]);
    
    mask = inpolygon(Xg_,Yg_,x,y);
    mask = double(mask);
    mask(mask==0)=NaN;
    
    Zg_=Zg_.*mask;
    
    plotResult(x,y,Xg,Yg,Zg,Xg_,Yg_,Zg_,get(coordConversion,'Value'))
    
    handles.x = x;
    handles.y = y;
    handles.Xg_ = Xg_;
    handles.Yg_ = Yg_;
    handles.Zg_ = Zg_;
    maskedData = 'y';
else
    msgbox('No mask geometry was provided.', 'Warn','warn')
    return
end

%Update de handle structure
guidata(windowGrid_,handles);
end

%SAVE THE GEOMETRY VERTEXES TO A PLY FILE
function saveGeometryToPLY_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(maskCreated=='y')
    if(strcmp(maskType,'polygon') || strcmp(maskType,'freehand'))
        h = handles.h;
        
        pos = getPosition(h);
        x = pos(:,1);
        y = pos(:,2);
    elseif(strcmp(maskType,'rectangle'))
        h = handles.h;
        
        pos = getPosition(h);
        xmin = pos(1);
        ymin = pos(2);
        xmax = xmin + pos(3);
        ymax = ymin + pos(4);
        x = [xmin;xmax;xmax;xmin];
        y = [ymin;ymin;ymax;ymax];
    elseif(strcmp(maskType,'elipse'))
        h = handles.h;
        
        pos = getVertices(h);
        x = pos(:,1);
        y = pos(:,2);
    else
        x = handles.X_coordinates;
        y = handles.Y_coordinates;
    end
else
    msgbox('No mask geometry was provided.', 'Warn','warn')
    return
end

coordinates = cat(2,x,y);

[FileName,PathName] = uiputfile({'*.ply','Data Files (*.ply)'},'Save File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

fid = fopen(Fullpath,'w+');
fprintf(fid,'%14s\r\n','/#CoordinateSystem="none / none"');
fprintf(fid,'%14s\r\n','/#Datum="none",XXXXXXXXXX,X.XXXXXXXXXX,X');
fprintf(fid,'%14s\r\n','/#Projection="none",X,XX,X.XXXX,');
fprintf(fid,'%9s\r\n','/#Units=m,1');
fprintf(fid,'%14s\r\n','/#LocalDatum="none"');
fprintf(fid,'%6s\r\n','poly 1');
fprintf(fid,'%35f %35f \r\n',transpose(coordinates));
fclose(fid);

%Update de handle structure
guidata(windowGrid_,handles);
end

%SAVE THE GEOMETRY VERTEXES TO A SHAPEFILE
function saveGeometryToSHAPEFILE_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(maskCreated=='y')
    if(strcmp(maskType,'polygon') ||...
            strcmp(maskType,'rectangle') ||...
            strcmp(maskType,'elipse') ||...
            strcmp(maskType,'freehand'))
        h = handles.h;
        
        pos = getPosition(h);
        x = pos(:,1);
        y = pos(:,2);
    else
        x = handles.X_coordinates;
        y = handles.Y_coordinates;
    end
    
    S=struct('Geometry','Polygon','BoundingBox',[min(x),min(y);max(x),max(y)],'X',x,'Y',y,'Id',0);
    
    [FileName,PathName] = uiputfile({'*.shp','Data Files (*.shp)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    shapewrite(S,Fullpath)
else
    msgbox('No mask geometry was provided.','Warn','warn')
    return
end

%Update de handle structure
guidata(windowGrid_,handles);
end

%DELETE THE PLOT OF THE WINDOW MASK FROM THE MAP
function deleteOutline_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(dataLoaded=='y')
    axes(graph)
    
    outline_ = findobj(gca,'type','line');
    if(~isempty(outline_))
        delete(outline_)
    end
    
    outline_ = findobj(gca,'Tag','imroi');
    if(~isempty(outline_))
        delete(outline_)
    end
else
    msgbox('There''s no input dataset loaded.','Warn','warn')
    return
end

%Update de handle structure
guidata(windowGrid_,handles);
end

%SET THE OUTPUT DATASET PATH
function saveFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(windowGrid_);

if(maskedData == 'y')
    X = handles.Xg_;
    Y = handles.Yg_;
    inputFile = handles.Zg_;
    
    outputFile = matrix2xyz(X,Y,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%6s %6s %6s\r\n','X','Y','Z');
    fprintf(fid,'%12.4f %12.4f %12.4f\r\n',transpose(outputFile));
    fclose(fid);
else
    msgbox('There''s no masked data to be saved.', 'Warn','warn')
    return
end
%Update de handle structure
guidata(windowGrid_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

%SHOW CURSOR POSITION WHEN MOUSE CURSOR IS HOVERING OVER SOME AXES OBJECT
function mouseMotion(varargin)
    C = get(graph,'CurrentPoint');
    
    xlim = get(graph,'xlim');
    ylim = get(graph,'ylim');
    outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
    outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
    if (outX && outY && dataLoaded=='y') %VERIFY IF MOUSE IS HOVERING OVER THE GRAPH
        set(xCoord,'String',['X: ',num2str(C(1,1))])
        set(yCoord,'String',['Y: ',num2str(C(1,2))])
    end
end

function [X,Y]=loadPLY(filePath)
    fid = fopen(filePath);
    A = fgets(fid);
    i = 0;
    
    while ischar(A)
        [v,count] = sscanf(A,'%f',[1 2]);
        if(count==2)
            i = i + 1;
            X(i) = v(1);
            Y(i) = v(2);
        end
        A = fgets(fid);
    end
end

function plotResult(x,y,Xg,Yg,Zg,Xg_,Yg_,Zg_,ConvCoord)
    
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
    
    figWidth__=1300;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    g1 = subplot(1,2,1);
    pcolor(Xg,Yg,Zg)
    shading interp
    [row,col]=size(Zg);
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','equalized');
        colormap(g1,cmapChanged)
    else
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','linear');
        colormap(g1,cmapChanged)
    end
    c=colorbar;
    set(get(c,'Label'),'String','Quantity (Unit)')
    set(get(c,'Label'),'FontWeight','bold')
    title('Input Map')
    xlabel(labelX,'FontWeight','bold')
    ylabel(labelY,'FontWeight','bold')
    axis image
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
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
    set(gca,'FontSize',17)
    set(gca,'Box','on')
    hold on
    ptc = patch(x,y,'red');
    set(ptc,'EdgeColor','black',...
        'FaceColor','none','LineWidth',2)
    hold off
    
    g2 = subplot(1,2,2);
    pcolor(Xg_,Yg_,Zg_)
    shading interp
    [row,col]=size(Zg_);
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(reshape(Zg_,[row*col,1]),'clra','equalized');
        colormap(g2,cmapChanged)
    else
        cmapChanged = colormaps(reshape(Zg_,[row*col,1]),'clra','linear');
        colormap(g2,cmapChanged)
    end
    c=colorbar;
    set(get(c,'Label'),'String','Quantity (Unit)')
    set(get(c,'Label'),'FontWeight','bold')
    title('Windowed Map')
    xlabel(labelX,'FontWeight','bold')
    ylabel(labelY,'FontWeight','bold')
    axis image
    minX = min(Xg_(:)); maxX = max(Xg_(:));
    minY = min(Yg_(:)); maxY = max(Yg_(:));
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
    set(gca,'FontSize',17)
    set(gca,'Box','on')
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