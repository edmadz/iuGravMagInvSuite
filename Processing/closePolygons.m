function [x_Closed,y_Closed]=closePolygons(x_cell,y_cell,x_gridOutline,y_gridOutline,mean_)

N=length(x_cell);

x_Closed=cell(N,1);
y_Closed=cell(N,1);

for i=1:N
    x_ = cell2mat(x_cell(i));
    x_ = strsplit(x_);
    x_ = str2double(x_);
    
    y_ = cell2mat(y_cell(i));
    y_ = strsplit(y_);
    y_ = str2double(y_);
    
    if(isClosed(x_,y_,mean_))
        x_Closed(i) = {num2str(x_)};
        y_Closed(i) = {num2str(y_)};
    else
        C=cat(2,x_gridOutline,y_gridOutline);
        Coord=cat(2,cat(1,x_(1),x_(end)),cat(1,y_(1),y_(end)));
        IDX = knnsearch(C(:,(1:2)),Coord);
        x__=x_gridOutline(min(IDX):max(IDX));
        y__=y_gridOutline(min(IDX):max(IDX));
        [x_,y_]=polybool('union',x_,y_,x__,y__);
        x_Closed(i) = {num2str(x_)};
        y_Closed(i) = {num2str(y_)};
    end
end