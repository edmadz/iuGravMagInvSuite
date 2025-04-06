function Zg = inverseInterp(x,y,z,Xg,Yg,lambda,it)
% Gridding with Inverse Interpolation

m = length(x);
[dx,dy] = find_cell_size(Xg,Yg);
Xg_1D = (min(x):dx:max(x))';
Yg_1D = (min(y):dy:max(y))';

[ny,nx] = size(Xg);
n = nx*ny;

b = 2/(dx*dy);   % parametro da eq. (2)

% matriz de interpolacao

% localiza pontos com menor distancia

Xg_1D = [Xg_1D(1) - 100*dx ; Xg_1D ; Xg_1D(end) + 100*dx]; % aumenta artificialmente
Yg_1D = [Yg_1D(1) - 100*dy ; Yg_1D ; Yg_1D(end) + 100*dy]; % o dominio

[vec_ix,dist_x] = knnsearch(Xg_1D,x);
[vec_iy,dist_y] = knnsearch(Yg_1D,y);

dist_x_menos = Xg_1D(vec_ix-1)-x; % distancia dos pontos vizinhos
dist_y_menos = Yg_1D(vec_iy-1)-y;
dist_x_mais  = Xg_1D(vec_ix+1)-x;
dist_y_mais  = Yg_1D(vec_iy+1)-y;

dist_window(:,1) = dist_x_menos.^2 + dist_y_menos.^2;
dist_window(:,2) = dist_x_menos.^2 + dist_y.^2;
dist_window(:,3) = dist_x_menos.^2 + dist_y_mais.^2;
dist_window(:,4) = dist_x.^2 + dist_y_menos.^2;
dist_window(:,5) = dist_x.^2 + dist_y.^2;
dist_window(:,6) = dist_x.^2 + dist_y_mais.^2;
dist_window(:,7) = dist_x_mais.^2 + dist_y_menos.^2;
dist_window(:,8) = dist_x_mais.^2 + dist_y.^2;
dist_window(:,9) = dist_x_mais.^2 + dist_y_mais.^2;

% Calcula a exponencial e divide pela soma, conforme o artigo

dist_window = exp(-b*dist_window);
soma = dist_window*ones(9,1);

for j = 1:9
  dist_window(:,j) = dist_window(:,j)./soma;
end

% encontra os indices correspondentes aos pontos localizados

vec_ix = vec_ix - 1;
vec_iy = vec_iy - 1;

ind_window(:,5) = (vec_ix-1)*ny + vec_iy;
ind_window(:,2) = ind_window(:,5) - ny;
ind_window(:,1) = ind_window(:,2) - 1;
ind_window(:,3) = ind_window(:,2) + 1;
ind_window(:,4) = ind_window(:,5) - 1;
ind_window(:,6) = ind_window(:,5) + 1;
ind_window(:,8) = ind_window(:,5) + ny;
ind_window(:,7) = ind_window(:,8) - 1;
ind_window(:,9) = ind_window(:,8) + 1;

% corta indices fora de [1,n+1]

ind_window = ind_window.*(ind_window>=1).*(ind_window<=n);

% passa os indices cortados para n+1

ind_window = ind_window + (n+1).*(ind_window==0);

% monta a matriz (o "for" a seguir e' vetorizavel ?)

ind_row = repmat((1:m)',1,9);

%idx = sub2ind([m,n+1], reshape(ind_row,m*9,1),reshape(ind_window,m*9,1));

%L = spalloc(m,n+1,length(idx));

L = sparse(reshape(ind_row,m*9,1),reshape(ind_window,m*9,1),reshape(dist_window,m*9,1),m,n+1);
  
%L(idx) = reshape(dist_window,m*9,1);
L = L(:,1:n); % corta a coluna n+1

if(isnan(lambda))
    m = gcnr_theta(L,z,it,1e-8,nx,ny);
else
    m = gcnr_lambda(L,z,it,1e-8,nx,ny,lambda);
end

Zg = reshape(m,ny,nx);

end