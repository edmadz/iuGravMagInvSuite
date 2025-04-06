% GCNR - metodo de gradientes conjugados p/ equacoes normais
% Criterio de parada baseado na norma do residuo relativo
% Regularizacao de Thikonov (parametro lambda via curva theta)

function x=gcnr_theta2D(A,b,it_max,tol,nx,ny)

[N,M] = size(A); % Dimensoes do problema
tol = tol*norm(A'*b); % tolerancia do residuo relativo

% define parametros

fac = 1; % fator de ponderacao entre as 
         % regularizacoes no interior e na fronteira

it_lambda = min(50,N); % numero de iteracoes do GC no calculo da curva L
lambda_min = 2^-10;    % lambda minimo (lambda inicial)
nlb    = 20; % numero de pontos na curva L
fac_lb = 2;  % fator de atualizacao do lambda (lambda_{i+1}=fac_lb*lambda_i)

% Calcula matriz de regularizacao

e = ones(M,1);
L = spdiags(fac*[e,e,-4*e,e,e],[-ny,-1,0,1,ny],M,M);
L(1,:)=0; L(M,:) = 0; L(ny,:)=0; L(M-ny+1,:) = 0;

% $$$ L = sparse(M,M);
% $$$ for jx = 2:nx-1
% $$$   for jy = 2:ny-1
% $$$     i = (jx-1)*ny + jy;
% $$$     L(i,i) = -4;
% $$$     L(i,i+1) = 1;
% $$$     L(i,i-1) = 1;
% $$$     L(i,i+ny) = 1;
% $$$     L(i,i-ny) = 1;
% $$$   end
% $$$ end

% boundary operator

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

% Primeira rodada: calculo do lambda

lambda = lambda_min;
x = zeros(M,1);

for k = 1:nlb  % resolve sistema via CG para cada lambda
  x = 0*x;
  r   = [b - A*x;lambda*L*x];
  z0  = A'*r(1:N) + lambda*L'*r(N+1:end);
  p   = z0;
  zz0 = z0'*z0;
  i = 0;
  while(i<it_lambda & zz0>tol*tol)
    i = i + 1;
    w    = [A*p;lambda*L*p];
    alfa = zz0/(w'*w); 
    x    = x + alfa*p;  
    r    = r - alfa*w; 
    z    = A'*r(1:N) + lambda*L'*r(N+1:end);
    zz   = z'*z;
    beta = zz/zz0;
    p    = z + beta*p;  
    z0 = z;
    zz0 = zz;
  end
  Logr(k) = log(norm(b-A*x)^2);
  Logx(k) = log(norm(L*x)^2);
  lambda = lambda*fac_lb;
end

%Logr=log(Logr); Logx=log(Logx);

plot(Logr,Logx,'o-'); hold on

dLogr(1:nlb-1) = Logr(2:nlb) - Logr(1:nlb-1);
dLogx(1:nlb-1) = Logx(2:nlb) - Logx(1:nlb-1);

% calcula cossenos de vetores consecutivos, salvando o menor
% OBS: cosseno em VALOR ABSOLUTO via produto escalar

mincos = 1.0;
lambda2 = lambda_min;
for k = 1:nlb-2
  lambda2 = lambda2*fac_lb;
  x1 = dLogr(k); y1 = dLogx(k); x2 = dLogr(k+1); y2 = dLogx(k+1);
  aux = abs(x1*x2+y1*y2)/sqrt((x1*x1+y1*y1)*(x2*x2+y2*y2));
  if(aux<mincos)
    iopt = k;
    mincos = aux;
    lambda = lambda2;
  end
end
plot(Logr(iopt+1),Logx(iopt+1),'ro','MarkerSize',10); hold off
%ylim([min(Logx),Logx(iopt-1)]);
set(gca,'FontSize',14);
title('Curva L (Fig. 5 / Minty)');

disp(['Lambda otimo: ',num2str( lambda )]);

% Segunda rodada: calculo da solucao com o lambda otimo

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
