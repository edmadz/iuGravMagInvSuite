function GUIextractProfile

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIextractProfile_ = figure('Menubar','none',...
    'Name','Extract Profile from a Grid',...
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

parameters = uipanel(GUIextractProfile_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

popupDist = uicontrol(parameters,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036],...
    'Callback',@colorDistType_callback);

profileSamples=uicontrol(parameters,...
    'TooltipString','Number of profile samples.',...
    'Style','edit',...
    'Units','normalized',...
    'String','200',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.944 0.036]);

extractionType = uicontrol(parameters,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Extract interactively','Extract a row','Extract a column','Extract from a Control File'},...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.944 0.036],...
    'Callback',@extractionType_callback);

profileType = uicontrol(parameters,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Visible','on',...
    'Value',1,...
    'String',{'Single Line','Polyline'},...
    'fontUnits','normalized',...
    'position',[0.03 0.615 0.944 0.036]);

firstColumnType = uicontrol(parameters,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Visible','on',...
    'Value',1,...
    'String',{'Profile with x axis','Profile with y axis','Profile with true distance'},...
    'fontUnits','normalized',...
    'position',[0.03 0.565 0.944 0.036]);

interpMode = uicontrol(parameters,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Linear','Spline','Cubic'},...
    'fontUnits','normalized',...
    'position',[0.03 0.515 0.944 0.036]);

uicontrol(parameters,...
    'Style','pushbutton',...
    'Units','normalized',...
    'String','Extract Profile',...
    'fontUnits','normalized',...
    'position',[0.03 0.465 0.944 0.036],...
    'Callback',@extractProfile_callback);

txtRow = uicontrol(parameters,...
    'Style','text',...
    'Units','normalized',...
    'Visible','off',...
    'String','Row:1',...
    'fontUnits','normalized',...
    'position',[0.03 0.65 0.944 0.036]);

sliderRow = uicontrol(parameters,...
    'Style','slider',...
    'Units','normalized',...
    'Visible','off',...
    'Min',1,'Max',10,'Value',1,...
    'SliderStep',[0.1 0.2],...
    'position',[0.03 0.615 0.944 0.036],...
    'Callback',@currentRow_callback);

txtColumn = uicontrol(parameters,...
    'Style','text',...
    'Units','normalized',...
    'Visible','off',...
    'String','Column:1',...
    'fontUnits','normalized',...
    'position',[0.03 0.65 0.944 0.036]);

sliderColumn = uicontrol(parameters,...
    'Style','slider',...
    'Units','normalized',...
    'Visible','off',...
    'Min',1,'Max',10,'Value',1,...
    'SliderStep',[0.1 0.2],...
    'position',[0.03 0.615 0.944 0.036],...
    'Callback',@currentColumn_callback);

X_ar_=uicontrol(parameters,...
    'Style','edit',...
    'Units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.03 0.165 0.3 0.036]);

Y_ar_=uicontrol(parameters,...
    'Style','edit',...
    'Units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.35 0.165 0.3 0.036]);

Z_ar_=uicontrol(parameters,...
    'Style','edit',...
    'Units','normalized',...
    'String','0.3',...
    'fontUnits','normalized',...
    'position',[0.67 0.165 0.3 0.036]);

uicontrol(parameters,...
    'Style','pushbutton',...
    'Units','normalized',...
    'String','Profile 3D View',...
    'fontUnits','normalized',...
    'position',[0.03 0.115 0.944 0.036],...
    'Callback',@profile3DView_callback);

uicontrol(parameters,...
    'Style','pushbutton',...
    'Units','normalized',...
    'String','Remove Profile Marks',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'Callback',@removeProfileMark_callback);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIextractProfile_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graph = axes(graphPanel,...
    'Units','normalized',...
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

file = uimenu(GUIextractProfile_,'label','File');
uimenu(file,'Label','Open a Gridded Data...','Accelerator','O','CallBack',@openFile_callback);
uimenu(file,'Label','Save Profile...','Accelerator','S','CallBack',@saveFile_callBack);

controlFile = uimenu(GUIextractProfile_,'label','Control File');
uimenu(controlFile,'Label','Load Control File...','Accelerator','K','CallBack',@loadControlFile_callBack);
uimenu(controlFile,'Label','Save Control File...','Accelerator','K','CallBack',@saveControlFile_callback);

Cmenu = uicontextmenu(GUIextractProfile_);
set(GUIextractProfile_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

f=1;
dataLoaded = 'n';
profileExtracted = 'n';
set(GUIextractProfile_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACK
%--------------------------------------------------------------------------

%LOAD INPUT GRID FILE
function openFile_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

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

[row,col] = size(Xg);
set(sliderRow,'max',row)
set(sliderRow,'SliderStep',[1/row 0.2])
set(sliderColumn,'max',col)
set(sliderColumn,'SliderStep',[1/col 0.2])

[cell_dx,cell_dy] = find_cell_size(Xg,Yg);

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.row = row;
handles.col = col;
handles.cell_dx = cell_dx;
handles.cell_dy = cell_dy;
dataLoaded = 'y';
%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%CHANGE THE COLOR DISTRIBUTION OF THE ANOMALY MAP
function colorDistType_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

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
    
    set(graph,'XTickLabel',[]);
    set(graph,'YTickLabel',[]);
    set(graph,'XTick',[]);
    set(graph,'YTick',[]);
    set(graph,'Box','on');
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%SET THE EXTRACTION TYPE
function extractionType_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(get(extractionType,'Value')==1)
    set(profileType,'Visible','on')
    set(txtRow,'Visible','off')
    set(sliderRow,'Visible','off')
    set(txtColumn,'Visible','off')
    set(sliderColumn,'Visible','off')
elseif(get(extractionType,'Value')==2)
    set(txtRow,'Visible','on')
    set(sliderRow,'Visible','on')
    set(txtColumn,'Visible','off')
    set(sliderColumn,'Visible','off')
    set(profileType,'Visible','off')
elseif(get(extractionType,'Value')==3)
    set(txtColumn,'Visible','on')
    set(sliderColumn,'Visible','on')
    set(txtRow,'Visible','off')
    set(sliderRow,'Visible','off')
    set(profileType,'Visible','off')
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%EXTRACT THE PROFILE FROM THE GRID
function extractProfile_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(dataLoaded=='y')
    N = str2double(get(profileSamples,'String'));
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    cell_dx = handles.cell_dx;
    cell_dy = handles.cell_dy;
    
    figWidth__=1360;
    figHeight__=500;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    f=figure('NumberTitle','off','Name','Profile','Visible','off',...
        'units','pixel','position',[posX_ posY_ figWidth__ figHeight__]);
    
    if(get(extractionType,'Value')==1)         %Interactively
        if(get(profileType,'Value')==1)        %Single Line
            axes(graph)
            h = imline();
            pos=getPosition(h);
            x = pos(:,1);
            y = pos(:,2);
            
            plotProfileOverMap(x,y)
            delete(h)
            
            [x,y,d,a] = extractProfile(Xg,Yg,Zg,x,y,N,get(interpMode,'Value'));
            
            if(get(firstColumnType,'Value')==1)
                
                plotExtractedProfile(x,a)
                
                handles.x = x;
                handles.y = y;
                handles.firstColumn = x;
                handles.a = a;
            elseif(get(firstColumnType,'Value')==2)
                
                plotExtractedProfile(y,a)
                
                handles.x = x;
                handles.y = y;
                handles.firstColumn = y;
                handles.a = a;
            elseif(get(firstColumnType,'Value')==3)
                
                plotExtractedProfile(d,a)
                
                handles.x = x;
                handles.y = y;
                handles.firstColumn = d;
                handles.a = a;
            end
        elseif(get(profileType,'Value')==2)    %Polyline
            axes(graph)
            h = impoly('Closed',false);
            pos=getPosition(h);
            x = pos(:,1);
            y = pos(:,2);
            
            plotProfileOverMap(x,y)
            delete(h)
            
            [x,y,d,a] = extractProfile(Xg,Yg,Zg,x,y,N,get(interpMode,'Value'));
            
            if(get(firstColumnType,'Value')==1)
                
                plotExtractedProfile(x,a)
                
                handles.x = x;
                handles.y = y;
                handles.firstColumn = x;
                handles.a = a;
            elseif(get(firstColumnType,'Value')==2)
                
                plotExtractedProfile(y,a)
                
                handles.x = x;
                handles.y = y;
                handles.firstColumn = y;
                handles.a = a;
            elseif(get(firstColumnType,'Value')==3)
                
                plotExtractedProfile(d,a)
                
                handles.x = x;
                handles.y = y;
                handles.firstColumn = d;
                handles.a = a;
            end
        end
    elseif(get(extractionType,'Value')==2)     %Row
        current_row = ceil(get(sliderRow,'Value'));
        x_profile = Xg(current_row,:);
        y_profile = Yg(current_row,:);
        a_profile = Zg(current_row,:);
        
        h = findobj(gca,'Type','line');
        if(~isempty(h))
            delete(h)
        end
        axes(graph)
        hold on
        plot([min(Xg(:)) max(Xg(:))],[min(Yg(:))+current_row*cell_dy min(Yg(:))+current_row*cell_dy],'k-')
        axis([min(Xg(:)) max(Xg(:)) min(Yg(:)) max(Yg(:))])
        hold off
        
        plotExtractedProfile(x_profile,a_profile)
        
        handles.x = x_profile;
        handles.y = y_profile;
        handles.firstColumn = x_profile;
        handles.a = a_profile;
    elseif(get(extractionType,'Value')==3)     %Column
        current_col = ceil(get(sliderColumn,'Value'));
        x_profile = Yg(:,current_col);
        y_profile = Xg(:,current_col);
        a_profile = Zg(:,current_col);
        
        h = findobj(gca,'Type','line');
        if(~isempty(h))
            delete(h)
        end
        axes(graph)
        hold on
        plot([min(Xg(:))+current_col*cell_dx min(Xg(:))+current_col*cell_dx],[min(Yg(:)) max(Yg(:))],'k-')
        axis([min(Xg(:)) max(Xg(:)) min(Yg(:)) max(Yg(:))])
        hold off
        
        plotExtractedProfile(x_profile,a_profile)
        
        handles.x = x_profile;
        handles.y = y_profile;
        handles.firstColumn = x_profile;
        handles.a = a_profile;
    elseif(get(extractionType,'Value')==4) %from control file
        x=handles.controlX;
        y=handles.controlY;
        
        [x,y,d,a] = extractProfile(Xg,Yg,Zg,x,y,N,get(interpMode,'Value'));
        
        x=x';
        y=y';
        d=d';
        a=a';
        
        if(get(firstColumnType,'Value')==1)
            
            plotExtractedProfile(x,a)
            
            handles.x = x;
            handles.y = y;
            handles.firstColumn = x;
            handles.a = a;
        elseif(get(firstColumnType,'Value')==2)
            
            plotExtractedProfile(y,a)
            
            handles.x = x;
            handles.y = y;
            handles.firstColumn = y;
            handles.a = a;
        elseif(get(firstColumnType,'Value')==3)
            
            plotExtractedProfile(d,a)
            
            handles.x = x;
            handles.y = y;
            handles.firstColumn = d;
            handles.a = a;
        end
    end
    
    profileExtracted = 'y';
else
    msgbox('Load some data before trying to extract the profile.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%SAVE CONTROL FILE
function saveControlFile_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(profileExtracted=='y')
    line=findobj(gca,'type','line');
    if(~isempty(line) || length(line)==1)
        x=line.XData;
        y=line.YData;
        
        outputFile = cat(2,x',y');
        
        [filename, pathname] = uiputfile('*.dat','Save Profile...');
        Fullpath = [pathname filename];
        if (sum(Fullpath)==0)
            return
        end
        
        fid = fopen(Fullpath,'w+');
        fprintf(fid,'%8s %8s\r\n','x','y');
        fprintf(fid,'%12.6f %12.6f\r\n',transpose(outputFile));
        fclose(fid);
    else
        msgbox('There is no profile line drawned on the map area.','Warn','warn','modal')
        return
    end
else
    msgbox('Extract a profile from data before trying to save a control file.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%LOAD CONTROL FILE
function loadControlFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(dataLoaded=='y')
    [FileName,PathName] = uigetfile({'*.dat','Data Files (*.dat)'},'Select a Control File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    data=importdata(Fullpath);
    data=data.data;
    x=data(:,1);
    y=data(:,2);
    
    hold on
    axes(graph)
    plot(x,y,'k-')
    text(x(1),y(1),'A')
    text(x(end),y(end),'B')
    hold off
    
    handles.controlX = x;
    handles.controlY = y;
else
    msgbox('Load some data before trying to load some control file.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%SHOW A 3D VIEW OF THE PROFILE
function profile3DView_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(profileExtracted=='y')
    x = handles.x;
    y = handles.y;
    a = handles.a;
    Xg = handles.Xg;
    Yg = handles.Yg;
    X_ar = str2double(get(X_ar_,'String'));
    Y_ar = str2double(get(Y_ar_,'String'));
    Z_ar = str2double(get(Z_ar_,'String'));
    
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    plot3(x./1000,y./1000,a,'k-','lineWidth',2)
    xlabel('Easting [km]')
    ylabel('Northing [km]')
    title('Profile 3D View')
    xlim([min(Xg(:))./1000 max(Xg(:))./1000])
    ylim([min(Yg(:))./1000 max(Yg(:))./1000])
    set(gca,'fontSize',14)
    pbaspect([X_ar Y_ar Z_ar])
    view(-24,27)
    grid on
    grid minor
else
    msgbox('Extract a profile from data before trying to show the profile 3d view.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%DELETE THE PROFILE PLOTS FROM INPUT DATA GRAPH AREA
function removeProfileMark_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(profileExtracted=='y')
    l = findobj(graph,'Type','line');
    t = findobj(graph,'Type','text');
    delete(l)
    delete(t)
else
    msgbox('Extract a profile from data before trying to delete the profile marks.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%SHOW THE CURRENT PROFILE ROW
function currentRow_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(dataLoaded=='n')
    if(get(extractionType,'Value')==2)
        set(sliderRow,'Value',1)
    end
else
    a = strcat('Row: ',num2str(ceil(get(sliderRow,'Value'))));
    set(txtRow,'String',a)
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%SHOW THE CURRENT PROFILE COLUMN
function currentColumn_callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(dataLoaded=='n')
    if(get(extractionType,'Value')==3)
        set(sliderColumn,'Value',1)
    end
else
    a = strcat('Column: ',num2str(ceil(get(sliderColumn,'Value'))));
    set(txtColumn,'String',a)
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
end

%SAVE OUTPUT PROFILE
function saveFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIextractProfile_);

if(profileExtracted=='y')
    a = handles.a;
    X_ = handles.firstColumn;
    
    [r,c]=size(a);
    
    if(r>c) %vector column
        outputFile = cat(2,X_,a);
    else
        outputFile = cat(2,X_',a');
    end
    
    [filename, pathname] = uiputfile('*.txt','Save Profile...');
    Fullpath = [pathname filename];
    if (sum(Fullpath)==0)
        return
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%8s %8s\r\n','Position','Profile');
    fprintf(fid,'%6.2f %12.4f\r\n',outputFile');
    fclose(fid);
else
    msgbox('Extract a profile from data before trying to save a file.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIextractProfile_,handles);
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

function plotExtractedProfile(x,a)
    set(f,'Visible','on')
    g=findobj(f,'Type','Axes');
    axes(g)
    plot(x,a,'k-','LineWidth',1.5)
    hold on
    txt_A = text(x(1),a(1),'A','FontSize',20);
    txt_B = text(x(end),a(end),'B','FontSize',20);
    if(x(1)>x(end))
        set(txt_A,'HorizontalAlignment','left')
        set(txt_B,'HorizontalAlignment','right')
    else
        set(txt_A,'HorizontalAlignment','right')
        set(txt_B,'HorizontalAlignment','left')
    end
    xlabel('Position')
    ylabel('Profile Magnitude')
    xLength = abs(x(1)-x(end));
    xHeigth = max(a)-min(a);
    if(x(1)>x(end))
        xlim([x(end)-(xLength*0.1) x(1)+(xLength*0.1)])
    else
        xlim([x(1)-(xLength*0.1) x(end)+(xLength*0.1)])
    end
    ylim([min(a)-(xHeigth*0.1) max(a)+(xHeigth*0.1)])
    grid on
    hold off
    set(gca,'FontSize',17)
end

function plotProfileOverMap(x,y)
    hold on
    axes(graph)
    plot(x,y,'k-','LineWidth',1.5)
    txt_A = text(x(1),y(1),'A','FontSize',20);
    txt_B = text(x(end),y(end),'B','FontSize',20);
    
    if(x(1)>x(end))
        set(txt_A,'HorizontalAlignment','left')
        set(txt_B,'HorizontalAlignment','right')
    else
        set(txt_A,'HorizontalAlignment','right')
        set(txt_B,'HorizontalAlignment','left')
    end
    
    hold off
end

end