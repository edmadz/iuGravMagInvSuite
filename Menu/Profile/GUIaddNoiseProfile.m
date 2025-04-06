function GUIaddNoiseProfile

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX_,posY_,Width,Height]=centralizeWindow(width,height);
figposition = [posX_,posY_,Width,Height];

GUIaddNoiseProfile_ = figure('Menubar','none',...
    'Name','Profile Analysis',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------

parameters = uipanel(GUIaddNoiseProfile_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

noiseType = uicontrol(parameters,'Style','popupmenu',...
    'TooltipString','Noise magnitude type.',...
    'units','normalized',...
    'Value',1,...
    'String',{'Uniformly Distributed Noise','Normally Distributed Noise'},...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036],...
    'CallBack',@magType_callBack);

magType = uicontrol(parameters,'Style','popupmenu',...
    'TooltipString','Noise magnitude type.',...
    'units','normalized',...
    'Value',1,...
    'String',{'In percentage','In loaded data units'},...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.944 0.036],...
    'CallBack',@magType_callBack);

maxMagnitude = uicontrol(parameters,'Style','edit',...
    'TooltipString','Maximum magnitude of loaded data.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.944 0.036]);

noiseLevel = uicontrol(parameters,'Style','edit',...
    'TooltipString','Noise level.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.765 0.944 0.036],...
    'CallBack',@noiseLevel_callBack);

noiseAmplitude = uicontrol(parameters,'Style','edit',...
    'TooltipString','Noise amplitude.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'position',[0.03 0.715 0.944 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','Add Noise to Profile',...
    'fontUnits','normalized',...
    'position',[0.03 0.665 0.944 0.036],...
    'Callback',@addNoise_callBack);

imageFileFormat = uicontrol(parameters,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'png','jpeg','jpg','tiff'},...
    'fontUnits','normalized',...
    'TooltipString','Image file format.',...
    'position',[0.03 0.165 0.944 0.036]);

DPI_=uicontrol(parameters,'Style','edit',...
    'units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'TooltipString','Dots per inch.',...
    'position',[0.03 0.115 0.944 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'units','normalized',...
    'String','Export Workspace as Image',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'CallBack',@exportWorkspaceAsImage_callBack);

%--------------------------------------------------------------------------
graphPanel = uipanel(GUIaddNoiseProfile_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

AnomProfile = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.56 0.88 0.39]);

EnhancedAnomProfile = axes(graphPanel,...
    'Units','normalized',...
    'xgrid','on',...
    'ygrid','on',...
    'Box','on',...
    'fontsize',12,...
    'position',[0.07 0.08 0.88 0.37]);

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIaddNoiseProfile_,'label','File');

uimenu(file,'Label','Open Profile...','Accelerator','O','CallBack',@LoadProfile_callBack);
uimenu(file,'Label','Save Profile...','Accelerator','S','CallBack',@GenerateFile_callBack);

dataLoaded = 'n';
filterApplied = 'n';
set(GUIaddNoiseProfile_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function LoadProfile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

[X,profile]=loadProfileEulerDeconvolution(Fullpath);

denominator = 1;

axes(AnomProfile)
plot(X./denominator,profile,'-k','linewidth',2);
set(AnomProfile,'XGrid','on')
set(AnomProfile,'YGrid','on')
xlabel('Position (m)')
ylabel('Profile Magnitude')
title('INPUT PROFILE')
set(AnomProfile,'fontSize',12)
legend('Profile without noise')
xlim([min(X)./denominator max(X)./denominator])

set(maxMagnitude,'String',max(abs(profile)))

handles.X = X;
handles.profile = profile;
dataLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%SET MAGNITUDE NOISE TYPE
function magType_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

set(noiseLevel,'String','')
set(noiseAmplitude,'String','')

%Update de handle structure
guidata(hObject,handles);
end

%SET NOISE MAGNITUDE
function noiseLevel_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    if(get(magType,'Value')==1)
        maxMag=str2double(get(maxMagnitude,'String'));
        noisePerc=str2double(get(noiseLevel,'String'))/100;
        set(noiseAmplitude,'String',num2str(maxMag*noisePerc))
    else
        noisePerc=str2double(get(noiseLevel,'String'));
        set(noiseAmplitude,'String',num2str(noisePerc))
    end
else
    set(noiseLevel,'String','')
    msgbox('Load some data before trying to set noise level.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%CORRUPT DATA WITH NOISE
function addNoise_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    X = handles.X;
    profile = handles.profile;
    
    noiseValue = str2double(get(noiseLevel,'String'));
    
    if(get(magType,'Value')==1)
        noiseValue = noiseValue/100;
        maxZg = max(abs(profile));
        noiseAmp = noiseValue*maxZg;
    else
        noiseAmp = noiseValue;
    end
    
    noise = randn(size(profile));
    normNoise = noise./max(noise);
    
    Noise = noiseAmp*normNoise;
    
    profile_=profile+Noise;
    
    axes(EnhancedAnomProfile)
    plot(X./1000,profile_,'-k','linewidth',2)
    xlabel('Position (km)')
    ylabel('Profile Magnitude')
    title('PROFILE CORRUPTED BY NOISE')
    set(EnhancedAnomProfile,'XGrid','on')
    set(EnhancedAnomProfile,'YGrid','on')
    set(EnhancedAnomProfile,'fontsize',12)
    legend('Data with noise')
    xlim([min(X)./1000 max(X)./1000])
    
    handles.profile_ = profile_;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to corrupt the input data.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(filterApplied=='y')
    X = handles.X;
    inputFile = handles.profile_;
    
    outputFile = cat(2,X,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save Profile...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return;
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%1s %14s \r\n','Position','Noise_Corrupted_Data');
    fprintf(fid,'%6.2f %8.6f\r\n',transpose(outputFile));
    fclose(fid);
else
    msgbox('Corrupt the input data before trying to save the output file.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%EXPORT WORKSPACE AS IMAGE
function exportWorkspaceAsImage_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Save Image...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

msg=msgbox('Wait a moment!','Warn','warn');

format_=get(imageFileFormat,'String');
imageF = char(strcat('-d',format_(get(imageFileFormat,'Value'))));
dpi_ = strcat('-r',get(DPI_,'String'));
fName = strsplit(FileName,'.');
ImagePath = char(strcat(PathName,fName(1)));

map_width = 1030;
map_heigth = 736;
aspectX = map_width/map_width;
aspectY = map_heigth/map_width;

fig = figure('Position',[500,500,1000*aspectX,1000*aspectY],'Visible','off');
h = copyobj(graphPanel,fig);
set(h,'Position',[0.02 0.02 0.96 0.96],'BorderType','none')

print(fig,ImagePath,imageF,dpi_)
delete(fig)

delete(msg)
msgbox('Map Exported!','Warn','warn')

%Update de handle structure
guidata(hObject,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTION
%--------------------------------------------------------------------------

function [position,value]=loadProfileEulerDeconvolution(Fullpath)
    data = importdata(Fullpath);

    if (isstruct(data))
        dado = data.data;
        position = dado(:,1);
        value = dado(:,2);
    else
        dado = data;
        position = dado(:,1);
        value = dado(:,2);
    end
end

end