function GUIbutterworthFilter

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX_,posY_,Width,Height]=centralizeWindow(width,height);
figposition = [posX_,posY_,Width,Height];

butterworthFilter_ = figure('Menubar','none',...
    'Name','Butterworth Filter',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','figure',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------

optionPanel = uipanel(butterworthFilter_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Spectrum',...
    'fontUnits','normalized',...
    'position',[0.03 0.93 0.944 0.036],...
    'CallBack',@ShowSpectrum_callBack);

typeFilter = uicontrol(optionPanel,'Style','popupmenu',...
    'Units','normalized',...
    'String',{'Choose a Filter','Low-Pass','High-Pass','Band-Pass','Band-Stop'},...
    'fontUnits','normalized',...
    'Value',1,...
    'position',[0.03 0.85 0.944 0.036],...
    'Callback',@setFilterType_callBack);

btn_F1 = uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','F1',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.03 0.8 0.944 0.036],...
    'CallBack',@F1_callBack);

btn_F2 = uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','F2',...
    'fontUnits','normalized',...
    'Enable','off',...
    'position',[0.03 0.75 0.944 0.036],...
    'CallBack',@F2_callBack);

O_ = uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','2',...
    'fontUnits','normalized',...
    'tooltipstring','Filter order.',...
    'position',[0.03 0.7 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Show Filter',...
    'fontUnits','normalized',...
    'position',[0.03 0.65 0.944 0.036],...
    'CallBack',@plotFilter_callBack);

popupYScale = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Set spectrum Y axis scale to linear','Set spectrum Y axis scale to log'},...
    'fontUnits','normalized',...
    'position',[0.03 0.6 0.944 0.036],...
    'CallBack',@changeYAxis_callBack);

coordConvertion = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.03 0.55 0.944 0.036]);

popupDist = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.03 0.5 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Perform Filtering',...
    'fontUnits','normalized',...
    'position',[0.03 0.45 0.944 0.036],...
    'CallBack',@performFiltering_callBack);

imageFileFormat = uicontrol(optionPanel,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'png','jpeg','jpg','tiff'},...
    'fontUnits','normalized',...
    'TooltipString','Image file format.',...
    'position',[0.03 0.15 0.944 0.036]);

DPI_=uicontrol(optionPanel,'Style','edit',...
    'units','normalized',...
    'String','300',...
    'fontUnits','normalized',...
    'TooltipString','Dots per inch.',...
    'position',[0.03 0.1 0.944 0.036]);

uicontrol(optionPanel,'Style','pushbutton',...
    'units','normalized',...
    'String','Export Workspace as Image',...
    'fontUnits','normalized',...
    'position',[0.03 0.05 0.944 0.036],...
    'CallBack',@exportWorkspaceAsImage_callBack);
%--------------------------------------------------------------------------

graphPanel = uipanel(butterworthFilter_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.96]);

FourierSpec = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.08 0.55 0.51 0.35]);
set(get(FourierSpec,'XAxis'),'Visible','off');
set(get(FourierSpec,'YAxis'),'Visible','off');

FourierSpec2D = axes(graphPanel,...
    'Units','normalized',...
    'tag','2D_1',...
    'position',[0.67 0.55 0.25 0.35]);
set(get(FourierSpec2D,'XAxis'),'Visible','off');
set(get(FourierSpec2D,'YAxis'),'Visible','off');

Filter = axes(graphPanel,...
    'Units','normalized',...
    'position',[0.08 0.1 0.51 0.35]);
set(get(Filter,'XAxis'),'Visible','off');
set(get(Filter,'YAxis'),'Visible','off');

Filter2D = axes(graphPanel,...
    'Units','normalized',...
    'tag','2D_2',...
    'position',[0.67 0.1 0.25 0.35]);
set(get(Filter2D,'XAxis'),'Visible','off');
set(get(Filter2D,'YAxis'),'Visible','off');

%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(butterworthFilter_,'label','File');
uimenu(file,'Label','Load File...','Accelerator','O','CallBack',@OpenFile_callBack);
uimenu(file,'Label','Save File...','Accelerator','S','CallBack',@SaveFile_callBack);

Cmenu = uicontextmenu(butterworthFilter_);
set(butterworthFilter_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
specsDisplayed = 'n';
filterTypeSetup = 'n';
cutOffF1Setup = 'n';
cutOffF2Setup = 'n';
filterApplied = 'n';
set(butterworthFilter_,'Visible','On')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return;
end

msg=msgbox('Wait a moment!','Warn','warn','modal');

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);
[cell_dx,cell_dy]=find_cell_size(Xg,Yg);

handles.X = X;
handles.Y = Y;
handles.Z = Z;
handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.cell_dx = cell_dx;
handles.cell_dy = cell_dy;

pause(1)
delete(msg)
msgbox('Data loaded!','Warn','warn','modal')

dataLoaded = 'y';
%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SHOW THE FOURIER SPECTRUM OF THE INPUT DATASET
function ShowSpectrum_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(dataLoaded=='y')
    Zg = handles.Zg;
    Z = handles.Z;
    
    [Zg_prepared] = padding2D(Zg,3,25,1,'y');
    
    % Create the wavenumber space
    [F1,F2] = freqspace(size(Zg_prepared),'meshgrid');
    kx=((2*pi*(length(F1)/2)/(length(F1)-1))*F1); kx(kx==0)=0.0000000000000001;
    ky=((2*pi*(length(F2)/2)/(length(F2)-1))*F2); ky(ky==0)=0.0000000000000001;
    
    minKx = min(min(kx)); maxKx = max(max(kx));
    minKy = min(min(ky)); maxKy = max(max(ky));
    
    FFT = fftshift(fft2(Zg_prepared));
    FFT2D = log(abs(FFT));
    [rows,~] = size(FFT);
    if(mod(rows,2))
        FFT_1D = abs(FFT(round(rows/2),:));
        X_1D = kx(round(rows/2),:);
    else
        FFT_1D = abs(FFT(round(rows/2)+1,:));
        X_1D = kx(round(rows/2)+1,:);
    end
    maxF = max(FFT_1D);
    FFT_1D_norm = abs(FFT_1D./maxF);
    
    if(get(popupYScale,'Value')==1)
        axes(FourierSpec)
        plot(X_1D,FFT_1D_norm,'b-','LineWidth',1.5)
        title('1D FOURIER SPECTRUM [HORIZONTAL WAVENUMBER DIRECTION]')
        set(FourierSpec,'XGrid','on')
        set(FourierSpec,'YGrid','on')
        axis([min(X_1D(:)) max(X_1D(:)) min(FFT_1D_norm(:))-min(FFT_1D_norm(:))*0.1 max(FFT_1D_norm(:))*1.1])
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Spectrum Magnitude')
    else
        axes(FourierSpec)
        plot(X_1D,FFT_1D_norm,'b-','LineWidth',1.5)
        title('1D FOURIER SPECTRUM [HORIZONTAL WAVENUMBER DIRECTION]')
        set(FourierSpec,'XGrid','on')
        set(FourierSpec,'YGrid','on')
        set(gca,'YScale','log')
        axis([min(X_1D(:)) max(X_1D(:)) min(FFT_1D_norm(:))-min(FFT_1D_norm(:))*0.1 max(FFT_1D_norm(:))*1.1])
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Magnitude')
    end
    
    axes(FourierSpec2D)
    pcolor(kx,ky,FFT2D)
    shading interp
    cmapChanged = colormaps(Z,'clra','linear');
    colormap(cmapChanged)
    title('2D FOURIER SPECTRUM')
    xlabel('kx (2\pi rad/m)')
    ylabel('ky (2\pi rad/m)')
    
    handles.minKx = minKx;
    handles.maxKx = maxKx;
    handles.minKy = minKy;
    handles.maxKy = maxKy;
    handles.FFT2D = FFT2D;
    specsDisplayed = 'y';
else
    msgbox('Load some dataset before trying to display it is spectrum.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SET THE FILTER TYPE
function setFilterType_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(dataLoaded=='y')
    selection = get(typeFilter,'Value');
    
    if(selection == 1)
        flagtypeFilter = 1;
        set(btn_F1,'Enable','off')
        set(btn_F2,'Enable','off')
        set(btn_F1,'String','F1')
        set(btn_F2,'String','F2')
    elseif(selection == 2)
        flagtypeFilter = 2;
        set(btn_F1,'Enable','on')
        set(btn_F2,'Enable','off')
        set(btn_F1,'String','F1 = 0')
        set(btn_F2,'String','F2 = inf')
    elseif(selection == 3)
        flagtypeFilter = 3;
        set(btn_F1,'Enable','on')
        set(btn_F2,'Enable','off')
        set(btn_F1,'String','F1 = 0')
        set(btn_F2,'String','F2 = inf')
    elseif(selection == 4)
        flagtypeFilter = 4;
        set(btn_F1,'Enable','on')
        set(btn_F2,'Enable','on')
        set(btn_F1,'String','F1 = 0')
        set(btn_F2,'String','F2 = 0')
    elseif(selection == 5)
        flagtypeFilter = 5;
        set(btn_F1,'Enable','on')
        set(btn_F2,'Enable','on')
        set(btn_F1,'String','F1 = 0')
        set(btn_F2,'String','F2 = 0')
    end
    
    filterTypeSetup = 'y';
    handles.flagtypeFilter = flagtypeFilter;
else
    set(typeFilter,'Value',1)
    msgbox('Load some dataset before trying to set the filter type.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SET THE FIRST CUT FREQUENCY VALUE F1
function F1_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(filterTypeSetup=='y' && specsDisplayed=='y')
    flagtypeFilter = handles.flagtypeFilter;
    if(cutOffF2Setup=='y')
        F2 = handles.F2;
        if(flagtypeFilter~=1)
            h = impoint(FourierSpec);
            pos=getPosition(h);
            x_f1 = pos(1);
            
            if(abs(x_f1)>abs(F2))
                delete(h)
                msgbox('The absolute value of F1 must be lower than the absolute value of F2!','Warn','warn','modal')
                h = impoint(FourierSpec);
                pos= getPosition(h);
                x_f1 = pos(1);
            end
            
            set(btn_F1,'String',strcat('F1=',num2str(x_f1)))
            handles.F1 = x_f1;
            delete(h)
            cutOffF1Setup = 'y';
        else
            return
        end
    else
        if(flagtypeFilter~=1)
            h = impoint(FourierSpec);
            pos=getPosition(h);
            x_f1 = pos(1);
            set(btn_F1,'String',strcat('F1=',num2str(x_f1)))
            handles.F1 = x_f1;
            delete(h)
            cutOffF1Setup = 'y';
        else
            return
        end
    end
else
    msgbox('Setup the filter type and display the spectrum before trying to set the cut-off frequency.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SET THE SECOND CUT FREQUENCY VALUE F2
function F2_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);
flagtypeFilter = handles.flagtypeFilter;

if(filterTypeSetup=='y' && specsDisplayed=='y')
    if(flagtypeFilter~=1)
        F1 = handles.F1;
        h = impoint(FourierSpec);
        pos= getPosition(h);
        x_f2 = pos(1);
        
        if(abs(x_f2)<abs(F1))
            delete(h)
            msgbox('The absolute value of F2 must be greater than the absolute value of F1!','Warn','warn','modal')
            h = impoint(FourierSpec);
            pos= getPosition(h);
            x_f2 = pos(1);
        end
        
        set(btn_F2,'String',strcat('F2=',num2str(x_f2)))
        handles.F2 = x_f2;
        delete(h)
        cutOffF2Setup = 'y';
    else
        return
    end
else
    msgbox('Setup the filter type and display the spectrum before trying to set the cut-off frequency.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SHOW THE BUTTERWORTH FILTER AMPLITUDE
function plotFilter_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(filterTypeSetup=='y')
    flagtypeFilter = handles.flagtypeFilter;
    Zg = handles.Zg;
    Z = handles.Z;
    minKx = handles.minKx;
    maxKx = handles.maxKx;
    minKy = handles.minKy;
    maxKy = handles.maxKy;
    
    O = str2double(get(O_,'String'));
    
    if(cutOffF1Setup == 'y' && cutOffF2Setup == 'y')
        F1 = handles.F1;
        F2 = handles.F2;
    elseif(cutOffF1Setup == 'y')
        F1 = handles.F1;
    else
        return
    end
    
    if(flagtypeFilter==2)
        [filteredData,kernel] = butterworth2D(Zg,F1,NaN,O,25,'lp');
        [rows,cols] = size(kernel);
        kernel_1d = kernel(round(rows/2)+1,:);
        
        x_1d = linspace(minKx,maxKx,length(kernel_1d));
        axes(Filter)
        plot(x_1d,kernel_1d,'r','LineWidth',1.5)
        hold on
        axes(FourierSpec);xl=xlim;yl=ylim;
        axes(Filter)
        set(Filter,'ylim',[yl(1) yl(2)])
        set(Filter,'xlim',[xl(1) xl(2)])
        plot([F1 F1],[yl(1) yl(2)],'k:','LineWidth',1.5)
        plot([-F1 -F1],[yl(1) yl(2)],'k:','LineWidth',1.5)
        hold off
        set(Filter,'XGrid','on')
        set(Filter,'YGrid','on')
        title('LOW PASS FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Filter Amplitude')
        
        x = linspace(minKx,maxKx,cols);
        y = linspace(minKy,maxKy,rows);
        [Xg,Yg] = meshgrid(x,y);
        axes(Filter2D)
        pcolor(Xg,Yg,kernel)
        shading interp
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
        title('2D LOW PASS FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('ky (2\pi rad/m)')
    elseif(flagtypeFilter==3)
        [filteredData,kernel] = butterworth2D(Zg,F1,NaN,O,25,'hp');
        [rows,cols] = size(kernel);
        kernel_1d = kernel(round(rows/2)+1,:);
        
        x_1d = linspace(minKx,maxKx,length(kernel_1d));
        axes(Filter)
        plot(x_1d,kernel_1d,'r','LineWidth',1.5);
        hold on
        axes(FourierSpec);xl=xlim;yl=ylim;
        axes(Filter)
        set(Filter,'ylim',[yl(1) yl(2)])
        set(Filter,'xlim',[xl(1) xl(2)])
        plot([F1 F1],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([-F1 -F1],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        hold off
        set(Filter,'XGrid','on')
        set(Filter,'YGrid','on')
        axis([min(x_1d(:)) max(x_1d(:)) -0.05 max(kernel_1d(:))*1.1])
        title('HIGH PASS FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Filter Amplitude')
        
        x = linspace(minKx,maxKx,cols);
        y = linspace(minKy,maxKy,rows);
        [Xg,Yg] = meshgrid(x,y);
        axes(Filter2D)
        pcolor(Xg,Yg,kernel)
        shading interp
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
        title('2D HIGH PASS FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('ky (2\pi rad/m)')
    elseif(flagtypeFilter==4)
        [filteredData,kernel] = butterworth2D(Zg,F1,F2,O,25,'bp');
        [rows,cols] = size(kernel);
        kernel_1d = kernel(round(rows/2)+1,:);
        
        x_1d = linspace(minKx,maxKx,length(kernel_1d));
        axes(Filter)
        plot(x_1d,kernel_1d,'r','LineWidth',1.5);
        hold on
        axes(FourierSpec);xl=xlim;yl=ylim;
        axes(Filter)
        set(Filter,'ylim',[yl(1) yl(2)])
        set(Filter,'xlim',[xl(1) xl(2)])
        plot([F1 F1],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([F2 F2],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([-F1 -F1],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([-F2 -F2],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        hold off
        set(Filter,'XGrid','on')
        set(Filter,'YGrid','on')
        axis([min(x_1d(:)) max(x_1d(:)) -0.05 max(kernel_1d(:))*1.1])
        title('BAND PASS FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Filter Amplitude')
        
        x = linspace(minKx,maxKx,cols);
        y = linspace(minKy,maxKy,rows);
        [Xg,Yg] = meshgrid(x,y);
        axes(Filter2D)
        pcolor(Xg,Yg,kernel)
        shading interp
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
        title('2D BAND PASS FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('ky (2\pi rad/m)')
    elseif(flagtypeFilter==5)
        [filteredData,kernel] = butterworth2D(Zg,F1,F2,O,25,'bs');
        [rows,cols] = size(kernel);
        kernel_1d = kernel(round(rows/2)+1,:);
        
        x_1d = linspace(minKx,maxKx,length(kernel_1d));
        axes(Filter)
        plot(x_1d,kernel_1d,'r','LineWidth',1.5);
        hold on
        axes(FourierSpec);xl=xlim;yl=ylim;
        axes(Filter)
        set(Filter,'ylim',[yl(1) yl(2)])
        set(Filter,'xlim',[xl(1) xl(2)])
        plot([F1 F1],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([F2 F2],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([-F1 -F1],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        plot([-F2 -F2],[-0.05 max(kernel_1d(:))*1.1],'k:','LineWidth',1.5)
        hold off
        set(Filter,'XGrid','on')
        set(Filter,'YGrid','on')
        axis([min(x_1d(:)) max(x_1d(:)) -0.05 max(kernel_1d(:))*1.1])
        title('BAND STOP FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Filter Amplitude')
        
        x = linspace(minKx,maxKx,cols);
        y = linspace(minKy,maxKy,rows);
        [Xg,Yg] = meshgrid(x,y);
        axes(Filter2D)
        pcolor(Xg,Yg,kernel)
        shading interp
        cmapChanged = colormaps(Z,'clra','linear');
        colormap(cmapChanged)
        title('2D BAND STOP FILTER')
        xlabel('kx (2\pi rad/m)')
        ylabel('ky (2\pi rad/m)')
    else
        return
    end
    
    filterApplied = 'y';
    handles.filteredData = filteredData;
    handles.kernel = kernel;
else
    msgbox('Setup the filter type and cut-off frequency/ies before trying to display the Butterworth filter.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%CHANGE THE Y AXIS SCALE OF PROFILE GRAPHS
function changeYAxis_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(dataLoaded=='y')
    Zg = handles.Zg;
    [Zg_prepared] = padding2D(Zg,3,25,1,'y');
    
    % Create the wavenumber space
    [F1,~] = freqspace(size(Zg_prepared),'meshgrid');
    kx=((2*pi*(length(F1)/2)/(length(F1)-1))*F1); kx(kx==0)=0.0000000000000001;
    
    FFT = fftshift(fft2(Zg_prepared));
    [rows,~] = size(FFT);
    if(mod(rows,2))
        FFT_1D = abs(FFT(round(rows/2),:));
        X_1D = kx(round(rows/2),:);
    else
        FFT_1D = abs(FFT(round(rows/2)+1,:));
        X_1D = kx(round(rows/2)+1,:);
    end
    maxF = max(FFT_1D);
    FFT_1D_norm = abs(FFT_1D./maxF);
    
    if(get(popupYScale,'Value')==1)
        axes(FourierSpec)
        plot(X_1D,FFT_1D_norm,'b-','LineWidth',1.5)
        title('1D FOURIER SPECTRUM [HORIZONTAL WAVENUMBER DIRECTION]')
        set(FourierSpec,'XGrid','on')
        set(FourierSpec,'YGrid','on')
        axis([min(X_1D(:)) max(X_1D(:)) min(FFT_1D_norm(:))-min(FFT_1D_norm(:))*0.1 max(FFT_1D_norm(:))*1.1])
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Spectrum Magnitude')
    else
        axes(FourierSpec)
        plot(X_1D,FFT_1D_norm,'b-','LineWidth',1.5)
        title('1D FOURIER SPECTRUM [HORIZONTAL WAVENUMBER DIRECTION]')
        set(FourierSpec,'XGrid','on')
        set(FourierSpec,'YGrid','on')
        set(gca,'YScale','log')
        axis([min(X_1D(:)) max(X_1D(:)) min(FFT_1D_norm(:))-min(FFT_1D_norm(:))*0.1 max(FFT_1D_norm(:))*1.1])
        xlabel('kx (2\pi rad/m)')
        ylabel('Normalized Spectrum Magnitude')
    end
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SAVE WORKSPACE AS IMAGE
function exportWorkspaceAsImage_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(filterApplied=='y' && specsDisplayed == 'y')
    FFT2D = handles.FFT2D;
    
    [FileName,PathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'},'Save Image...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    format_=get(imageFileFormat,'String');
    imageF = char(strcat('-d',format_(get(imageFileFormat,'Value'))));
    dpi_ = strcat('-r',get(DPI_,'String'));
    fName = strsplit(FileName,'.');
    ImagePath = char(strcat(PathName,fName(1)));
    
    fig = figure('Position',[0,0,1030,734],'Visible','off');
    graph_handle = findobj(graphPanel,'type','axes');
    
    copyobj(graph_handle,fig);
    
    graph_handle_ = findobj(fig,'type','axes');
    
    [row,col]=size(FFT2D);
    cmapChanged = colormaps(reshape(FFT2D,[row*col,1]),'clra','linear');
    colormap(graph_handle_(1),cmapChanged)
    colormap(graph_handle_(2),cmapChanged)
    colormap(graph_handle_(3),cmapChanged)
    colormap(graph_handle_(4),cmapChanged)
    
    print(fig,ImagePath,imageF,dpi_)
    delete(fig)
    
    msgbox('Map Exported.','Warn','warn','modal')
else
    msgbox('Fill up the workspace ploting both spectrum and filter representations before trying to export an image.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%PERFORM THE FILTERING
function performFiltering_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);

if(filterApplied=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    Zg_=handles.filteredData;
    
    d = get(popupDist,'Value');
    c = get(coordConvertion,'Value');
    [fig1,fig2]=generateResultFigures(650,700,Xg,Yg,Zg,Zg_,d,d,'clra','clra',c);
    
    %link the axes of the result figures
    h_1=zoom(fig1); set(h_1,'ActionPostCallback',@linkAxes)
    h_2=zoom(fig2); set(h_2,'ActionPostCallback',@linkAxes)
    p_1=pan(fig1); set(p_1,'ActionPostCallback',@linkAxes)
    p_2=pan(fig2); set(p_2,'ActionPostCallback',@linkAxes)
    
    set(fig1,'WindowButtonDownFcn',@mouseButtonD)
    set(fig2,'WindowButtonDownFcn',@mouseButtonD)
    
    handles.Zg_ = Zg_;
else
    msgbox('Apply the filter before trying to save a file.','Warn','warn','modal')
    return
end

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function SaveFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(butterworthFilter_);
X = handles.X;
Y = handles.Y;
inputFile = handles.Zg_;

outputFile = matrix2xyz(X,Y,inputFile);

[FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

fid = fopen(Fullpath,'w+');
fprintf(fid,'%6s %6s %14s\r\n','X','Y','Z');
fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile));
fclose(fid);

%Update de handle structure
guidata(butterworthFilter_,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

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
    if (outX && outY && filterApplied=='y')
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