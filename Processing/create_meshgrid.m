function [Xg,Yg] = create_meshgrid(X,Y)

max_X = max(X);min_X = min(X);
max_Y = max(Y);min_Y = min(Y);

%VERIFICA SE A COLUNA DOS X OU DOS Y VARIA PRIMEIRO
if(X(2)~=X(1)) %X VARIA PRIMEIRO
    k=find(logical(diff(Y)));
    col=min(k);
    row=length(Y)/col;
else           %Y VARIA PRIMEIRO
    k=find(logical(diff(X)));
    row=min(k);
    col=length(Y)/row;
end

%Cria um linspace
vetorX = linspace(min_X,max_X,col);
vetorY = linspace(min_Y,max_Y,row);

[Xg,Yg]=meshgrid(vetorX,vetorY);

end