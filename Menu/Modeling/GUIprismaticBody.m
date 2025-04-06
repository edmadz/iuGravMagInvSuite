function GUIprismaticBody

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIprismaticBody_ = figure('Menubar','none',...
    'Name','Gravity and Magnetic Anomaly of Prismatic Bodies',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','on');

%--------------------------------------------------------------------------
FGparameters = uipanel(GUIprismaticBody_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);
%--------------------------------------------------GRID
Xo_=uicontrol(FGparameters,...
    'TooltipString','Initial grid value in x direction [meters].',...
    'Style','edit',...
    'Units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.3 0.036]);

Xf_=uicontrol(FGparameters,...
    'TooltipString','Final grid value in x direction [meters].',...
    'Style','edit',...
    'Units','normalized',...
    'String','10000',...
    'fontUnits','normalized',...
    'position',[0.35 0.915 0.3 0.036]);

dx_=uicontrol(FGparameters,...
    'TooltipString','Interpolation cell in x direction [meters].',...
    'Style','edit',...
    'Units','normalized',...
    'String','50',...
    'fontUnits','normalized',...
    'position',[0.67 0.915 0.3 0.036]);

Yo_=uicontrol(FGparameters,...
    'TooltipString','Initial grid value in y direction [meters].',...
    'Style','edit',...
    'Units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.3 0.036]);

Yf_=uicontrol(FGparameters,...
    'TooltipString','Final grid value in y direction [meters].',...
    'Style','edit',...
    'Units','normalized',...
    'String','10000',...
    'fontUnits','normalized',...
    'position',[0.35 0.865 0.3 0.036]);

dy_=uicontrol(FGparameters,...
    'TooltipString','Interpolation cell in y direction [meters].',...
    'Style','edit',...
    'Units','normalized',...
    'String','50',...
    'fontUnits','normalized',...
    'position',[0.67 0.865 0.3 0.036]);

%--------------------------------------------------FIELD

fieldStrength_=uicontrol(FGparameters,...
    'TooltipString','Magnetic field strength [nT].',...
    'Style','edit',...
    'Units','normalized',...
    'String','57000',...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.3 0.036]);

I_=uicontrol(FGparameters,...
    'TooltipString','Magnetic field inclination [degree].',...
    'Style','edit',...
    'Units','normalized',...
    'String','90',...
    'fontUnits','normalized',...
    'position',[0.35 0.815 0.3 0.036]);

D_=uicontrol(FGparameters,...
    'TooltipString','Magnetic field declination [degree].',...
    'Style','edit',...
    'Units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.67 0.815 0.3 0.036]);

%--------------------------------------------------BODY

magNoise_=uicontrol(FGparameters,...
    'TooltipString','Noise level of gravity anomaly.',...
    'Style','edit',...
    'Units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.03 0.765 0.46 0.036]);

gravNoise_=uicontrol(FGparameters,...
    'TooltipString','Noise level of magnetic anomaly.',...
    'Style','edit',...
    'Units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.51 0.765 0.46 0.036]);

popupAnomalyType=uicontrol(FGparameters,'Style','popupmenu',...
    'TooltipString','Field anomaly that will be displayed.',...
    'units','normalized',...
    'Value',1,...
    'String',{'Show Magnetic Anomaly','Show Gravimetric Anomaly'},...
    'fontUnits','normalized',...
    'position',[0.03 0.715 0.944 0.036],...
    'CallBack',@typeToBeShowed_callBack);

popupGraphType=uicontrol(FGparameters,'Style','popupmenu',...
    'TooltipString','Anomaly representation.',...
    'units','normalized',...
    'Value',1,...
    'String',{'2D','3D'},...
    'fontUnits','normalized',...
    'position',[0.03 0.665 0.22 0.036],...
    'CallBack',@typeToBeShowed_callBack);

popupColorDist=uicontrol(FGparameters,'Style','popupmenu',...
    'TooltipString','Color distribution.',...
    'units','normalized',...
    'Value',1,...
    'String',{'Linear','Histogram Equalized'},...
    'fontUnits','normalized',...
    'position',[0.27 0.665 0.704 0.036],...
    'CallBack',@typeToBeShowed_callBack);

prismNumber = uicontrol(FGparameters,'Style','edit',...
    'TooltipString','Number of input prisms.',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.03 0.365 0.7 0.036]);

uicontrol(FGparameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Ok',...
    'fontUnits','normalized',...
    'position',[0.75 0.365 0.22 0.036],...
    'CallBack',@prismNumber_callBack);

magFileName = uicontrol(FGparameters,'Style','edit',...
    'TooltipString','Suffix of magnetic anomaly name file.',...
    'units','normalized',...
    'String','_mag.xyz',...
    'fontUnits','normalized',...
    'Position',[0.03 0.315 0.944 0.036]);

gravFileName = uicontrol(FGparameters,'Style','edit',...
    'TooltipString','Suffix of gravity anomaly name file.',...
    'units','normalized',...
    'String','_grav.xyz',...
    'fontUnits','normalized',...
    'Position',[0.03 0.265 0.944 0.036]);

uicontrol(FGparameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute the Anomalies',...
    'fontUnits','normalized',...
    'Position',[0.03 0.215 0.944 0.036],...
    'CallBack',@GenerateAnomalies_callBack);

popupModelClipping = uicontrol(FGparameters,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Hide 3D Model Portions out of Study Area','Show 3D Model Portions out of Study Area'},...
    'fontUnits','normalized',...
    'Position',[0.03 0.165 0.944 0.036]);

Z_lower = uicontrol(FGparameters,'Style','edit',...
    'units','normalized',...
    'TooltipString','Lower vertical limit.',...
    'String','0',...
    'fontUnits','normalized',...
    'Position',[0.03 0.115 0.46 0.036]);

Z_upper = uicontrol(FGparameters,'Style','edit',...
    'units','normalized',...
    'TooltipString','Upper vertical limit.',...
    'String','500',...
    'fontUnits','normalized',...
    'Position',[0.51 0.115 0.46 0.036]);

uicontrol(FGparameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Show 3D Model',...
    'fontUnits','normalized',...
    'Position',[0.03 0.065 0.944 0.036],...
    'CallBack',@showModel_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIprismaticBody_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.4 0.76 0.581]);

graph = axes(graphPanel,'units','normalized',...
    'Position',[0.1 0.1 0.8 0.8]);
set(graph.XAxis,'Visible','off');
set(graph.YAxis,'Visible','off');

rnames2 = {'Magnetic Susceptibility [SI]','Remanent Intensity [A/m]','Density Contrast [kg/m^3]','Prism Width [m]','Prism Length [m]','Prism Thickness [m]','X Coordinate [m]','Y Coordinate [m]','Depth to the top [m]','Strike Azimuth [degrees]','Remanent Declination [degrees]','Remanent Inclination [degrees]'};

tableOfPrismParameters = uitable(GUIprismaticBody_,'units','normalized','RowName',rnames2,...
    'Position',[0.23 0.02 0.76 0.35],'ColumnEditable',true,'fontSize',11);

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIprismaticBody_,'label','File');

uimenu(file,'Label','Load Model...','Accelerator','L','CallBack',@loadModel_callback);
uimenu(file,'Label','Save Model...','Accelerator','S','CallBack',@saveModel_callback);

anomGenerated = 'n';
prismParametersProvided = 'n';
set(GUIprismaticBody_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%SET THE NUMBER OF INPUT PRISMS
function prismNumber_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

n = str2double(get(prismNumber,'String'));

for x=1:n
    if(x==1)
        cnames2=strcat('Prism 0',num2str(x));
    elseif(x==n)
        s = cnames2;
        cnames2=strcat(s,',Prism 0',num2str(x));
    else
        s = cnames2;
        cnames2=strcat(s,',Prism 0',num2str(x));
    end
end

param = zeros(12,n);

cnames2=strsplit(cnames2,',');
set(tableOfPrismParameters,'ColumnName',cnames2)
set(tableOfPrismParameters,'Data',param)

handles.n = n;
prismParametersProvided = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%LOAD PRISM PARAMETERS FILE
function loadModel_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.dat','Data Files (*.dat)'},'Select a model parameters file');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

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

%--------------------------------------------------------------------------
%UPDATE GRID PHYSICAL PARAMETERS
%--------------------------------------------------------------------------

set(Xo_,'String',num2str(Data_1(1)));
set(Xf_,'String',num2str(Data_1(2)));
set(dx_,'String',num2str(Data_1(3)));
set(Yo_,'String',num2str(Data_1(4)));
set(Yf_,'String',num2str(Data_1(5)));
set(dy_,'String',num2str(Data_1(6)));
set(fieldStrength_,'String',num2str(Data_1(7)));
set(I_,'String',num2str(Data_1(8)));
set(D_,'String',num2str(Data_1(9)));
set(magNoise_,'String',num2str(Data_1(10)));
set(gravNoise_,'String',num2str(Data_1(11)));

%--------------------------------------------------------------------------
%UPDATE GEOMETRICAL PARAMETERS
%--------------------------------------------------------------------------

[row,~] = size(Data_);
set(prismNumber,'String',row)

for x=1:row
    if(x==1)
        cnames2=strcat('Prism 0',num2str(x));
    elseif(x==row)
        s = cnames2;
        cnames2=strcat(s,',Prism 0',num2str(x));
    else
        s = cnames2;
        cnames2=strcat(s,',Prism 0',num2str(x));
    end
end

cnames2=strsplit(cnames2,',');
set(tableOfPrismParameters,'ColumnName',cnames2)
set(tableOfPrismParameters,'Data',Data_')

prismParametersProvided = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%SAVE PRISM PARAMETERS FILE
function saveModel_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

%Open a dialog box to store the data file path
[FileName,PathName] = uiputfile({'*.dat','Data Files (*.dat)'},'Choose one file');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

header1='x0 xf dx y0 yf dy fieldStrength inclination declination noiseLevelMag noiseLevelGrav';
generalParameters=[str2double(get(Xo_,'String')),...
    str2double(get(Xf_,'String')),...
    str2double(get(dx_,'String')),...
    str2double(get(Yo_,'String')),...
    str2double(get(Yf_,'String')),...
    str2double(get(dy_,'String')),...
    str2double(get(fieldStrength_,'String')),...
    str2double(get(I_,'String')),...
    str2double(get(D_,'String')),...
    str2double(get(magNoise_,'String')),...
    str2double(get(gravNoise_,'String'))];

header2='suscept mag_reman density_contrast width lenght tickness coord_center_x coord_center_y depth_top strike_azimuth dec_reman inc_reman';
bodyParameters=get(tableOfPrismParameters,'Data');

fid = fopen(Fullpath,'w+');
fprintf(fid,'%6s\r\n',header1);
fprintf(fid,'%6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f\r\n',generalParameters);
fprintf(fid,'%6s\r\n',header2);
fprintf(fid,'%6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f %6.5f\r\n',bodyParameters);
fclose(fid);

%Update de handle structure
guidata(hObject,handles);
end

%GENERATE THE ANOMALIES
function GenerateAnomalies_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    msgbox('Provide the path and name of the output files.','Warn','warn')
    return
else
    fn=strsplit(FileName,'.');
    magFile = strcat(PathName,char(fn(1)),get(magFileName,'String'));
    gravFile = strcat(PathName,char(fn(1)),get(gravFileName,'String'));
end

xo=str2double(get(Xo_,'String'));
xf=str2double(get(Xf_,'String'));
yo=str2double(get(Yo_,'String'));
yf=str2double(get(Yf_,'String'));
dx=str2double(get(dx_,'String'));
dy=str2double(get(dy_,'String'));
D=str2double(get(D_,'String'));
I=str2double(get(I_,'String'));
magStrength=str2double(get(fieldStrength_,'String'));
magNoise=str2double(get(magNoise_,'String'));
gravNoise=str2double(get(gravNoise_,'String'));

P = get(tableOfPrismParameters,'Data');

[M,G]=grav_mag_prisma(xo,xf,yo,yf,dx,dy,D,I,magStrength,magNoise,gravNoise,magFile,gravFile,P');

[row,col]=size(M);
%generate the X and Y grid coordinates
[Xg,Yg] = meshgrid(xo:dx:xf,yo:dy:yf);

%plot the anomaly
if(get(popupAnomalyType,'Value')==1)
    axes(graph)
    if(get(popupGraphType,'Value')==1)
        pcolor(Xg,Yg,M)
        axis image
    else
        surf(Xg,Yg,M)
        axis tight
    end
    cmapChanged = colormaps(reshape(M,[row*col,1]),'clra','linear');
    colormap(cmapChanged);
    shading interp
    colorbar
    title('MAGNETIC ANOMALY')
    xlabel('Easting (m)')
    ylabel('Northing (m)')
else
    axes(graph)
    if(get(popupGraphType,'Value')==1)
        pcolor(Xg,Yg,G)
        axis image
    else
        surf(Xg,Yg,G)
        axis tight
    end
    cmapChanged = colormaps(reshape(G,[row*col,1]),'clra','linear');
    colormap(cmapChanged);
    shading interp
    colorbar
    title('GRAVIMETRIC ANOMALY')
    xlabel('Easting (m)')
    ylabel('Northing (m)')
end

handles.Xg = Xg;
handles.Yg = Yg;
handles.M = M;
handles.G = G;
anomGenerated = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%SET THE GRAV DATASET PATH
function typeToBeShowed_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(anomGenerated=='y' && get(popupAnomalyType,'Value')==1)
    M = handles.M;
    Xg = handles.Xg;
    Yg = handles.Yg;
    
    axes(graph)
    if(get(popupGraphType,'Value')==1)
        pcolor(Xg,Yg,M)
        axis image
    else
        surf(Xg,Yg,M)
        zlabel('Anomaly [nT]')
        axis tight
    end
    if(get(popupColorDist,'Value')==1)
        [row,col]=size(M);
        cmapChanged = colormaps(reshape(M,[row*col,1]),'clra','linear');
        colormap(cmapChanged)
    else
        [row,col]=size(M);
        cmapChanged = colormaps(reshape(M,[row*col,1]),'clra','equalized');
        colormap(cmapChanged)
    end
    shading interp
    colorbar
    title('MAGNETIC ANOMALY')
    xlabel('Easting [m]')
    ylabel('Northing [m]')
    pbaspect([1 1 0.3])
elseif(anomGenerated=='y' && get(popupAnomalyType,'Value')==2)
    G = handles.G;
    Xg = handles.Xg;
    Yg = handles.Yg;
    
    axes(graph)
    if(get(popupGraphType,'Value')==1)
        pcolor(Xg,Yg,G)
        axis image
    else
        surf(Xg,Yg,G)
        zlabel('Anomaly [mGal]')
        axis tight
    end
    if(get(popupColorDist,'Value')==1)
        [row,col]=size(G);
        cmapChanged = colormaps(reshape(G,[row*col,1]),'clra','linear');
        colormap(cmapChanged)
    else
        [row,col]=size(G);
        cmapChanged = colormaps(reshape(G,[row*col,1]),'clra','equalized');
        colormap(cmapChanged)
    end
    shading interp
    colorbar
    title('GRAVIMETRIC ANOMALY')
    xlabel('Easting [m]')
    ylabel('Northing [m]')
    pbaspect([1 1 0.3])
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW THE MODEL CAUSING ANOMALY
function showModel_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(prismParametersProvided=='y')
    minX=str2double(get(Xo_,'String'));
    maxX=str2double(get(Xf_,'String'));
    minY=str2double(get(Yo_,'String'));
    maxY=str2double(get(Yf_,'String'));
    
    P = get(tableOfPrismParameters,'Data');
    [~,numberOfPrisms] = size(P);
    P_ = double(P==0);
    
    if(sum(P_)==12)
        msgbox('Provide the spatial parameters of the prisms.','Warn','warn')
        return
    else
        width_=P(4,:)./1000;
        lenght_=P(5,:)./1000;
        thickness_=P(6,:)./1000;
        Cx_=P(7,:)./1000;
        Cy_=P(8,:)./1000;
        depth_=P(9,:)./1000;
        strike_=P(10,:);
        
        figWidth__=1000;
        figHeight__=700;
        Pix_SS = get(0,'screensize');
        W = Pix_SS(3);
        H = Pix_SS(4);
        posX_ = W/2 - figWidth__/2;
        posY_ = H/2 - figHeight__/2;
        
        f1=figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
        set(gca,'FontSize',17)
        set(gca,'Box','on')
        set(gca,'Zdir','reverse')
        xlabel('Easting (km)','FontWeight','bold')
        ylabel('Northing (km)','FontWeight','bold')
        zlabel('Depth (km)','FontWeight','bold')
        grid on
        grid minor
        
        for i_=1:numberOfPrisms
            i = [(Cx_(:,i_)-width_(:,i_)/2),(Cy_(:,i_)-lenght_(:,i_)/2),(thickness_(:,i_)+depth_(:,i_))];
            d = [width_(:,i_),lenght_(:,i_),-thickness_(:,i_)];
            voxel(i,d,[.83 .83 .83],strike_(i_),1)
            xlim([minX./1000 maxX./1000])
            ylim([minY./1000 maxY./1000])
            zlim([str2double(get(Z_lower,'String'))./1000,str2double(get(Z_upper,'String'))./1000])
            
            if(get(popupModelClipping,'Value')==1)
                set(gca,'ClippingStyle','3dbox')
            else
                set(gca,'ClippingStyle','rectangle')
            end
            hold on
        end
        
        widthArea=(maxX-minX)./1000;
        heightArea=(maxY-minY)./1000;
        if(widthArea>heightArea)
            b=heightArea/widthArea;
            pbaspect([1 b 1])
        else
            b=widthArea/heightArea;
            pbaspect([b 1 1])
        end
        setCoord(minX,minY,widthArea,heightArea,4,4)
        
        h = rotate3d;
        set(h,'ActionPreCallback','set(gcf,''windowbuttonmotionfcn'',@align_axislabel)')
        set(h,'ActionPostCallback','set(gcf,''windowbuttonmotionfcn'','''')')
        set(gcf,'ResizeFcn',@align_axislabel)
        align_axislabel([],gca)
        
        set(f1,'WindowButtonDownFcn',@mouseButtonD)
    end
else
    msgbox('Provide the parameters of the prisms.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

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

function mouseButtonD(varargin)
    C = get(gca,'CurrentPoint');
    
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
    outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
    if (outX && outY) %VERIFY IF MOUSE IS HOVERING OVER THE GRAPH
        [az,el]=view;
        if(az==0 && el==90)
            set(gca,'YTickLabelRotation',90)
        else
            set(gca,'YTickLabelRotation',0)
        end
    end
end

end