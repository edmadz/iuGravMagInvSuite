function GUIclassSeparationEulerDeconv

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 1360;
height = 768;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUIclassSeparationEulerDeconv_ = figure('Menubar','none',...
    'Name','Separate Euler Solutions in Depth Classes',...
    'NumberTitle','off',...
    'NextPlot','add',...
    'units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'Visible','off',...
    'Tag','GMS',...
    'Resize','off');

%--------------------------------------------------------------------------

inputParametersPanel = uipanel(GUIclassSeparationEulerDeconv_,...
    'Units','normalized',...
    'position',[0.014 0.02 0.2 0.96]);

NumberOfClasses = uicontrol(inputParametersPanel,'Style','edit',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Number of classes.',...
    'position',[0.03 0.915 0.944 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Set Intervals',...
    'fontUnits','normalized',...
    'position',[0.03 0.865 0.944 0.036],...
    'CallBack',@setClassLimits_callBack);

classLimitsTable=uitable(inputParametersPanel,...
    'Units','normalized',...
    'Data',[],...
    'fontSize',12,...
    'RowStriping','off',...
    'ColumnEditable',true,...
    'position',[0.03 0.265 0.944 0.5],...
    'ColumnName',{'Zo','Zf'});

ClassToBeSaved = uicontrol(inputParametersPanel,'Style','edit',...
    'Units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'TooltipString','Class to be saved.',...
    'position',[0.03 0.115 0.16 0.036]);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Filter Class',...
    'fontUnits','normalized',...
    'position',[0.21 0.115 0.765 0.036],...
    'CallBack',@generateClasses_callBack);

uicontrol(inputParametersPanel,'Style','pushbutton',...
    'Units','normalized',...
    'String','Save Class',...
    'fontUnits','normalized',...
    'position',[0.03 0.065 0.944 0.036],...
    'CallBack',@Save_callBack);

%--------------------------------------------------------------------------
boxPlotPanel = uipanel(GUIclassSeparationEulerDeconv_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.02 0.76 0.3]);

graphBoxplot = axes(boxPlotPanel,'Units','normalized',...
    'position',[0.07 0.25 0.88 0.55]);
set(graphBoxplot.XAxis,'Visible','off');
set(graphBoxplot.YAxis,'Visible','off');

graphPanel = uipanel(GUIclassSeparationEulerDeconv_,...
    'Units','normalized',...
    'BackgroundColor','white',...
    'position',[0.23 0.34 0.76 0.64]);

graphHist = axes(graphPanel,'Units','normalized',...
    'position',[0.07 0.12 0.88 0.8]);
set(graphHist.XAxis,'Visible','off');
set(graphHist.YAxis,'Visible','off');
%--------------------------------------------------------------------------
%MENU
%--------------------------------------------------------------------------

file = uimenu(GUIclassSeparationEulerDeconv_,'label','File');
uimenu(file,'Label','Open Euler Solutions...','Accelerator','O','CallBack',@openFile_callBack);

controlFile = uimenu(GUIclassSeparationEulerDeconv_,'label','Control File');
uimenu(controlFile,'Label','Load depth limits control file...','Accelerator','L','CallBack',@loadControlFile_callBack);
uimenu(controlFile,'Label','Save depth limits control file...','Accelerator','S','CallBack',@saveControlFile_callBack);

dataLoaded = 'n';
classLimitsGenerated = 'n';
classesGenerated = 'n';
i__=1;
set(GUIclassSeparationEulerDeconv_,'Visible','on')
%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN EULER SOLUTIONS DATA
function openFile_callBack(hObject,callbackdata,handles)
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
    [~,colData] = size(dado);
    if(colData==3)
        EulerSolutions_x0 = dado(1:end-8,1);
        EulerSolutions_y0 = dado(1:end-8,2);
        EulerSolutions_z0 = dado(1:end-8,3);
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
    if(colData==3)
        EulerSolutions_x0 = dado(1:end-8,1);
        EulerSolutions_y0 = dado(1:end-8,2);
        EulerSolutions_z0 = dado(1:end-8,3);
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

set(classLimitsTable,'Data',[])

axes(graphHist)
hist_=histogram(EulerSolutions_z0,50);
xlabel('Depth')
ylabel('Number of depth solutions')
set(hist_,'FaceColor',[.5 .5 .5])
set(graphHist,'FontSize',12)

boxplot(EulerSolutions_z0)

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
handles.hist_ = hist_;
dataLoaded = 'y';
i__=1;
%Update de handle structure
guidata(hObject,handles);
end

%SET THE CLASS LIMITS
function setClassLimits_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded == 'y')
    axes(graphHist)
    lines=findobj(gca,'type','line');
    texts=findobj(gca,'type','text');
    if(~isempty(lines))
        delete(lines)
    end
    if(~isempty(texts))
        delete(texts)
    end
    
    N_ = str2double(get(NumberOfClasses,'String'));
    
    if(N_>0)
        nLimits = N_*2;
        set(classLimitsTable,'Data',[])
        yl = ylim;
        %str = cell([N_,1]);
        for i=1:nLimits
            h = impoint();
            pos = getPosition(h);
            x_(i) = pos(:,1);
            delete(h)
            
            hold on
            plot(graphHist,[x_(i),x_(i)],[0,max(yl)],'--k','LineWidth',2);
            if(~mod(i,2))
                x_text=((x_(i-1)-x_(i))/2)+x_(i);
                yl=ylim(graphHist);
                y_text=yl(2)/2;
                text(x_text,y_text,strcat('CLASS 0',num2str(i/2)),...
                    'HorizontalAlignment','center','Rotation',90,...
                    'FontSize',20)
            end
            hold off
            
            if(~logical(mod(i,2)))
                classLimitsData(i__,1:2) = [x_(i-1), x_(i)];
                set(classLimitsTable,'Data',classLimitsData)
                i__=i__+1;
            end
        end
    else
        msgbox('Provide a non-negative value for class number.','Warn','warn')
        return
    end
    
    handles.classLimitsData = classLimitsData;
    handles.N_ = N_;
    classLimitsGenerated = 'y';
else
    msgbox('Load a data before trying to mark the class limits.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%LOAD DEPTH LIMITS CONTROL FILE
function loadControlFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(dataLoaded=='y')
    [FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select a Control File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return
    end
    
    A = importdata(Fullpath);
    set(classLimitsTable,'Data',A)
    
    handles.N_ = length(A);
    classLimitsGenerated = 'y';
else
    msgbox('Load a dataset before trying to load depth limits control file.','Warn','warn');
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SAVE DEPTH LIMITS CONTROL FILE
function saveControlFile_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(classLimitsGenerated=='y')
    Data = get(classLimitsTable,'Data');
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save the Control File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return
    end
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%6.2f %6.2f\r\n',transpose(Data));
    fclose(fid);
else
    msgbox('Set the classes limits before trying to save a control file.','Warn','warn');
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SEPARATE THE EULER SOLUTIONS IN DEPTH CLASSES BY HISTOGRAM ANALYSIS
function generateClasses_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(classLimitsGenerated == 'y')
    N_ = handles.N_; %number of depth classes
    EulerSolutions_x0 = handles.EulerSolutions_x0;
    EulerSolutions_y0 = handles.EulerSolutions_y0;
    EulerSolutions_z0 = handles.EulerSolutions_z0;
    WS = handles.WS;
    N = handles.N;
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    
    widthArea=maxX-minX;
    heightArea=maxY-minY;
    
    C = str2double(get(ClassToBeSaved,'String'));
    if( (C<1) || (C>N_) )
        msgbox(strcat('Provide a class value >= 1 or <=',num2str(N_)),'Warn','warn')
        return
    end
    
    if(C>0 && C<=N_) %Se o valor fornecido estiver dentro do intervalo de classes
        Data = get(classLimitsTable,'Data');
        minZ_ = Data(C,1);
        maxZ_ = Data(C,2);
        
        subclass_x0 = EulerSolutions_x0;
        subclass_y0 = EulerSolutions_y0;
        subclass_z0 = EulerSolutions_z0;
        
        subclass_x0(EulerSolutions_z0<minZ_)=[];
        subclass_y0(EulerSolutions_z0<minZ_)=[];
        subclass_z0(EulerSolutions_z0<minZ_)=[];
        
        subclass_x0(subclass_z0>maxZ_)=[];
        subclass_y0(subclass_z0>maxZ_)=[];
        subclass_z0(subclass_z0>maxZ_)=[];
    else
        msgbox('The provided value exceeds the number of classes.','Warn','warn');
        return
    end
    
    minZ = min(EulerSolutions_z0(:));
    maxZ = max(EulerSolutions_z0(:));
    
    figWidth__=1000;
    figHeight__=700;
    Pix_SS = get(0,'screensize');
    W = Pix_SS(3);
    H = Pix_SS(4);
    posX_ = W/2 - figWidth__/2;
    posY_ = H/2 - figHeight__/2;
    
    f1=figure('units','pixel','position', [posX_ posY_ figWidth__ figHeight__]);
    scatter3(subclass_x0,subclass_y0,subclass_z0,20,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75]);
    if(min(subclass_z0(:))<max(subclass_z0(:)))
        xlim([minX maxX])
        ylim([minY maxY])
        zlim([minZ maxZ])
    elseif(min(subclass_z0(:))>max(subclass_z0(:)))
        xlim([minX maxX])
        ylim([minY maxY])
        zlim([minZ maxZ])
    end
    ttl = strcat('CLASS 0',num2str(C),' - EULER SOLUTIONS N=',num2str(N),' WINDOW=',num2str(WS),'x',num2str(WS));
    title(ttl)
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
    
    handles.EulerSolutions_x0_class = subclass_x0;
    handles.EulerSolutions_y0_class = subclass_y0;
    handles.EulerSolutions_z0_class = subclass_z0;
    classesGenerated = 'y';
else
    msgbox('Set the class limits before trying to filter the input data.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%SAVE THE CLASSES
function Save_callBack(hObject,callbackdata,handles)
%Retrieve the handle structure
handles = guidata(hObject);

if(classesGenerated == 'y')
    EulerSolutions_x0_class = handles.EulerSolutions_x0_class;
    EulerSolutions_y0_class = handles.EulerSolutions_y0_class;
    inputFile = handles.EulerSolutions_z0_class;
    WS = handles.WS;
    N = handles.N;
    minX = handles.minX;
    maxX = handles.maxX;
    minY = handles.minY;
    maxY = handles.maxY;
    minZ = handles.minZ;
    maxZ = handles.maxZ;
    
    outputFile = matrix2xyz(EulerSolutions_x0_class,EulerSolutions_y0_class,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (Fullpath == 0)
        return
    end
    
    fid = fopen(Fullpath,'w+');
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
else
    msgbox('Generate an Euler Depth Class before trying to save a file.','Warn','warn')
    return
end

%Update de handle structure
guidata(hObject,handles);
end

%--------------------------------------------------------------------------
%LOCAL FUNCTIONS
%--------------------------------------------------------------------------

function boxplot(data)
    %statistic variables
    median_=median(data);
    min_=min(data);
    max_=max(data);
    outLdown_=[];
    outLup_=[];
    Q_1=median(data(data<median_));
    Q_3=median(data(data>median_));
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
    
    %rectangle variables
    rectWidth = IQR;
    rectHeight = 0.5;
    
    axes(graphBoxplot)
    h=findobj(graphBoxplot,'type','line'); delete(h);
    h=findobj(graphBoxplot,'type','rectangle'); delete(h);
    set(graphBoxplot.XAxis,'Visible','on')
    set(graphBoxplot.YAxis,'Visible','on')
    set(gca,'Box','on')
    rectangle('position',[Q_1,0.25,rectWidth,rectHeight],...
        'FaceColor',[.5 .5 .5],'EdgeColor','k'); hold on
    plot([median_,median_],[0.25 0.75],'k-','LineWidth',2)
    plot([WhiskerDown_,Q_1],[0.5,0.5],'k-')
    plot([Q_3,WhiskerUp_],[0.5,0.5],'k-')
    plot([WhiskerDown_,WhiskerDown_],[0.4,0.6],'k-','LineWidth',2)
    plot([WhiskerUp_,WhiskerUp_],[0.4,0.6],'k-','LineWidth',2)
    plot(outLdown_,(0.5)*ones(size(outLdown_)),'d','MarkerEdgeColor','k',...
        'MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',0.5)
    plot(outLup_,(0.5)*ones(size(outLup_)),'d','MarkerEdgeColor','k',...
        'MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',0.5)
    hold off
    xlabel('Depth')
    set(graphBoxplot,'FontSize',12)
    
    axes(graphHist); xl = xlim(gca);
    axes(graphBoxplot)
    xlim(xl)
    ylim([0 1])
    axes(graphHist)
end

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

end