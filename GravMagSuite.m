%--------------------------------------------------------------------------
% GRAV MAG SUITE - Grav Mag Suite is an open source MATLAB-based package for
% processing potential field geophysical data.
%--------------------------------------------------------------------------
% This main GUI function connects with all other GUI functions and provide
% some tools for manage the processing data.
%--------------------------------------------------------------------------
%           AUTHOR
%Fabrício Rodrigues Castro
%
%           COLABORATORS
%Saulo Pomponet Oliveira
%Jeferson de Souza
%Francisco José Ferreira Fonseca
%
%Federal University of Paraná [UFPR]
%Laboratory for Research in Applied Geophysics [LPGA]
%Brazil

function GravMagSuite

clc
clear
warning('off','all')

%--------------------------------------------------------------------------
%MAIN WINDOW COMPONENTS
%--------------------------------------------------------------------------

width=1366;
height=768;

%Centralize the main window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);

gravMagSuiteGUI = figure('Menubar','none','Name','Grav Mag Suite',...
    'NumberTitle','off','NextPlot','add','units','pixel',...
    'position',[posX,posY,Width,Height],'Toolbar','figure',...
    'Visible','off','Resize','on','Tag','mainGUI',...
    'CloseRequestFcn',@closeWindow);

popupColormapType = uicontrol(gravMagSuiteGUI,'Style','popupmenu',...
    'Units','normalized',...
    'fontUnits','normalized',...
    'position',[0.01 0.95 0.14 0.036],...
    'Callback',@setColormap_callBack);

colormapGraph=axes(gravMagSuiteGUI,'units','normalized',...
    'Position',[0.01 0.9 0.14 0.036],...
    'XTickLabel',[],'YTickLabel',[],...
    'XTick',[],'YTick',[],'Box','on');

popupGraphType = uicontrol(gravMagSuiteGUI,'Style','popupmenu',...
    'Units','normalized',...
    'String',{'pcolor','surf','wireframe'},...
    'fontUnits','normalized',...
    'position',[0.01 0.85 0.14 0.036],...
    'Callback',@setGraphType_callBack);

popupDistColorType = uicontrol(gravMagSuiteGUI,'Style','popupmenu',...
    'Units','normalized',...
    'String',{'Linear','Equalized Histogram'},...
    'fontUnits','normalized',...
    'position',[0.01 0.8 0.14 0.036],...
    'Callback',@setColorDistribution_callBack);

coordConversion = uicontrol(gravMagSuiteGUI,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.01 0.75 0.14 0.036],...
    'Callback',@setCoordinates_callBack);

verticalExagerationSLD = uicontrol(gravMagSuiteGUI,'Style','slider',...
    'Units','normalized',...
    'Min',1,'Max',400,'Value',1,...
    'SliderStep',[0.04 0.08],...
    'position',[0.01 0.7 0.14 0.036],...
    'Callback',@verticalExaggeration_callBack);

statisticalInfo = uicontrol(gravMagSuiteGUI,'Style','edit',...
    'TooltipString','Display some statistical informations about input dataset.',...
    'units','normalized',...
    'Min',1,'Max',5,...
    'Enable','off',...
    'HorizontalAlignment','left',...
    'String','',...
    'FontSize',13,...
    'position',[0.01 0.35 0.14 0.335]);

imageFileFormat = uicontrol(gravMagSuiteGUI,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'png','jpeg','jpg','tiff'},...
    'fontUnits','normalized',...
    'TooltipString','Image file format.',...
    'position',[0.01 0.163 0.14 0.036]);

DPI_=uicontrol(gravMagSuiteGUI,'Style','edit',...
    'units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'TooltipString','Dots per inch.',...
    'position',[0.01 0.113 0.14 0.036]);

uicontrol(gravMagSuiteGUI,'Style','pushbutton',...
    'units','normalized',...
    'String','Export Map',...
    'fontUnits','normalized',...
    'position',[0.01 0.063 0.14 0.036],...
    'CallBack',@exportMapAsImage_callBack);

%--------------------------------------------------------------------------

panelGraph = uipanel(gravMagSuiteGUI,'Title','','units','normalized',...
    'Position',[0.16 0.06 0.83 0.927],...
    'BackgroundColor','white',...
    'BorderType','etchedin');

mainGraph = axes(panelGraph,'units','normalized',...
    'Position',[0.15 0.15 0.7 0.7]);
set(get(mainGraph,'XAxis'),'Visible','off');
set(get(mainGraph,'YAxis'),'Visible','off');

%--------------------------------------------------------------------------

panelStatus = uipanel(gravMagSuiteGUI,'Title','','units','normalized',...
    'Position',[0.01 0.01 0.98 0.04],...
    'BorderType','etchedin');

panelVersion = uicontrol(panelStatus,'Style','edit',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Enable','off',...
    'BackgroundColor',[0.85 0.85 0.85],...
    'Position',[0.65 0 0.35 1]);

set(panelVersion,'String',['Version: 1.1.1 - Date: ',date,' - fcastrogeof@gmail.com'])

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(gravMagSuiteGUI,'label','File');
uimenu(file,'Label','Open ASCII...','Accelerator','O','CallBack',@openFile_callBack);
uimenu(file,'Label','Open .mat file...','CallBack',@openMAT_callBack);
uimenu(file,'Label','Data Statistics','CallBack',@GUIdataStatistics_callBack);
uimenu(file,'Label','Generate a color table from image','CallBack',@GUIgenerateColormap_callBack);
uimenu(file,'Label','Load Line Shapefile','CallBack',@loadShape_callBack);
uimenu(file,'Label','Export Map','CallBack',@GUIexportMap_callBack);
uimenu(file,'Label','Reset GUI','CallBack',@clearPlottingArea_callBack);
uimenu(file,'Label','Exit','Callback',@closeWindow,'Separator','on');

profile = uimenu(gravMagSuiteGUI,'label','Profile');
uimenu(profile,'Label','Profile Analysis','CallBack',@GUIprofileAnalysis_callBack);
uimenu(profile,'Label','Extract Profile from a Grid','CallBack',@GUIextractProfile_callBack);
uimenu(profile,'Label','Add Noise to Profile','CallBack',@GUIaddNoiseToProfile_callBack);

grid = uimenu(gravMagSuiteGUI,'label','Grid');
interpolate = uimenu(grid,'Label','Interpolate');
uimenu(interpolate,'Label','Inverse interpolation','CallBack',@GUIinverseInterp_callBack);
uimenu(interpolate,'Label','Gap Filling','CallBack',@GUIgapFilling_callBack);
uimenu(interpolate,'Label','MATLAB Gridata','CallBack',@GUIgridData_callBack);
uimenu(interpolate,'Label','MATLAB Scattered Interpolant','CallBack',@GUIscatteredInterpolant_callBack);
uimenu(grid,'Label','Regrid Data','CallBack',@GUIregridData_callBack);
uimenu(grid,'Label','Window Grid','CallBack',@GUIwindowGrid_callBack);
uimenu(grid,'Label','Grid Outline','CallBack',@GUIgridOutline_callBack);
uimenu(grid,'Label','Fill NaN Values','CallBack',@GUIfillNaN_callBack);
uimenu(grid,'Label','Trend Removal','CallBack',@GUItrendRemoval_callBack);
uimenu(grid,'Label','Add Noise to Grid','CallBack',@GUIaddNoiseToGrid_callBack);

fieldTransformations = uimenu(gravMagSuiteGUI,'label','Field Transformations');
uimenu(fieldTransformations,'Label','Derivative','CallBack',@GUIderivative_callBack);
uimenu(fieldTransformations,'Label','Directional Derivative','CallBack',@GUIdirectionalDerivative_callBack);
uimenu(fieldTransformations,'Label','Generalized Derivative Operator','CallBack',@GUIgeneralDerivativeOperator_callBack);
uimenu(fieldTransformations,'Label','Vertical Derivative using Upward Continuation','CallBack',@GUIvertDerivUwContinuation_callBack);
uimenu(fieldTransformations,'Label','Field Continuation','CallBack',@GUIfieldContinuation_callBack);
uimenu(fieldTransformations,'Label','Directional Cosine','CallBack',@GUIdirectionalCosine_callBack);
uimenu(fieldTransformations,'Label','Change Direction of Measurement','CallBack',@GUIdirectionOfMeasurement_callBack);
rtp = uimenu(fieldTransformations,'Label','Reduction to the Pole');
uimenu(rtp,'Label','Classical Equation','CallBack',@GUIrtpGunn_callBack);
uimenu(rtp,'Label','Pseudo Inclination Method','CallBack',@GUIrtpMacLeod_callBack);
uimenu(fieldTransformations,'Label','Reduction to the Equator','CallBack',@GUIreductionToEquator_callBack);
uimenu(fieldTransformations,'Label','Vertical Integration','CallBack',@GUIverticalIntegration_callBack);
uimenu(fieldTransformations,'Label','Hilbert Transform','CallBack',@GUIhilbertTransform_callBack);
uimenu(fieldTransformations,'Label','Anisotropic Diffusion Filter','CallBack',@GUIanisotropicDiffusionFilter_callBack);
filters = uimenu(fieldTransformations,'Label','Filters');
convFilters = uimenu(filters,'Label','Convolutional Filters');
uimenu(convFilters,'Label','3x3 Convolutional','CallBack',@GUI3x3conv_callBack);
fourierFilters = uimenu(filters,'Label','Fourier Filters');
uimenu(fourierFilters,'Label','Butterworth Filter','CallBack',@GUIbutterworthFilter_callBack);

edgeDetectors = uimenu(gravMagSuiteGUI,'label','Enhancement Filters');
uimenu(edgeDetectors,'Label','Classical Enhancement Filters','CallBack',@GUIclassicalEnhancementFilters_callBack);
uimenu(edgeDetectors,'Label','TDR+-TDX','CallBack',@GUItdr_tdx_callBack);

semiquantitativeMethods = uimenu(gravMagSuiteGUI,'label','Semiquantitative Methods');
uimenu(semiquantitativeMethods,'Label','Source Distance','CallBack',@GUIsourceDistance_callBack);
uimenu(semiquantitativeMethods,'Label','Tilt-Depth','CallBack',@GUItiltDepth_callBack);
uimenu(semiquantitativeMethods,'Label','Signum Transform','CallBack',@GUIsignumTransform_callBack);
Euler = uimenu(semiquantitativeMethods,'label','Euler Deconvolution');
uimenu(Euler,'Label','2D Euler Deconvolution','CallBack',@GUIclassical2DEulerDeconv_callBack);
Euler3D = uimenu(Euler,'label','3D Euler Deconvolution');
uimenu(Euler3D,'Label','Standard Euler Deconvolution','CallBack',@GUIclassical3DEulerDeconv_callBack);
uimenu(Euler3D,'Label','Constrained Moving Window Euler Deconvolution','CallBack',@GUICMWEulerDeconv_callBack);
uimenu(Euler3D,'Label','AN-EUL','CallBack',@GUIanEuler_callBack);
uimenu(Euler3D,'Label','Plot Euler Solutions...','Separator','on','CallBack',@GUIplotEulerSolutions_callBack);
uimenu(Euler3D,'Label','Separate in Histogram Classes','CallBack',@GUIclassSeparationEulerDeconv_callBack);
uimenu(Euler3D,'Label','SubSet Solutions','CallBack',@GUIsubsetEulerDeconv_callBack);

modeling = uimenu(gravMagSuiteGUI,'label','Modeling');
twoDimensionalModeling = uimenu(modeling,'label','2D Modeling');
uimenu(twoDimensionalModeling,'Label','Spherical Body','CallBack',@GUIsphericalBodyProfile_callBack);
uimenu(twoDimensionalModeling,'Label','Dyke-like Body','CallBack',@GUIdikeLikeBody_callBack);
uimenu(twoDimensionalModeling,'Label','Fault Model','CallBack',@GUIfaultModel_callBack);
uimenu(twoDimensionalModeling,'Label','Irregular Cross-Section Body','CallBack',@GUIirregularCrossSectionBody_callBack);
threeDimensionalModeling = uimenu(modeling,'label','3D Modeling');
uimenu(threeDimensionalModeling,'Label','Spherical Body','CallBack',@GUIsphericalBodyMap_callBack);
uimenu(threeDimensionalModeling,'Label','Prismatic Body','CallBack',@GUIprismaticBody_callBack);

%--------------------------------------------------------------------------
%Make GUI visible after load all components
set(gravMagSuiteGUI,'Visible','on')

uicontrolHandles=findall(gcf,'Type','uicontrol');
N__=length(uicontrolHandles);
uiPositions=zeros([N__,4]);
W_handles=cell([N__,1]);
H_handles=cell([N__,1]);
for i__=1:N__
    uiPositions(i__,:)=uicontrolHandles(i__).Position;
    W_handles(i__)={uiPositions(i__,3)};
    H_handles(i__)={uiPositions(i__,4)};
end
set(gravMagSuiteGUI,'SizeChangedFcn',{@resizeBehavior,width,height,W_handles,H_handles})

add2MATLABpath('\Third-party')
add2MATLABpath('\Processing')
add2MATLABpath('\ascii files\Grids')
add2MATLABpath('\Menu\Enhancement Filters')
add2MATLABpath('\Menu\Field Transformations')
add2MATLABpath('\Menu\File')
add2MATLABpath('\Menu\Grid')
add2MATLABpath('\Menu\Modeling')
add2MATLABpath('\Menu\Modeling\GUIirregularCrossSectionBody')
add2MATLABpath('\Menu\Profile')
add2MATLABpath('\Menu\Semiquantitative Methods')

Cmenu = uicontextmenu(gravMagSuiteGUI);
set(gravMagSuiteGUI,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

tbls
currentTBL
dataLoaded = 'n';

%--------------------------------------------------------------------------
%Shapefile properties GUI
%--------------------------------------------------------------------------

width=250;
height=150;

%Centralize the main window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);

shapeProperties = figure('Menubar','none','Name','Shape Properties',...
    'NumberTitle','off','NextPlot','add','units','pixel',...
    'position',[posX,posY,Width,Height],'Toolbar','none',...
    'Visible','off','Resize','off','CloseRequestFcn',@closeWindow2);

uicontrol(shapeProperties,'Style','pushbutton',...
    'units','normalized',...
    'String','Done',...
    'fontUnits','normalized',...
    'position',[0.05 0.1 0.9 0.18],...
    'CallBack',@closeWindow2);

shapeLineStyle = uicontrol(shapeProperties,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Solid Line [-]','Dashed Line [--]','Dotted Line [:]','Dash-dotted Line [-.]'},...
    'tooltipstring','Line style of shapefile',...
    'fontUnits','normalized',...
    'position',[0.05 0.3 0.9 0.18]);

shapeLineColor = uicontrol(shapeProperties,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Black','White','Red','Green','Blue','Cyan','Magenta','Yellow'},...
    'tooltipstring','Color of shapefile',...
    'fontUnits','normalized',...
    'position',[0.05 0.5 0.9 0.18]);

shapeLineWidth = uicontrol(shapeProperties,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'tooltipstring','Line width of shapefile',...
    'fontUnits','normalized',...
    'position',[0.05 0.7 0.9 0.18]);

%--------------------------------------------------------------------------
%CALLBACK FUNCTIONS
%--------------------------------------------------------------------------

%FILE MENU OPTIONS---------------------------------------------------------

function openFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select an ASCII File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);
[row,col]=size(Zg);
[dx,dy]=find_cell_size(Xg,Yg);

Z_=Z; Z_(isnan(Z))=[];
nElements = {['Samples: ',num2str(numel(Z))]};
nDummies = {['Dummies/NaN: ',num2str(numel(Z)-numel(Z_))]};
nRows = {['Rows: ',num2str(row)]};
nCols = {['Cols: ',num2str(col)]};
xCell = {['Cell size in x: ',num2str(dx)]};
yCell = {['Cell size in y: ',num2str(dy)]};
Min = {['Min: ',num2str(min(Z_))]};
Max = {['Max: ',num2str(max(Z_))]};
Mean = {['Mean: ',num2str(mean(Z_))]};
Median = {['Median: ',num2str(median(Z_))]};
StandardDev = {['Standard Deviation: ',num2str(std(Z_))]};

info = [nElements;nDummies;nRows;nCols;xCell;yCell;Min;Max;Mean;Median;StandardDev];
set(statisticalInfo,'String',info)
set(statisticalInfo,'Enable','on')

tbl_ = get(popupColormapType,'String');
tbl_ = char(tbl_(get(popupColormapType,'Value')));

ConvCoord = get(coordConversion,'Value');

axes(mainGraph)
plotIndividualMap(Xg,Yg,Zg,...
    get(popupDistColorType,'Value'),...
    tbl_,ConvCoord,get(popupGraphType,'Value'));

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.row = row;
handles.col = col;
dataLoaded = 'y';
%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

function openMAT_callBack(varargin)

GUIloadMAT

end

function GUIdataStatistics_callBack(varargin)

GUIdataStatistics

end

function GUIgenerateColormap_callBack(varargin)

GUIgenerateColormap

end

function loadShape_callBack(varargin)

[FileName,PathName] = uigetfile({'*.shp','Data Files (*.shp)'},'Select Shapefile...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

S = shaperead(Fullpath);

set(shapeProperties,'Visible','on')

waitfor(shapeProperties,'Visible','off');

lineStyleVec = {'-';'--';':';'-.'};
lineStyle = lineStyleVec{get(shapeLineStyle,'Value')};

lineWidth = str2double(get(shapeLineWidth,'String'));

colorVec = ['k';'w';'r';'g';'b';'c';'m';'y'];
color = colorVec(get(shapeLineColor,'Value'));

mapshow(mainGraph,S,...
    'Color',color,...
    'LineStyle',lineStyle,...
    'LineWidth',lineWidth)

end

function GUIexportMap_callBack(varargin)

GUIexportMap

end

function clearPlottingArea_callBack(varargin)

if(dataLoaded == 'n')
    msgbox('This function will be enabled just after open some dataset.','Warn','warn','modal')
    return
elseif(dataLoaded == 'y')
    cla(mainGraph,'reset')
    set(mainGraph.XAxis,'Visible','off')
    set(mainGraph.YAxis,'Visible','off')
    set(table,'Data','')
    set(table,'ColumnName','')
    dataLoaded='n';
    set(xCoord,'String','')
    set(yCoord,'String','')
end

end

%PROFILE MENU OPTIONS------------------------------------------------------

function GUIprofileAnalysis_callBack(varargin)

GUIprofileAnalysis

end

function GUIextractProfile_callBack(varargin)

GUIextractProfile

end

function GUIaddNoiseToProfile_callBack(varargin)

GUIaddNoiseProfile

end

%GRID MENU OPTIONS---------------------------------------------------------

function GUIgridData_callBack(varargin)

GUIgridData

end

function GUIscatteredInterpolant_callBack(varargin)

GUIscatteredInterpolant

end

function GUIgapFilling_callBack(varargin)

GUIgapFilling

end

function GUIinverseInterp_callBack(varargin)

GUIinverseInterp

end

function GUIregridData_callBack(varargin)

GUIregridData

end

function GUIwindowGrid_callBack(varargin)

GUIwindowGrid

end

function GUIgridOutline_callBack(varargin)

GUIgridOutline

end

function GUIfillNaN_callBack(varargin)

GUIfillNaN

end

function GUItrendRemoval_callBack(varargin)

GUItrendRemoval

end

function GUIaddNoiseToGrid_callBack(varargin)

GUIaddNoise

end

%FIELD TRANSFORMATIONS MENU OPTIONS----------------------------------------

function GUIderivative_callBack(varargin)

GUIderivative

end

function GUIdirectionalDerivative_callBack(varargin)

GUIdirectionalDerivative

end

function GUIgeneralDerivativeOperator_callBack(varargin)

GUIgeneralDerivativeOperator

end

function GUIvertDerivUwContinuation_callBack(varargin)

GUIvertDerivUwContinuation

end

function GUIfieldContinuation_callBack(varargin)

GUIfieldContinuation

end

function GUIdirectionalCosine_callBack(varargin)

GUIdirectionalCosine

end

function GUIdirectionOfMeasurement_callBack(varargin)

GUIdirectionOfMeasurement

end

function GUIrtpGunn_callBack(varargin)

GUIrtpGunn

end

function GUIrtpMacLeod_callBack(varargin)

GUIrtpMacLeod

end

function GUIreductionToEquator_callBack(varargin)

GUIreductionToEquator

end

function GUIverticalIntegration_callBack(varargin)

GUIverticalIntegration

end

function GUIhilbertTransform_callBack(varargin)

GUIhilbertTransform

end

function GUIanisotropicDiffusionFilter_callBack(varargin)

GUIanisotropicDiffusionFilter

end

function GUI3x3conv_callBack(varargin)

GUI3x3conv

end

function GUIbutterworthFilter_callBack(varargin)

GUIbutterworthFilter

end

%ENHANCEMENT FILTERS MENU OPTIONS------------------------------------------

function GUIclassicalEnhancementFilters_callBack(varargin)

GUIclassicalEnhancementFilters

end

function GUItdr_tdx_callBack(varargin)

GUItdr_tdx

end

%SEMIQUANTITATIVE METHODS MENU OPTIONS-------------------------------------

function GUIsourceDistance_callBack(varargin)
%Retrieve the handle structure

GUIsourceDistance

end

function GUItiltDepth_callBack(varargin)

GUItiltDepth

end

function GUIsignumTransform_callBack(varargin)

GUIsignumTransform

end

function GUIclassical2DEulerDeconv_callBack(varargin)

GUIclassical2DEulerDeconv


end

function GUIclassical3DEulerDeconv_callBack(varargin)

GUIclassical3DEulerDeconv

end

function GUICMWEulerDeconv_callBack(varargin)

GUICMWEulerDeconv

end

function GUIanEuler_callBack(varargin)

GUIanEuler

end

function GUIplotEulerSolutions_callBack(varargin)

GUIplotEulerSolutions

end

function GUIclassSeparationEulerDeconv_callBack(varargin)

GUIclassSeparationEulerDeconv

end

function GUIsubsetEulerDeconv_callBack(varargin)

GUIsubsetEulerDeconv

end

%MODELING MENU OPTIONS-----------------------------------------------------
%3d
function GUIprismaticBody_callBack(varargin)

GUIprismaticBody

end

function GUIsphericalBodyMap_callBack(varargin)

GUIsphericalBodyMap

end
%2d
function GUIsphericalBodyProfile_callBack(varargin)

GUIsphericalBodyProfile

end

function GUIdikeLikeBody_callBack(varargin)

GUIdikeLikeBody

end

function GUIfaultModel_callBack(varargin)

GUIfaultModel

end

function GUIirregularCrossSectionBody_callBack(varargin)

GUIirregularCrossSectionBody

end

%--------------------------------------------------------------------------

function setColormap_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

currentTBL

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    tbl_ = get(popupColormapType,'String');
    tbl_ = char(tbl_(get(popupColormapType,'Value')));
    
    ConvCoord = get(coordConversion,'Value');
    
    ar = get(mainGraph,'DataAspectRatio');
    axes(mainGraph)
    plotIndividualMap(Xg,Yg,Zg,...
        get(popupDistColorType,'Value'),...
        tbl_,ConvCoord,get(popupGraphType,'Value'));
    set(gca,'DataAspectRatio',ar)
end

%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

function setGraphType_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    tbl_ = get(popupColormapType,'String');
    tbl_ = char(tbl_(get(popupColormapType,'Value')));
    
    ConvCoord = get(coordConversion,'Value');
    
    if(get(popupGraphType,'Value')~=1)
        ar = get(mainGraph,'DataAspectRatio');
        axes(mainGraph)
        plotIndividualMap(Xg,Yg,Zg,...
            get(popupDistColorType,'Value'),...
            tbl_,ConvCoord,get(popupGraphType,'Value'));
        set(mainGraph,'DataAspectRatio',ar);
    else
        set(verticalExagerationSLD,'Value',1)
        axes(mainGraph)
        plotIndividualMap(Xg,Yg,Zg,...
            get(popupDistColorType,'Value'),...
            tbl_,ConvCoord,get(popupGraphType,'Value'));
    end
end

%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

function setColorDistribution_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    tbl_ = get(popupColormapType,'String');
    tbl_ = char(tbl_(get(popupColormapType,'Value')));
    
    ConvCoord = get(coordConversion,'Value');
    
    ar = get(mainGraph,'DataAspectRatio');
    axes(mainGraph)
    plotIndividualMap(Xg,Yg,Zg,...
        get(popupDistColorType,'Value'),...
        tbl_,ConvCoord,get(popupGraphType,'Value'));
    set(mainGraph,'DataAspectRatio',ar);
end

%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

function setCoordinates_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

if(dataLoaded == 'y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    tbl_ = get(popupColormapType,'String');
    tbl_ = char(tbl_(get(popupColormapType,'Value')));
    
    ConvCoord = get(coordConversion,'Value');
    
    ar = get(mainGraph,'DataAspectRatio');
    axes(mainGraph)
    plotIndividualMap(Xg,Yg,Zg,...
        get(popupDistColorType,'Value'),...
        tbl_,ConvCoord,get(popupGraphType,'Value'))
    set(mainGraph,'DataAspectRatio',ar)
end

%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

function verticalExaggeration_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

if(dataLoaded == 'y' && (get(popupGraphType,'Value')==2 || get(popupGraphType,'Value')==3))
    val = get(verticalExagerationSLD,'Value');
    P=[1,1,1/(val)];
    set(gca,'DataAspectRatio',P)
else
    msgbox('This function will be allowed after open some dataset and graph type is set to Surf.','Warn','warn')
    set(verticalExagerationSLD,'Value',1)
    return
end

%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

function exportMapAsImage_callBack(varargin)
%Retrieve the handle structure
handles = guidata(gravMagSuiteGUI);

if(dataLoaded == 'y')
    Zg = handles.Zg;
    
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
        aspectX = map_width/map_width;
        aspectY = map_heigth/map_width;
    else
        aspectY = (map_heigth/map_heigth)*1.2;
        aspectX = map_width/map_heigth;
    end
    
    fig = figure('Position',[200,200,1000*aspectX,1000*aspectY],'Visible','off');
    graph = findobj(panelGraph,'Type','Axes');
    copyobj(graph,fig);
    
    c = findobj(panelGraph,'Type','Colorbar');
    str = get(get(c,'Label'),'String');
    
    c=colorbar;
    set(get(c,'Label'),'String',str)
    set(get(c,'Label'),'FontWeight','bold')
    
    set(get(gca,'xlabel'),'FontWeight','bold')
    set(get(gca,'ylabel'),'FontWeight','bold')
    
    [row,col]=size(Zg);
    
    colormaps_ = get(popupColormapType,'String');
    colormapSelected = char(colormaps_(get(popupColormapType,'Value')));
    
    if(get(popupDistColorType,'Value')==1)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'linear');
        colormap(fig,cmapChanged)
    elseif(get(popupDistColorType,'Value')==2)
        cmapChanged = colormaps(reshape(Zg,[row*col,1]),colormapSelected,'equalized');
        colormap(fig,cmapChanged)
    end
    
    set(gca,'position',[0.13 0.13 .7 .78])
    
    print(fig,ImagePath,imageF,dpi_)
    delete(fig)
    
    delete(msg)
    msgbox('Map Exported!','Warn','warn')
else
    msgbox('This function will be allowed after open some dataset.','Warn','warn')
    return
end

%Update de handle structure
guidata(gravMagSuiteGUI,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

%CENTRALIZE THE GUI WINDOW
function [posX,posY,Width,Height]=centralizeWindow(Width_,Height_)

%Size of the screen
screensize = get(0,'Screensize');
Width = screensize(3);
Height = screensize(4);

posX = (Width/2)-(Width_/2);
posY = (Height/2)-(Height_/2);
Width=Width_;
Height=Height_;

end

%READ ALL AVAILABLE COLORMAPS IN TBL FOLDER
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
    set(popupColormapType,'String',tbl_)
end

%SEARCH FOR TBLS
function currentTBL
    colormapChoosen = get(popupColormapType,'String');
    
    tblFolder=loadTBL(strcat(char(colormapChoosen(get(popupColormapType,'Value'))),'.tbl'));
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

%CLOSE THE WINDOW
function closeWindow(varargin)

GUIcloseRequest
h = findobj('Tag','closeRequest');
if(length(h)~=1)
    h = h(1);
end
waitfor(h,'Visible','off')
a = guidata(h);
selection = a.choice;
delete(h)

if(selection==1)
    delete(gravMagSuiteGUI)
    ocultFIG = findobj('Type','figure','-and','Visible','off');
    if(~isempty(ocultFIG))
        delete(ocultFIG)
    end
elseif(selection==2)
    delete(gravMagSuiteGUI)
    ocultFIG = findobj('Type','figure','-and','Visible','off');
    if(~isempty(ocultFIG))
        delete(ocultFIG)
    end
    complementaryFIG = findobj('Type','figure','-and','Tag','GMS');
    if(~isempty(complementaryFIG))
        delete(complementaryFIG)
    end
else
    return
end

end

function closeWindow2(varargin)
    set(shapeProperties,'Visible','off')
    set(shapeLineStyle,'Value',1)
    set(shapeLineColor,'Value',1)
    set(shapeLineWidth,'String','1')
end

%ADD SOME DIRECTORY TO MATLAB PATH
function add2MATLABpath(additionalFilePath)

pcPlatform = computer('arch');
pcPlatform = pcPlatform(1:3);
if(strcmp(pcPlatform,'gln') || strcmp(pcPlatform,'mac'))
    fragmentedPath = strsplit(additionalFilePath,'\');
    fragmentedPath = fragmentedPath(1,2:end);
    n=length(fragmentedPath);
    a='';
    for i=1:n
        a = [a,'/',fragmentedPath{:,i}];
    end
    additionalFilePath = a;
end

rootDirectory = pwd;

newpath = [rootDirectory,additionalFilePath];

oldpath = path;
path(oldpath,newpath)

end

%COPY THE GUI DATA TO MATLAB WORKSPACE
function copy2MATLABworkspace(varargin)
    data = guidata(gcf);
    if(~isempty(data))
        assignin('base','GUIdata',data)
    else
        msgbox('There are no variables associated with this GUI.','Warn','warn','modal')
        return
    end
end

end