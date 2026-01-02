function g=grav(a,b,h,x,y,teta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adiciona o valor de 0.1% da menor aresta do prisma as coordenadas dos 
% vertices para evitar a singularidade devido a coincidencia de um ponto de 
% campo com o vertice do prisma. Estas linhas podem ser comentadas se o 
% usuario nao desejar esta opcao.
%vi=min([abs(a(2)-a(1)),abs(b(2)-b(1)),abs(h(2)-h(1))]);
%a=a+0.001*vi;
%b=b+0.001*vi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variavel utilizada para troca de sinais.
s(1)=-1;
s(2)=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encontra as coordenadas do centro do prisma e desloca o sistema de
% coordenadas para este centro.

ac=(a(2)+a(1))/2;
bc=(b(2)+b(1))/2;
x=x-ac;
y=y-bc;
a=a-ac;
b=b-bc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aplica a funcao "rotat" que rotaciona o sistema de coordenadas por um
% angulo teta.
[x y]=rotat(x,y,teta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcula a anomalia gravimetrica pela formula (4), de Plouff
% (1976), atraves da funcao 'f' descrita abaixo.

g=f(a,b,h,x,y,1,1,1,s)+f(a,b,h,x,y,1,1,2,s) +f(a,b,h,x,y,1,2,1,s)+...
    f(a,b,h,x,y,1,2,2,s)+f(a,b,h,x,y,2,1,1,s)+f(a,b,h,x,y,2,1,2,s)+...
    f(a,b,h,x,y,2,2,1,s)+f(a,b,h,x,y,2,2,2,s);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função "f" da formula de Plouff (1976).

function f=f(a,b,h,x,y,i,j,k,s)

f=s(i).*s(j)*s(k).*(h(k).*atan(alfa(i,a,x).*betta(j,b,y)./(R(i,j,k,a,b,x,y,h).*h(k)))-...
    alfa(i,a,x).*log( R(i,j,k,a,b,x,y,h)+betta(j,b,y))-betta(j,b,y).*log( R(i,j,k,a,b,x,y,h)+alfa(i,a,x)));

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rotaciona o sistema de coordenadas por um angulo teta.

function [xr yr]=rotat(x,y,teta)

xr=x.*cos(teta)+y.*sin(teta);
yr=-x.*sin(teta)+y.*cos(teta);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcula os valores das distancias utilizadas na funcao "F" da formula de
% Bhaskara Rao & Ramesh Babu (1991) e  da funcao "f" da formula de
% Plouff (1976).

function R=R(i,j,k,a,b,x,y,h)

R=sqrt(alfa(i,a,x).^2+betta(j,b,y).^2+h(k).^2);

return

function alfa=alfa(i,a,x)

alfa=a(i)-x;

return

function betta=betta(i,b,y)

betta=b(i)-y;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

