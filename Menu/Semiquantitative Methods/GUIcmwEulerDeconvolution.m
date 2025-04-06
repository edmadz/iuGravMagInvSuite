function GUIcmwEulerDeconvolution

clc
clear
warning('off','all')

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIcmwEulerDeconvolution_ = figure('Menubar','none',...
    'Name','Constrained Moving Window Euler Deconvolution',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------
inputParametersPanel = uipanel(GUIcmwEulerDeconvolution_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

functionDriveW = uicontrol(inputParametersPanel,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'TDR','TDR-TDX','TDR+TDX','ASA','TDX'},...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036],...
    'CallBack',@typeOfFunction_callBack);

expansion_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Percent grid expansion (%).',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.03 0.865 0.944 0.036]);

WS_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','10',...
    'fontUnits','normalized',...
    'TooltipString','Window size in grid nodes.',...
    'position',[0.03 0.815 0.944 0.036]);

N_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'TooltipString','Value related with the source shape (Structural Index).',...
    'position',[0.03 0.765 0.944 0.036]);

n_1 = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'Enable','off',...
    'TooltipString','Number of times to pass a hanning window filter and reduce spurious peaks in the input dataset.',...
    'position',[0.03 0.715 0.944 0.036]);

popupFlightHeight_ = uicontrol(inputParametersPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Measuring heigth discounting mode','Use a fixed value','Use the point-to-point approach'},...
    'fontUnits','normalized',...
    'position',[0.03 0.665 0.944 0.036],...
    'CallBack',@flightHeightMode_callBack);

H_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'Enable','off',...
    'fontUnits','normalized',...
    'TooltipString','Mean flight heigth in meters.',...
    'position',[0.03 0.615 0.944 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Euler Deconvolution',...
    'fontUnits','normalized',...
    'position',[0.03 0.565 0.944 0.036],...
    'CallBack',@cmwEulerDeconv_callBack);

coordConversion = uicontrol(inputParametersPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use original units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'position',[0.03 0.515 0.944 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Euler Solution Histogram',...
    'fontUnits','normalized',...
    'position',[0.03 0.265 0.944 0.036],...
    'CallBack',@solutionHisto_callBack);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Input Data',...
    'fontUnits','normalized',...
    'position',[0.03 0.215 0.944 0.036],...
    'CallBack',@showInput_callBack);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Dx',...
    'fontUnits','normalized',...
    'position',[0.03 0.165 0.944 0.036],...
    'CallBack',@showDx_callBack);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Dy',...
    'fontUnits','normalized',...
    'position',[0.03 0.115 0.944 0.036],...
    'CallBack',@showDy_callBack);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Dz',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'CallBack',@showDz_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIcmwEulerDeconvolution_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graphSol = axes(graphPanel,'Units','normalized',...
    'position',[0.1 0.1 0.8 0.8]);
set(graphSol.XAxis,'Visible','off');
set(graphSol.YAxis,'Visible','off');
%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIcmwEulerDeconvolution_,'label','File');
uimenu(file,'Label','Open Input Data...','Accelerator','O','CallBack',@loadFile_callBack);
uimenu(file,'Label','Save Euler Solutions...','Accelerator','S','CallBack',@GenerateFile_callBack);

elevation = uimenu(GUIcmwEulerDeconvolution_,'label','Elevation Maps');
uimenu(elevation,'Label','Load Measuring Height File...','Accelerator','H','CallBack',@loadMeasuringHeight_callBack);
uimenu(elevation,'Label','Load Topography File...','Accelerator','T','CallBack',@loadTopo_callBack);
uimenu(elevation,'Label','Load GPS Altimetry File...','Accelerator','G','CallBack',@loadGPSalt_callBack);

dataLoaded = 'n';
eulerPerformed = 'n';
topoLoaded = 'n';
gpsAltLoaded = 'n';
measuringHeightLoaded = 'n';
set(GUIcmwEulerDeconvolution_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%FLIGHT HEIGHT MODE
function flightHeightMode_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(get(popupFlightHeight_,'value')==2)
    set(H_,'Enable','on')
elseif(get(popupFlightHeight_,'value')==3)
    set(H_,'Enable','off')
else
    set(H_,'Enable','off')    
end

%Update de handle structure
guidata(hObject,handles);
end

%
function typeOfFunction_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(get(functionDriveW,'value')==1)
    set(n_1,'Enable','off')
elseif(get(functionDriveW,'value')==2)
    set(n_1,'Enable','off')
elseif(get(functionDriveW,'value')==3)
    set(n_1,'Enable','off')
elseif(get(functionDriveW,'value')==4)
    set(n_1,'Enable','on')
else
    set(n_1,'Enable','off')    
end

%Update de handle structure
guidata(hObject,handles);
end

%LOAD THE TOPOGRAPHY FILE
function loadTopo_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select Topography File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return;
end

[~,~,~,~,~,topo]=OpenFile(Fullpath);

handles.topo = topo;
topoLoaded = 'y';
msgbox('Topography Loaded!','Warn','warn','modal')
%Update de handle structure
guidata(hObject,handles);
end

%LOAD THE GPS ALTIMETRY FILE
function loadGPSalt_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select GPS Altimetry File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return;
end

[~,~,~,~,~,gpsAlt]=OpenFile(Fullpath);

handles.gpsAlt = gpsAlt;
gpsAltLoaded = 'y';
msgbox('GPS Altimetry Loaded!','Warn','warn','modal')
%Update de handle structure
guidata(hObject,handles);
end

%LOAD THE MEASURING HEIGHT FILE
function loadMeasuringHeight_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select GPS Altimetry File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[~,~,~,~,~,mHeight]=OpenFile(Fullpath);

handles.mHeight = mHeight;
measuringHeightLoaded = 'y';
msgbox('GPS Altimetry Loaded!','Warn','warn','modal')
%Update de handle structure
guidata(hObject,handles);
end

%OPEN THE INPUT DATASET
function loadFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return;
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
dataLoaded = 'y';
msgbox('Data Loaded!','Warn','warn','modal')
%Update de handle structure
guidata(hObject,handles);
end

%PERFORM THE CONSTRAINED MOVING WINDOW EULER DECONVOLUTION
function cmwEulerDeconv_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded == 'y')
    Zg = handles.Zg;
    Xg = handles.Xg;
    Yg = handles.Yg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    if(get(popupFlightHeight_,'value')==2)
        H__ = str2double(get(H_,'String'));
    elseif(get(popupFlightHeight_,'value')==3)
        if(measuringHeightLoaded=='y')
            mHeight = handles.mHeight;
            
            H__ = mHeight;
        elseif(topoLoaded=='y' && gpsAltLoaded=='y')
            topo = handles.topo;
            gpsAlt = handles.gpsAlt;
            
            H__ = gpsAlt-topo;
        else
            msgbox('Load topography and gps altimetry files of the measuring height file itselt before trying to select this option.','Warn','warn','modal')
            set(popupFlightHeight_,'Value',1)
            return
        end
    else
        H__ = 0;
    end
    
    WS = str2double(get(WS_,'String'));
    N = str2double(get(N_,'String'));
    exp = str2double(get(expansion_,'String'));
    n = str2double(get(n_1,'String'));
    
    %Calculate the derivatives
    Dx = difference(Xg,Yg,Zg,'x',exp);
    Dy = difference(Xg,Yg,Zg,'y',exp);
    Dz = differentiate(Xg,Yg,Zg,'z',exp);
    
    %Apply the function that guide the euler scanning window selected by the user
    if(get(functionDriveW,'Value')==1)
        F = atan2(Dz,sqrt(Dx.^2+Dy.^2));
        functionFlag = 'TDR';
    elseif(get(functionDriveW,'Value')==2)
        THDR = sqrt(Dx.^2+Dy.^2);
        %THDR(THDR<1e-2)=0;
        TDR = atan2(Dz,THDR);
        TDX = atan2(THDR,abs(Dz));
        F = TDR-TDX;
        functionFlag = 'TDR-TDX';
    elseif(get(functionDriveW,'Value')==3)
        THDR = sqrt(Dx.^2+Dy.^2);
        %THDR(THDR<1e-2)=0;
        TDR = atan2(Dz,THDR);
        TDX = atan2(THDR,abs(Dz));
        F = TDR+TDX;
        functionFlag = 'TDR+TDX';
    elseif(get(functionDriveW,'Value')==4)
        ASA=sqrt(Dx.^2+Dy.^2+Dz.^2);
        F=ASA;
        functionFlag = 'ASA';
    else
        THDR = sqrt(Dx.^2+Dy.^2);
        TDX = atan2(THDR,abs(Dz));
        F=TDX;
        functionFlag = 'TDX';
    end
    
    %----------------------
    %Apply the hanning filter
    x_track_window=Xg;
    y_track_window=Yg;
    
    if(strcmp(functionFlag,'ASA'))
        if(n>0)
            fp = [0.06 0.10 0.06;0.10 0.06 0.10;0.06 0.10 0.06];
            F=applyConvFilter(F,25,fp,n);
        end
        [~,~,ix,iy]=peakfinder(Xg,Yg,F);
        N__=length(ix);
        Zg_mask = NaN(size(Zg));
        for i=1:N__
            Zg_mask(ix(i),iy(i))=1;
        end
        
        x_track_window(isnan(Zg_mask))=NaN;
        y_track_window(isnan(Zg_mask))=NaN;
        T_='(nT/m)';
        D_=2;
    else
        Zg_mask=F;
        if(get(functionDriveW,'Value')==5)
            Zg_mask(F<1)=NaN;
        else
            Zg_mask(F<0)=NaN;
        end
        
        TDR_P_TDX = atan2(Dz,sqrt(Dx.^2+Dy.^2))+atan2(sqrt(Dx.^2+Dy.^2),abs(Dz));
        h_=(0.9*(pi/2));
        TDR_P_TDX(TDR_P_TDX<h_)=NaN;
        Zg_mask_ = removeAloneSpikes(TDR_P_TDX);
        
        [row,col]=size(Zg_mask_);
        mask = NaN([row,col]);
        for i=1:row
            for j=1:col
                if(~isnan(Zg_mask(i,j)) && ~isnan(Zg_mask_(i,j)))
                    mask(i,j)=1;
                end
            end
        end
        
        Zg_mask = mask;
        x_track_window=Xg;
        y_track_window=Yg;
        x_track_window(isnan(Zg_mask))=NaN;
        y_track_window(isnan(Zg_mask))=NaN;
        
        T_='(rad)';
        D_=2;
    end
    
    l = 0;
    [row,col] = size(Zg);
    for x_=-ceil(WS/2):row
        xo = max(x_,1);
        xf = min(x_+(WS-1),row);
        xm = round((xo+xf)/2);
        for y_=-ceil(WS/2):col
            yo = max(y_,1);
            yf = min(y_+(WS-1),col);
            ym = round((yo+yf)/2);
            if(~isnan(Zg_mask(xm,ym)))
                l = l+1;
                %Windowing of TMI matrix
                T_w=Zg(xo:xf,yo:yf);
                %Windowing of derivative matrices
                Dx_w=Dx(xo:xf,yo:yf);
                Dy_w=Dy(xo:xf,yo:yf);
                Dz_w=Dz(xo:xf,yo:yf);
                %Windowing of coordinate matrices
                Xg_w=Xg(xo:xf,yo:yf);
                Yg_w=Yg(xo:xf,yo:yf);
                
                %Convert the above matrices in vectors
                [a,b]=size(T_w);
                T_v=reshape(T_w',[a*b,1]);
                Dx_v=reshape(Dx_w',[a*b,1]);
                Dy_v=reshape(Dy_w',[a*b,1]);
                Dz_v=reshape(Dz_w',[a*b,1]);
                Xg_v=reshape(Xg_w',[a*b,1]);
                Yg_v=reshape(Yg_w',[a*b,1]);
                
                %Matrix A
                N_v=ones((a*b),1);
                N_v = N_v.*N;
                A = cat(2,Dx_v,Dy_v,Dz_v,N_v);
                
                %Vetor d
                d = Xg_v.*Dx_v + Yg_v.*Dy_v + N_v.*T_v;
                
                %Euler depth solutions by least squares
                m=A\d;
                %erro=norm(A*m)
                EulerSolutions_x0(l) = m(1);
                EulerSolutions_y0(l) = m(2);
                EulerSolutions_z0(l) = m(3);
                EulerSolutions_B(l) = m(4);
            end
        end
    end
    
    %Deduct the flight height from EulerSolutions_z0
    if(get(popupFlightHeight_,'value')==3)
        fh = interp2(Xg,Yg,H__,EulerSolutions_x0,EulerSolutions_y0,'linear');
        EulerSolutions_z0 = EulerSolutions_z0-fh;
    else
        EulerSolutions_z0 = EulerSolutions_z0-H__;
    end
    
    %Remove those solutions that lies above the topographic surface
    if(get(popupFlightHeight_,'value')==3)
        topoAboveSolution = interp2(Xg,Yg,topo,EulerSolutions_x0,EulerSolutions_y0,'linear');
        EulerSolutions_z0 = -EulerSolutions_z0;
        EulerSolutions_x0(EulerSolutions_z0>topoAboveSolution) = [];
        EulerSolutions_y0(EulerSolutions_z0>topoAboveSolution) = [];
        EulerSolutions_z0(EulerSolutions_z0>topoAboveSolution) = [];
        EulerSolutions_z0 = -EulerSolutions_z0;
    elseif(get(popupFlightHeight_,'value')==2)
        EulerSolutions_z0 = -EulerSolutions_z0;
        EulerSolutions_x0(EulerSolutions_z0>H__)=[];
        EulerSolutions_y0(EulerSolutions_z0>H__)=[];
        EulerSolutions_z0(EulerSolutions_z0>H__)=[];
        EulerSolutions_z0 = -EulerSolutions_z0;
    else
        EulerSolutions_z0 = -EulerSolutions_z0;
        EulerSolutions_x0(EulerSolutions_z0>0)=[];
        EulerSolutions_y0(EulerSolutions_z0>0)=[];
        EulerSolutions_z0(EulerSolutions_z0>0)=[];
        EulerSolutions_z0 = -EulerSolutions_z0;
    end
    
    %Remove solutions at depth equal to zero
    EulerSolutions_x0(EulerSolutions_z0==0)=[];
    EulerSolutions_y0(EulerSolutions_z0==0)=[];
    EulerSolutions_z0(EulerSolutions_z0==0)=[];
    
    %Remove points with coordinates out of study area limits
    xv=[minX maxX maxX minX minX];
    yv=[minY minY maxY maxY minY];
    in=inpolygon(EulerSolutions_x0,EulerSolutions_y0,xv,yv);
    
    EulerSolutions_x0=EulerSolutions_x0(in);
    EulerSolutions_y0=EulerSolutions_y0(in);
    EulerSolutions_z0=EulerSolutions_z0(in);
    
    if(get(coordConversion,'Value')==1) %use original units
        denominator = 1;
        labelX = 'Easting (units)';
        labelY = 'Northing (units)';
        histogramXlabel = 'Quantity (units)';
    elseif(get(coordConversion,'Value')==2) %from m to km
        denominator = 1000;
        labelX = 'Easting (km)';
        labelY = 'Northing (km)';
        histogramXlabel = 'Depth (km)';
    elseif(get(coordConversion,'Value')==3) %from m to m
        denominator = 1;
        labelX = 'Easting (m)';
        labelY = 'Northing (m)';
        histogramXlabel = 'Depth (m)';
    elseif(get(coordConversion,'Value')==4) %from km to m
        denominator = 1/1000;
        labelX = 'Easting (m)';
        labelY = 'Northing (m)';
        histogramXlabel = 'Depth (m)';
    elseif(get(coordConversion,'Value')==5) %from km to km
        denominator = 1;
        labelX = 'Easting (km)';
        labelY = 'Northing (km)';
        histogramXlabel = 'Depth (km)';
    end
    
    %Plota as soluções de Euler
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    %PRODUCT WHICH THE MASK IS BASED
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
    surf(Xg./denominator,Yg./denominator,F)
    view([0,90])
    shading interp
    [row,col]=size(F);
    cmapChanged = colormaps(reshape(F,[row*col,1]),'clra','linear');
    colormap(cmapChanged)
    customColorbar(10,D_,17,0,17,'bold',T_,'E')
    set(gca,'fontSize',17)
    xlabel(labelX,'FontWeight','bold')
    ylabel(labelY,'FontWeight','bold')
    title('Filter used to construct the mask')
    axis image
    set(gca,'Box','on')
    generateCoord(gca)
    set(gca,'YTickLabelRotation',90)
    p_ = get(gca,'position');
    
    %CONSTRAINING MASK
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    scatter(x_track_window(:)./denominator,y_track_window(:)./denominator,5,'r','filled')
    set(gca,'fontSize',18)
    title('Constraining Mask')
    xlabel(labelX,'FontWeight','bold')
    ylabel(labelY,'FontWeight','bold')
    axis image
    xlim([minX./denominator maxX./denominator])
    ylim([minY./denominator maxY./denominator])
    grid on
    set(gca,'Box','on')
    generateCoord(gca)
    set(gca,'YTickLabelRotation',90)
    set(gca,'position',p_)
    
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    scatter3(EulerSolutions_x0./denominator,...
        EulerSolutions_y0./denominator,...
        EulerSolutions_z0./denominator,...
        20,EulerSolutions_z0./denominator,'filled');
    xlim([minX./denominator maxX./denominator])
    ylim([minY./denominator maxY./denominator])
    zlim([min(EulerSolutions_z0)./denominator max(EulerSolutions_z0)./denominator])
    cmapChanged = colormaps(EulerSolutions_z0./denominator,'clra','linear');
    colormap(cmapChanged)
    customColorbar(6,3,18,0,18,'bold',histogramXlabel,'E')
    stringTitle = {strcat('EULER DEPTH SOLUTIONS N=',num2str(N));...
                   strcat('WINDOW SIZE=',num2str(WS),'x',num2str(WS))};
    title(stringTitle)
    xlabel(labelX,'FontWeight','bold')
    ylabel(labelY,'FontWeight','bold')
    zlabel(histogramXlabel,'FontWeight','bold')
    set(gca,'Zdir','reverse')
    set(gca,'FontSize',20)
    %view(-56,17)
    view(0,90)
    grid on
    set(gca,'Box','on')
    generateCoord(gca)
    axis image
    
    handles.WS = WS;
    handles.N = N;
    handles.minX = minX;
    handles.maxX = maxX;
    handles.minY = minY;
    handles.maxY = maxY;
    handles.minZ = min(EulerSolutions_z0);
    handles.maxZ = max(EulerSolutions_z0);
    handles.EulerSolutions_x0 = EulerSolutions_x0;
    handles.EulerSolutions_y0 = EulerSolutions_y0;
    handles.EulerSolutions_z0 = EulerSolutions_z0;
    handles.EulerSolutions_B = EulerSolutions_B;
    handles.x_track_window = x_track_window;
    handles.y_track_window = y_track_window;
    handles.Dx = Dx;
    handles.Dy = Dy;
    handles.Dz = Dz;
    eulerPerformed = 'y';
else
    msgbox('Load some data before trying to compute euler deconvolution.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW EULER DEPTH SOLUTION HISTOGRAM
function solutionHisto_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed=='y')
    EulerSolutions_x0_v = handles.EulerSolutions_x0_v;
    EulerSolutions_y0_v = handles.EulerSolutions_y0_v;
    EulerSolutions_z0_v = handles.EulerSolutions_z0_v;
    Xg = handles.Xg;
    Yg = handles.Yg;
    H__ = handles.H__;
    N = handles.N;
    WS = handles.WS;
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    edges=linspace(0,max(-EulerSolutions_z0_v),30);
    histogram(-EulerSolutions_z0_v,edges,'FaceColor',[.5 .5 .5])
    xlabel('Depth [m]')
    ylabel('Samples')
    title('DEPTH SOLUTIONS HISTOGRAM')
    xlim([0 max(-EulerSolutions_z0_v)])
    set(gca,'fontSize',17)
    grid on
    
    f1=figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__]);
    scatter3(EulerSolutions_x0_v,EulerSolutions_y0_v,EulerSolutions_z0_v,20,EulerSolutions_z0_v,'filled')
    cmapChanged = colormaps(EulerSolutions_z0_v,'clra','linear');
    colormap(cmapChanged)
    customColorbar(10,1,16,0,17,'bold','Depth [m]','E')
    xlim([min(Xg(:)) max(Xg(:))])
    ylim([min(Yg(:)) max(Yg(:))])
    zlim([min(EulerSolutions_z0_v) H__])
    stringTitle = strcat('EULER DEPTH SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
    title(stringTitle)
    xlabel('Easting [m]')
    ylabel('Northing [m]')
    zlabel('Depth [m]')
    set(gca,'fontSize',17)
    widthArea=max(Xg(:))-min(Xg(:));
    heightArea=max(Yg(:))-min(Yg(:));
    if(widthArea>heightArea)
        b=heightArea/widthArea;
        pbaspect([1 b 0.3])
    else
        b=widthArea/heightArea;
        pbaspect([b 1 0.3])
    end
    view(-24,27)
    grid on
    grid minor
    set(gca,'Box','on')
    setCoord(min(Xg(:)),min(Yg(:)),widthArea,heightArea,5,5)
    
    set(f1,'WindowButtonDownFcn',@mouseButtonD)
else
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW EULER DEPTH SOLUTION HISTOGRAM
function showInput_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg./1000,Yg./1000,Zg)
    [row,col]=size(Zg);
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','equalized');
    colormap(cmapChanged)
    shading interp
    customColorbar(10,3,13,0,15,'normal','','E')
    xlabel('Easting [km]')
    ylabel('Northing [km]')
    title('INPUT DATA')
    set(gca,'fontSize',14)
    axis image
else
    
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW X DERIVATIVE OF THE INPUT DATASET
function showDx_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Dx = handles.Dx;
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg./1000,Yg./1000,Dx)
    [row,col]=size(Dx);
    cmapChanged = colormaps(reshape(Dx,[row*col,1]),'clra','equalized');
    colormap(cmapChanged)
    shading interp
    customColorbar(10,3,13,0,15,'normal','','E')
    xlabel('Easting [km]')
    ylabel('Northing [km]')
    title('D_x OF INPUT DATA')
    set(gca,'fontSize',14)
    axis image
else
    
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW Y DERIVATIVE OF THE INPUT DATASET
function showDy_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Dy = handles.Dy;
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg./1000,Yg./1000,Dy)
    [row,col]=size(Dy);
    cmapChanged = colormaps(reshape(Dy,[row*col,1]),'clra','equalized');
    colormap(cmapChanged)
    shading interp
    customColorbar(10,3,13,0,15,'normal','','E')
    xlabel('Easting [km]')
    ylabel('Northing [km]')
    title('D_y OF INPUT DATA')
    set(gca,'fontSize',14)
    axis image
else
    
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SHOW X DERIVATIVE OF THE INPUT DATASET
function showDz_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Dz = handles.Dz;
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg./1000,Yg./1000,Dz)
    [row,col]=size(Dz);
    cmapChanged = colormaps(reshape(Dz,[row*col,1]),'clra','equalized');
    colormap(cmapChanged)
    shading interp
    customColorbar(10,3,13,0,15,'normal','','E')
    xlabel('Easting [km]')
    ylabel('Northing [km]')
    title('D_z OF INPUT DATA')
    set(gca,'fontSize',14)
    axis image
else
    
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(eulerPerformed == 'y')
    WS = handles.WS;
    N = handles.N;
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    EulerSolutions_x0 = handles.EulerSolutions_x0;
    EulerSolutions_y0 = handles.EulerSolutions_y0;
    inputFile = handles.EulerSolutions_z0;
    x_track_window = handles.x_track_window;
    y_track_window = handles.y_track_window;
    x_track_window(isnan(x_track_window))=[];
    y_track_window(isnan(y_track_window))=[];
    z_mask = ones(size(y_track_window));
    
    outputFile = matrix2xyz(EulerSolutions_x0,EulerSolutions_y0,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return;
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%14s %14s %14s\r\n','X0','Y0','Z0');
    fprintf(fid,'%6.2f %6.2f %6.2f\r\n',transpose(outputFile));
    fprintf(fid,'%14s\r\n',num2str(WS));
    fprintf(fid,'%14s\r\n',num2str(N));
    fprintf(fid,'%14s\r\n',num2str(minX));
    fprintf(fid,'%14s\r\n',num2str(maxX));
    fprintf(fid,'%14s\r\n',num2str(minY));
    fprintf(fid,'%14s\r\n',num2str(maxY));
    fprintf(fid,'%14s\r\n',num2str(minZ));
    fprintf(fid,'%14s\r\n',num2str(maxZ));
    fclose(fid);
    
    if(get(functionDriveW,'Value')==1)
        fid = fopen([PathName 'mask_tdr.xyz'],'w+');
    elseif(get(functionDriveW,'Value')==2)
        fid = fopen([PathName 'mask_tdr-tdx.xyz'],'w+');
    elseif(get(functionDriveW,'Value')==3)
        fid = fopen([PathName 'mask_tdr+tdx.xyz'],'w+');
    else
        fid = fopen([PathName 'mask_asa.xyz'],'w+');
    end
    fprintf(fid,'%6.2f %6.2f %6.2f\r\n',transpose(matrix2xyz(x_track_window,y_track_window,z_mask)));
    fclose(fid);
else
    msgbox('Compute euler solutions before trying to save a file.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
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

function setCoord(xLimMin,yLimMin,W,H,nx,ny)
    r_W=W/nx;
    r_H=H/ny;
    
    for i=1:ny-1
        coordY(i)=round(yLimMin+i*r_H);
    end
    
    for i=1:nx-1
        coordX(i)=round(xLimMin+i*r_W);
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
    if (outX && outY && eulerPerformed=='y') %VERIFY IF MOUSE IS HOVERING OVER THE GRAPH
        [az,el]=view;
        if(az==0 && el==90)
            set(gca,'YTickLabelRotation',90)
        else
            set(gca,'YTickLabelRotation',0)
        end
    end
end

function Zg_out = removeAloneSpikes(Zg)
    [row,col]=size(Zg);
    
    for i=2:row-1
        for j=2:col-1
            edgeCondition = isnan([Zg(i+1,j),Zg(i-1,j),...
                Zg(i,j+1),Zg(i,j-1),...
                Zg(i+1,j+1),Zg(i+1,j-1),...
                Zg(i-1,j+1),Zg(i-1,j-1)]);
            
            if((i-1)==1 && (j-1)==1)
                Zg(i-1,j+1)=NaN; Zg(i-1,j)=NaN; Zg(i-1,j-1)=NaN;
                Zg(i,j-1)=NaN; Zg(i+1,j-1)=NaN;
            elseif((j-1)==1)
                if((i+1)==row)
                    Zg(i+1,j)=NaN; Zg(i+1,j+1)=NaN;
                end
                Zg(i-1,j-1)=NaN; Zg(i,j-1)=NaN; Zg(i+1,j-1)=NaN;
            elseif((i+1)==row)
                if((j+1)==col)
                    Zg(i,j+1)=NaN; Zg(i-1,j+1)=NaN;
                end
                Zg(i+1,j-1)=NaN; Zg(i+1,j)=NaN; Zg(i+1,j+1)=NaN;
            elseif((j+1)==col)
                if((i-1)==1)
                    Zg(i-1,j)=NaN; Zg(i-1,j-1)=NaN;
                end
                Zg(i+1,j+1)=NaN; Zg(i,j+1)=NaN; Zg(i-1,j+1)=NaN;
            elseif((i-1)==1)
                Zg(i-1,j+1)=NaN; Zg(i-1,j)=NaN; Zg(i-1,j-1)=NaN;
            end
            
            if((~isnan(Zg(i,j)) && sum(edgeCondition)>=5))
                Zg(i,j)=NaN;
            end
        end
    end
    Zg_out=Zg;
end

function generateCoord(s1)

xl_s1=get(s1,'XLim'); yl_s1=get(s1,'YLim');
minX = xl_s1(1); maxX = xl_s1(2);
minY = yl_s1(1); maxY = yl_s1(2);

set(s1,'Xlim',[minX maxX])
set(s1,'Ylim',[minY maxY])
set(s1,'YTickLabelRotation',90)
Y_coord = linspace(minY,maxY,5);
set(s1,'YTick',Y_coord)
Y_coord_ = prepCoord(Y_coord);
set(s1,'YTickLabel',Y_coord_)
X_coord = linspace(minX,maxX,5);
set(s1,'XTick',X_coord)
X_coord_ = prepCoord(X_coord);
set(s1,'XTickLabel',X_coord_)
set(s1,'Box','on')

end

end