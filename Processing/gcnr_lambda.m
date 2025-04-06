% GCNR - metodo de gradientes conjugados p/ equacoes normais
% Criterio de parada baseado na norma do residuo relativo

function x=gcnr_lambda(A,b,it_max,tol,nx,ny,lambda)

[N,M] = size(A); % Dimensoes do problema
x = zeros(M,1);

fac = 1; % fator de ponderacao entre as 
         % regularizacoes no interior e na fronteira

e = ones(M,1);
L = spdiags(fac*[e,e,-4*e,e,e],[-ny,-1,0,1,ny],M,M);
L(1,:)=0; L(M,:) = 0; L(ny,:)=0; L(M-ny+1,:) = 0;
  
for jy = 2:ny-1
  jx = 1;
  i = (jx-1)*ny + jy;
  L(i,:) = 0;
  L(i,i+1) = 1;
  L(i,i) = -2;
  L(i,i-1) = 1;
  jx = nx;
  i = (jx-1)*ny + jy;
  L(i,:) = 0;
  L(i,i+1) = 1;
  L(i,i) = -2;
  L(i,i-1) = 1;
end

for jx = 2:nx-1
  jy = 1;
  i = (jx-1)*ny + jy;
  L(i,:) = 0;
  L(i,i+ny) = 1;
  L(i,i) = -2;
  L(i,i-ny) = 1;
  jy = ny;
  i = (jx-1)*ny + jy;
  L(i,:) = 0;
  L(i,i+ny) = 1;
  L(i,i) = -2;
  L(i,i-ny) = 1;
end

tol = tol*norm(A'*b); 

r   = [b - A*x;lambda*L*x];
z0  = A'*r(1:N) + lambda*L'*r(N+1:end);
p   = z0;
zz0 = z0'*z0;

for i=1:it_max
  w    = [A*p;lambda*L*p];
  alfa = zz0/(w'*w); 
  x    = x + alfa*p;  
  r    = r - alfa*w; 
  z    = A'*r(1:N) + lambda*L'*r(N+1:end);
  zz   = z'*z;
  beta = zz/zz0;
  p    = z + beta*p;  
  
  if( sqrt(zz) < tol)
    disp(['Numero de iteracoes: ',num2str(i)]);
    break;
  end
  
  z0 = z;
  zz0 = zz;
end

disp(['Norma do residuo do sistema linear: ',num2str( sqrt(zz)/norm(A'*b) )]);
