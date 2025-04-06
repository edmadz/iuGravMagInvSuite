function GUItrendRemoval

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUItrendRemoval_ = figure('Name','Trend Removal',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUItrendRemoval_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUItrendRemoval_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);
%--------------------------------------------------------------------------
popupDist = uicontrol(GUItrendRemoval_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

popupSaveTrend = uicontrol(GUItrendRemoval_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Save trend surface','Don''t save trend surface'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.625 0.65 0.08]);

n = uicontrol(GUItrendRemoval_,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'TooltipString','Polynomial degree [high values must generate unstable results].',...
    'Position',[0.3 0.525 0.32 0.08]);

coordConversion = uicontrol(GUItrendRemoval_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.63 0.525 0.32 0.08]);

showTrend = uicontrol(GUItrendRemoval_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Do not show trend surface','Show trend surface'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.3 0.425 0.65 0.08]);
%--------------------------------------------------------------------------

uicontrol(GUItrendRemoval_,'Style','pushbutton',...
    'units','normalized',...
    'String','Remove Trend',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@trendRemoval_callBack);

uicontrol(GUItrendRemoval_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUItrendRemoval_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUItrendRemoval_);
set(GUItrendRemoval_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
trendRemoved = 'n';
set(GUItrendRemoval_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN A DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUItrendRemoval_);

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
handles.FileName = FileName;
dataLoaded = 'y';
%Update de handle structure
guidata(GUItrendRemoval_,handles);
end

%TREND REMOVAL
function trendRemoval_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUItrendRemoval_);

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    degree = str2double(get(n,'String'));
    [output,trend,~] = removetrend(Zg,degree);
    
    d = get(popupDist,'Value');
    c = get(coordConversion,'Value');
    [fig1,fig2]=generateResultFigures(650,700,Xg,Yg,Zg,output,d,d,'clra','clra',c);
    
    if(get(showTrend,'Value')==2)
        figWidth__=650;
        figHeight__=700;
        Pix_SS = get(0,'screensize');
        W = Pix_SS(3);
        H = Pix_SS(4);
        posX_ = W/2 - figWidth__/2;
        posY_ = H/2 - figHeight__/2;
        
        figure('units','pixel',...
            'position',[posX_ posY_ figWidth__ figHeight__])
        pcolor(Xg,Yg,trend)
        [row,col]=size(trend);
        if(d==1)
            cmapChanged = colormaps(reshape(trend,[row*col,1]),'clra','equalized');
            colormap(cmapChanged)
        else
            cmapChanged = colormaps(reshape(trend,[row*col,1]),'clra','linear');
            colormap(cmapChanged)
        end
        shading interp
        c=colorbar;
        set(get(c,'Label'),'String','Quantity (Unit)')
        set(get(c,'Label'),'FontWeight','bold')
        title('Trend Surface')
        labelX = 'Easting (units)';
        labelY = 'Northing (units)';
        xlabel(labelX,'FontWeight','bold')
        ylabel(labelY,'FontWeight','bold')
        axis image
        set(gca,'Xlim',[minX maxX])
        set(gca,'Ylim',[minY maxY])
        set(gca,'YTickLabelRotation',90)
        Y_coord = linspace(minY,maxY,5);
        set(gca,'YTick',Y_coord)
        Y_coord_ = prepCoord(Y_coord);
        set(gca,'YTickLabel',Y_coord_)
        X_coord = linspace(minX,maxX,5);
        set(gca,'XTick',X_coord)
        X_coord_ = prepCoord(X_coord);
        set(gca,'XTickLabel',X_coord_)
        set(gca,'FontSize',17)
        set(gca,'Box','on')
    end
    
    %link the axes of the result figures
    h_1=zoom(fig1); set(h_1,'ActionPostCallback',@linkAxes)
    h_2=zoom(fig2); set(h_2,'ActionPostCallback',@linkAxes)
    p_1=pan(fig1); set(p_1,'ActionPostCallback',@linkAxes)
    p_2=pan(fig2); set(p_2,'ActionPostCallback',@linkAxes)
    
    set(fig1,'WindowButtonDownFcn',@mouseButtonD)
    set(fig2,'WindowButtonDownFcn',@mouseButtonD)
    
    handles.output = output;
    handles.trend = trend;
    trendRemoved = 'y';
else
    msgbox('Load some data before trying to remove trend.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUItrendRemoval_,handles);
end

%SET THE OUTPUT DATASET PATH
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUItrendRemoval_);

if(trendRemoved == 'y')
    X = handles.X;
    Y = handles.Y;
    inputFile_1 = handles.output;
    
    outputFile_1 = matrix2xyz(X,Y,inputFile_1);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%6s %6s %14s\r\n','X','Y','Z');
    fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile_1));
    fclose(fid);
    
    if(get(popupSaveTrend,'Value')==1)
        inputFile_2 = handles.trend;
        
        outputFile_2 = matrix2xyz(X,Y,inputFile_2);
        
        name = FileName;
        name = strsplit(name,'.');
        name_ = char(name(1));
        name_ = strcat(name_,'_trend_surface.',char(name(2)));
        
        Fullpath = strcat(PathName,name_);
        
        fid = fopen(Fullpath,'w+');
        fprintf(fid,'%6s %6s %14s\r\n','X','Y','Trend');
        fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile_2));
        fclose(fid);
    end
else
    msgbox('Remove trend before trying to save the output file.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUItrendRemoval_,handles);
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