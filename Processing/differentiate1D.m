function [Dx,Dz] = differentiate1D(X,Z)

I = sqrt(-1);

N = length(X);
a = X(1);
dx = X(2)-X(1);
b = X(N)+dx;

%Extends 
x_esq = X - (b-a);
x_dir = X + (b-a);

% Variavel independente no dominio da frequencia

dkp = 1/(3*(b-a));      % incremento de frequencia
kappa = dkp*((-3*N/2):(3*N/2-1));  % grid da frequencia

% Extensao da funcao f em x_dir e x_esq

df_dir = (Z(N)-Z(N-1))/dx;
f_dir = Z(N) + df_dir*(x_dir-X(N));
f_dir = f_dir - f_dir(N)*(x_dir-X(N)).^2/(x_dir(N)-X(N))^2;
cos_dir = (cos(linspace(0,pi/2,length(f_dir)))).^5;
f_dir = f_dir.*cos_dir;

df_esq = (Z(2)-Z(1))/dx;
f_esq = Z(1) + df_esq*(x_esq-X(1));
f_esq = f_esq - f_esq(1)*(x_esq-X(1)).^2/(x_esq(1)-X(1))^2;
cos_esq = (cos(linspace(pi/2,0,length(f_esq)))).^5;
f_esq = f_esq.*cos_esq;

x_ext = [x_esq,X,x_dir];
f_ext = [f_esq,Z,f_dir];

% Transformada via FFT

F = dx*fft(f_ext);   % resultado no dominio [0,N] = [0,2*kp]
F = fftshift(F);     % redistribui o dominio da freq. para [-kp,kp]
F = F.*exp(-I*2*pi*(2*a-b)*kappa); % corrige com o termo da extremidade 'a' de [a,b]

% Calcula derivada no dominio da frequencia
% Derivada X
dxF = I*(2*pi)*kappa.*F;

% Transformada inversa

dxF = ifftshift(dxF.*exp(I*2*pi*(2*a-b)*kappa)); % corrige e desfaz o shift
Dx = (1/dx)*ifft(dxF);
Dx = real(Dx);

% Derivada Z
dzF = (2*pi)*abs(kappa).*F;

% Transformada inversa

dzF = ifftshift(dzF.*exp(I*2*pi*(2*a-b)*kappa)); % corrige e desfaz o shift
Dz = (1/dx)*ifft(dzF);
Dz = real(Dz);

% Corta a resposta no intervalo [a,b]

b=b-dx;

[aux,i1] = min(abs(x_ext-a));
[aux,i2] = min(abs(x_ext-b));

Dx = Dx(i1:i2);
Dz = Dz(i1:i2);