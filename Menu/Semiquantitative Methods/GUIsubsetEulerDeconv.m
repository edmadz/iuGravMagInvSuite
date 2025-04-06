function GUIsubsetEulerDeconv

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIsubsetEulerDeconv_ = figure('Menubar','none',...
    'Name','Separate Euler Solutions by Polygon Mask',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------
inputParametersPanel = uipanel(GUIsubsetEulerDeconv_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Generate Polygon',...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036],...
    'CallBack',@generatePolygonMask_callBack);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Mask Euler Solutions',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.944 0.036],...
    'CallBack',@applyPolygonMask_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIsubsetEulerDeconv_,...
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

file = uimenu(GUIsubsetEulerDeconv_,'label','File');

uimenu(file,'Label','Open Euler Solutions...','Accelerator','O','CallBack',@OpenFile_callBack);
uimenu(file,'Label','Save Euler Solutions...','Accelerator','S','CallBack',@Save_callBack);

cur = 0;
Polygon = {};
dataLoaded = 'n';
set(GUIsubsetEulerDeconv_,'Visible','on')
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

[EulerSolutions_x0,EulerSolutions_y0,EulerSolutions_z0,...
    WS,N,minX,maxX,minY,maxY,minZ,maxZ]=loadEulerSolutions(Fullpath);

widthArea=maxX-minX;
heightArea=maxY-minY;

axes(graphSol)
scatter3(EulerSolutions_x0,EulerSolutions_y0,EulerSolutions_z0,20,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75]);
xlim([minX maxX])
ylim([minY maxY])
zlim([minZ maxZ])
ttl = strcat('EULER DEPTH SOLUTIONS SI=',num2str(N),' WINDOW SIZE=',num2str(WS),'x',num2str(WS));
title(ttl)
view(0,90)
if(widthArea>heightArea)
    b=heightArea/widthArea;
    pbaspect([1 b 0.3])
else
    b=widthArea/heightArea;
    pbaspect([b 1 0.3])
end
xlabel('Easting (m)','FontWeight','bold')
ylabel('Northing (m)','FontWeight','bold')
zlabel('Depth (m)','FontWeight','bold')
grid on
set(gca,'Box','on')
set(gca,'Xlim',[minX maxX])
set(gca,'Ylim',[minY maxY])
Y_coord = linspace(minY,maxY,5);
set(gca,'YTick',Y_coord)
Y_coord_ = prepCoord(Y_coord);
set(gca,'YTickLabel',Y_coord_)
set(gca,'YTickLabelRotation',90)
X_coord = linspace(minX,maxX,5);
set(gca,'XTick',X_coord)
X_coord_ = prepCoord(X_coord);
set(gca,'XTickLabel',X_coord_)
set(gca,'FontSize',17)
set(gca,'Box','on')
set(gca,'ZDir','reverse')

handles.EulerSolutions_x0 = EulerSolutions_x0;
handles.EulerSolutions_y0 = EulerSolutions_y0;
handles.EulerSolutions_z0 = EulerSolutions_z0;
handles.WS = WS;
handles.N = N;
handles.minX = minX;
handles.maxX = maxX;
handles.minY = minY;
handles.maxY = maxY;
handles.minZ = minZ;
handles.maxZ = maxZ;
dataLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%GENERATE POLYGON MASK
function generatePolygonMask_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

cur = cur+1;
h = impoly(gca);
setColor(h,[1,0,1])
pos = getPosition(h);
Polygon{cur,1} = pos;

%Update de handle structure
guidata(hObject,handles);
end

%APPLY THE POLYGON MASK ON EULER SOLUTIONS
function applyPolygonMask_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);
EulerSolutions_x0 = handles.EulerSolutions_x0;
EulerSolutions_y0 = handles.EulerSolutions_y0;
EulerSolutions_z0 = handles.EulerSolutions_z0;
WS = handles.WS;
N = handles.N;
minX = handles.minX;
maxX = handles.maxX;
minY = handles.minY;
maxY = handles.maxY;
minZ = handles.minZ;
maxZ = handles.maxZ;

N_=length(Polygon);

maskX = [];
maskY = [];
maskZ = [];

for i=1:N_
    coord = Polygon{i};
    x_ = coord(:,1); y_ = coord(:,2);
    in = inpolygon(EulerSolutions_x0,EulerSolutions_y0,x_,y_);
    
    mask_x0 = EulerSolutions_x0;
    mask_y0 = EulerSolutions_y0;
    mask_z0 = EulerSolutions_z0;
    
    maskX = [maskX; mask_x0(in)];
    maskY = [maskY; mask_y0(in)];
    maskZ = [maskZ; mask_z0(in)];
end

%Delete repeated Euler solutions
A = cat(2,maskX,maskY,maskZ);
B = unique(A,'rows');

maskX = B(:,1);
maskY = B(:,2);
maskZ = B(:,3);

widthArea=maxX-minX;
heightArea=maxY-minY;

figWidth__=1000;
figHeight__=700;
Pix_SS = get(0,'screensize');
W = Pix_SS(3);
H = Pix_SS(4);
posX_ = W/2 - figWidth__/2;
posY_ = H/2 - figHeight__/2;

f1=figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
scatter3(maskX,maskY,maskZ,20,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75]);
xlim([minX maxX])
ylim([minY maxY])
zlim([minZ maxZ])
ttl = strcat('SUBSET - EULER SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
title(ttl)
grid on
grid minor
set(gca,'Box','on')
set(gca,'FontSize',17)
if(widthArea>heightArea)
    b=heightArea/widthArea;
    pbaspect([1 b 0.3])
else
    b=widthArea/heightArea;
    pbaspect([b 1 0.3])
end
xlabel('Easting (m)','FontWeight','bold')
ylabel('Northing (m)','FontWeight','bold')
zlabel('Depth (m)','FontWeight','bold')
grid on
set(gca,'Box','on')
set(gca,'Xlim',[minX maxX])
set(gca,'Ylim',[minY maxY])
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

set(f1,'WindowButtonDownFcn',@mouseButtonD)

handles.EulerSolutions_x0 = maskX;
handles.EulerSolutions_y0 = maskY;
handles.EulerSolutions_z0 = maskZ;
%Update de handle structure
guidata(hObject,handles);
end

%SAVE THE MASKED EULER SOLUTIONS
function Save_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);
EulerSolutions_x0 = handles.EulerSolutions_x0;
EulerSolutions_y0 = handles.EulerSolutions_y0;
inputFile = handles.EulerSolutions_z0;
WS = handles.WS;
N = handles.N;
minX = handles.minX;
maxX = handles.maxX;
minY = handles.minY;
maxY = handles.maxY;
minZ = handles.minZ;
maxZ = handles.maxZ;
%the matrix of the derivative is the input of the function that converts it
%into the xyz format
outputFile = matrix2xyz(EulerSolutions_x0,EulerSolutions_y0,inputFile);

[filename, pathname] = uiputfile('*.txt','Salvar Arquivo...');
newfilename = fullfile(pathname, filename);

outputFile_path.String=num2str(newfilename);

fid = fopen(newfilename,'w+');
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

%Update de handle structure
guidata(hObject,handles);
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

function [x0,y0,z0,WS,N,minX,maxX,minY,maxY,minZ,maxZ]=loadEulerSolutions(path)
    data = importdata(path);

    if (isstruct(data))
        dado = data.data;
        [~,colData] = size(dado);
        if(colData~=3)
            msgbox('This data has more or less than 3 columns.','Warn','warn')
            return;
        elseif(colData==3)
            x0 = dado(1:end-8,1);
            y0 = dado(1:end-8,2);
            z0 = dado(1:end-8,3);
            WS = dado(end-7,1);
            N = dado(end-6,1);
            minX = dado(end-5,1);
            maxX = dado(end-4,1);
            minY = dado(end-3,1);
            maxY = dado(end-2,1);
            minZ = dado(end-1,1);
            maxZ = dado(end,1);
        end
    else
        dado = data;
        [~,colData] = size(dado);
        if(colData~=3)
            msgbox('This data has more or less than 3 columns.','Warn','warn')
            return;
        elseif(colData==3)
            x0 = dado(1:end-8,1);
            y0 = dado(1:end-8,2);
            z0 = dado(1:end-8,3);
            WS = dado(end-7,1);
            N = dado(end-6,1);
            minX = dado(end-5,1);
            maxX = dado(end-4,1);
            minY = dado(end-3,1);
            maxY = dado(end-2,1);
            minZ = dado(end-1,1);
            maxZ = dado(end,1);
        end
    end
end

end