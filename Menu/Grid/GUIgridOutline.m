function GUIgridOutline

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIgridOutline_ = figure('Name','Grid Outline',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUIgridOutline_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUIgridOutline_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------
popupDist = uicontrol(GUIgridOutline_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

uicontrol(GUIgridOutline_,'Style','pushbutton',...
    'units','normalized',...
    'String','Generate Outline',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@gridOutline_callBack);
%--------------------------------------------------------------------------

uicontrol(GUIgridOutline_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUIgridOutline_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUIgridOutline_);
set(GUIgridOutline_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
filterApplied = 'n';
set(GUIgridOutline_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridOutline_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

set(inputFile_path,'String',num2str(Fullpath))

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
dataLoaded = 'y';
%Update de handle structure
guidata(GUIgridOutline_,handles);
end

%GENERATE THE GRID OUTLINE
function gridOutline_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridOutline_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    [x,y]=gridOutline(Xg,Yg,Zg);
    outline=cat(2,x,y);
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    figWidth__=600;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__-8;
    posY_ = H/2 - figHeight__/2;
    
    fig1=figure('units','pixel','Tag','fig_',...
        'position',[posX_ posY_ figWidth__ figHeight__]);
    pcolor(Xg,Yg,Zg)
    [row,col]=size(Zg);
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','equalized');
        colormap(cmapChanged)
    else
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','linear');
        colormap(cmapChanged)
    end
    shading interp
    title('INPUT DATA')
    xlabel('Easting (m)','FontWeight','bold')
    ylabel('Northing (m)','FontWeight','bold')
    set(gca,'fontSize',17)
    axis image
    grid on
    set(gca,'Box','on')
    width__=max(Xg(:))-min(Xg(:));
    height__=max(Yg(:))-min(Yg(:));
    axis([min(Xg(:))-(width__*0.01) max(Xg(:))+(width__*0.01) min(Yg(:))-(height__*0.01) max(Yg(:))+(height__*0.01)])
    set(gca,'YTickLabelRotation',90)
    Y_coord = linspace(minY,maxY,5);
    set(gca,'YTick',Y_coord)
    Y_coord_ = prepCoord(Y_coord);
    set(gca,'YTickLabel',Y_coord_)
    X_coord = linspace(minX,maxX,5);
    set(gca,'XTick',X_coord)
    X_coord_ = prepCoord(X_coord);
    set(gca,'XTickLabel',X_coord_)
    xl=xlim; yl=ylim;
    
    posX_ = W/2+8;
    fig2=figure('units','pixel','Tag','fig_',...
        'position',[posX_ posY_ figWidth__ figHeight__]);
    patch(x,y,'w')
    xlabel('Easting (m)','FontWeight','bold')
    ylabel('Northing (m)','FontWeight','bold')
    title('Grid Outline')
    axis image
    set(gca,'fontSize',17)
    xlim([xl(1) xl(2)])
    ylim([yl(1) yl(2)])
    grid on
    set(gca,'Box','on')
    set(gca,'YTickLabelRotation',90)
    Y_coord = linspace(minY,maxY,5);
    set(gca,'YTick',Y_coord)
    Y_coord_ = prepCoord(Y_coord);
    set(gca,'YTickLabel',Y_coord_)
    X_coord = linspace(minX,maxX,5);
    set(gca,'XTick',X_coord)
    X_coord_ = prepCoord(X_coord);
    set(gca,'XTickLabel',X_coord_)
    
    %link the axes of the result figures
    h_1=zoom(fig1); set(h_1,'ActionPostCallback',@linkAxes)
    h_2=zoom(fig2); set(h_2,'ActionPostCallback',@linkAxes)
    p_1=pan(fig1); set(p_1,'ActionPostCallback',@linkAxes)
    p_2=pan(fig2); set(p_2,'ActionPostCallback',@linkAxes)
    
    handles.outline = outline;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to generate the grid outline.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIgridOutline_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgridOutline_);

if(filterApplied=='y')
    outline=handles.outline;
    
    [FileName,PathName] = uiputfile({'*.ply','Data Files (*.ply)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%14s\r\n','/#CoordinateSystem="none / none"');
    fprintf(fid,'%14s\r\n','/#Datum="none",XXXXXXXXXX,X.XXXXXXXXXX,X');
    fprintf(fid,'%14s\r\n','/#Projection="none",X,XX,X.XXXX,');
    fprintf(fid,'%9s\r\n','/#Units=m,1');
    fprintf(fid,'%14s\r\n','/#LocalDatum="none"');
    fprintf(fid,'%6s\r\n','poly 1');
    fprintf(fid,'%35f %35f \r\n',transpose(outline));
    fclose(fid);
else
    msgbox('Generate the grid outline before trying to save the output file.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIgridOutline_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

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