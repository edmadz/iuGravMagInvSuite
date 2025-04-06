function GUIclassical3DEulerDeconv

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIclassical3DEulerDeconv_ = figure('Menubar','none',...
    'Name','Classical Euler Deconvolution [Moving Window]',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------
inputParametersPanel = uipanel(GUIclassical3DEulerDeconv_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

expansion_ = uicontrol(inputParametersPanel,'Style','edit',...
    'TooltipString','Percent grid expansion (%).',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.03 0.915 0.944 0.036]);

H_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'TooltipString','Mean Flight Heigth [meters]. For ground survey set this value zero.',...
    'position',[0.03 0.865 0.944 0.036]);

DP_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','100',...
    'fontUnits','normalized',...
    'TooltipString','Consider only the solutions that lies between a pre estipulated acceptance depth interval.',...
    'position',[0.03 0.815 0.944 0.036]);

DWS_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','100',...
    'fontUnits','normalized',...
    'TooltipString','Accept the solutions, whose distance from the window center, lies between a pre stipulated distance value.',...
    'position',[0.03 0.765 0.944 0.036]);

J_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','10',...
    'fontUnits','normalized',...
    'TooltipString','Window size in grid nodes.',...
    'position',[0.03 0.715 0.944 0.036]);

N_ = uicontrol(inputParametersPanel,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'TooltipString','Value related with the source shape (Structural Index).',...
    'position',[0.03 0.665 0.944 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Euler Deconvolution',...
    'fontUnits','normalized',...
    'position',[0.03 0.615 0.944 0.036],...
    'CallBack',@EulerDeconv_callBack);

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
graphPanel = uipanel(GUIclassical3DEulerDeconv_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graphSol = axes(graphPanel,'Units','normalized',...
    'position',[0.1 0.1 0.8 0.8]);
set(get(graphSol,'XAxis'),'Visible','off');
set(get(graphSol,'YAxis'),'Visible','off');
%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIclassical3DEulerDeconv_,'label','File');
uimenu(file,'Label','Open Input Data...','Accelerator','O','CallBack',@OpenFile_callBack);
uimenu(file,'Label','Save Euler Solutions...','Accelerator','S','CallBack',@GenerateFile_callBack);

Cmenu = uicontextmenu(GUIclassical3DEulerDeconv_);
set(GUIclassical3DEulerDeconv_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
eulerPerformed = 'n';
set(GUIclassical3DEulerDeconv_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
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
guidata(GUIclassical3DEulerDeconv_,handles);
end

%COMPUTE EULER DECONVOLUTION
function EulerDeconv_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(dataLoaded == 'y')
    Zg = handles.Zg;
    Xg = handles.Xg;
    Yg = handles.Yg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    widthArea = maxX-minX;
    heightArea = maxY-minY;
    
    DP = str2double(get(DP_,'String'))/100;
    if((DP<0) || (DP>1))
        set(DP_,'String',100)
        msgbox('Provide a value between 0 and 100.','Warn','warn')
        return
    end
    
    DWS = str2double(get(DWS_,'String'))/100;
    if((DWS<0) || (DWS>1))
        set(DP_,'String',100)
        msgbox('Provide a value between 0 and 100.','Warn','warn')
        return
    end
    
    H__ = str2double(get(H_,'String'));
    if(H__<0)
        set(H_,'String',0)
        msgbox('Provide a positive value for the mean flight heigth.','Warn','warn')
        return
    end
    
    WS = str2double(get(J_,'String'));
    N = str2double(get(N_,'String'));
    exp=str2double(get(expansion_,'String'));
    
    %Calculate the derivatives
    Dx = difference(Xg,Yg,Zg,'x',exp);
    Dy = difference(Xg,Yg,Zg,'y',exp);
    Dz = differentiate(Xg,Yg,Zg,'z',exp);
    
    %Euler solution matrices
    EulerSolutions_x0 = zeros(size(Zg));
    EulerSolutions_y0 = zeros(size(Zg));
    EulerSolutions_z0 = zeros(size(Zg));
    EulerSolutions_B = zeros(size(Zg));
    Dist_ = zeros(size(Zg));
    
    Z__=Zg;
    
    [row,col] = size(Zg);
    for x_=1:row-(WS-1)
        for y_=1:col-(WS-1)
            %Windowing of TMI matrix
            T_w=Z__(x_:(x_+(WS-1)),y_:(y_+(WS-1)));
            %Windowing of derivative matrices
            Dx_w=Dx(x_:(x_+(WS-1)),y_:(y_+(WS-1)));
            Dy_w=Dy(x_:(x_+(WS-1)),y_:(y_+(WS-1)));
            Dz_w=Dz(x_:(x_+(WS-1)),y_:(y_+(WS-1)));
            %Windowing of coordinate matrices
            Xg_w=Xg(x_:(x_+(WS-1)),y_:(y_+(WS-1)));
            Yg_w=Yg(x_:(x_+(WS-1)),y_:(y_+(WS-1)));
            
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
            EulerSolutions_x0(x_,y_)=m(1);
            EulerSolutions_y0(x_,y_)=m(2);
            EulerSolutions_z0(x_,y_)=m(3)-H__;
            EulerSolutions_B(x_,y_)=m(4);
            
            %Distance between euler solution and the central position of
            %corresponding window
            X_windowCenter = min(Xg_w(:))+((max(Xg_w(:))-min(Xg_w(:)))/2);
            Y_windowCenter = min(Yg_w(:))+((max(Yg_w(:))-min(Yg_w(:)))/2);
            Dist_(x_,y_) = sqrt((X_windowCenter-(EulerSolutions_x0(x_,y_)))^2+(Y_windowCenter-(EulerSolutions_y0(x_,y_)))^2+(EulerSolutions_z0(x_,y_))^2);
        end
    end
    
    %Converte as matrizes das posições das soluções em vetores
    EulerSolutions_x0_v = reshape(EulerSolutions_x0',[row*col,1]);
    EulerSolutions_y0_v = reshape(EulerSolutions_y0',[row*col,1]);
    EulerSolutions_z0_v = reshape(EulerSolutions_z0',[row*col,1]);
%     Dist_v = reshape(Dist_',[row*col,1]);
%     disp(strcat('Dist Min: ',num2str(min(Dist_v)),' m'))
%     disp(strcat('Dist Mean: ',num2str(mean(Dist_v)),' m'))
%     disp(strcat('Dist Max: ',num2str(max(Dist_v)),' m'))
%     %------------------------------------------- FILTERING 01
%     tolDistanceMax = mean(Dist_v)+(mean(Dist_v)*DWS);
%     
%     n_=length(EulerSolutions_z0_v);
%     for x_=1:n_
%         if((Dist_v(x_)>tolDistanceMax))
%             EulerSolutions_x0_v(x_) = NaN;
%             EulerSolutions_y0_v(x_) = NaN;
%             EulerSolutions_z0_v(x_) = NaN;
%         end
%     end
%     
%     EulerSolutions_x0_v(isnan(EulerSolutions_x0_v))=[];
%     EulerSolutions_y0_v(isnan(EulerSolutions_y0_v))=[];
%     EulerSolutions_z0_v(isnan(EulerSolutions_z0_v))=[];
%     
    %------------------------------------------- FILTERING 02
%     tolDepthMax = -WS_m-(WS_m*DP);
    
%     n_=length(EulerSolutions_z0_v);
%     for x_=1:n_
%         if((EulerSolutions_z0_v(x_) > H__))% || (EulerSolutions_z0_v(x_) < tolDepthMax))
%             EulerSolutions_x0_v(x_) = NaN;
%             EulerSolutions_y0_v(x_) = NaN;
%             EulerSolutions_z0_v(x_) = NaN;
%         end
%     end
%     
%     EulerSolutions_x0_v(isnan(EulerSolutions_x0_v))=[];
%     EulerSolutions_y0_v(isnan(EulerSolutions_y0_v))=[];
%     EulerSolutions_z0_v(isnan(EulerSolutions_z0_v))=[];
    
    %------------------------------------------- FILTERING 03
    EulerSolutions_x0_v(EulerSolutions_z0_v<0) = [];
    EulerSolutions_y0_v(EulerSolutions_z0_v<0) = [];
    EulerSolutions_z0_v(EulerSolutions_z0_v<0) = [];
    
    %------------------------------------------- FILTERING 04
    xv=[minX maxX maxX minX minX];
    yv=[minY minY maxY maxY minY];
    in=inpolygon(EulerSolutions_x0_v,EulerSolutions_y0_v,xv,yv);
    
    EulerSolutions_x0_v=EulerSolutions_x0_v(in);
    EulerSolutions_y0_v=EulerSolutions_y0_v(in);
    EulerSolutions_z0_v=EulerSolutions_z0_v(in);
    
    axes(graphSol)
    scatter3(EulerSolutions_x0_v,EulerSolutions_y0_v,EulerSolutions_z0_v,20,EulerSolutions_z0_v,'filled')
    view(0,90)
    cmapChanged = colormaps(EulerSolutions_z0_v,'clra','linear');
    colormap(flipud(cmapChanged))
    c=colorbar;
    set(get(c,'Label'),'String','DEPTH (m)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    zlabel('Depth (m)')
    xlim([minX maxX])
    ylim([minY maxY])
    zlim([H__ max(EulerSolutions_z0_v)])
    stringTitle = strcat('EULER DEPTH SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
    title(stringTitle)
    if(widthArea>heightArea)
        b=heightArea/widthArea;
        pbaspect([1 b 0.3])
    else
        b=widthArea/heightArea;
        pbaspect([b 1 0.3])
    end
    grid on
    set(gca,'Box','on')
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
    set(gca,'ZDir','reverse')
    
    set(graphSol,'ButtonDownFcn',@mouseButtonD)
    
    handles.WS = WS;
    handles.N = N;
    handles.minX = min(min(Xg));
    handles.maxX = max(max(Xg));
    handles.minY = min(min(Yg));
    handles.maxY = max(max(Yg));
    handles.minZ = min(EulerSolutions_z0_v);
    handles.maxZ = max(EulerSolutions_z0_v);
    handles.EulerSolutions_x0_v = EulerSolutions_x0_v;
    handles.EulerSolutions_y0_v = EulerSolutions_y0_v;
    handles.EulerSolutions_z0_v = EulerSolutions_z0_v;
    handles.Dx = Dx;
    handles.Dy = Dy;
    handles.Dz = Dz;
    eulerPerformed = 'y';
else
    msgbox('Load some data before trying to compute euler deconvolution.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
end

%SHOW EULER DEPTH SOLUTION HISTOGRAM
function solutionHisto_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(eulerPerformed=='y')
    EulerSolutions_z0_v = handles.EulerSolutions_z0_v;
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    edges=linspace(0,max(EulerSolutions_z0_v),30);
    histogram(EulerSolutions_z0_v,edges,'FaceColor',[.5 .5 .5])
    xlabel('DEPTH (m)')
    ylabel('NUMBER OF DEPTH SOLUTIONS')
    title('DEPTH SOLUTIONS HISTOGRAM')
    xlim([0 max(EulerSolutions_z0_v)])
    set(gca,'fontSize',17)
    grid on
else
    msgbox('Load some data before trying to show the depth histogram.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
end

%SHOW EULER DEPTH SOLUTION HISTOGRAM
function showInput_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg,Yg,Zg)
    [row,col]=size(Zg);
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),'clra','equalized');
    colormap(cmapChanged)
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','RTP TMI (nT)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
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
    set(gca,'ZDir','reverse')
else
    msgbox('Load some data before trying to display the input data.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
end

%SHOW X DERIVATIVE OF THE INPUT DATASET
function showDx_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(eulerPerformed=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Dx = handles.Dx;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg,Yg,Dx)
    [row,col]=size(Dx);
    cmapChanged = colormaps(reshape(Dx,[row*col,1]),'gray','linear');
    colormap(cmapChanged)
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','D_x (nT/m)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    title('D_x OF THE INPUT DATA')
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
else
    msgbox('Load some data before trying to display the horizontal derivative in x direction of the input data.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
end

%SHOW Y DERIVATIVE OF THE INPUT DATASET
function showDy_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(eulerPerformed=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Dy = handles.Dy;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg,Yg,Dy)
    [row,col]=size(Dy);
    cmapChanged = colormaps(reshape(Dy,[row*col,1]),'gray','linear');
    colormap(cmapChanged)
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','D_y (nT/m)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    title('D_y OF THE INPUT DATA')
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
else
    msgbox('Load some data before trying to display the horizontal derivative in y direction of the input data.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
end

%SHOW X DERIVATIVE OF THE INPUT DATASET
function showDz_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(eulerPerformed=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Dz = handles.Dz;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    %Plot the euler solutions
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    figure('units','pixel','Position',[posX_,posY_,figWidth__,figHeight__])
    pcolor(Xg,Yg,Dz)
    [row,col]=size(Dz);
    cmapChanged = colormaps(reshape(Dz,[row*col,1]),'gray','linear');
    colormap(cmapChanged)
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','D_z (nT/m)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    title('D_z OF THE INPUT DATA')
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
else
    msgbox('Load some data before trying to display the vertical derivative of the input data.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIclassical3DEulerDeconv_);

if(eulerPerformed == 'y')
    WS = handles.WS;
    N = handles.N;
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    EulerSolutions_x0_v = handles.EulerSolutions_x0_v;
    EulerSolutions_y0_v = handles.EulerSolutions_y0_v;
    inputFile = handles.EulerSolutions_z0_v;
    
    outputFile = matrix2xyz(EulerSolutions_x0_v,EulerSolutions_y0_v,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%4s %4s %4s\r\n','X0','Y0','Z0');
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
else
    msgbox('Compute euler solutions before trying to save a file.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIclassical3DEulerDeconv_,handles);
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
    if (outX && outY && eulerPerformed=='y') %VERIFY IF MOUSE IS HOVERING OVER THE GRAPH
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