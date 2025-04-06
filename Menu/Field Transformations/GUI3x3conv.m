function GUI3x3conv

%--------------------------------------------------------------------------
%GRAPHICAL INTERFACE
%--------------------------------------------------------------------------

%Size of the current window
width = 576;
height = 324;
%Centralize the current window at the center of the screen
[posX,posY,Width,Height]=centralizeWindow(width,height);
figposition = [posX,posY,Width,Height];

GUI3x3conv_ = figure('Visible','off',...
    'Name','Convolutional Filters',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'Tag','GMS',...
    'WindowStyle','normal');

uicontrol(GUI3x3conv_,'Style','pushbutton',...
    'units','normalized',...
    'String','Input Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.85 0.2 0.08],...
    'CallBack',@OpenFile_callBack);

inputFile_path = uicontrol(GUI3x3conv_,'Style','edit',...
    'TooltipString','Input data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.85 0.65 0.08]);

%--------------------------------------------------------------------------
popupDist = uicontrol(GUI3x3conv_,'Style','popupmenu',...
    'units','normalized',...
    'Value',1,...
    'String',{'Histogram Equalized','Linear'},...
    'TooltipString','Color Distribution.',...
    'fontUnits','normalized',...
    'position',[0.3 0.725 0.65 0.08]);

popupConvFilterType_ = uicontrol(GUI3x3conv_,'Style','popupmenu',...
    'units','normalized',...
    'Value',2,...
    'String',{'None','Hanning','Laplace','Horizontal Derivative (x)','Horizontal Derivative (y)','Horizontal Derivative (45 deg)'},...
    'fontUnits','normalized',...
    'TooltipString','Filter Type.',...
    'position',[0.3 0.625 0.65 0.08]);

expansion_ = uicontrol(GUI3x3conv_,'Style','edit',...
    'units','normalized',...
    'String','25',...
    'fontUnits','normalized',...
    'TooltipString','Grid expansion (%).',...
    'position',[0.3 0.525 0.65 0.08]);

convFileType_ = uicontrol(GUI3x3conv_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Load an ASCII File','Provide the Filter Parameters'},...
    'fontUnits','normalized',...
    'position',[0.3 0.425 0.32 0.08],...
    'CallBack',@convFileType_callBack);

coordConversion = uicontrol(GUI3x3conv_,'Style','popupmenu',...
    'units','normalized',...
    'String',{'Use Original Units','From m to km','From m to m','From km to m','From km to km'},...
    'fontUnits','normalized',...
    'TooltipString','Convert axis units.',...
    'position',[0.63 0.425 0.32 0.08]);

n_ = uicontrol(GUI3x3conv_,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'TooltipString','Number of passes to apply.',...
    'position',[0.3 0.325 0.32 0.08]);

i_ = uicontrol(GUI3x3conv_,'Style','edit',...
    'units','normalized',...
    'String','1',...
    'fontUnits','normalized',...
    'TooltipString','Multiplier to apply to grid values [for derivative convolutional filters this value must be 1/cell].',...
    'position',[0.63 0.325 0.32 0.08]);

uicontrol(GUI3x3conv_,'Style','pushbutton',...
    'units','normalized',...
    'String','Apply 3x3 Convolutional Filter',...
    'fontUnits','normalized',...
    'position',[0.3 0.225 0.65 0.08],...
    'CallBack',@convFilter3x3_callBack);
%--------------------------------------------------------------------------

uicontrol(GUI3x3conv_,'Style','pushbutton',...
    'units','normalized',...
    'String','Output Data',...
    'fontUnits','normalized',...
    'position',[0.05 0.08 0.2 0.08],...
    'CallBack',@GenerateFile_callBack);

outputFile_path = uicontrol(GUI3x3conv_,'Style','edit',...
    'TooltipString','Output data path.',...
    'units','normalized',...
    'String','',...
    'fontUnits','normalized',...
    'Position',[0.3 0.08 0.65 0.08]);

Cmenu = uicontextmenu(GUI3x3conv_);
set(GUI3x3conv_,'UIContextMenu',Cmenu)
uimenu(Cmenu,'Label','Copy the GUI variables into the MATLAB workspace','Callback',@copy2MATLABworkspace);

dataLoaded = 'n';
filterApplied = 'n';
fpFile = 'n';
editedFP = 'n';
set(GUI3x3conv_,'Visible','on')

%3x3 filter parameters matrix interface
[posX__,posY__,Width__,Height__]=centralizeWindow(324,324);
figposition_=[posX__,posY__,Width__,Height__];

GUI3x3filterParam_ = figure('Visible','off',...
    'Name','3x3 Convolutional Filter Parameters',...
    'NumberTitle','off',...
    'Units','pixel',...
    'position',figposition_,...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize','off',...
    'WindowStyle','modal');

edt_1x1 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(1,1)','position',[0.1 0.8 0.2 0.08]);
edt_1x2 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(1,2)','position',[0.4 0.8 0.2 0.08]);
edt_1x3 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(1,3)','position',[0.7 0.8 0.2 0.08]);
edt_2x1 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(2,1)','position',[0.1 0.6 0.2 0.08]);
edt_2x2 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(2,2)','position',[0.4 0.6 0.2 0.08]);
edt_2x3 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(2,3)','position',[0.7 0.6 0.2 0.08]);
edt_3x1 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(3,1)','position',[0.1 0.4 0.2 0.08]);
edt_3x2 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(3,2)','position',[0.4 0.4 0.2 0.08]);
edt_3x3 = uicontrol(GUI3x3filterParam_,'Style','edit','units','normalized',...
    'fontUnits','normalized','TooltipString','(3,3)','position',[0.7 0.4 0.2 0.08]);
uicontrol(GUI3x3filterParam_,'Style','pushbutton','units','normalized','String','Done',...
    'fontUnits','normalized','position',[0.1 0.2 0.8 0.08],'CallBack',@acceptFP_callBack);

%--------------------------------------------------------------------------
%CALLBACKS
%--------------------------------------------------------------------------

%OPEN THE INPUT DATASET
function OpenFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUI3x3conv_);

[FileName,PathName] = uigetfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Select File...');
Fullpath = [PathName FileName];
if (sum(Fullpath)==0)
    return
end

[X,Y,Z,Xg,Yg,Zg]=OpenFile(Fullpath);

set(inputFile_path,'String',num2str(Fullpath))

handles.Xg = Xg;
handles.Yg = Yg;
handles.Zg = Zg;
handles.X = X;
handles.Y = Y;
handles.Z = Z;
dataLoaded = 'y';
%Update de handle structure
guidata(GUI3x3conv_,handles);
end

%LOAD A FILTER PARAMETERS FILE OR PROVIDE IT BY YOURSELF
function convFileType_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUI3x3conv_);

if(get(convFileType_,'Value')==1)
    set(popupConvFilterType_,'Value',1)
    [FileName,PathName] = uigetfile({'*.dat','Data Files (*.dat)'},'Select File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    fp = importdata(Fullpath);
    if(size(fp)==[3,3])
        handles.fp=fp;
        fpFile = 'y';
    else
        msgbox('Load a valid file for filter parameters.','Warn','warn')
        return
    end
else
    set(popupConvFilterType_,'Value',1)
    set(GUI3x3filterParam_,'Visible','on')
    editedFP = 'y';
end

%Update de handle structure
guidata(GUI3x3conv_,handles);
end

%APPLY A CONVOLUTIONAL FILTER
function convFilter3x3_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUI3x3conv_);

if(dataLoaded=='y')
    Xg = handles.Xg;
    Yg = handles.Yg;
    Zg = handles.Zg;
    
    exp = str2double(get(expansion_,'String'));
    expansion = exp/100;
    n = str2double(get(n_,'String'));
    i=str2double(get(i_,'String'));
    [dx,dy]=find_cell_size(Xg,Yg);
    d = sqrt(dx.^2+dy.^2);
    
    if(((fpFile=='y') || (editedFP=='y')) && (get(popupConvFilterType_,'Value')==1))
        fp = handles.fp;
        Zg_=applyConvFilter(Zg,expansion,fp,n);
        Zg_=Zg_.*i;
    else
        if(get(popupConvFilterType_,'Value')==2)
            fp = [0.06 0.10 0.06;0.10 0.06 0.10;0.06 0.10 0.06];
            Zg_=applyConvFilter(Zg,expansion,fp,n);
        elseif(get(popupConvFilterType_,'Value')==3)
            fp = [0 -0.25 0;-0.25 1 -0.25;0 -0.25 0];
            Zg_=applyConvFilter(Zg,expansion,fp,n);
        elseif(get(popupConvFilterType_,'Value')==4)
            fp = [0 0 0;1 0 -1;0 0 0];
            Zg_=applyConvFilter(Zg,expansion,fp,n);
            Zg_=Zg_./dx;
        elseif(get(popupConvFilterType_,'Value')==5)
            fp = [0 1 0;0 0 0;0 -1 0];
            Zg_=applyConvFilter(Zg,expansion,fp,n);
            Zg_=Zg_./dy;
        else
            fp = [0 1 0;1 0 -1;0 -1 0];
            Zg_=applyConvFilter(Zg,expansion,fp,n);
            Zg_=Zg_./d;
        end
    end
    
    d = get(popupDist,'Value');
    c = get(coordConversion,'Value');
    [fig1,fig2]=generateResultFigures(650,700,Xg,Yg,Zg,Zg_,d,d,'clra','clra',c);
    
    %link the axes of the result figures
    h_1=zoom(fig1); set(h_1,'ActionPostCallback',@linkAxes)
    h_2=zoom(fig2); set(h_2,'ActionPostCallback',@linkAxes)
    
    set(fig1,'WindowButtonDownFcn',@mouseButtonD)
    set(fig2,'WindowButtonDownFcn',@mouseButtonD)
    
    handles.Zg_ = Zg_;
    filterApplied = 'y';
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUI3x3conv_,handles);
end

%FILTER PARAMETERS PROVIDED
function acceptFP_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUI3x3conv_);

fp=filterParam();
handles.fp = fp;

%Update de handle structure
guidata(GUI3x3conv_,handles);
end

%SET THE OUTPUT DATASET PATH AND SAVE
function GenerateFile_callBack(varargin)
%Retrieve the handle structure
handles = guidata(GUI3x3conv_);

if(filterApplied == 'y')
    X = handles.Xg;
    Y = handles.Yg;
    inputFile = handles.Zg_;
    
    outputFile = matrix2xyz(X,Y,inputFile);
    
    [FileName,PathName] = uiputfile({'*.xyz;*.txt;*.dat','Data Files (*.xyz,*.txt,*.dat)'},'Save File...');
    Fullpath = [PathName FileName];
    if (sum(Fullpath)==0)
        return
    end
    
    set(outputFile_path,'String',num2str(Fullpath))
    
    fid = fopen(Fullpath,'w+');
    fprintf(fid,'%6s %6s %14s\r\n','X','Y','H');
    fprintf(fid,'%6.2f %6.2f %12.8e\r\n',transpose(outputFile));
    fclose(fid);
else
    msgbox('Load some data before trying to apply the filter.','Warn','warn')
    return
end

%Update de handle structure
guidata(GUI3x3conv_,handles);
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

function fp=filterParam()
    fp_1x1=str2double(get(edt_1x1,'String'));
    fp_1x2=str2double(get(edt_1x2,'String'));
    fp_1x3=str2double(get(edt_1x3,'String'));
    fp_2x1=str2double(get(edt_2x1,'String'));
    fp_2x2=str2double(get(edt_2x2,'String'));
    fp_2x3=str2double(get(edt_2x3,'String'));
    fp_3x1=str2double(get(edt_3x1,'String'));
    fp_3x2=str2double(get(edt_3x2,'String'));
    fp_3x3=str2double(get(edt_3x3,'String'));
    fp=[fp_1x1,fp_1x2,fp_1x3;fp_2x1,fp_2x2,fp_2x3;fp_3x1,fp_3x2,fp_3x3];
    set(GUI3x3filterParam_,'Visible','off')
end

function out_=applyConvFilter(Zg,expansion,fp,n)
    [nx,ny]=size(Zg);
    [Zg_,cdiff,rdiff] = fillGaps(Zg,1,expansion);
    nanmask=generateNaNmask(Zg);
    
    out=Zg_;
    for i=1:n
        out = conv2(out,fp,'same');
    end
    out = out(1+rdiff:nx+rdiff,1+cdiff:ny+cdiff);
    out_=out.*nanmask;
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