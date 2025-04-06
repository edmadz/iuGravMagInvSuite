function [Mag_,Grav_]=grav_mag_prisma(xo,xf,yo,yf,inc_x,inc_y,D,I,F,ruido_grav,ruido_mag,nomeMag,nomeGrav,varargin)
% MAIN PROGRAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Condicional that executes the program in the Matlab prompt (nargin==0) if
% the user does not provide the input parameters or reads the input
% parameters if they are provided. In the first case the parameters will be
% requested on the prompt.
if nargin==0
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reads the following input parameters: vertical and horizontal span and
    % grid spacing.
    xf=input('Enter the horizontal span of the area (meter): ');
    yf=input('Enter the vertical span of the area (meter): ');
    inc_x=input('Enter the grid spacing for the horizontal direction (meter): ');
    inc_y=input('Enter the grid spacing for the vertical direction (meter): ');
    disp('Warning, a closely spaced grid may oveload the memory:');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reads the following input parameters: Earth magnetic declination
    % and inclination, field intensity, noise amplitude (fro grav and mag)
    % number of prisms and filename.
    D=input('Enter the Magnetic Declination  (Degree): ');
    I=input('Enter the Magnetic Inclination (Degree): ');
    F=input('Digite o valor do Campo Magnetico (nT): ');
    ruido_grav=input('Enter the noise amplitude for the gravimety anomaly (mGal) (0, se nao quer ruido): ');
    ruido_mag=input('Enter the noise amplitude for the magnetic anomaly(nT) (0, se nao quer ruido): ');
    nomeMag=input('Enter the ".xyz" filename where the mag data will be saved: ','s');
    nomeGrav=input('Enter the ".xyz" filename where the grav data will be saved: ','s');
    N=input('How many prisms do you want generate: ');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    % Read the input parameters for the prism(s).
    mpar=cell2mat(varargin);
    tm=size(mpar);
    if tm(1)==1
        vp=varargin; tp=size(vp); N=tp(2);
    else
        for i=1:tm(1)
            vp{i}=mpar(i,:);
        end
        tp=size(vp); N=tp(2);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates the mesh where the field will be calculated.
mx=max(xo:inc_x:xf);
my=max(yo:inc_y:yf);
[y,x]=meshgrid(xo:inc_x:mx,yo:inc_y:my);
% Pre-aolocates the memory for the output data.
Mag_=zeros(size(x));
Grav_=zeros(size(x));
vpar=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert angles e defines constants.
I=deg2rad(I);
D=deg2rad(D);
gama = 6.67428e-11;
ji=(F*1e-9)/(4*pi*1e-7);
cm=1e-7;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over the number of prims. The gravity and magnetic anomalies are
% calculated by the subroutines "mag." e "grav.m".
for i=1:N
% "Switch 0" for reading the parameters on the Matlab prompt or
% "Switch 1" for reading the parameters from a file or vector.
switch nargin
    case 0
        % Reads the data on the prompt.
        xi=input('Susceptibility (SI): ');
        fi=input('Intensity of the remanent magnetization (A/m): ');
        ro=input('Density (kg/m^3): ');
        L=input('Width: ') ;
        C=input('Length: ');
        H=input('Tickness: ');
        bc=input('X coordinate of the prism: ') ;
        ac=input('Y coordinate of the prism: ') ;
        h(1)=input('Depth to the top: ') ;
        teta=input('Azimuth: '); teta=deg2rad(teta);
        % Checks if a non-zero remanent magnetizations is provided.
        % If so, requests the values of the declination (D0) and
        % inclination (I0), else, sets D0=D e I0=I.
        if fi==0
            D0=D;
            I0=I;
        else
            D0=input('Declination of the remanent magnetization (Degree): ');
            D0=deg2rad(D0);
            I0=input('Inclination of the remanent magnetization (Degree): ');
            I0=deg2rad(I0);
        end
    otherwise
        % Reads the data from a vector.
        p=vp{i};
        xi=p(1); fi=p(2); ro=p(3); L=p(4); C=p(5); H=p(6);  bc=p(7);
        ac=p(8); h(1)=p(9); teta=p(10); teta=deg2rad(teta);
        if fi==0
            D0=D;
            I0=I;
        else
            D0=p(11); D0=deg2rad(D0);
            I0=p(12); I0=deg2rad(I0);
        end
end
% Finds the vertices coordinate from the center coordinate, and the
% bottom coordinate from the top ones.
a(1)=ac-C/2;a(2)=ac+C/2;b(1)=bc-L/2;b(2)=bc+L/2; h(2)=h(1)+H;
vpar=[vpar;[b(1) b(2) a(1) a(2) h(1) h(2) teta ac bc]];
% Calculates the induced magnetization.
j0=xi*ji;
% Calculates the total magnetization.
jt=j0+fi;
% Executes the subroutines "mag.m" e "grav.m" with parameters provided
% by the users and adds (N times), if it is the case, the previous
% (in-1 cycle) output.
Mag_=Mag_+cm*jt*mag(a,b,h,x,y,teta,I0,D0,I,D,j0,fi,i);
Grav_=Grav_+(gama*ro)*grav(a,b,h,x,y,teta);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Converts the magnetic anomaly unit to nT and gravity one to mGal.
Mag_=Mag_/1e-9;
Grav_=Grav_/(1e-5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adds gaussian noise to the anomalies (ruido_mag=0 and ruido_grav=0, if
% it was not requested).
Mag_=Mag_+ruido_mag*randn(size(Mag_));
Grav_=Grav_+ruido_grav*randn(size(Grav_));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Converts the data format from grid to vector ([x,y,z]).
% If you want save the data in grid format, do it before the next four lines.
y_v=reshape(y,numel(y),1);
x_v=reshape(x,numel(x),1);
Mag__=reshape(Mag_,numel(Mag_),1);
Grav__=reshape(Grav_,numel(Grav_),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Groups all data sets in a single vector.
Mag__=[y_v x_v Mag__]';
Grav__=[y_v x_v Grav__]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saves data with the filename provided by the user. You can change the
% output resolution changing the values inside the "fprintf" command.
fid = fopen(nomeMag,'wt');
fprintf(fid,'%s\n','X Y mag');
fprintf(fid,'%7.3f %7.3f %14.6f \n',Mag__);
fclose(fid);

% Saves data with the filename provided by the user. You can change the
% output resolution changing the values inside the "fprintf" command.
fid = fopen(nomeGrav,'wt');
fprintf(fid,'%s\n','X Y grav');
fprintf(fid,'%7.3f %7.3f %14.6f \n',Grav__);
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% AUXILIARY FUNCTIONS USED IN THE MAIN PROGRAM.
% Functions "grav.m" and "mag.m" are in separAte files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function rotatv(vr,teta,ac,bc)
        
        % Rotates the prism by theta and puts the prism center in the original
        % position.
        vx=([vr(1) vr(2)].*cos(teta)+[vr(3) vr(4)].*sin(teta))+bc;
        vy=(-[vr(1) vr(2)].*sin(teta)+[vr(3) vr(4)].*cos(teta))+ac;
        % Plots the prism edges.
        line([vx(1) vx(2)],[vy(1) vy(2)],[vr(5) vr(6)],'linewidth',2);
        % Uncomment the next line to plot the edges projection on the  z=0 plane.
        %line([vx(1) vx(2)],[vy(1) vy(2)],'Color','k','LineStyle','--','linewidth',2);
        return
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % Uncomment the lines below when running in OCTAVE.
        % function angle_r = deg2rad (angle_d)
        %
        % if (nargin != 1)
        %     usage("deg2rad (angle_d)");
        %     endif
        %
        %     angle_r = angle_d * (pi/180);
        %
        % endfunction
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
