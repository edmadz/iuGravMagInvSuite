function GUItiltDepth

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUItiltDepth_ = figure('Name','Tilt-Depth',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUItiltDepth_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUItiltDepth_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------
popupDist = uicontrol(GUItiltDepth_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

expansion_ = uicontrol(GUItiltDepth_,'Style','edit',...
    'TooltipString','Percent grid expansion (%).',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.3 0.625 0.65 0.08]);

uicontrol(GUItiltDepth_,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Depth',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@tiltDepth_callBack);

%--------------------------------------------------------------------------

uicontrol(GUItiltDepth_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUItiltDepth_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUItiltDepth_);
set(GUItiltDepth_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
tiltDepthComputed = 'n';
set(GUItiltDepth_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUItiltDepth_);

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
guidata(GUItiltDepth_,handles);
end

%PERFORM THE TILT DEPTH
function tiltDepth_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUItiltDepth_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    widthArea = maxX-minX;
    heightArea = maxY-minY;
    [row,col]=size(Zg);
    
    exp = str2double(get(expansion_,'String'));
    
    Dx = difference(Xg,Yg,Zg,'x',exp);
    Dy = difference(Xg,Yg,Zg,'y',exp);
    Dz = differentiate(Xg,Yg,Zg,'z',exp);
    
    TDR = rad2deg(atan(Dz./sqrt(Dx.^2+Dy.^2)));
    
    %--------------------------------Plota o TDR com as isolinhas
    C0=findContour(Xg,Yg,TDR,0);
    C45p=findContour(Xg,Yg,TDR,45);
    C45m=findContour(Xg,Yg,TDR,-45);
    
    depth=tiltDepth(C45m,C45p,C0);
    
    minX=min(Xg(:)); maxX=max(Xg(:));
    minY=min(Yg(:)); maxY=max(Yg(:));
    minZ=min(depth);
    X0 = C0(:,1);
    Y0 = C0(:,2);
    
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H_ = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H_/2 - figHeight__/2;
    
    f1=figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
    scatter3(X0,Y0,depth,20,depth,'filled')
    view(0,90)
    cmapChanged = colormaps(depth,'clra','linear');
    colormap(flipud(cmapChanged))
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','DEPTH (m)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    zlabel('Depth (m)')
    title('TILT-DEPTH SOLUTIONS')
    if(widthArea>heightArea)
        b=heightArea/widthArea;
        pbaspect([1 b 0.3])
    else
        b=widthArea/heightArea;
        pbaspect([b 1 0.3])
    end
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
    set(gca,'YTickLabelRotation',90)
    set(gca,'ZDir','reverse')
    grid on
    
    set(f1,'WindowButtonDownFcn',@mouseButtonD)
    
    %input dataset
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    pcolor(Xg,Yg,Zg)
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','equalized');
        colormap(cmapChanged)
    else
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','linear');
        colormap(cmapChanged)
    end
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','RTP TMI (nT)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    title('INPUT DATA')
    set(gca,'fontSize',17)
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
    set(gca,'YTickLabelRotation',90)
    set(gca,'ZDir','reverse')
    
    %tdr
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    pcolor(Xg,Yg,TDR)
    hold on
    contour(Xg,Yg,TDR,[0 0],'k-','ShowText','on');
    contour(Xg,Yg,TDR,[45 45],'k--','ShowText','on');
    contour(Xg,Yg,TDR,[-45 -45],'k--','ShowText','on');
    hold off
    [row,col]=size(TDR);
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(reshape(TDR,[row*col,1]),'clra','equalized');
        colormap(cmapChanged)
    else
        cmapChanged = colormaps(reshape(TDR,[row*col,1]),'clra','linear');
        colormap(cmapChanged)
    end
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','TDR (º)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    title('TDR')
    set(gca,'fontSize',17)
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
    set(gca,'YTickLabelRotation',90)
    set(gca,'ZDir','reverse')
    
    %histogram
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    histogram(depth,30,'FaceColor',[0.5 0.5 0.5])
    xlabel('DEPTH (m)')
    ylabel('NUMBER OF DEPTH SOLUTIONS')
    title('TILT-DEPTH SOLUTION HISTOGRAM')
    set(gca,'fontSize',17)
    
    handles.minX = minX;
    handles.maxX = maxX;
    handles.minY = minY;
    handles.maxY = maxY;
    handles.minZ = minZ;
    handles.maxZ = 0;
    handles.X0 = X0;
    handles.Y0 = Y0;
    handles.depth = depth;
    tiltDepthComputed = 'y';
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUItiltDepth_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUItiltDepth_);

if(tiltDepthComputed == 'y')
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    X0 = handles.X0;
    Y0 = handles.Y0;
    inputFile = handles.depth;
    
    outputFile = matrix2xyz(X0,Y0,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%1s %1s %10s\r\n','X','Y','Tilt_Depth');
    fprintf(fid,'%6.4f %6.4f %6.4f\r\n',transpose(outputFile));
    fprintf(fid,'%14s\r\n',num2str(minX));
    fprintf(fid,'%14s\r\n',num2str(maxX));
    fprintf(fid,'%14s\r\n',num2str(minY));
    fprintf(fid,'%14s\r\n',num2str(maxY));
    fprintf(fid,'%14s\r\n',num2str(minZ));
    fprintf(fid,'%14s\r\n',num2str(maxZ));
    fclose(fid);
else
    msgbox('Compute the tilt-depth solution before trying to save a file.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUItiltDepth_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function mouseButtonD(varargin)
    C = get(gca,'CurrentPoint');
    
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
    outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
    if (outX && outY && dataLoaded=='y') %VERIFY IF MOUSE IS HOVERING OVER THE GRAPH
        [az,el]=view;
        if(az==0 && el==90)
            set(gca,'YTickLabelRotation',90)
        else
            set(gca,'YTickLabelRotation',0)
        end
    end
end

function C=findContour(Xg,Yg,TDR,v)
    f=figure('Visible','off');
    [C,~]=contour(Xg,Yg,TDR,[v v]);
    delete(f)
    x=C(1,:); y=C(2,:);
    y(x==0)=[];
    x(x==0)=[];
    C = [x;y];
    C=C';
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