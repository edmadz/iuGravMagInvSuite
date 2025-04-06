function GUICMWEulerDeconv

clc
clear
warning('off','all')

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUICMWEulerDeconv_ = figure('Name','Euler Deconvolution [Constrained Moving Window]',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUICMWEulerDeconv_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------
functionDriveW = uicontrol(GUICMWEulerDeconv_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'TDR','TDR-TDX','TDR+TDX','ASA','TDX'},...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

expansion_ = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'TooltipString','Percent grid expansion (%).',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.3 0.625 0.32 0.08]);

H_ = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'TooltipString','Mean flight heigth in meters (For ground survey set this value equal to zero).',...
    'position',[0.63 0.625 0.32 0.08]);

WS_ = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'units','normalized',...
    'String','10',...
    'fontUnits','normalized',...
    'TooltipString','Window size in grid nodes.',...
    'position',[0.3 0.525 0.32 0.08]);

N_ = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'TooltipString','Value related to source shape [Structural Index].',...
    'position',[0.63 0.525 0.32 0.08]);

n_1 = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'TooltipString','Number of times to pass a hanning window filter and reduce spurious peaks [spikes].',...
    'position',[0.3 0.425 0.32 0.08]);

coordConversion = uicontrol(GUICMWEulerDeconv_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use original units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'position',[0.63 0.425 0.32 0.08]);

uicontrol(GUICMWEulerDeconv_,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Euler Deconvolution',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@cmwEulerDeconv_callBack);

%--------------------------------------------------------------------------

uicontrol(GUICMWEulerDeconv_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUICMWEulerDeconv_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

dataLoaded = 'n';
eulerPerformed = 'n';
set(GUICMWEulerDeconv_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);
[cell_dx,cell_dy]=find_cell_size(Xg,Yg);

set(inputFile_path,'String',num2str(Fullpath))

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
    
    H__ = str2double(get(H_,'String'));
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
%         if(n>0)
%             fp = [0.06 0.10 0.06;0.10 0.06 0.10;0.06 0.10 0.06];
%             F=applyConvFilter(F,25,fp,n);
%         end
%         [~,~,ix,iy]=peakfinder(Xg,Yg,F);
%         N__=length(ix);
%         Zg_mask = NaN(size(Zg));
%         for i=1:N__
%             Zg_mask(ix(i),iy(i))=1;
%         end
        Zg_mask=F;
        if(get(functionDriveW,'Value')==5)
            Zg_mask(F<1)=NaN;
        else
            Zg_mask(F<0)=NaN;
%             Zg_mask(abs(F-0.1)>0.1)=NaN;
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
                EulerSolutions_z0(l) = m(3)-H__;
                EulerSolutions_B(l) = m(4);
            end
        end
    end
    
    EulerSolutions_x0(EulerSolutions_z0<0)=[];
    EulerSolutions_y0(EulerSolutions_z0<0)=[];
    EulerSolutions_z0(EulerSolutions_z0<0)=[];
    
    %Remove points with coordinates out of study area limits
    xv=[min(Xg(:)) max(Xg(:)) max(Xg(:)) min(Xg(:)) min(Xg(:))];
    yv=[min(Yg(:)) min(Yg(:)) max(Yg(:)) max(Yg(:)) min(Yg(:))];
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
    xlim([min(Xg(:))./denominator max(Xg(:))./denominator])
    ylim([min(Yg(:))./denominator max(Yg(:))./denominator])
    grid on
    set(gca,'Box','on')
    generateCoord(gca)
    set(gca,'YTickLabelRotation',90)
    set(gca,'position',p_)
    
%     figure('units','pixel','position', [posX_ posY_ figWidth__ 400])
%     binsLimits = binsGeneration(-1.5625,3.125,80);
%     histogram_(EulerSolutions_z0,binsLimits,'Samples',histogramXlabel)
%     set(gca,'XLim',[0,250])
%     xTck = linspace(0,250,11);
%     set(gca,'XTick',xTck)
%     set(gca,'XTickLabels',xTck/denominator)
%     yl=get(gca,'YLim');
%     hold on
%     plot([100,100],[yl(1),yl(2)],'k--','LineWidth',1)
%     plot([125,125],[yl(1),yl(2)],'k--','LineWidth',1)
%     plot([150,150],[yl(1),yl(2)],'k--','LineWidth',1)
%     plot([175,175],[yl(1),yl(2)],'k--','LineWidth',1)
%     plot([200,200],[yl(1),yl(2)],'k--','LineWidth',1)
%     plot([225,225],[yl(1),yl(2)],'k--','LineWidth',1)
%     
%     t=text(100,yl(2),'P1','HorizontalAlignment','center','FontSize',20);
%     g=get(t,'Extent'); set(t,'position',[g(1)+(g(3)/2),g(2)+(g(4))])
%     t=text(125,yl(2),'P2','HorizontalAlignment','center','FontSize',20);
%     g=get(t,'Extent'); set(t,'position',[g(1)+(g(3)/2),g(2)+(g(4))])
%     t=text(150,yl(2),'P3 P5','HorizontalAlignment','center','FontSize',20);
%     g=get(t,'Extent'); set(t,'position',[g(1)+(g(3)/2),g(2)+(g(4))])
%     t=text(175,yl(2),'P4','HorizontalAlignment','center','FontSize',20);
%     g=get(t,'Extent'); set(t,'position',[g(1)+(g(3)/2),g(2)+(g(4))])
%     t=text(200,yl(2),'P6','HorizontalAlignment','center','FontSize',20);
%     g=get(t,'Extent'); set(t,'position',[g(1)+(g(3)/2),g(2)+(g(4))])
%     t=text(225,yl(2),'P7','HorizontalAlignment','center','FontSize',20);
%     g=get(t,'Extent'); set(t,'position',[g(1)+(g(3)/2),g(2)+(g(4))])
%     hold off
    
%     edges=linspace(0,max(EulerSolutions_z0)./denominator,200);
%     histogram(EulerSolutions_z0./denominator,edges,'FaceColor',[.5 .5 .5])
%     xlabel(histogramXlabel)
%     ylabel('Number of Solutions')
%     title('Depth solution histogram')
%     set(gca,'fontSize',20)
%     set(gca,'XLim',[0,max(EulerSolutions_z0)./denominator])
%     grid on
    
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    scatter3(EulerSolutions_x0./denominator,...
        EulerSolutions_y0./denominator,...
        EulerSolutions_z0./denominator,...
        20,EulerSolutions_z0./denominator,'filled');
    xlim([min(Xg(:))./denominator max(Xg(:))./denominator])
    ylim([min(Yg(:))./denominator max(Yg(:))./denominator])
    zlim([H__./denominator max(EulerSolutions_z0)./denominator])
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
    handles.minX = min(Xg(:));
    handles.maxX = max(Xg(:));
    handles.minY = min(Yg(:));
    handles.maxY = max(Yg(:));
    handles.minZ = min(EulerSolutions_z0);
    handles.maxZ = max(EulerSolutions_z0);
    handles.EulerSolutions_x0 = EulerSolutions_x0;
    handles.EulerSolutions_y0 = EulerSolutions_y0;
    handles.EulerSolutions_z0 = EulerSolutions_z0;
    handles.EulerSolutions_B = EulerSolutions_B;
    handles.x_track_window = x_track_window;
    handles.y_track_window = y_track_window;
    eulerPerformed = 'y';
else
    msgbox('Load some data before trying to compute euler deconvolution.','Warn','warn','modal')
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
    x_track_window = handles.x_track_window;
    y_track_window = handles.y_track_window;
    x_track_window(isnan(x_track_window))=[];
    y_track_window(isnan(y_track_window))=[];
    z_mask = ones(size(y_track_window));
    inputFile = handles.EulerSolutions_z0;
    
    outputFile = matrix2xyz(EulerSolutions_x0,EulerSolutions_y0,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%5s %5s %5s\r\n','X0','Y0','Z0');
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

function Zg_out = removeAloneSpikes_(Zg)
    [row,col]=size(Zg);
    
    for i=2:row-1
        for j=2:col-1
            edgeCondition = isnan([Zg(i+1,j)+Zg(i-1,j),...
                Zg(i,j+1)+Zg(i,j-1),...
                Zg(i+1,j+1)+Zg(i-1,j-1),...
                Zg(i-1,j+1)+Zg(i+1,j-1)]);
            
%             if((i-1)==1 && (j-1)==1)
%                 Zg(i-1,j+1)=NaN; Zg(i-1,j)=NaN; Zg(i-1,j-1)=NaN;
%                 Zg(i,j-1)=NaN; Zg(i+1,j-1)=NaN;
%             elseif((j-1)==1)
%                 if((i+1)==row)
%                     Zg(i+1,j)=NaN; Zg(i+1,j+1)=NaN;
%                 end
%                 Zg(i-1,j-1)=NaN; Zg(i,j-1)=NaN; Zg(i+1,j-1)=NaN;
%             elseif((i+1)==row)
%                 if((j+1)==col)
%                     Zg(i,j+1)=NaN; Zg(i-1,j+1)=NaN;
%                 end
%                 Zg(i+1,j-1)=NaN; Zg(i+1,j)=NaN; Zg(i+1,j+1)=NaN;
%             elseif((j+1)==col)
%                 if((i-1)==1)
%                     Zg(i-1,j)=NaN; Zg(i-1,j-1)=NaN;
%                 end
%                 Zg(i+1,j+1)=NaN; Zg(i,j+1)=NaN; Zg(i-1,j+1)=NaN;
%             elseif((i-1)==1)
%                 Zg(i-1,j+1)=NaN; Zg(i-1,j)=NaN; Zg(i-1,j-1)=NaN;
%             end
            
            if((~isnan(Zg(i,j)) && sum(edgeCondition)>=4))
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