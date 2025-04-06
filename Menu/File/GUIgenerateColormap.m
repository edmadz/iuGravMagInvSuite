function GUIgenerateColormap

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIgenerateColormap_ = figure('Name','Generate Colormap File from Image',...
    'Visible','off',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUIgenerateColormap_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUIgenerateColormap_,'Style','edit',...
    'TooltipString','Input Data Path',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);
%--------------------------------------------------------------------------

popupMode = uicontrol(GUIgenerateColormap_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Horizontally Disposed','Vertically Disposed'},...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08],...
    'CallBack',@changeMode_callBack);

colormapGraph=axes(GUIgenerateColormap_,'units','normalized',...
    'Position',[0.3 0.525 0.65 0.08]);
set(colormapGraph,'XTickLabel',[]);
set(colormapGraph,'YTickLabel',[]);
set(colormapGraph,'XTick',[]);
set(colormapGraph,'YTick',[]);
set(colormapGraph,'Box','on');

%--------------------------------------------------------------------------

uicontrol(GUIgenerateColormap_,'Style','pushbutton',...
    'units','normalized',...
    'String','Generate Colormap',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@generateColormap_callBack);

%--------------------------------------------------------------------------

uicontrol(GUIgenerateColormap_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUIgenerateColormap_,'Style','edit',...
    'TooltipString','Output Data Path',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

mode = 'horizontal';
set(GUIgenerateColormap_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgenerateColormap_);

[FileName,PathName] = uigetfile({'*.png;*.jpg;*.jpeg','Image Files (*.png,*.jpg,*.jpeg)'},'Select Image...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return;
end

image_=imread(Fullpath);
[row,col,~]=size(image_);

if(row>=col)
    mode = 'vertical';
    set(popupMode,'Value',2)
elseif(row<col)
    mode = 'horizontal';
    set(popupMode,'Value',1)
end

set(inputFile_path,'String',num2str(Fullpath))

axes(colormapGraph)
if(strcmp(mode,'horizontal'))
    image_=image(image_);
elseif(strcmp(mode,'vertical'))
    image_=image(rot90(image_,3));
end
axis fill
set(colormapGraph,'XTickLabel',[]);
set(colormapGraph,'YTickLabel',[]);
set(colormapGraph,'XTick',[]);
set(colormapGraph,'YTick',[]);
set(colormapGraph,'Box','on');

handles.image_ = image_;
%Update de handle structure
guidata(GUIgenerateColormap_,handles);
end

%GENERATE COLORMAP
function generateColormap_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgenerateColormap_);
image_ = handles.image_;

image_ = image_.CData;

[row,col,~]=size(image_);

x=linspace(1,col,col);
xq=linspace(1,col,256);

X_half=round(row/2);
R=image_(X_half,:,1);
R=interp1(x,double(R),xq);
G=image_(X_half,:,2);
G=interp1(x,double(G),xq);
B=image_(X_half,:,3);
B=interp1(x,double(B),xq);

colormap_=cat(1,floor(R),floor(G),floor(B));
colormap_=colormap_';

msgbox('Colormap Generated!','Warn','warn')

handles.colormap_=colormap_;
%Update de handle structure
guidata(GUIgenerateColormap_,handles);
end

%SET THE OUTPUT DATASET PATH
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUIgenerateColormap_);
inputFile = handles.colormap_;

outputFile = inputFile;

[FileName,PathName] = uiputfile({'*.tbl','Data Files (*.tbl)'},'Save File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

set(outputFile_path,'String',num2str(Fullpath))

fid = fopen(Fullpath,'w+');
fprintf(fid,'%2s %1s %2s\r\n','{r','g','b}');
fprintf(fid,'%6.0f %6.0f %6.0f\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(GUIgenerateColormap_,handles);
end

end