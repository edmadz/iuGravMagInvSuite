function GUIregridData

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIregridData_ = figure('Name','Regrid Data',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Visible','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUIregridData_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUIregridData_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------
popupDist = uicontrol(GUIregridData_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

minX_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Minimum coordinate in x direction.',...
    'Position',[0.3 0.625 0.14 0.08]);

maxX_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Maximum coordinate in x direction.',...
    'Position',[0.47 0.625 0.14 0.08]);

spaceX_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Interpolation cell width.',...
    'Position',[0.64 0.625 0.14 0.08],...
    'CallBack',@spaceX_callBack);

nodesX_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Number of grid dots in x direction.',...
    'Position',[0.81 0.625 0.14 0.08],...
    'CallBack',@nodesX_callBack);

minY_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Minimum coordinate in y direction.',...
    'Position',[0.3 0.525 0.14 0.08]);

maxY_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Maximum coordinate in y direction.',...
    'Position',[0.47 0.525 0.14 0.08]);

spaceY_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Interpolation cell height.',...
    'Position',[0.64 0.525 0.14 0.08],...
    'CallBack',@spaceY_callBack);

nodesY_ = uicontrol(GUIregridData_,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Number of grid dots in y direction.',...
    'Position',[0.81 0.525 0.14 0.08],...
    'CallBack',@nodesY_callBack);

interpolationMethod = uicontrol(GUIregridData_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String', {'Interpolate Method','Spline','Bilinear','Bicubic','Nearest Neighbor'},...
    'fontUnits','normalized',...
    'position',[0.3 0.425 0.32 0.08]);

coordConversion = uicontrol(GUIregridData_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.63 0.425 0.32 0.08]);

uicontrol(GUIregridData_,'Style','pushbutton',...
    'units','normalized',...
    'String','Regrid Data',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@interpolate_callBack);

%--------------------------------------------------------------------------

uicontrol(GUIregridData_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUIregridData_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUIregridData_);
set(GUIregridData_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
filterApplied = 'n';
set(GUIregridData_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

minX = min(Xg(:)); maxX = max(Xg(:));
minY = min(Yg(:)); maxY = max(Yg(:));

set(minX_,'String',num2str(minX))
set(maxX_,'String',num2str(maxX))
set(minY_,'String',num2str(minY))
set(maxY_,'String',num2str(maxY))

[row,col] = size(Zg);
nodesX = col;
nodesY = row;

set(nodesX_,'String',num2str(col))
set(nodesY_,'String',num2str(row))

spaceX = (maxX-minX)/(nodesX-1);
spaceY = (maxY-minY)/(nodesY-1);
set(spaceX_,'String',num2str(spaceX))
set(spaceY_,'String',num2str(spaceY))

set(inputFile_path,'String',num2str(Fullpath))

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
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
guidata(GUIregridData_,handles);
end

function spaceX_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);
minX = handles.minX;
maxX = handles.maxX;

nodesX = ((maxX-minX)/str2double(get(spaceX_,'String'))) + 1;
set(nodesX_,'String',num2str(nodesX))

handles.nodesX = nodesX;
%Update de handle structure
guidata(GUIregridData_,handles);
end

function spaceY_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);
minY = handles.minY;
maxY = handles.maxY;

nodesY = ((maxY-minY)/str2double(get(spaceY_,'String'))) + 1;
set(nodesY_,'String',num2str(nodesY))

handles.nodesY = nodesY;
%Update de handle structure
guidata(GUIregridData_,handles);
end

function nodesX_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);
minX = handles.minX;
maxX = handles.maxX;

spaceX = (maxX-minX)/(str2double(get(nodesX_,'String'))-1);
set(spaceX_,'String',num2str(spaceX))

handles.spaceX = spaceX;
%Update de handle structure
guidata(GUIregridData_,handles);
end

function nodesY_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);
minY = handles.minY;
maxY = handles.maxY;

spaceY = (maxY-minY)/(str2double(get(nodesY_,'String'))-1);
set(spaceY_,'String',num2str(spaceY))

handles.spaceY = spaceY;
%Update de handle structure
guidata(GUIregridData_,handles);
end

%REGRID A GRID
function interpolate_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    nodesX = str2double(get(nodesX_,'String'));
    nodesY = str2double(get(nodesY_,'String'));
    
    x = linspace(minX,maxX,nodesX);
    y = linspace(minY,maxY,nodesY);
    
    [xq,yq] = meshgrid(x,y);
    
    if(get(interpolationMethod,'Value')==2)
        vq = interp2(Xg,Yg,Zg,xq,yq,'spline');
    elseif(get(interpolationMethod,'Value')==3)
        vq = interp2(Xg,Yg,Zg,xq,yq,'linear');
    elseif(get(interpolationMethod,'Value')==4)
        vq = interp2(Xg,Yg,Zg,xq,yq,'cubic');
    elseif(get(interpolationMethod,'Value')==5)
        vq = interp2(Xg,Yg,Zg,xq,yq,'nearest');
    else
        msgbox('Select some interpolation method.','Warn','warn','modal')
        return
    end
    
    d = get(popupDist,'Value');
    c = get(coordConversion,'Value');
    [fig1,fig2]=generateResultFigures(650,700,Xg,Yg,Zg,vq,d,d,'clra','clra',c);
    
    %link the axes of the result figures
    h_1=zoom(fig1); set(h_1,'ActionPostCallback',@linkAxes)
    h_2=zoom(fig2); set(h_2,'ActionPostCallback',@linkAxes)
    p_1=pan(fig1); set(p_1,'ActionPostCallback',@linkAxes)
    p_2=pan(fig2); set(p_2,'ActionPostCallback',@linkAxes)
    
    set(fig1,'WindowButtonDownFcn',@mouseButtonD)
    set(fig2,'WindowButtonDownFcn',@mouseButtonD)
    
    handles.xq = xq;
    handles.yq = yq;
    handles.vq = vq;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to regrid a grid.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUIregridData_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIregridData_);
xq = handles.xq;
yq = handles.yq;
inputFile = handles.vq;

outputFile = matrix2xyz(xq,yq,inputFile);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

set(outputFile_path,'String',num2str(Fullpath));

fid = fopen(Fullpath,'w+');
fprintf(fid,'%6s %6s %14s\r\n','X','Y','Z');
fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(GUIregridData_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

%GET CURSOR POSITION WHEN MOUSE BUTTON IS PRESSED OVER SOME AXES OBJECT
function mouseButtonD(varargin)
    ax = findobj('type','axes');
    if(length(ax)<2)
        msgbox('Close the map window and apply the filter again.','Warn','warn')
        return
    end
    xl=get(ax(1),'Xlim');
    width__ = xl(2)-xl(1);
    
    C = get(ax(1),'CurrentPoint');
    xlim = get(ax(1),'xlim');
    ylim = get(ax(1),'ylim');
    outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
    outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
    if (outX && outY && filterApplied=='y')
        if(strcmp(get(gcf,'selectiontype'),'normal'))
            cl_ = width__*0.05;
            line=findobj('type','line','-and','Tag','cross');
            if(~isempty(line))
                delete(line)
            end
            axes(ax(1))
            hold on
            plot([C(1,1)-(cl_/2),C(1,1)+(cl_/2),NaN,C(1,1),C(1,1)],...
                [C(1,2),C(1,2),NaN,C(1,2)-(cl_/2),C(1,2)+(cl_/2)],...
                'k-','linewidth',2,'Tag','cross')
            hold off
            
            axes(ax(2))
            hold on
            plot([C(1,1)-(cl_/2),C(1,1)+(cl_/2),NaN,C(1,1),C(1,1)],...
                [C(1,2),C(1,2),NaN,C(1,2)-(cl_/2),C(1,2)+(cl_/2)],...
                'k-','linewidth',2,'Tag','cross')
            hold off
        elseif(strcmp(get(gcf,'selectiontype'),'alt'))
            line=findobj('type','line','-and','Tag','cross');
            if(~isempty(line))
                delete(line)
            end
        end
    end
end

%SET EQUAL THE AXES LIMITS OF THE RESULT FIGURES
function linkAxes(varargin)
    h=findobj('type','figure','-and','Tag','fig_');
    N=length(h);
    
    %Link the axis
    if(N==2)
        a1 = get(h(1),'CurrentAxes');
        a2 = get(h(2),'CurrentAxes');
        set(a2,'xlim',get(a1,'xlim'))
        set(a2,'ylim',get(a1,'ylim'))
    end
    
    %Update the crosses if they exist
    line=findobj('type','line','-and','Tag','cross');
    if(~isempty(line))
        l=line(1);
        x_l = get(l,'XData');
        y_l = get(l,'YData');
        if(diff(x_l)==0) %vertical line of the cross
            C=[(x_l(1)),((y_l(1)+y_l(2))/2)];
        else
            C=[((x_l(1)+x_l(2))/2),(y_l(1))];
        end
        delete(line)
        
        xl=get(a1,'Xlim');
        width__ = xl(2)-xl(1);
        cl_ = width__*0.05;
        
        axes(a1)
        hold on
        plot([C(1,1)-(cl_/2),C(1,1)+(cl_/2),NaN,C(1,1),C(1,1)],...
            [C(1,2),C(1,2),NaN,C(1,2)-(cl_/2),C(1,2)+(cl_/2)],...
            'k-','linewidth',2,'Tag','cross')
        hold off
        
        axes(a2)
        hold on
        plot([C(1,1)-(cl_/2),C(1,1)+(cl_/2),NaN,C(1,1),C(1,1)],...
            [C(1,2),C(1,2),NaN,C(1,2)-(cl_/2),C(1,2)+(cl_/2)],...
            'k-','linewidth',2,'Tag','cross')
        hold off
    end
    
    %update the ticklabels of both axis
    xl_h1 = get(get(h(1),'CurrentAxes'),'Xlim');
    yl_h1 = get(get(h(1),'CurrentAxes'),'Ylim');
    xl_h2 = get(get(h(2),'CurrentAxes'),'Xlim');
    yl_h2 = get(get(h(2),'CurrentAxes'),'Ylim');
    
    Xcoord_1 = round(linspace(xl_h1(1),xl_h1(2),5));
    Ycoord_1 = round(linspace(yl_h1(1),yl_h1(2),5));
    Xcoord_2 = round(linspace(xl_h2(1),xl_h2(2),5));
    Ycoord_2 = round(linspace(yl_h2(1),yl_h2(2),5));
    
    set(get(h(1),'CurrentAxes'),'XTick',Xcoord_1)
    set(get(h(1),'CurrentAxes'),'YTick',Ycoord_1)
    set(get(h(2),'CurrentAxes'),'XTick',Xcoord_2)
    set(get(h(2),'CurrentAxes'),'YTick',Ycoord_2)
    
    xc_1 = prepCoord(Xcoord_1); yc_1 = prepCoord(Ycoord_1);
    xc_2 = prepCoord(Xcoord_2); yc_2 = prepCoord(Ycoord_2);
    
    set(get(h(1),'CurrentAxes'),'XTickLabel',xc_1)
    set(get(h(1),'CurrentAxes'),'YTickLabel',yc_1)
    set(get(h(2),'CurrentAxes'),'XTickLabel',xc_2)
    set(get(h(2),'CurrentAxes'),'YTickLabel',yc_2)
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