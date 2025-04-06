function GUIsourceDistance

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIsourceDistance_ = figure('Visible','off',...
    'Name','Source Distance',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUIsourceDistance_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUIsourceDistance_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------
popupDist = uicontrol(GUIsourceDistance_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

viewMode = uicontrol(GUIsourceDistance_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Surface Map','Scatter Plot'},...
    'fontUnits','normalized',...
    'position',[0.3 0.625 0.65 0.08]);

expansion_ = uicontrol(GUIsourceDistance_,'Style','edit',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.3 0.525 0.65 0.08]);

% inc_ = uicontrol(Rdistance2015_,'Style','edit',...
%     'units','normalized',...
%     'String','',...
%     'fontUnits','normalized',...
%     'TooltipString','Geomagnetic Field Inclination (degrees).',...
%     'position',[0.3 0.525 0.31 0.08]);
% 
% strikeDirection_ = uicontrol(Rdistance2015_,'Style','edit',...
%     'units','normalized',...
%     'String','',...
%     'fontUnits','normalized',...
%     'TooltipString','Angle between the positive x axis and north (degrees).',...
%     'position',[0.64 0.525 0.31 0.08]);
% 
% uicontrol(Rdistance2015_,'Style','pushbutton',...
%     'units','normalized',...
%     'String','Compute Dip',...
%     'fontUnits','normalized',...
%     'position',[0.3 0.425 0.65 0.08],...
%     'CallBack',@Dip_callBack);
% 
% uicontrol(Rdistance2015_,'Style','pushbutton',...
%     'units','normalized',...
%     'String','Compute Susceptibility Thickness Product',...
%     'fontUnits','normalized',...
%     'position',[0.3 0.325 0.65 0.08],...
%     'CallBack',@STP_callBack);

uicontrol(GUIsourceDistance_,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Depth',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@Depth_callBack);
%--------------------------------------------------------------------------

uicontrol(GUIsourceDistance_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUIsourceDistance_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUIsourceDistance_);
set(GUIsourceDistance_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
filterApplied = 'n';
set(GUIsourceDistance_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsourceDistance_);

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
guidata(GUIsourceDistance_,handles);
end

%COMPUTE THE DIP
function Dip_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsourceDistance_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Z = handles.Z;
    Zg = handles.Zg;
    
    exp=str2double(get(expansion_,'String'));
    
    Dx = difference(Xg,Yg,Zg,'x',exp);
    Dz = differentiate(Xg,Yg,Zg,'z',exp);
    
    R_xz = Dx./Dz;
    
    i = str2double(get(inc_,'String'));
    alpha = str2double(get(strikeDirection_,'String'));
    
    I=atand(tan(i)./cos(alpha));
    
    DIP = - atand(R_xz) - 90 +2.*I;
    
    figWidth__=600;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__-8;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','position',[posX_ posY_ figWidth__ figHeight__])
    pcolor(Xg,Yg,DIP)
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(Z,'clra','equalized');
        colormap(cmapChanged)
    else
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
    end
    shading interp
    colorbar
    ylabel('Northing [m]')
    xlabel('Easting [m]')
    title('DIP')
    axis image
else
    msgbox('Load some data before trying to estimate the dip.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUIsourceDistance_,handles);
end

%COMPUTE THE SUSCEPTIBILITY THICKNESS PRODUCT
function STP_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsourceDistance_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Z = handles.Z;
    Zg = handles.Zg;
    
    exp=str2double(get(expansion_,'String'));
    
    Dx = difference(Xg,Yg,Zg,'x',exp);
    Dy = difference(Xg,Yg,Zg,'y',exp);
    Dz = differentiate(Xg,Yg,Zg,'z',exp);
    
    [Hx,Hy]=H_(Zg,exp,2,'on');
    AS0 = sqrt(Hx.^2+Hy.^2+Zg.^2);
    AS1 = sqrt(Dx.^2+Dy.^2+Dz.^2);
    
    R=(AS0./AS1);
    
    i = str2double(get(inc_,'String'));
    alpha = str2double(get(strikeDirection_,'String'));
    I=atand(tan(i)./cos(alpha));
    
    c = 1 - ((cos(I))^2)*((sin(alpha))^2);
    F = 23000;
    
    KW = (AS0.*R)./(2*F.*c);
    
    figWidth__=600;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__-8;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','position',[posX_ posY_ figWidth__ figHeight__])
    pcolor(Xg,Yg,KW)
    if(get(popupDist,'Value')==1)
        cmapChanged = colormaps(Z,'clra','equalized');
        colormap(cmapChanged)
    else
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
    end
    shading interp
    colorbar
    ylabel('Northing [m]')
    xlabel('Easting [m]')
    title('SUSCEPTIBILITY THICKNESS PRODUCT')
    axis image
else
    msgbox('Load some data before trying to estimate the susceptibility thickness product.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUIsourceDistance_,handles);
end

%APPLY THE DISTANCE R FROM COOPER(2015)
function Depth_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsourceDistance_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    widthArea = maxX-minX;
    heightArea = maxY-minY;
    [row,col]=size(Zg);
    
    exp=str2double(get(expansion_,'String'));
    
    Dx = difference(Xg,Yg,Zg,'x',exp);
    Dy = difference(Xg,Yg,Zg,'y',exp);
    Dz = differentiate(Xg,Yg,Zg,'z',exp);
    
    [Hx,Hy]=H_(Xg,Yg,Zg,exp,2,'off');
    AS0 = sqrt(Hx.^2+Hy.^2+Zg.^2);
    AS1 = sqrt(Dx.^2+Dy.^2+Dz.^2);
    
    R=(AS0./AS1);
    
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','position',[posX_ posY_ figWidth__ figHeight__])
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
    set(get(c,'Label'),'String','Quantity (Unit)')
    set(get(c,'Label'),'FontWeight','bold')
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    title('INPUT DATA')
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
    
    if(get(viewMode,'Value')==1) %surface map
        mean_r = mean(R(:));
        std_r = std(R(:));
        a=0.5;
        R(R>(mean_r+a*std_r))=NaN;
        figure('units','pixel','position',[posX_ posY_ figWidth__ figHeight__])
        surf(Xg,Yg,R)
        view(0,90)
        cmapChanged = colormaps(reshape(R,[row*col,1]),'clra','linear');
        colormap(flipud(cmapChanged))
        shading interp
        c=colorbar;
        set(get(c,'Label'),'String','DEPTH (m)')
        set(get(c,'Label'),'FontWeight','bold')
        set(get(c,'Label'),'FontSize',17)
        ylabel('Northing (m)','FontWeight','bold')
        xlabel('Easting (m)','FontWeight','bold')
        title('SURFACE MAP - SOURCE DISTANCE')
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
    else
        TDR = atan(Dz./sqrt(Dx.^2+Dy.^2));
        TDX = atan(sqrt(Dx.^2+Dy.^2)./abs(Dz));
        TDR_TDX = TDR-TDX;
        fp = [0.06 0.10 0.06;0.10 0.06 0.10;0.06 0.10 0.06];
        TDR_TDX=applyConvFilter(TDR_TDX,25,fp,1);
        
        [X__,Y__,~,~]=peakfinder(Xg,Yg,TDR_TDX);
        
        x_=X__; y_=Y__;
        r_=interp2(Xg,Yg,R,x_,y_);
        mean_r = mean(r_);
        std_r = std(r_);
        a = 2;
        x_(r_>(mean_r+a*std_r))=[];
        y_(r_>(mean_r+a*std_r))=[];
        r_(r_>(mean_r+a*std_r))=[];
        
        f1=figure('units','pixel','position',[posX_ posY_ figWidth__ figHeight__]);
        scatter3(x_,y_,r_,30,r_,'filled')
        view(0,90)
        cmapChanged = colormaps(r_,'clra','linear');
        colormap(flipud(cmapChanged))
        c=colorbar;
        set(get(c,'Label'),'String','DEPTH (m)')
        set(get(c,'Label'),'FontWeight','bold')
        set(get(c,'Label'),'FontSize',17)
        zlim([0 (max(r_)+(0.2*max(r_)))])
        ylabel('Northing (m)','FontWeight','bold')
        xlabel('Easting (m)','FontWeight','bold')
        title('SCATTERED SOLUTIONS MAP - SOURCE DISTANCE')
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
        
        set(f1,'WindowButtonDownFcn',@mouseButtonD)
        
        figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
        histogram(r_,30,'FaceColor',[0.5 0.5 0.5])
        xlabel('DEPTH (m)')
        ylabel('NUMBER OF DEPTH SOLUTIONS')
        title('SOURCE DISTANCE DEPTH SOLUTION HISTOGRAM')
        xlim([0 max(r_)])
        set(gca,'fontSize',17)
        
        minX=min(Xg(:)); maxX=max(Xg(:));
        minY=min(Yg(:)); maxY=max(Yg(:));
        minZ=min(r_);
        
        handles.minX = minX;
        handles.maxX = maxX;
        handles.minY = minY;
        handles.maxY = maxY;
        handles.minZ = minZ;
        handles.maxZ = 0;
        handles.x_ = x_;
        handles.y_ = y_;
        handles.r_ = r_;
    end
    
    filterApplied = 'y';
else
    msgbox('Load some data before trying to estimate the depth.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIsourceDistance_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsourceDistance_);

if(filterApplied == 'y')
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    x_ = handles.x_;
    y_ = handles.y_;
    inputFile = handles.r_;
    
    outputFile = matrix2xyz(x_,y_,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%1s %1s %1s\r\n','X','Y','R');
    fprintf(fid,'%6.4f %6.4f %6.4f\r\n',transpose(outputFile));
    fprintf(fid,'%14s\r\n',num2str(minX));
    fprintf(fid,'%14s\r\n',num2str(maxX));
    fprintf(fid,'%14s\r\n',num2str(minY));
    fprintf(fid,'%14s\r\n',num2str(maxY));
    fprintf(fid,'%14s\r\n',num2str(minZ));
    fprintf(fid,'%14s\r\n',num2str(maxZ));
    fclose(fid);
else
    msgbox('Apply the filter before trying to save the output file.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIsourceDistance_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function out_=applyConvFilter(Zg,expansion,fp,n)
    [nx,ny]=size(Zg);
    expansion = expansion/100;
    [Zg_,cdiff,rdiff] = fillGaps(Zg,1,expansion);
    nanmask=generateNaNmask(Zg);
    
    out=Zg_;
    for i=1:n
        out = conv2(out,fp,'same');
    end
    out = out(1+rdiff:nx+rdiff,1+cdiff:ny+cdiff);
    out_=out.*nanmask;
end

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