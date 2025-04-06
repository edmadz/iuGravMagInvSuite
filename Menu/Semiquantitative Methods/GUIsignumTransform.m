function GUIsignumTransform

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIsignumTransform_ = figure('Name','Signum Transform',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUIsignumTransform_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUIsignumTransform_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);
%--------------------------------------------------------------------------
popupDist = uicontrol(GUIsignumTransform_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

popup = uicontrol(GUIsignumTransform_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Dz','Dzz','Dz-THDR'},...
    'fontUnits','normalized',...
    'position',[0.3 0.625 0.32 0.08]);

g_ = uicontrol(GUIsignumTransform_,'Style','edit',...
    'TooltipString','Factor used to remove depth solutions greater than the mean + standard deviation (eg. mean+(factor*std)).',...
    'units','normalized',...
    'String','2',...
    'fontUnits','normalized',...
    'position',[0.63 0.625 0.32 0.08]);

expansion_ = uicontrol(GUIsignumTransform_,'Style','edit',...
    'TooltipString','Percent grid expansion (%).',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.3 0.525 0.32 0.08]);

coordConversion = uicontrol(GUIsignumTransform_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.63 0.525 0.32 0.08]);

uicontrol(GUIsignumTransform_,'Style','pushbutton',...
    'units','normalized',...
    'String','Apply Signum Transform',...
    'fontUnits','normalized',...
    'position',[0.3 0.325 0.65 0.08],...
    'CallBack',@Signum_callBack);

uicontrol(GUIsignumTransform_,'Style','pushbutton',...
    'units','normalized',...
    'String','Compute Depth and Width',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@computeDepth_callBack);

%--------------------------------------------------------------------------

uicontrol(GUIsignumTransform_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUIsignumTransform_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUIsignumTransform_);
set(GUIsignumTransform_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
stQualiApplied = 'n';
stSemiQuantiApplied = 'n';
set(GUIsignumTransform_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsignumTransform_);

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
guidata(GUIsignumTransform_,handles);
end

%APPLY THE SIGNUM TRANSFORM
function Signum_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsignumTransform_);

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    exp = str2double(get(expansion_,'String'));
    
    if(get(popup,'Value') == 1)
        Dz = differentiate(Xg,Yg,Zg,'z',exp);
        f = Dz;
    elseif(get(popup,'Value') == 2)
        Dx = difference(Xg,Yg,Zg,'x',exp);
        Dxx = difference(Xg,Yg,Dx,'x',exp);
        Dy = difference(Xg,Yg,Zg,'y',exp);
        Dyy = difference(Xg,Yg,Dy,'y',exp);
        Dzz = -(Dxx+Dyy);
        f = Dzz;
    elseif(get(popup,'Value') == 3)
        Dx = difference(Xg,Yg,Zg,'x',exp);
        Dy = difference(Xg,Yg,Zg,'y',exp);
        Dz = differentiate(Xg,Yg,Zg,'z',exp);
        THDR = sqrt(Dx.^2+Dy.^2);
        f = Dz-THDR;
    end
    
    %f = f./abs(f);
    f = (f>=0)-(f<0);
    f_ = imgaussfilt(f,0.5);
    
    d = get(popupDist,'Value');
    c = get(coordConversion,'Value');
    [fig1,fig2]=generateResultFigures(1000,700,Xg,Yg,Zg,f_,d,2,'clra','clra',c);
    
    %link the axes of the result figures
    h_1=zoom(fig1); set(h_1,'ActionPostCallback',@linkAxes)
    h_2=zoom(fig2); set(h_2,'ActionPostCallback',@linkAxes)
    p_1=pan(fig1); set(p_1,'ActionPostCallback',@linkAxes)
    p_2=pan(fig2); set(p_2,'ActionPostCallback',@linkAxes)
    
    set(fig1,'WindowButtonDownFcn',@mouseButtonD)
    set(fig2,'WindowButtonDownFcn',@mouseButtonD)
    
    handles.Xg = Xg;
    handles.Yg = Yg;
    handles.f = f;
    stQualiApplied = 'y';
    stSemiQuantiApplied = 'n';
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIsignumTransform_,handles);
end

%ESTIMATE DEPTH
function computeDepth_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsignumTransform_);

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    minX = min(Xg(:)); maxX = max(Xg(:));
    minY = min(Yg(:)); maxY = max(Yg(:));
    
    widthArea = maxX-minX;
    heightArea = maxY-minY;
    
    Dz = differentiate(Xg,Yg,Zg,'z',25);
    %ST_dz = (Dz>=0)-(Dz<0);
    
    Dx = difference(Xg,Yg,Zg,'x',25);
    Dy = difference(Xg,Yg,Zg,'y',25);
    THDR = sqrt(Dx.^2+Dy.^2);
    dz_thdr = Dz-THDR;
    %ST_dz_thdr = (dz_thdr>=0)-(dz_thdr<0);
    
    TDR = atan2(Dz,THDR);
    TDX = atan2(THDR,abs(Dz));
    TDR_TDX=TDR-TDX;
    fp = [0.06 0.10 0.06;0.10 0.06 0.10;0.06 0.10 0.06];
    TDR_TDX=applyConvFilter(TDR_TDX,25,fp,1);
    
    [X__,Y__,~,~]=peakfinder(Xg,Yg,TDR_TDX);
    
    C_peak = cat(2,X__',Y__');
    
    f=figure('Visible','off');
    [C_dz,~]=contour(Xg,Yg,Dz,[0 0]); hold on
    [C_dz_thdr,~]=contour(Xg,Yg,dz_thdr,[0 0]);
    scatter(X__,Y__,5,'k')
    delete(f)
    
    [depth,width_]=signumDepth(C_dz,C_dz_thdr,C_peak);
    
    X__(depth<0)=[];
    Y__(depth<0)=[];
    width_(depth<0)=[];
    depth(depth<0)=[];
    
    medianDepth = median(depth);
    g=str2double(get(g_,'String'));
    stdDepth = g*std(depth);
    
    X__(depth>(medianDepth+stdDepth))=[];
    Y__(depth>(medianDepth+stdDepth))=[];
    width_(depth>(medianDepth+stdDepth))=[];
    depth(depth>(medianDepth+stdDepth))=[];
    
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H_ = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H_/2 - figHeight__/2;
    
    %depth solutions
    fig1=figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
    scatter3(X__,Y__,depth,20,depth,'filled')
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
    title('SIGNUM DEPTH SOLUTIONS')
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
    
    %width solutions
    fig2=figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
    scatter3(X__,Y__,width_,20,width_,'filled')
    view(0,90)
    cmapChanged = colormaps(width_,'clra','linear');
    colormap(flipud(cmapChanged))
    shading interp
    c=colorbar;
    set(get(c,'Label'),'String','WIDTH (m)')
    set(get(c,'Label'),'FontWeight','bold')
    set(get(c,'Label'),'FontSize',17)
    ylabel('Northing (m)','FontWeight','bold')
    xlabel('Easting (m)','FontWeight','bold')
    zlabel('Depth (m)')
    title('SIGNUM WIDTH SOLUTIONS')
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
    
    %histogram
    figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__])
    edges=linspace(0,max(depth),30);
    histogram(depth,edges,'FaceColor',[.5 .5 .5])
    xlabel('DEPTH (m)')
    ylabel('NUMBER OF DEPTH SOLUTIONS')
    title('DEPTH SOLUTION HISTOGRAM')
    xlim([0 max(depth)])
    set(gca,'fontSize',17)
    grid on
    
    set(fig1,'WindowButtonDownFcn',@mouseButtonD_)
    set(fig2,'WindowButtonDownFcn',@mouseButtonD_)
    
    minX=min(Xg(:)); maxX=max(Xg(:));
    minY=min(Yg(:)); maxY=max(Yg(:));
    minZ=min(depth);
    
    handles.minX = minX;
    handles.maxX = maxX;
    handles.minY = minY;
    handles.maxY = maxY;
    handles.minZ = minZ;
    handles.maxZ = 0;
    handles.X__ = X__;
    handles.Y__ = Y__;
    handles.width_ = width_;
    handles.depth = depth;
    stSemiQuantiApplied = 'y';
    stQualiApplied = 'n';
else
    msgbox('Load some data before trying to compute depth and width.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUIsignumTransform_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIsignumTransform_);

if(stSemiQuantiApplied == 'y')
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    X__ = handles.X__;
    Y__ = handles.Y__;
    inputFile = handles.depth;
    
    outputFile = matrix2xyz(X__,Y__,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    
    ds = '_depth_solution';
    FileName_depth = editFileName(FileName,ds);
    
    Fullpath = [PathName FileName_depth];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%1s %1s %1s\r\n','X','Y','D');
    fprintf(fid,'%6.4f %6.4f %6.4f\r\n',transpose(outputFile));
    fprintf(fid,'%14s\r\n',num2str(minX));
    fprintf(fid,'%14s\r\n',num2str(maxX));
    fprintf(fid,'%14s\r\n',num2str(minY));
    fprintf(fid,'%14s\r\n',num2str(maxY));
    fprintf(fid,'%14s\r\n',num2str(minZ));
    fprintf(fid,'%14s\r\n',num2str(maxZ));
    fclose(fid);
    
    inputFile = handles.width_;
    outputFile = matrix2xyz(X__,Y__,inputFile);
    
    minZ = 0; maxZ=max(inputFile);
    
    ws = '_width_solution';
    FileName_width = editFileName(FileName,ws);
    
    Fullpath = [PathName FileName_width];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%1s %1s %1s\r\n','X','Y','W');
    fprintf(fid,'%6.4f %6.4f %6.4f\r\n',transpose(outputFile));
    fprintf(fid,'%14s\r\n',num2str(minX));
    fprintf(fid,'%14s\r\n',num2str(maxX));
    fprintf(fid,'%14s\r\n',num2str(minY));
    fprintf(fid,'%14s\r\n',num2str(maxY));
    fprintf(fid,'%14s\r\n',num2str(minZ));
    fprintf(fid,'%14s\r\n',num2str(maxZ));
    fclose(fid);
else
    Xg = handles.Xg;
    Yg = handles.Yg;
    inputFile = handles.f;
    
    outputFile = matrix2xyz(Xg,Yg,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%1s %1s %2s\r\n','X','Y','ST');
    fprintf(fid,'%6.4f %6.4f %6.4f\r\n',transpose(outputFile));
    fclose(fid);
end

%Update de handle structure
guidata(GUIsignumTransform_,handles);
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
    if (outX && outY && stQualiApplied=='y')
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

function mouseButtonD_(varargin)
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