function [Xq,Yq] = find_cell_size(X,Y)

[row_x,col_x]=size(X);
[row_y,col_y]=size(Y);

X = reshape(X,[(row_x*col_x),1]);
Y = reshape(Y,[(row_y*col_y),1]);

l_x=length(X);
l_y=length(Y);

%Configura a extensão do linspace
for i=1:(l_x-1)
    if X(i)~=X(i+1)
        xq = abs(X(i+1)-X(i));
    end
end

for i=1:(l_y-1)
    if (Y(i)~=Y(i+1))
        yq = abs(Y(i+1)-Y(i));
    end
end

Xq = xq;
Yq = yq;

end