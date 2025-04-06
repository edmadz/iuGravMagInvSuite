function GUIexportMap

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
[posX_,posY_,Width,Height]=centralizeWindow(width,height);
figposition = [posX_,posY_,Width,Height];

GUIexportMap_ = figure('Menubar','none',...
    'Name','Export Map',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------
tabs = uitabgroup(GUIexportMap_,...
    'Units','normalized',...
    'Position',[0.014 0.02 0.3 0.96]);

%--------------------------------------------------------------------------
tab1 = uitab(tabs,'Title','General Options');

gridName_ = uicontrol(tab1,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Name of the data loaded.',...
    'position',[0.03 0.915 0.944 0.036]);

graphType_ = uicontrol(tab1,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Interpolated Map','Contour Map','Surface Map'},...
    'fontUnits','normalized',...
    'TooltipString','Graph type.',...
    'position',[0.03 0.815 0.944 0.036]);

ColorDistributionType = uicontrol(tab1,'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Equalized','Linear'},...
    'fontUnits','normalized',...
    'TooltipString','Color distribution.',...
    'position',[0.03 0.765 0.944 0.036],...
    'CallBack',@changeColorDist_Callback);

ColormapType = uicontrol(tab1,'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{''},...
    'fontUnits','normalized',...
    'TooltipString','Colormap or colortbl.',...
    'position',[0.03 0.715 0.944 0.036],...
    'CallBack',@colorbar_Callback);

colormapGraph=axes(tab1,'units','normalized',...
    'Position',[0.03 0.665 0.944 0.036],...
    'XTickLabel',[],'YTickLabel',[],...
    'XTick',[],'YTick',[],'Box','on');

inputDataQuantity = uicontrol(tab1,'Style','popupmenu',...
    'units','normalized',...
    'String',{'From meters','From kilometers'},...
    'fontUnits','normalized',...
    'TooltipString','Coordinates convertion.',...
    'position',[0.03 0.615 0.45 0.036]);

convertedDataQuantity = uicontrol(tab1,'Style','popupmenu',...
    'units','normalized',...
    'String',{'To kilometers','To meters'},...
    'fontUnits','normalized',...
    'TooltipString','Coordinates convertion.',...
    'position',[0.52 0.615 0.45 0.036]);

NxCoord = uicontrol(tab1,'Style','edit',...
    'units','normalized',...
    'String','3',...
    'fontUnits','normalized',...
    'TooltipString','Number of horizontal coordinate labels displayed.',...
    'position',[0.03 0.565 0.45 0.036]);

NyCoord = uicontrol(tab1,'Style','edit',...
    'units','normalized',...
    'String','3',...
    'fontUnits','normalized',...
    'TooltipString','Number of vertical coordinate labels displayed.',...
    'position',[0.52 0.565 0.45 0.036]);

gridLines = uicontrol(tab1,'Style','popupmenu',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Dotted Line','Dashed Line','Solid Line','Dash-dotted Line','No Grid Lines'},...
    'fontUnits','normalized',...
    'TooltipString','Grid Line Style.',...
    'position',[0.03 0.515 0.944 0.036]);

showNorthArrow = uicontrol(tab1,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Show North Arrow','Hide North Arrow'},...
    'fontUnits','normalized',...
    'position',[0.03 0.465 0.944 0.036]);

uicontrol(tab1,'Style','pushbutton',...
    'units','normalized',...
    'String','Map Preview',...
    'fontUnits','normalized',...
    'position',[0.03 0.215 0.944 0.036],...
    'CallBack',@displayMapPreview_callBack);

imageFileFormat = uicontrol(tab1,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'png','jpeg','jpg','tiff'},...
    'fontUnits','normalized',...
    'TooltipString','Image file format.',...
    'position',[0.03 0.165 0.944 0.036]);

DPI_=uicontrol(tab1,'Style','edit',...
    'units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'TooltipString','Dots per inch.',...
    'position',[0.03 0.115 0.944 0.036]);

uicontrol(tab1,'Style','pushbutton',...
    'units','normalized',...
    'String','Export Map',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'CallBack',@saveMap_callBack);

%--------------------------------------------------------------------------
tab2 = uitab(tabs,'Title','Colorbar');

colorbarTitle_ = uicontrol(tab2,'Style','edit',...
    'units','normalized',...
    'String','(nT)',...
    'fontUnits','normalized',...
    'TooltipString','Colorbar title.',...
    'position',[0.03 0.915 0.944 0.036]);

colorbarVertHor_ = uicontrol(tab2,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Vertical Colorbar','Horizontal Colorbar'},...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.944 0.036]);

nTicks_ = uicontrol(tab2,'Style','edit',...
    'units','normalized',...
    'String','10',...
    'fontUnits','normalized',...
    'TooltipString','Number of tick labels.',...
    'position',[0.03 0.815 0.944 0.036]);

decimal_ = uicontrol(tab2,'Style','edit',...
    'units','normalized',...
    'String','2',...
    'fontUnits','normalized',...
    'TooltipString','Decimal Approximation.',...
    'position',[0.03 0.765 0.944 0.036]);

fontSize_ = uicontrol(tab2,'Style','edit',...
    'units','normalized',...
    'String','20',...
    'fontUnits','normalized',...
    'TooltipString','Font size of tick labels.',...
    'position',[0.03 0.715 0.944 0.036]);

angle_ = uicontrol(tab2,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'TooltipString','Angle of tick labels.',...
    'position',[0.03 0.665 0.944 0.036]);

fontSizeTitle_ = uicontrol(tab2,'Style','edit',...
    'units','normalized',...
    'String','20',...
    'fontUnits','normalized',...
    'TooltipString','Font size of colorbar title.',...
    'position',[0.03 0.615 0.944 0.036]);

fontWeightTitle_ = uicontrol(tab2,'Style','popupmenu',...
    'units','normalized',...
    'Value',2,...
    'String',{'normal','bold'},...
    'fontUnits','normalized',...
    'TooltipString','Font weight of colorbar title.',...
    'position',[0.03 0.565 0.944 0.036]);

%--------------------------------------------------------------------------
tab3 = uitab(tabs,'Title','Graphic Scale');

showGeoScale = uicontrol(tab3,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Show Graphic Scale','Hide Graphic Scale'},...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036]);

GSperc = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'String','0.2',...
    'fontUnits','normalized',...
    'TooltipString','Scale bar width in percentage of graph width.',...
    'position',[0.03 0.865 0.944 0.036]);

GSheight = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'String','0.01',...
    'fontUnits','normalized',...
    'TooltipString','Scale bar height in percentage of graph height.',...
    'position',[0.03 0.815 0.944 0.036]);

vertNumberDist = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'String','0.06',...
    'fontUnits','normalized',...
    'TooltipString','Vertical distance of scale bar numbers.',...
    'position',[0.03 0.765 0.944 0.036]);

vertMetricDist = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'String','0.01',...
    'fontUnits','normalized',...
    'TooltipString','Vertical distance of scale bar unit.',...
    'position',[0.03 0.715 0.944 0.036]);

GSfontSize = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'String','18',...
    'fontUnits','normalized',...
    'TooltipString','Font size.',...
    'position',[0.03 0.665 0.944 0.036]);

uicontrol(tab3,'Style','pushbutton',...
    'units','normalized',...
    'String','Font Color',...
    'fontUnits','normalized',...
    'TooltipString','Font color.',...
    'position',[0.03 0.615 0.8 0.036],...
    'CallBack',@selectGSfontColor_callBack);

currentGSfontColor = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'BackgroundColor',[0 0 0],...
    'fontUnits','normalized',...
    'position',[0.87 0.615 0.1 0.036]);

GSunits = uicontrol(tab3,'Style','edit',...
    'units','normalized',...
    'String','kilometers',...
    'fontUnits','normalized',...
    'TooltipString','Unit of graphic scale.',...
    'position',[0.03 0.565 0.944 0.036]);

%--------------------------------------------------------------------------
tab4 = uitab(tabs,'Title','Profile');

profileLineStyle = uicontrol(tab4,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Solid Line (-)','Dashed Line (--)','Dotted Line (:)','Dash-dot Line (-.)'},...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036]);

uicontrol(tab4,'Style','pushbutton',...
    'units','normalized',...
    'String','Line Color',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.8 0.036],...
    'CallBack',@setProfileColor_callBack);

currentLineColor = uicontrol(tab4,'Style','edit',...
    'units','normalized',...
    'BackgroundColor',[0 0 0],...
    'fontUnits','normalized',...
    'position',[0.87 0.865 0.1 0.036]);

profileLineWidth = uicontrol(tab4,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.944 0.036]);

initialProfileLabel = uicontrol(tab4,'Style','edit',...
    'units','normalized',...
    'String','A',...
    'fontUnits','normalized',...
    'position',[0.03 0.765 0.45 0.036]);

finalProfileLabel = uicontrol(tab4,'Style','edit',...
    'units','normalized',...
    'String','B',...
    'fontUnits','normalized',...
    'position',[0.525 0.765 0.45 0.036]);

fontSize = uicontrol(tab4,'Style','edit',...
    'units','normalized',...
    'String','14',...
    'fontUnits','normalized',...
    'position',[0.03 0.715 0.944 0.036]);

profileFontWeight_ = uicontrol(tab4,'Style','popupmenu',...
    'units','normalized',...
    'Value',2,...
    'String',{'normal','bold'},...
    'fontUnits','normalized',...
    'TooltipString','Font weight of profile limits.',...
    'position',[0.03 0.665 0.944 0.036]);

%--------------------------------------------------------------------------
tab5 = uitab(tabs,'Title','Text');

txt = uicontrol(tab5,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036]);

fontSize___ = uicontrol(tab5,'Style','edit',...
    'units','normalized',...
    'String','20',...
    'fontUnits','normalized',...
    'Tooltipstring','Font size.',...
    'position',[0.03 0.865 0.944 0.036]);

fontWeigth___ = uicontrol(tab5,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Normal','Bold'},...
    'fontUnits','normalized',...
    'Tooltipstring','Font weigth.',...
    'position',[0.03 0.815 0.944 0.036]);

uicontrol(tab5,'Style','pushbutton',...
    'units','normalized',...
    'String','Add a new text',...
    'fontUnits','normalized',...
    'position',[0.03 0.765 0.944 0.036],...
    'CallBack',@setText_callBack);

table = uitable(tab5,'units','normalized',...
    'position',[0.03 0.315 0.944 0.4],...
    'ColumnName',{'Text','X coordinate','Y coordinate'},...
    'RowStriping','off');

uicontrol(tab5,'Style','pushbutton',...
    'units','normalized',...
    'String','Save text control file',...
    'fontUnits','normalized',...
    'position',[0.03 0.265 0.944 0.036],...
    'CallBack',@saveTextControlFile_callBack);

uicontrol(tab5,'Style','pushbutton',...
    'units','normalized',...
    'String','Reset text tab',...
    'fontUnits','normalized',...
    'position',[0.03 0.215 0.944 0.036],...
    'CallBack',@resetTextTab_callBack);

%--------------------------------------------------------------------------

graphPanel = uipanel(GUIexportMap_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.33 0.02 0.66 0.96]);

graphNorthArrow = axes(graphPanel,'Units','normalized',...
    'position',[0.1 0.1 0.8 0.8]);
set(graphNorthArrow,'Visible','off');

graph = axes(graphPanel,'Units','normalized',...
    'position',[0.1 0.1 0.8 0.8]);
set(get(graph,'XAxis'),'Visible','off');
set(get(graph,'YAxis'),'Visible','off');
set(graph,'Visible','off');

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------
file = uimenu(GUIexportMap_,'label','File');
uimenu(file,'Label','Open File...','Accelerator','O','CallBack',@OpenFile_callBack);

profile_=uimenu(GUIexportMap_,'Label','Profile');
uimenu(profile_,'Label','Load Profile','Accelerator','P','CallBack',@loadProfile_callBack);

text_=uimenu(GUIexportMap_,'Label','Text');
uimenu(text_,'Label','Load Text','Accelerator','T','CallBack',@loadTextControlFile_callBack);

tbls
currentTBL

profileColor_ = [0 0 0];
GSfontColor_ = [0 0 0];
dataLoaded = 'n';
previewMapDisplayed = 'n';
numberOfText = 0;
tableData = {};

set(GUIexportMap_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACK FUNCTIONS
%--------------------------------------------------------------------------

%SHOW COLORBAR
function colorbar_Callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

currentTBL

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    colormaps_ = get(ColormapType,'String');
    colormapSelected = char(colormaps_(get(ColormapType,'Value')));
    
    axes(graph)
    if(get(graphType_,'Value')==1)
        pcolor(Xg,Yg,Zg);shading interp
    elseif(get(graphType_,'Value')==2)
        contourf(Xg,Yg,Zg)
    else
        surf(Xg,Yg,Zg);shading interp
    end
    [row,col]=size(Zg);
    currentColorDist = get(ColorDistributionType,'String');
    currentColorDist = currentColorDist(get(ColorDistributionType,'Value'));
    if(strcmp(currentColorDist,'Linear'))
        currentColorDist = 'linear';
    else
        currentColorDist = 'equalized';
    end
    
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,currentColorDist);
    colormap(cmapChanged)
    axis image
    
    set(graph,'XTickLabel',[]);
    set(graph,'YTickLabel',[]);
    set(graph,'XTick',[]);
    set(graph,'YTick',[]);
    set(graph,'Box','on');
    
    if(previewMapDisplayed=='y')
        [colorbarTitle__,nTicks__,decimal__,...
            fontSize__,angle__,fontSizeTitle__,...
            fontWeightTitle__,cbFlagPosition]=displayMap(Xg,Yg,Zg);
        
        handles.colorbarTitle__ = colorbarTitle__;
        handles.nTicks__ = nTicks__;
        handles.decimal__ = decimal__;
        handles.fontSize__ = fontSize__;
        handles.angle__ = angle__;
        handles.fontSizeTitle__ = fontSizeTitle__;
        handles.fontWeightTitle__ = fontWeightTitle__;
        handles.cbFlagPosition = cbFlagPosition;
    end
end

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%CHANGE COLOR DISTRIBUTION
function changeColorDist_Callback(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    colormaps_ = get(ColormapType,'String');
    colormapSelected = char(colormaps_(get(ColormapType,'Value')));
    
    axes(graph)
    if(get(graphType_,'Value')==1)
        pcolor(Xg,Yg,Zg);shading interp
    elseif(get(graphType_,'Value')==2)
        contourf(Xg,Yg,Zg)
    else
        surf(Xg,Yg,Zg);shading interp
    end
    [row,col]=size(Zg);
    if(get(ColorDistributionType,'Value')==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'equalized');
    else
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'linear');
    end
    colormap(cmapChanged)
    axis image
    
    set(graph,'XTickLabel',[]);
    set(graph,'YTickLabel',[]);
    set(graph,'XTick',[]);
    set(graph,'YTick',[]);
    set(graph,'Box','on');
    
    if(previewMapDisplayed=='y')
        [colorbarTitle__,nTicks__,decimal__,...
            fontSize__,angle__,fontSizeTitle__,...
            fontWeightTitle__,cbFlagPosition]=displayMap(Xg,Yg,Zg);
        
        handles.colorbarTitle__ = colorbarTitle__;
        handles.nTicks__ = nTicks__;
        handles.decimal__ = decimal__;
        handles.fontSize__ = fontSize__;
        handles.angle__ = angle__;
        handles.fontSizeTitle__ = fontSizeTitle__;
        handles.fontWeightTitle__ = fontWeightTitle__;
        handles.cbFlagPosition = cbFlagPosition;
    end
end

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%CHANGE GRAPHIC SCALE FONT COLOR
function selectGSfontColor_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

GUIGScolorSelector

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%OPEN A DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

colormaps_ = get(ColormapType,'String');
colormapSelected = char(colormaps_(get(ColormapType,'Value')));

axes(graph)
if(get(graphType_,'Value')==1)
    pcolor(Xg,Yg,Zg);shading interp
elseif(get(graphType_,'Value')==2)
    contourf(Xg,Yg,Zg)
else
    surf(Xg,Yg,Zg);shading interp
end
[row,col]=size(Zg);
cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'equalized');
colormap(cmapChanged)
axis image

set(graph,'XTickLabel',[]);
set(graph,'YTickLabel',[]);
set(graph,'XTick',[]);
set(graph,'YTick',[]);
set(graph,'Box','on');

set(gridName_,'String',Fullpath)

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.row = row;
handles.col = col;
dataLoaded = 'y';
previewMapDisplayed = 'n';
%Update de handle structure
guidata(GUIexportMap_,handles);
end

%GENERATE THE MAP
function displayMapPreview_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);
Xg = handles.Xg;
Yg = handles.Yg;
Zg = handles.Zg;

[colorbarTitle__,nTicks__,decimal__,...
        fontSize__,angle__,fontSizeTitle__,...
        fontWeightTitle__,cbFlagPosition]=displayMap(Xg,Yg,Zg);

handles.colorbarTitle__ = colorbarTitle__;
handles.nTicks__ = nTicks__;
handles.decimal__ = decimal__;
handles.fontSize__ = fontSize__;
handles.angle__ = angle__;
handles.fontSizeTitle__ = fontSizeTitle__;
handles.fontWeightTitle__ = fontWeightTitle__;
handles.cbFlagPosition = cbFlagPosition;
previewMapDisplayed = 'y';
%Update de handle structure
guidata(GUIexportMap_,handles);
end

%EXPORT MAP
function saveMap_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);
Zg = handles.Zg;
nTicks__ = handles.nTicks__;
decimal__ = handles.decimal__;
fontSize__ = handles.fontSize__;
angle__ = handles.angle__;
fontSizeTitle__ = handles.fontSizeTitle__;
fontWeightTitle__ = handles.fontWeightTitle__;
colorbarTitle__ = handles.colorbarTitle__;
cbFlagPosition = handles.cbFlagPosition;

[FileName,PathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Save Image...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

msg=msgbox('Wait a moment!','Warn','warn');

format_=get(imageFileFormat,'String');
imageF = char(strcat('-d',format_(get(imageFileFormat,'Value'))));
dpi_ = strcat('-r',get(DPI_,'String'));
fName = strsplit(FileName,'.');
ImagePath = char(strcat(PathName,fName(1)));

pos=get(gca,'OuterPosition');
map_width = pos(3);
map_heigth = pos(4);

if(map_width>map_heigth)
    map_heigth = map_heigth*1.3518;
    aspectX = map_width/map_width;
    aspectY = map_heigth/map_width;
else
    aspectY = map_heigth/map_heigth;
    aspectX = map_width/map_heigth;
end

fig = figure('Position',[200,200,1000*aspectX,1000*aspectY],'Visible','off');
copyobj(graph,fig);

[row,col]=size(Zg);

colormaps_ = get(ColormapType,'String');
colormapSelected = char(colormaps_(get(ColormapType,'Value')));

if(get(ColorDistributionType,'Value')==1)
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'equalized');
    colormap(fig,cmapChanged)
elseif(get(ColorDistributionType,'Value')==2)
    cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'linear');
    colormap(fig,cmapChanged)
end

customColorbar(nTicks__,decimal__,fontSize__,angle__,fontSizeTitle__,fontWeightTitle__,colorbarTitle__,cbFlagPosition)
set(gca,'position',[0.1 0.04 .78 .84])

print(fig,ImagePath,imageF,dpi_)
delete(fig)

delete(msg)
msgbox('Map Exported!','Warn','warn')

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%SET PROFILE LINE COLOR
function setProfileColor_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

GUIprofileColorSelector

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%LOAD PROFILE
function loadProfile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

[FileName,PathName] = uigetfile({'*.dat','Data Files (*.dat)'},'Select Profile...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return;
end

data=importdata(Fullpath);
data=data.data;

x=data(:,1);
y=data(:,2);

if(get(profileLineStyle,'Value')==1)
    lineStyle='-';
elseif(get(profileLineStyle,'Value')==2)
    lineStyle='--';
elseif(get(profileLineStyle,'Value')==3)
    lineStyle=':';
elseif(get(profileLineStyle,'Value')==4)
    lineStyle='-.';
end

lineWidth = str2double(get(profileLineWidth,'String'));

initialLabel = get(initialProfileLabel,'String');
finalLabel = get(finalProfileLabel,'String');
fontSize__ = str2double(get(fontSize,'String'));

textWeigth = get(profileFontWeight_,'String');
textWeigth = char(textWeigth(get(profileFontWeight_,'Value')));

hold on
profileLine=plot(x,y,lineStyle,'LineWidth',lineWidth,'Color',profileColor_);
if(x(1)<x(2))
    profileTxt1=text(x(1),y(1),initialLabel,'FontSize',fontSize__,...
        'Color',profileColor_,'FontWeight',textWeigth);
    a=get(profileTxt1,'Extent');
    set(profileTxt1,'Position',[x(1)-a(3),y(1)])
    profileTxt2=text(x(end),y(end),finalLabel,'FontSize',fontSize__,...
        'Color',profileColor_,'FontWeight',textWeigth);
else
    profileTxt1=text(x(1),y(1),initialLabel,'FontSize',fontSize__,...
        'Color',profileColor_,'FontWeight',textWeigth);
    profileTxt2=text(x(end),y(end),finalLabel,'FontSize',fontSize__,...
        'Color',profileColor_,'FontWeight',textWeigth);
    a=get(profileTxt2,'Extent');
    set(profileTxt2,'Position',[x(end)-a(3),y(end)])
end
hold off

handles.profileLine=profileLine;
handles.profileTxt1=profileTxt1;
handles.profileTxt2=profileTxt2;
%Update de handle structure
guidata(GUIexportMap_,handles);
end

%ADD TEXT OVER THE MAP
function setText_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

if(dataLoaded=='y')
    txt__=get(txt,'String');
    if(~isempty(txt__))
        
        fs = str2double(get(fontSize___,'String'));
        fw = get(fontWeigth___,'String');
        fw = fw(get(fontWeigth___,'Value'));
        
        h=impoint(graph);
        pos=getPosition(h);
        delete(h)
        x=pos(1);
        y=pos(2);
        
        displayText(x,y,txt__,fs,fw)
        numberOfText = numberOfText + 1;
        
        if(numberOfText==1)
            tableData = {txt__,num2str(x),num2str(y)};
            set(table,'Data',tableData)
        else
            tableData = cat(1,tableData,{txt__,num2str(x),num2str(y)});
            set(table,'Data',tableData)
        end
    else
        msgbox('Provide some text.','Warn','warn','modal')
        return
    end
    
end

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%SAVE TEXT CONTROL FILE
function saveTextControlFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

data = get(table,'Data');
data = string(data);

[FileName,PathName] = uiputfile({'*.dat','Data Files (*.dat)'},'Save control file...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return;
end

fid = fopen(Fullpath,'w');
fprintf(fid,'%s %s %s \r\n',transpose(data));
fclose(fid);

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%LOAD TEXT CONTROL FILE
function loadTextControlFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

[FileName,PathName] = uigetfile({'*.dat','Data Files (*.dat)'},'Select control file...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return;
end

fileID = fopen(Fullpath);
C=textscan(fileID,'%s %s %s');
fclose(fileID);

data = horzcat(C{:});
set(table,'Data',data)

[N,~] = size(data);

fs = str2double(get(fontSize___,'String'));
fw = get(fontWeigth___,'String');
fw = fw(get(fontWeigth___,'Value'));

for i=1:N
    hold on
    displayText(str2double(data{i,2}),str2double(data{i,3}),data{i,1},fs,fw)
    hold off
end

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%RESET TEXT TAB
function resetTextTab_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIexportMap_);

set(table,'Data',[]);
numberOfText = 0;

%Update de handle structure
guidata(GUIexportMap_,handles);
end

%--------------------------------------------------------------------------
%PARALLEL INTERFACES
%--------------------------------------------------------------------------

function GUIprofileColorSelector()

%Centralize the current window at the center of the screen
[posX__,posY__,Width_,Height_]=centralizeWindow(500,150);
figposition_ = [posX__,posY__,Width_,Height_];

GUIprofileColorSelector_ = figure('Menubar','none',...
    'Visible','off',...
    'Name','Profile Color Selector',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition_,...
    'Toolbar','none',...
    'Visible','on',...
    'Resize','off',...
    'WindowStyle','modal',...
    'CloseRequestFcn',@closeWindow);

uicontrol(GUIprofileColorSelector_,'Style','text',...
    'units','normalized',...
    'String','R',...
    'fontUnits','normalized',...
    'position',[0.03 0.67 0.1 0.2]);

uicontrol(GUIprofileColorSelector_,'Style','text',...
    'units','normalized',...
    'String','G',...
    'fontUnits','normalized',...
    'position',[0.03 0.37 0.1 0.2]);

uicontrol(GUIprofileColorSelector_,'Style','text',...
    'units','normalized',...
    'String','B',...
    'fontUnits','normalized',...
    'position',[0.03 0.07 0.1 0.2]);

R_channel_slider = uicontrol(GUIprofileColorSelector_,'Style','slider',...
    'units','normalized',...
    'Min',0,'Max',155,'Value',0,...
    'SliderStep',[1/156,0.10],...
    'fontUnits','normalized',...
    'position',[0.13 0.7 0.4 0.2],...
    'CallBack',@setRvalue_Callback);

G_channel_slider = uicontrol(GUIprofileColorSelector_,'Style','slider',...
    'units','normalized',...
    'Min',0,'Max',155,'Value',0,...
    'SliderStep',[1/156,0.10],...
    'fontUnits','normalized',...
    'position',[0.13 0.4 0.4 0.2],...
    'CallBack',@setGvalue_Callback);

B_channel_slider = uicontrol(GUIprofileColorSelector_,'Style','slider',...
    'units','normalized',...
    'Min',0,'Max',155,'Value',0,...
    'SliderStep',[1/156,0.10],...
    'fontUnits','normalized',...
    'position',[0.13 0.1 0.4 0.2],...
    'CallBack',@setBvalue_Callback);

R_channel_value = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.57 0.7 0.1 0.2]);

G_channel_value = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.57 0.4 0.1 0.2]);

B_channel_value = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.57 0.1 0.1 0.2]);

selectedColor_ = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'BackgroundColor',[0 0 0],...
    'fontUnits','normalized',...
    'position',[0.7 0.1 0.27 0.8]);

function setRvalue_Callback(varargin)
    r=round(get(R_channel_slider,'Value'));
    set(R_channel_value,'String',num2str(r))
    color = get(selectedColor_,'BackgroundColor');
    set(selectedColor_,'BackgroundColor',[r/156 color(2) color(3)])
    profileColor_ = get(selectedColor_,'BackgroundColor');
end

function setGvalue_Callback(varargin)
    g=round(get(G_channel_slider,'Value'));
    set(G_channel_value,'String',num2str(g))
    color = get(selectedColor_,'BackgroundColor');
    set(selectedColor_,'BackgroundColor',[color(1) g/156 color(3)])
    profileColor_ = get(selectedColor_,'BackgroundColor');
end

function setBvalue_Callback(varargin)
    b=round(get(B_channel_slider,'Value'));
    set(B_channel_value,'String',num2str(b))
    color = get(selectedColor_,'BackgroundColor');
    set(selectedColor_,'BackgroundColor',[color(1) color(2) b/156])
    profileColor_ = get(selectedColor_,'BackgroundColor');
end

function closeWindow(varargin)
    delete(gcf)
    set(currentLineColor,'BackgroundColor',profileColor_)
end

end

function GUIGScolorSelector()

%Centralize the current window at the center of the screen
[posX__,posY__,Width_,Height_]=centralizeWindow(500,150);
figposition_ = [posX__,posY__,Width_,Height_];

GUIprofileColorSelector_ = figure('Menubar','none',...
    'Visible','off',...
    'Name','Profile Color Selector',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition_,...
    'Toolbar','none',...
    'Visible','on',...
    'Resize','off',...
    'WindowStyle','modal',...
    'CloseRequestFcn',@closeWindow);

uicontrol(GUIprofileColorSelector_,'Style','text',...
    'units','normalized',...
    'String','R',...
    'fontUnits','normalized',...
    'position',[0.03 0.67 0.1 0.2]);

uicontrol(GUIprofileColorSelector_,'Style','text',...
    'units','normalized',...
    'String','G',...
    'fontUnits','normalized',...
    'position',[0.03 0.37 0.1 0.2]);

uicontrol(GUIprofileColorSelector_,'Style','text',...
    'units','normalized',...
    'String','B',...
    'fontUnits','normalized',...
    'position',[0.03 0.07 0.1 0.2]);

R_channel_slider = uicontrol(GUIprofileColorSelector_,'Style','slider',...
    'units','normalized',...
    'Min',0,'Max',155,'Value',0,...
    'SliderStep',[1/156,0.10],...
    'fontUnits','normalized',...
    'position',[0.13 0.7 0.4 0.2],...
    'CallBack',@setRvalue_Callback);

G_channel_slider = uicontrol(GUIprofileColorSelector_,'Style','slider',...
    'units','normalized',...
    'Min',0,'Max',155,'Value',0,...
    'SliderStep',[1/156,0.10],...
    'fontUnits','normalized',...
    'position',[0.13 0.4 0.4 0.2],...
    'CallBack',@setGvalue_Callback);

B_channel_slider = uicontrol(GUIprofileColorSelector_,'Style','slider',...
    'units','normalized',...
    'Min',0,'Max',155,'Value',0,...
    'SliderStep',[1/156,0.10],...
    'fontUnits','normalized',...
    'position',[0.13 0.1 0.4 0.2],...
    'CallBack',@setBvalue_Callback);

R_channel_value = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.57 0.7 0.1 0.2]);

G_channel_value = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.57 0.4 0.1 0.2]);

B_channel_value = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'String','0',...
    'fontUnits','normalized',...
    'position',[0.57 0.1 0.1 0.2]);

selectedColor_ = uicontrol(GUIprofileColorSelector_,'Style','edit',...
    'units','normalized',...
    'BackgroundColor',[0 0 0],...
    'fontUnits','normalized',...
    'position',[0.7 0.1 0.27 0.8]);

function setRvalue_Callback(varargin)
    r=round(get(R_channel_slider,'Value'));
    set(R_channel_value,'String',num2str(r))
    color = get(selectedColor_,'BackgroundColor');
    set(selectedColor_,'BackgroundColor',[r/156 color(2) color(3)])
    GSfontColor_ = get(selectedColor_,'BackgroundColor');
end

function setGvalue_Callback(varargin)
    g=round(get(G_channel_slider,'Value'));
    set(G_channel_value,'String',num2str(g))
    color = get(selectedColor_,'BackgroundColor');
    set(selectedColor_,'BackgroundColor',[color(1) g/156 color(3)])
    GSfontColor_ = get(selectedColor_,'BackgroundColor');
end

function setBvalue_Callback(varargin)
    b=round(get(B_channel_slider,'Value'));
    set(B_channel_value,'String',num2str(b))
    color = get(selectedColor_,'BackgroundColor');
    set(selectedColor_,'BackgroundColor',[color(1) color(2) b/156])
    GSfontColor_ = get(selectedColor_,'BackgroundColor');
end

function closeWindow(varargin)
    delete(gcf)
    set(currentGSfontColor,'BackgroundColor',GSfontColor_)
end

end

function [colorbarTitle__,nTicks__,decimal__,...
        fontSize__,angle__,fontSizeTitle__,...
        fontWeightTitle__,cbFlagPosition]=displayMap(Xg,Yg,Zg)
    axes(graph)
    
    colorbarTitle__ = get(colorbarTitle_,'String');
    nTicks__ = str2double(get(nTicks_,'String'));
    decimal__ = str2double(get(decimal_,'String'));
    fontSize__ = str2double(get(fontSize_,'String'));
    angle__ = str2double(get(angle_,'String'));
    fontSizeTitle__ = str2double(get(fontSizeTitle_,'String'));
    fontWeightTitle__ = get(fontWeightTitle_,'String');
    fontWeightTitle__ = char(fontWeightTitle__(get(fontWeightTitle_,'Value')));
    inputDataQuantity__ = get(inputDataQuantity,'String');
    inputDataQuantity__ = inputDataQuantity__(get(inputDataQuantity,'Value'));
    convertedDataQuantity__ = get(convertedDataQuantity,'String');
    convertedDataQuantity__ = convertedDataQuantity__(get(convertedDataQuantity,'Value'));
    GSfontSize__ = str2double(get(GSfontSize,'String'));
    
    GSperc__ = str2double(get(GSperc,'String'));
    GSheight__ = str2double(get(GSheight,'String'));
    vertNumberDist__ = str2double(get(vertNumberDist,'String'));
    vertMetricDist__ = str2double(get(vertMetricDist,'String'));
    GSunits__ = get(GSunits,'String');
    
    if(get(showGeoScale,'Value')==1)
        showGeoScale__='on';
    else
        showGeoScale__='off';
    end
    
    if(get(showNorthArrow,'Value')==1)
        showNorthArrow__='on';
    else
        showNorthArrow__='off';
    end
    
    if(get(graphType_,'Value')==1)
        pcolor(graph,Xg,Yg,Zg);
        %     h=surf(graph,Xg,Yg,Zg);
        %     view(0,90)
        %     lightangle(90,60)
        %     set(h,'FaceLighting','flat')
        %     set(h,'AmbientStrength',0.3)
        %     set(h,'DiffuseStrength',0.8)
        %     set(h,'SpecularStrength',0)
        %     set(h,'SpecularExponent',25)
        %     set(h,'BackFaceLighting','unlit')
    elseif(get(graphType_,'Value')==2)
        contourf(graph,Xg,Yg,Zg)
    elseif(get(graphType_,'Value')==3)
        surf(graph,Xg,Yg,Zg)
        grid on
        grid minor
        view(-38,25)
    end
    
    [row,col]=size(Zg);
    
    colormaps_ = get(ColormapType,'String');
    colormapSelected = char(colormaps_(get(ColormapType,'Value')));
    
    if(get(ColorDistributionType,'Value')==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'equalized');
        colormap(cmapChanged)
    elseif(get(ColorDistributionType,'Value')==2)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'linear');
        colormap(cmapChanged)
    elseif(get(ColorDistributionType,'Value')==3)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'normalized');
        colormap(cmapChanged)
    end
    
    shading interp
    
    if(get(colorbarVertHor_,'Value')==1)
        cbFlagPosition = 'E';
    else
        cbFlagPosition = 'S';
    end
    
    customColorbar(nTicks__,decimal__,fontSize__,angle__,fontSizeTitle__,fontWeightTitle__,colorbarTitle__,cbFlagPosition)
    
    if(get(gridLines,'Value')==1)  %Dotted line
        showGridLines = 'on';
        gridLineStyle = ':';
    elseif(get(gridLines,'Value')==2)  %Dashed line
        showGridLines = 'on';
        gridLineStyle = '--';
    elseif(get(gridLines,'Value')==3)  %Solid line
        showGridLines = 'on';
        gridLineStyle = '-';
    elseif(get(gridLines,'Value')==4)  %Dash-dotted line
        showGridLines = 'on';
        gridLineStyle = '-.';
    elseif(get(gridLines,'Value')==5)  %No line
        showGridLines = 'off';
        gridLineStyle = '--';
    end
    
    mapLayout(0,str2double(get(NyCoord,'String'))+1,...
        str2double(get(NxCoord,'String'))+1,...
        showGridLines,gridLineStyle,showGeoScale__,...
        GSperc__,GSheight__,vertNumberDist__,...
        vertMetricDist__,GSunits__,showNorthArrow__,...
        inputDataQuantity__,convertedDataQuantity__,...
        GSfontSize__,GSfontColor_)
    
    %axis normal
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function tbls
    currentF=pwd;
    whatPCPlatform = computer('arch');
    whatPCPlatform = whatPCPlatform(1:3);
    if(strcmp(whatPCPlatform,'win'))
        tblFolder=strcat(currentF,'\tbl');
        tblGeophFolder=strcat(tblFolder,'\geophysics');
    elseif(strcmp(whatPCPlatform,'gln'))
        tblFolder=strcat(currentF,'/tbl');
        tblGeophFolder=strcat(tblFolder,'/geophysics');
    end
    content_=dir(tblGeophFolder);
    N=length(content_);
    tbl_=cell([N-2,1]);
    for i=1:N-2
        t=content_(i+2).name;
        t=strsplit(t,'.');
        tbl_(i,1)={char(t(1))};
    end
    set(ColormapType,'String',tbl_)
end

function currentTBL
    colormapChoosen = get(ColormapType,'String');
    
    tblFolder=loadTBL(strcat(char(colormapChoosen(get(ColormapType,'Value'))),'.tbl'));
    colors = findcolormap(tblFolder);
    colors = colors';
    
    if(max(colors(:))>1) %colors ranging from 0 to 255
        colors = colors./255;
    end
    
    R_channel = colors(1,:);
    G_channel = colors(2,:);
    B_channel = colors(3,:);
    
    Cl = cat(3,cat(1,R_channel,R_channel),cat(1,G_channel,G_channel),cat(1,B_channel,B_channel));
    
    axes(colormapGraph)
    imagesc(Cl)
    set(colormapGraph,'XTickLabel',[]);
    set(colormapGraph,'YTickLabel',[]);
    set(colormapGraph,'XTick',[]);
    set(colormapGraph,'YTick',[]);
    set(colormapGraph,'Box','on');
end

function displayText(x,y,txt,fontSize,fontWeigth)
    hold on
    t=text(x,y,txt);
    set(t,'FontSize',fontSize)
    set(t,'HorizontalAlignment','center')
    if(strcmp(fontWeigth,'Bold'))
        set(t,'FontWeight','bold')
    else
        set(t,'FontWeight','normal')
    end
    hold off
end

end