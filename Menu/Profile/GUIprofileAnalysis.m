function GUIprofileAnalysis

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIprofileAnalysis_ = figure('Menubar','none',...
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

parameters = uipanel(GUIprofileAnalysis_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

popup = uicontrol(parameters,'Style','popupmenu',...
    'TooltipString','Qualitative edge detector.',...
    'Units','normalized',...
    'Value',1,...
    'String',{'ASA','THDR','TDR','TDR_THDR','TAHG','TDX','Theta-Map','TDR-TDX','TDR+TDX'},...
    'fontUnits','normalized',...
    'position',[0.03 0.915 0.944 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','Apply Qualitative Filter',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.944 0.036],...
    'Callback',@applyED_callback);

diffDirection = uicontrol(parameters,'Style','popupmenu',...
    'TooltipString','Derivative direction.',...
    'Units','normalized',...
    'Value',1,...
    'String',{'X','Z'},...
    'fontUnits','normalized',...
    'position',[0.03 0.815 0.46 0.036]);

diffOrder = uicontrol(parameters,'Style','edit',...
    'TooltipString','Derivative order.',...
    'Units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.51 0.815 0.46 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','Compute Derivative',...
    'fontUnits','normalized',...
    'position',[0.03 0.765 0.944 0.036],...
    'Callback',@differentiate_callback);

filterType = uicontrol(parameters,'Style','popupmenu',...
    'TooltipString','Convolutional filters.',...
    'Units','normalized',...
    'Value',1,...
    'String',{'Moving Average',''},...
    'fontUnits','normalized',...
    'position',[0.03 0.665 0.944 0.036]);

nPasses = uicontrol(parameters,'Style','edit',...
    'TooltipString','Number of passes.',...
    'Units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'position',[0.03 0.615 0.944 0.036]);

windowSize_ = uicontrol(parameters,'Style','edit',...
    'TooltipString','Window size.',...
    'Units','normalized',...
    'String','5',...
    'fontUnits','normalized',...
    'position',[0.03 0.565 0.944 0.036]);

uicontrol(parameters,'Style','pushbutton',...
    'Units','normalized',...
    'String','Apply Filter',...
    'fontUnits','normalized',...
    'position',[0.03 0.515 0.944 0.036],...
    'Callback',@filter_callback);

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
graphPanel = uipanel(GUIprofileAnalysis_,...
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

file = uimenu(GUIprofileAnalysis_,'label','File');

uimenu(file,'Label','Open Profile...','Accelerator','O','CallBack',@LoadProfile_callBack);
uimenu(file,'Label','Save Profile...','Accelerator','S','CallBack',@saveFile_callBack);

dataLoaded = 'n';
filterApplied = 'n';
set(GUIprofileAnalysis_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%LOAD A PROFILE DATA
function LoadProfile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (Fullpath == 0)
    return
end

data = importdata(Fullpath);

if (isstruct(data))
    dado = data.data;
    X = dado(:,1);
    profile = dado(:,2);
else
    dado = data;
    X = dado(:,1);
    profile = dado(:,2);
end

axes(AnomProfile)
plot(X./1000,profile,'-k','linewidth',2);
set(AnomProfile,'XGrid','on')
set(AnomProfile,'YGrid','on')
xlabel('Position (km)')
ylabel('Profile Magnitude')
title('INPUT PROFILE')
set(AnomProfile,'fontSize',12)
legend('Input Profile')
xlim([min(X)./1000 max(X)./1000])

handles.X = X;
handles.profile = profile;
dataLoaded = 'y';
%Update de handle structure
guidata(hObject,handles);
end

%APPLY THE DERIVATIVE FILTER
function differentiate_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    X = handles.X;
    profile = handles.profile;
    
    O = str2double(get(diffOrder,'String'));
    
    diff_=profile;
    if(get(diffDirection,'Value')==1)
        for n=1:O
            diff_ = difference1D(X',diff_');
        end
        flag = 'Dx';
    elseif(get(diffDirection,'Value')==2)
        for n=1:O
            [~,diff_] = differentiate1D(X',diff_');
            diff_=diff_';
        end
        flag = 'Dz';
    end
    
    axes(EnhancedAnomProfile)
    plot(X./1000,diff_,'-k','linewidth',2)
    xlabel('Position (km)')
    ylabel('Filter Magnitude')
    title(strcat('DERIVATIVE DF/',flag,' ORDER [',num2str(O),']'))
    set(EnhancedAnomProfile,'XGrid','on')
    set(EnhancedAnomProfile,'YGrid','on')
    set(EnhancedAnomProfile,'fontsize',12)
    legend('Processed Profile')
    xlim([min(X)./1000 max(X)./1000])
    
    flagDiff = 1;
    flagED = 0;
    flagFilter = 0;
    
    handles.flagED = flagED;
    handles.flagDiff = flagDiff;
    handles.flagFilter = flagFilter;
    handles.diff_ = diff_;
    handles.flag = flag;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%APPLY THE EDGE-DETECTOR FILTER
function applyED_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    X = handles.X;
    profile = handles.profile;
    
    Dx = difference1D(X',profile');
    [~,Dz] = differentiate1D(X',profile');
    
    if(get(popup,'Value')==1)
        F=sqrt(Dx.^2+Dz.^2);
        
        flag = 'ASA';
    elseif(get(popup,'Value')==2)
        F=abs(Dx);
        
        flag = 'THDR';
    elseif(get(popup,'Value')==3)
        F=atan2(Dz,abs(Dx));
        
        flag = 'TDR';
    elseif(get(popup,'Value')==4)
        TDR=atan2(Dz,abs(Dx));
        TDR_dx=difference1D(X',TDR');
        F=abs(TDR_dx.^2);
        
        flag = 'TDR_THDR';
    elseif(get(popup,'Value')==5)
        THDR=abs(Dx);
        THDR_dx=difference1D(X',THDR');
        [~,THDR_dz]=differentiate1D(X',THDR);
        F=atan(THDR_dz./abs(THDR_dx));
        
        flag = 'TAHG';
    elseif(get(popup,'Value')==6)
        THDR=abs(Dx);
        F=atan2(THDR,abs(Dz));
        
        flag = 'TDX';
    elseif(get(popup,'Value')==7)
        THDR=abs(Dx);
        ASA=sqrt(Dx.^2+Dz.^2);
        F=acos(THDR./ASA);
        
        flag = 'Theta_Map';
    elseif(get(popup,'Value')==8)
        THDR=abs(Dx);
        TDR=atan2(Dz,THDR);
        TDX=atan2(THDR,abs(Dz));
        F=TDR-TDX; %F=F.*transpose(profile);
        
        flag = 'TDR-TDX';
    elseif(get(popup,'Value')==9)
        THDR=abs(Dx);
        TDR=atan2(Dz,THDR);
        TDX=atan2(THDR,abs(Dz));
        F=TDR+TDX;
        
        flag = 'TDR+TDX';
    end
    
    axes(EnhancedAnomProfile)
    plot(X./1000,F,'-k','linewidth',2);
    xlabel('Position (km)')
    ylabel('Filter Magnitude')
    title(flag)
    set(EnhancedAnomProfile,'XGrid','on')
    set(EnhancedAnomProfile,'YGrid','on')
    set(EnhancedAnomProfile,'fontSize',12)
    legend('Processed Profile')
    xlim([min(X)/1000 max(X)/1000])
    
    flagDiff = 0;
    flagED = 1;
    flagFilter = 0;
    
    handles.f = F;
    handles.flagED = flagED;
    handles.flagDiff = flagDiff;
    handles.flagFilter = flagFilter;
    handles.flag = flag;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%FILTER THE INPUT PROFILE DATA
function filter_callback(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    X = handles.X;
    profile = handles.profile;
    
    n=str2double(get(nPasses,'String'));
    WS=str2double(get(windowSize_,'String'));
    
    if(get(filterType,'Value')==1)
        b = (1/WS)*ones(1,WS);
        a = 1;
        
        F=profile;
        for i=1:n
            if(mod(i,2))
                F = filter(b,a,F);
            else
                F=flipud(F);
                F = filter(b,a,F);
                F=flipud(F);
            end
        end
        F=F';
        
        flag = 'Moving Average';
    elseif(get(filterType,'Value')==2)
        return
    end
    
    axes(EnhancedAnomProfile)
    plot(X./1000,F,'-k','linewidth',2);
    xlabel('Position (km)')
    ylabel('Filter Magnitude')
    title(flag)
    set(EnhancedAnomProfile,'XGrid','on')
    set(EnhancedAnomProfile,'YGrid','on')
    set(EnhancedAnomProfile,'fontsize',12)
    legend('Processed Profile')
    xlim([min(X)/1000 max(X)/1000])
    
    handles.f = F;
    flagDiff = 0;
    flagED = 0;
    flagFilter = 1;
    handles.flagED = flagED;
    handles.flagDiff = flagDiff;
    handles.flagFilter = flagFilter;
    handles.flag = flag;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function saveFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(filterApplied=='y')
    X = handles.X;
    flagDiff = handles.flagDiff;
    flagED = handles.flagED;
    flagFilter = handles.flagFilter;
    
    if(flagDiff==1)
        inputFile = handles.diff_;
        flag = handles.flag;
    elseif(flagED==1)
        inputFile = handles.f;
        flag = handles.flag;
    elseif(flagFilter==1)
        inputFile = handles.f;
        flag = handles.flag;
    end
    
    inputFile = inputFile';
    outputFile = cat(2,X,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%8s %8s\r\n','X',flag);
    fprintf(fid,'%6.2f %12.8e\r\n',transpose(outputFile));
    fclose(fid);
else
    msgbox('Apply the filter before trying to save the output file.','Warn','warn')
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

end