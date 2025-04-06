function GUIdataStatistics

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIdataStatistics_ = figure('Menubar','none',...
    'Name','Data Statistics',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowButtonDownFcn',@mouseButtonD);

%--------------------------------------------------------------------------

optionPanel = uipanel(GUIdataStatistics_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

popupColorDist = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.03 0.925 0.944 0.036],...
    'CallBack',@updateColorDist_callBack);

totalGridPoints = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Total number of grid points.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.875 0.944 0.036]);

numberOfSamples = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Number of samples.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.825 0.46 0.036]);

numberOfNaN = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Number of NaN/Dummie grid points.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.51 0.825 0.46 0.036]);

minValue = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Minimum value.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.775 0.944 0.036]);

maxValue = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Maximum value.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.725 0.944 0.036]);

mean_ = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Mean.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.675 0.944 0.036]);

median_ = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Median.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.625 0.944 0.036]);

variance = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Variance.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.575 0.944 0.036]);

standardDeviation = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Standard deviation.',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.525 0.944 0.036]);

dataPerc = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Data percentage until histogram vertical dotted red line.',...
    'Units','normalized',...
    'String','0%',...
    'fontUnits','normalized',...
    'position',[0.03 0.475 0.944 0.036]);

nBins = uicontrol(optionPanel,'Style','edit',...
    'TooltipString','Number of bins.',...
    'Units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'position',[0.03 0.425 0.944 0.036]);

CurrentSampleValue_=uicontrol(optionPanel,'Style','edit',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.375 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Update Histogram',...
    'fontUnits','normalized',...
    'position',[0.03 0.325 0.944 0.036],...
    'CallBack',@updateHistogram_callBack);

tgbtn_outliers=uicontrol(optionPanel,'Style','togglebutton',...
    'Units','normalized',...
    'String','Show Outliers on Map',...
    'fontUnits','normalized',...
    'Value',0,...
    'position',[0.03 0.275 0.944 0.036],...
    'CallBack',@showOutliers_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIdataStatistics_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

graph = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.1 0.1 0.35 0.8]);
set(get(graph,'XAxis'),'Visible','off');
set(get(graph,'YAxis'),'Visible','off');

graphHist = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.55 0.55 0.35 0.35]);
set(get(graphHist,'XAxis'),'Visible','off');
set(get(graphHist,'YAxis'),'Visible','off');

graphBoxplot = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.55 0.1 0.35 0.35]);
set(get(graphBoxplot,'XAxis'),'Visible','off');
set(get(graphBoxplot,'YAxis'),'Visible','off');

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIdataStatistics_,'label','File');
uimenu(file,'Label','Open File...','Accelerator','O','CallBack',@OpenFile_callBack);

Cmenu = uicontextmenu(GUIdataStatistics_);
set(GUIdataStatistics_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

Z__=[];
Xg_=[];
Yg_=[];
Zg_=[];
dataLoaded = 'n';
set(GUIdataStatistics_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIdataStatistics_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

minX = min(Xg(:)); maxX = max(Xg(:));
minY = min(Yg(:)); maxY = max(Yg(:));

Z_NaN=Z;
X_NaN=X;
Y_NaN=Y;
n_NaN=sum(double(isnan(Z_NaN)));
X_NaN(isnan(Z_NaN))=[];
Y_NaN(isnan(Z_NaN))=[];
Z_NaN(isnan(Z_NaN))=[];

set(totalGridPoints,'String',num2str(numel(Z)))
set(numberOfSamples,'String',num2str(numel(Z)-n_NaN))
set(numberOfNaN,'String',num2str(n_NaN))
set(minValue,'String',num2str(min(Z)))
set(maxValue,'String',num2str(max(Z)))
set(mean_,'String',num2str(mean(Z_NaN)))
set(median_,'String',num2str(median(Z_NaN)))
set(variance,'String',num2str(var(Z_NaN)))
set(standardDeviation,'String',num2str(std(Z_NaN)))

axes(graph)
pcolor(Xg,Yg,Zg)
shading interp
if(get(popupColorDist,'Value')==1)
    cmapChanged = colormaps(Z,'clra','equalized');
else
    cmapChanged = colormaps(Z,'clra','linear');
end
colormap(cmapChanged)
xlabel('Easting (m)','FontWeight','bold')
ylabel('Northing (m)','FontWeight','bold')
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
set(gca,'FontSize',13)
set(gca,'Box','on')

axes(graphHist)
h=histogram(Z_NaN,str2double(get(nBins,'String')));
set(h,'FaceColor',[0.5 0.5 0.5])
set(h,'EdgeColor','none')
xl=xlim;
yl=ylim;
hold on
plot([xl(1)*0.96,xl(1)*0.96],[yl(1),yl(2)],'r:','LineWidth',1.5)
hold off
set(gca,'FontSize',13)

Z__=Z_NaN;
Xg_=Xg;
Yg_=Yg;
Zg_=Zg;

iOut=boxplot(Z_NaN);

X_NaN=X_NaN(iOut);
Y_NaN=Y_NaN(iOut);

handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.X_NaN = X_NaN;
handles.Y_NaN = Y_NaN;
handles.Z_NaN = Z_NaN;
dataLoaded = 'y';
%Update de handle structure
guidata(GUIdataStatistics_,handles);
end

%UPDATE COLOR DISTRIBUTION
function updateColorDist_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIdataStatistics_);

if(dataLoaded=='y')
    Z_NaN = handles.Z_NaN;
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    axes(graph)
    pcolor(Xg,Yg,Zg)
    shading interp
    if(get(popupColorDist,'Value')==1)
        cmapChanged = colormaps(Z_NaN,'clra','equalized');
    else
        cmapChanged = colormaps(Z_NaN,'clra','linear');
    end
    colormap(cmapChanged)
    fixedCoord(6,45,6,45)
    axis image
end

%Update de handle structure
guidata(GUIdataStatistics_,handles);
end

%UPDATE HISTOGRAM
function updateHistogram_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIdataStatistics_);
Z=handles.Z;

h=histogram(graphHist,Z,str2double(get(nBins,'String')));
set(h,'FaceColor',[0.5 0.5 0.5])
set(h,'EdgeColor','none')

%Update de handle structure
guidata(GUIdataStatistics_,handles);
end

%SHOW OUTLIERS ON MAP
function showOutliers_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIdataStatistics_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    Z = handles.Z;
    X_NaN = handles.X_NaN;
    Y_NaN = handles.Y_NaN;
    
    if(get(tgbtn_outliers,'Value')==1)
        axes(graph)
        hold on
        scatter(X_NaN,Y_NaN,'k.')
        hold off
    else
        axes(graph)
        sct = findobj(gca,'Type','scatter');
        if(~isempty(sct))
            delete(sct)
        end
    end
else
    set(tgbtn_outliers,'Value',0)
    msgbox('Load some dataset before trying to plot outliers over the map.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(GUIdataStatistics_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function out=boxplot(data)
    %statistic variables
    median__=median(data);
    min_=min(data);
    max_=max(data);
    outLdown_=[];
    outLup_=[];
    Q_1=median(data(data<median__));
    Q_3=median(data(data>median__));
    IQR=Q_3-Q_1;
    WhiskerDown_ = Q_1-(1.5*IQR);
    if(WhiskerDown_<min_)
        WhiskerDown_=min_;
    else
        outLdown_ = data(data<WhiskerDown_);
    end
    WhiskerUp_ = Q_3+(1.5*IQR);
    if(WhiskerUp_>max_)
        WhiskerUp_=max_;
    else
        outLup_ = data(data>WhiskerUp_);
    end
    
    out1=data<WhiskerDown_;
    out2=data>WhiskerUp_;
    out = out1+out2;
    out(out>1)=1;
    out=logical(out);
    
    %rectangle variables
    rectWidth = IQR;
    rectHeight = 0.5;
    
    axes(graphBoxplot)
    set(get(graphBoxplot,'XAxis'),'Visible','on')
    set(get(graphBoxplot,'YAxis'),'Visible','on')
    set(gca,'Box','on')
    hold off
    plot(graphBoxplot,[-1000,-1000],[-1000,-1000])
    rectangle('position',[Q_1,0.25,rectWidth,rectHeight],...
        'FaceColor',[.5 .5 .5],'EdgeColor','k'); hold on
    plot([median__,median__],[0.25 0.75],'k-','LineWidth',2)
    plot([WhiskerDown_,Q_1],[0.5,0.5],'k-')
    plot([Q_3,WhiskerUp_],[0.5,0.5],'k-')
    plot([WhiskerDown_,WhiskerDown_],[0.4,0.6],'k-','LineWidth',2)
    plot([WhiskerUp_,WhiskerUp_],[0.4,0.6],'k-','LineWidth',2)
    plot(outLdown_,(0.5)*ones(size(outLdown_)),'d','MarkerEdgeColor','k',...
        'MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',0.5)
    plot(outLup_,(0.5)*ones(size(outLup_)),'d','MarkerEdgeColor','k',...
        'MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',0.5)
    hold off
    set(gca,'FontSize',13)
    
    xlabel(''); ylabel('')
    axes(graphHist); xl = xlim(gca);
    axes(graphBoxplot)
    xlim(xl)
    ylim([0 1])
    axes(graphHist)
end

function mouseButtonD(varargin)
    C = get(graphHist,'CurrentPoint');
    
    xlim = get(graphHist,'xlim');
    ylim = get(graphHist,'ylim');
    outX = ~any(diff([xlim(1) C(1,1) xlim(2)])<0);
    outY = ~any(diff([ylim(1) C(1,2) ylim(2)])<0);
    if (outX && outY && dataLoaded=='y')
        xl = get(graphHist,'Xlim');
        h=histogram(graphHist,Z__,str2double(get(nBins,'String')));
        set(h,'FaceColor',[0.5 0.5 0.5])
        set(h,'EdgeColor','none')
        set(graphHist,'Xlim',xl)
        yl=ylim;
        hold on
        plot(graphHist,[C(1,1),C(1,1)],[yl(1),yl(2)],'r:','LineWidth',1.5)
        hold off
        
        total_samples=numel(Z__);
        samplesUntilC = sum(double(Z__<C(1,1)));
        perc_=(samplesUntilC*100)/total_samples;
        set(dataPerc,'String',strcat(num2str(perc_),'%'))
    end
    
    C_ = get(graphBoxplot,'CurrentPoint');
    
    xlim_ = get(graphBoxplot,'xlim');
    ylim_ = get(graphBoxplot,'ylim');
    outX_ = ~any(diff([xlim_(1) C_(1,1) xlim_(2)])<0);
    outY_ = ~any(diff([ylim_(1) C_(1,2) ylim_(2)])<0);
    if (outX_ && outY_ && dataLoaded=='y')
        axes(graphHist)
        xl = get(graphHist,'Xlim');
        h=histogram(graphHist,Z__,str2double(get(nBins,'String')));
        set(h,'FaceColor',[0.5 0.5 0.5])
        set(h,'EdgeColor','none')
        set(graphHist,'Xlim',xl)
        yl=ylim;
        hold on
        plot(graphHist,[C_(1,1),C_(1,1)],[yl(1),yl(2)],'r:','LineWidth',1.5)
        hold off
        
        total_samples=numel(Z__);
        samplesUntilC = sum(double(Z__<C_(1,1)));
        perc_=(samplesUntilC*100)/total_samples;
        set(dataPerc,'String',strcat(num2str(perc_),'%'))
    end
    
    C__ = get(graph,'CurrentPoint');
    if(dataLoaded=='y')
        Zinterp = interp2(Xg_,Yg_,Zg_,C__(1,1),C__(1,2));
        if(isnan(Zinterp))
            return
        end
        
        set(CurrentSampleValue_,'String',num2str(Zinterp))
        xlim_ = get(graph,'xlim');
        ylim_ = get(graph,'ylim');
        outX_ = ~any(diff([xlim_(1) C__(1,1) xlim_(2)])<0);
        outY_ = ~any(diff([ylim_(1) C__(1,2) ylim_(2)])<0);
        if (outX_ && outY_ && dataLoaded=='y')
            axes(graphHist)
            xl = get(graphHist,'Xlim');
            h=histogram(graphHist,Z__,str2double(get(nBins,'String')));
            set(h,'FaceColor',[0.5 0.5 0.5])
            set(h,'EdgeColor','none')
            set(graphHist,'Xlim',xl)
            yl=ylim;
            hold on
            plot(graphHist,[Zinterp,Zinterp],[yl(1),yl(2)],'r:','LineWidth',1.5)
            hold off
            
            total_samples=numel(Z__);
            samplesUntilC = sum(double(Z__<Zinterp));
            perc_=(samplesUntilC*100)/total_samples;
            set(dataPerc,'String',strcat(num2str(perc_),'%'))
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