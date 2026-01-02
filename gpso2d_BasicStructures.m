%Safety clear
clear('options','opfun','data','model');
%THIS OPTIONS CAN BE CONFIGURED BY THE USER BUT WE CONSIDER THAT THEIR VALUES
%ARE GOOD FOR THE GRAVITY INVERSION PROBLEM AND WE HAVE MOVED HERE FROM
%gpso2d_Inversion.m IN ORDER TO SIMPLIFY THE MAIN INVERSION SCRIPT
%
%Use initial models uniformly distributed at the begining of the inversion
%0/1 -> no/yes, mandatory
uniform_distributed_initial_models = 1;
%Percentage of the swarm which will be considered as prior models. This
%percentage leads to a number of models (the best fitted from the initial swarm)
%that will be introduced in the swarm each prior_niter iterations. If this
%option is no desired, set 0. If a number >=0 is introduced, at least 1 model is
%used. This option will be taken into account only if
%uniform_distributed_initial_models~=0
prior_models = 2;
%Number of iterations for the introduction in the swarm the prior models
prior_niter = 5;
%Factor for multiplying the filter window coefficients for the rectangles
%corresponding to absolute constraints via borehole information
factor_fixed_depth = 3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OPTIONS STRUCTURE DEFAULT CONFIGURATIONS
%Control of the time step: 'lime', 'rand', 'randp', 'randc' (mandatory)
deltat_option = 'rand';
%Number of iterations to change deltat from 'deltat1lime' to 'deltat2lime' if
%deltat_option='lime' was selected (optional)
iterlime = 5;
%Time steps for lime and sand option (optional values)
deltat1lime = 0.7;
deltat2lime = 1.3;
%Initial population generation (can be also 'given')
%'given' is automatically set if uniform_distributed_initial_models=1
options.inversion.seed = 'random';
%Parameters for sampling: 0/1 -> non log/log
%If option 1 is choosen, the model and the search space must be positive
options.inversion.modellog = 0;
%Delta control of coordinates: 0/1 -> no/yes
options.pso.ccontrol = 0;
%Deltat for control
options.pso.cdelta = 0.5;
%Kind of projection over search space for points outside the search bounds:
%'near' (nearest limit), 'far' (farthest limit), 'bounce'
options.pso.proyection = 'near';
%
options.pso.elitism = 0;
%OPFUN STRUCTURE DEFAULT CONFIGURATIONS
%Control of the time step: 'lime', 'rand', 'randp', 'randc'
opfun.deltat_option = 'rand';
%Minumum and maximum time step for deltat_option='rand', 'randp' or 'randc'
%For delta values >1 the algorithm becomes more explorative, for values <1 the
%algorithm becomes more exploitative (mandatory values)
opfun.deltatmin = 0.7;
opfun.deltatmax = 1.2;
%For lime and sand
opfun.delta1 = 0.7;
opfun.delta2 = 1.3;
%Number of iterations for change to deltat2 if opfun.deltat_option = 'lime'
opfun.niter = 3;
%Relative dispersion for collapse control and deltat for this case disp<rdisp_cc
opfun.rdisp_cc = 5;
opfun.deltat_cc = 1.5;
%Prior model. DO NOT MODIFY HERE THIS VARIABLES!!!!!
opfun.prior.model = [];
opfun.prior.niter = 0;
%Extra header for additional data printing on screen: filtered models dispersion
opfun.extra_header = ' Dismk_f Int_modl_f';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CHECK FOR THE EXISTENCE AND KIND OF MANDATORY USER CONFIGURATION VARIABLES
%PSO family member
if exist('pso_family_member','var')~=1
    error('The variable ''pso_family_member'' is not defined');
end
%Swarm size
if (exist('swarm_size','var')~=1)||(isscalar(swarm_size)==0)||...
   ((swarm_size~=round(swarm_size))||(swarm_size<=0))
    error(['The variable ''swarm_size'' is not defined or is not a natural ',...
           'number']);
end
%Iterations number
if (exist('iterations_number','var')~=1)||(isscalar(iterations_number)==0)||...
   ((iterations_number~=round(iterations_number))||(iterations_number<=0))
    error(['The variable ''iterations_number'' is not defined or is not a ',...
           'natural number']);
end
%Use weights
if (exist('use_weights','var')~=1)||(isscalar(use_weights)==0)||...
   (use_weights~=round(use_weights))
    error('The variable ''use_weights'' is not defined or is not an integer');
end
%Use points on sediments only
if (exist('only_points_on_sediments','var')~=1)||...
   (isscalar(only_points_on_sediments)==0)||...
   (only_points_on_sediments~=round(only_points_on_sediments))
    error(['The variable ''only_points_on_sediments'' is not defined or is ',...
           'not an integer']);
end
%Regional trend identifier
if (exist('regional_trend','var')~=1)||(isscalar(regional_trend)==0)
    error('The variable ''regional_trend'' is not defined or is not a scalar');
end
%Filtering identifier
if (exist('use_filter','var')~=1)||(isscalar(use_filter)==0)
    error('The variable ''use_filter'' is not defined or is not a scalar');
end
%Filter size
if (exist('filter_size','var')~=1)||(isvector(filter_size)==0)
    error(['The variable ''filter_size'' is not defined or is not a scalar ',...
           'nor a vector']);
end
%Filter weights
if (exist('filter_weight_width','var')~=1)||(isscalar(filter_weight_width)==0)
    error(['The variable ''filter_weight_width'' is not defined or is not ',...
           'a scalar']);
end
%Depth factors
if (exist('depth_factors','var')~=1)||(isvector(depth_factors)==0)||...
   (isvector(depth_factors)&&(length(depth_factors)<3))
    error('The variable ''depth_factors'' is not defined or is not a ',...
          'three-element or four-element vector');
end
%Search space strict identifier
if (exist('search_space_strict','var')~=1)||(isscalar(search_space_strict)==0)
    error(['The variable ''search_space_strict'' is not defined or is not ',...
           'a scalar']);
end
%Kind of data to store in file
if (exist('file_precision','var')~=1)||(isscalar(file_precision)==0)||...
   ((file_precision~=32)&&(file_precision~=64))
    error(['The variable ''file_precision'' is not defined or has ',...
           'other value than 32 or 64']);
end
%Uniform distributed models
if (exist('uniform_distributed_initial_models','var')~=1)||...
   (isscalar(uniform_distributed_initial_models)==0)||...
 (uniform_distributed_initial_models~=round(uniform_distributed_initial_models))
    error(['The variable ''uniform_distributed_initial_models'' is not ',...
           'defined or is not an integer']);
end
%prior_models
if (exist('prior_models','var')~=1)||(isscalar(prior_models)==0)
    error('The variable ''prior_models'' is not defined');
end
%prior_niter
if (exist('prior_niter','var')~=1)||(isscalar(prior_niter)==0)||...
   (prior_niter~=round(prior_niter))
    error('The variable ''prior_niter'' is not defined');
end
%factor_fixed_depth
if (exist('factor_fixed_depth','var')~=1)||(isscalar(factor_fixed_depth)==0)
    error('The variable ''factor_fixed_depth'' is not defined');
end
%Deltat option
if exist('deltat_option','var')~=1
    error('The variable ''deltat_option'' is not defined');
end
%Deltat values
if exist('deltat','var')~=1
    error('The variable ''deltat'' is not defined');
end
if (isvector(deltat)~=1)||(length(deltat)<2)
    error('The variable ''deltat'' is not a vector');
end
%Norm
if (exist('norm_cost_function','var')~=1)||...
   (isscalar(norm_cost_function)==0)||...
   (norm_cost_function~=round(norm_cost_function))||(norm_cost_function<=0)
    error(['The variable ''norm_cost_function'' is not defined or is not a ',...
           'natural number']);
end
%Prefix for the output files
if (exist('prefix_output','var')~=1)||(ischar(prefix_output)==0)
    error('The variable ''prefix_output'' is not defined or is not a string');
end
%Output folder
if exist('folder_output','var')~=1
    error('The variable ''folder_output'' is not defined');
else
    %Check if the folder exists
    if exist(folder_output,'dir')~=7
        fprintf(2,['Warning: The folder %s does not exist. It will be ',...
                   'created\n'],folder_output);
        mkdir(folder_output);
    end
end
%Observations file
if (exist('observations_file','var')~=1)||(exist(observations_file,'file')~=2)
    error(['The variable ''observations_file'' is not defined or the path ',...
           'provided is not a data file']);
end
%Subsoil file
if (exist('subsoil_file','var')~=1)||(exist(subsoil_file,'file')~=2)
    error(['The variable ''subsoil_file'' is not defined or the path ',...
           'provided is not a data file']);
end
%Density file
if (exist('density_file','var')~=1)||(exist(density_file,'file')~=2)
    error(['The variable ''density_file'' is not defined or the path ',...
           'provided is not a data file']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSO family member to use
pso_family_member = upper(pso_family_member);
if (strcmp(pso_family_member,'CC')~=0)||(strcmp(pso_family_member,'CP')~=0)||...
   (strcmp(pso_family_member,'PC')~=0)||(strcmp(pso_family_member,'PP')~=0)||...
   (strcmp(pso_family_member,'PR')~=0)||(strcmp(pso_family_member,'RC')~=0)||...
   (strcmp(pso_family_member,'RP')~=0)||(strcmp(pso_family_member,'RR')~=0)||...
   (strcmp(pso_family_member,'RN')~=0)||(strcmp(pso_family_member,'PSO')~=0)
    %Code assignation
    options.pso.esquema = pso_family_member;
else
    error('Unknown ''pso_family_member'' value (%s)',pso_family_member);
end
%Prefix for output files and output folder
data.output.prefix = prefix_output;
data.output.folder = folder_output;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INVERSION OPTIONS
options.pso.size = swarm_size;
options.pso.maxiter = iterations_number;
opfun.depth_factors = depth_factors;
opfun.norm_cost_function = norm_cost_function;
opfun.file_precision = file_precision;
opfun.only_points_on_sediments = only_points_on_sediments;
if uniform_distributed_initial_models~=0
    options.inversion.seed = 'given';
end
if exist('subprism_size','var')==1
    if isscalar(subprism_size)==0
        error('The variable ''subprism_size'' must be a scalar');
    else
        opfun.subprism_size = subprism_size;
    end
else
    opfun.subprism_size = 0;
end
opfun.deltatmin = deltat(1);
opfun.deltatmax = deltat(2);
if prior_niter>0
    opfun.prior.niter = prior_niter;
else
    opfun.prior.niter = 0;
end
deltat_option = lower(deltat_option);
if (strcmp(deltat_option,'lime')~=0)||(strcmp(deltat_option,'rand')~=0)||...
   (strcmp(deltat_option,'randp')~=0)||(strcmp(deltat_option,'randc')~=0)
    opfun.deltat_option = deltat_option;
else
    error('Uknown ''deltat_option'' value');
end
if (strcmp(deltat_option,'lime')~=0)&&(exist('iterlime','var')==1)
    if isscalar(iterlime)&&(iterlime==round(iterlime))&&(iterlime>0)
        opfun.niter = iterlime;
    else
        error('The option ''iterlime'' must be a natural number');
    end
elseif (strcmp(deltat_option,'lime')~=0)&&(exist('iterlime','var')~=1)
    error('The variable ''iterlime'' must be defined as deltat_option=lime');
end
if (strcmp(deltat_option,'lime')~=0)&&...
   (exist('deltat1lime','var')==1)&&(exist('deltat2lime','var')==1)
    if isscalar(deltat1lime)&&isscalar(deltat2lime)
        opfun.delta1 = deltat1lime;
        opfun.delta2 = deltat2lime;
    else
        error(['The variables ''deltat1lime'' and ''deltat2lime'' must be ',...
               'scalars']);
    end
elseif (strcmp(deltat_option,'lime')~=0)&&...
       ((exist('deltat1lime','var')~=1)||(exist('deltat2lime','var')~=1))
    error(['The variables ''deltat1lime'' and ''deltat1lime'' must be ',...
           'defined due to deltat_option=lime']);
end
if prior_models>0.0
    prior_models = ceil(prior_models*options.pso.size/100.0);
    if prior_models>options.pso.size
        prior_models = options.pso.size;
    end
else
    prior_models = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DATA FILES
%Load observations file
data.obs.observations_file = observations_file;
gravity = load(data.obs.observations_file);
data.obs.use_weights = use_weights;
if ((data.obs.use_weights==0)&&(size(gravity,2)<4))||...
   ((data.obs.use_weights~=0)&&(size(gravity,2)<5))
    error('The file %s does not contain enough columns',...
          data.obs.observations_file);
end
%Number of gravity data
data.obs.ng = size(gravity,1)-1;
grav_col = size(gravity,2);
%Check if the file contains standard deviations information
has_sd = gravity(1,2);
if has_sd==0
    row_sd = 0;
    row_os = 4;
else
    if grav_col==4
        error(['Bad format in %s'],data.obs.observations_file);
    end
    has_sd = 1;
    row_sd = 4;
    row_os = 5;
end
%Check if the file contains (x,y) coordinates
has_xy = gravity(1,3);
%Loading observations
data.obs.f_to_SI = gravity(1,1);
data.obs.lh = gravity(2:end,1:2);
data.obs.gSI = gravity(2:end,3)*data.obs.f_to_SI;
if has_sd==0
    data.obs.sd_gSI = [];
    data.obs.weights = ones(data.obs.ng,1);
    if data.obs.use_weights~=0
        fprintf(2,['Warning: Variable ''use_weights'' is set to 1 but %s ',...
                   'does not contain standard deviation data. All weights ',...
                   'are set to 1\n'],data.obs.observations_file);
    end
else
    if data.obs.use_weights==0
        data.obs.sd_gSI = [];
        data.obs.weights = ones(data.obs.ng,1);
    else
        data.obs.sd_gSI = gravity(2:end,row_sd)*data.obs.f_to_SI;
        if sum(data.obs.sd_gSI==0.0)~=0
            error(['There is at leat one observation with standard ',...
                   'deviation equals 0.0 in %s'],data.obs.observations_file);
        end
        data.obs.weights = 1.0./(data.obs.sd_gSI.^2);
        data.obs.weights = data.obs.weights./max(data.obs.weights);
    end
end
data.obs.ps = logical(gravity(2:end,row_os));
if has_xy&&has_sd
    data.obs.xy = gravity(2:end,8:9);
elseif has_xy&&(~has_sd)
    data.obs.xy = gravity(2:end,7:8);
else
    data.obs.xy = [];
end
%-------------------------------------------------------------------------------
%Load initial subsoil file
data.subsoil.subsoil_file = subsoil_file;
subsoil = load(data.subsoil.subsoil_file);
%Loading data
data.subsoil.l = subsoil(:,1:2);
data.subsoil.htop = subsoil(:,3);
data.subsoil.hbot0 = subsoil(:,4);
data.subsoil.np = length(data.subsoil.l);
%Prisms' center coordinates
data.subsoil.lc = mean(data.subsoil.l')';
%(x,y) coordinates of prisms' centers
if has_xy
    %Distance from the first observation to all prism center
    dpc = data.subsoil.lc-data.obs.lh(1,1);
    %Azimuth of the profile
    aci = mod(atan2(data.obs.xy(end,1)-data.obs.xy(1,1),...
                    data.obs.xy(end,2)-data.obs.xy(1,2)),2.0*pi);
    %Coordinates of the projected rectangles centers
    data.subsoil.xy = [data.obs.xy(1,1)+dpc*sin(aci) ...
                       data.obs.xy(1,2)+dpc*cos(aci)];
else
     data.subsoil.xy = [];
end
%-------------------------------------------------------------------------------
%Density configuration
data.density.density_file = density_file;
if exist('h_density_file','var')==1
    if exist(h_density_file,'file')==2
        data.density.h_density_file = h_density_file;
        data.density.use_h_density_file = 1;
    else
        error(['The value stored in ''h_density_file'' is not a data file\n',...
               'If you do not want to use horizontal density definition ',...
               'you must comment the line containing this variable']);
    end
else
    data.density.h_density_file = '';
    data.density.use_h_density_file = 0;
end
%Loading data
if data.density.use_h_density_file~=0
    [data.density.def_rho,...
     data.density.def_h_rho] = gpso2d_LoadDensity(data.density.density_file,...
                                                  data.density.h_density_file);
    if sum(data.density.def_h_rho.id==0)~=0
        error('The file %s must not contain a segment with ID=0\n',...
              data.density.h_density_file);
    end
else
    data.density.def_rho = gpso2d_LoadDensity(data.density.density_file);
end
%Check if does not exist 0 id for density definition
if data.density.def_rho.id(1)~=0
    error('The first density definition in %s must have the ID 0\n',...
          data.density.density_file);
end
%Loop through each prism
for i=1:data.subsoil.np
    %Prism center
    pc = data.subsoil.lc(i);
    %Check if there are horizontal variation definitions
    if data.density.use_h_density_file~=0
        %Loop through the horizontal density segments
        for j=1:length(data.density.def_h_rho.id)
            %Check if the prism center lies inside the segment
            if (pc>data.density.def_h_rho.zones(j,1))&&...
               (pc<data.density.def_h_rho.zones(j,2))
                data.subsoil.density.rho_id(i) = data.density.def_h_rho.id(j);
                pos = find(data.density.def_rho.id==...
                           data.subsoil.density.rho_id(i));
                if length(pos)~=1
                    error(['The file %s have identifiers (%d) not defined ',...
                           'in %s which are needed to known'],...
                          data.density.h_density_file,...
                          data.subsoil.density.rho_id(i),...
                          data.density.density_file);
                end
                data.subsoil.density.rho{i} = data.density.def_rho.rho{pos};
                break;
            else
                data.subsoil.density.rho_id(i) = 0;
                data.subsoil.density.rho{i} = data.density.def_rho.rho{1};
            end
        end
    else
        data.subsoil.density.rho_id(i) = 0;
        data.subsoil.density.rho{i} = data.density.def_rho.rho{1};
    end
end
%-------------------------------------------------------------------------------
%Initial regional trend
if exist('trend_file','var')==1
    if exist(trend_file,'file')==2
        data.trend.trend_file = trend_file;
        data.trend.use_trend_file = 1;
    else
        error(['The value stored in ''trend_file'' is not a data file\n',...
               'If you do not want to use regional trend definition you ',...
               'must comment the line containing this variable']);
    end
    if regional_trend~=0
        data.trend.regional_trend = 1;
    else
        data.trend.regional_trend = 0;
    end
else
    data.trend.trend_file = '';
    data.trend.use_trend_file = 0;
    data.trend.regional_trend = 0;
    if regional_trend==1
        error(['The variable ''regional_trend'' is set to 1, but there is ',...
              'not a file defined in ''trend_file''']);
    end
end
%Loading data
if data.trend.use_trend_file~=0
    trend = load(data.trend.trend_file);
    if size(trend,1)<4
        error('The file\n%s\nmust have at least 4 rows',data.trend.trend_file);
    end
    if trend(1,1)==0.0
        error('The scale factor to convert into SI units in\n%s\nis zero',...
              data.trend.trend_file);
    end
    %Data extraction
    data.trend.polynomial_degree = size(trend,2)-1;
    data.trend.f_to_SI = trend(1,1);
    data.trend.l0 = trend(2,1);
    data.trend.coefficients = trend(3,:);
    data.trend.sd_coefficients = abs(trend(4,:));
    data.trend.trend0 = polyval(data.trend.coefficients,...
                                data.obs.lh(:,1)-data.trend.l0);
end
%-------------------------------------------------------------------------------
%Search limits
if exist('search_space_file','var')==1
    if exist(search_space_file,'file')==2
        %Load file
        search_space_f = load(search_space_file);
        if size(search_space_f,2)<3
            error(['The data stored in ''search_space_file'' has not ',...
                   'enough columns']);
        end
        %Upper and lower limits (row vectors)
        data.subsoil.hbot_max = interp1(search_space_f(:,1),...
                                        search_space_f(:,2),data.subsoil.lc,...
                                        'linear','extrap');
        data.subsoil.hbot_min = interp1(search_space_f(:,1),...
                                        search_space_f(:,3),data.subsoil.lc,...
                                        'linear','extrap');
    else
        error('The variable ''search_space_file'' is not a data file');
    end
else
    %Check the king of search bound construction
    if (length(opfun.depth_factors)==3)||(opfun.depth_factors(4)<=0.0)
        %Depth factors application
        prism_depth = data.subsoil.htop-data.subsoil.hbot0;
        data.subsoil.hbot_max = data.subsoil.htop-...
                                prism_depth*opfun.depth_factors(1);
        data.subsoil.hbot_min = data.subsoil.htop-...
                                prism_depth*opfun.depth_factors(2);
        %Check if minimum width must be used
        if opfun.depth_factors(3)>0.0
            %Computed depths
            computed_depths = abs(data.subsoil.hbot_max-data.subsoil.hbot_min);
            %Loop over all values
            for i=1:data.subsoil.np
                %If computed detph is smaller than the minimum
                if computed_depths(i)<opfun.depth_factors(3)
                    %Add the minimum width
                    data.subsoil.hbot_max(i) = data.subsoil.hbot0(i)+...
                                               opfun.depth_factors(3)/2.0;
                    data.subsoil.hbot_min(i) = data.subsoil.hbot0(i)-...
                                               opfun.depth_factors(3)/2.0;
                end
            end
        end
    else
        %Attraction of the initial model
        rect = [data.subsoil.l data.subsoil.hbot0 data.subsoil.htop ...
                ones(data.subsoil.np,1)*opfun.subprism_size];
        grav = gpso2d_GravityComputation(rect,data.subsoil.density.rho,...
                                         data.obs.lh);
        %Residuals (without regional trend if applicable)
        if data.trend.use_trend_file~=0
            grav = data.trend.trend0*data.trend.f_to_SI+grav;
        end
        residuals = (data.obs.gSI-grav)./data.obs.f_to_SI;
        %Refer residuals to its median
        median_residual = median(residuals);
        residuals = residuals-median_residual;
        max_residual = max(abs(residuals));
        %Relative weight of each redidual referred to the maximum value
        residuals = residuals./max_residual;
        %Relative residual referred to each rectangle
        residuals_r = interp1(data.obs.lh(:,1),residuals,data.subsoil.lc);
        %Bottom limits
        data.subsoil.hbot_max = zeros(data.subsoil.np,1);
        data.subsoil.hbot_min = zeros(data.subsoil.np,1);
        %Loop over all rectangles
        for i=1:data.subsoil.np
            %Check if there is information about residual
            if ~isnan(residuals_r(i))
                %Initial value based on the relative residuals
                initial_delta = opfun.depth_factors(4)*residuals_r(i);
                %Minimum delta value
                if opfun.depth_factors(3)>0.0
                    min_delta = opfun.depth_factors(3)/2.0;
                else
                    min_delta = opfun.depth_factors(4)/2.0;
                end
                %Check the magnitude
                if abs(initial_delta)<min_delta
                    delta_max = min_delta;
                    delta_min = -delta_max;
                else
                    if initial_delta>=0.0
                        delta_max = initial_delta;
                        delta_min = -min_delta;
                    else
                        delta_max = min_delta;
                        delta_min = initial_delta;
                    end
                end
            else
                %Set the values of the third element
                delta_max = opfun.depth_factors(3)/2.0;
                delta_min = -delta_max;
            end
            %Set the limits
            data.subsoil.hbot_max(i) = data.subsoil.hbot0(i)+delta_max;
            data.subsoil.hbot_min(i) = data.subsoil.hbot0(i)+delta_min;
        end
    end
    %Check if the search space must be strict
    if search_space_strict
        %Possible rectangles with search space outside the upper limit
        pos = data.subsoil.hbot_max>data.subsoil.htop;
        data.subsoil.hbot_max(pos) = data.subsoil.htop(pos);
        pos = data.subsoil.hbot_min>data.subsoil.htop;
        data.subsoil.hbot_min(pos) = data.subsoil.htop(pos);
    end
end
%Identifiers for fixed depth: 0/1/2 -> no/minimum depth/maximum depth
data.subsoil.fixed_depth = zeros(data.subsoil.np,1);
data.subsoil.fixed_depth_f = ones(data.subsoil.np,1);
%Positions of contiguous prisms
data.subsoil.contiguous = [1 1];
pos = 1;
for i=2:data.subsoil.np
    if data.subsoil.l(i,1)==data.subsoil.l(i-1,2)
        data.subsoil.contiguous(pos,2) = i;
    else
        pos = pos+1;
        data.subsoil.contiguous(pos,:) = [i i];
    end
end
%Weights for possible width-weighted filtering
data.subsoil.filter_weight = data.subsoil.l(:,2)-data.subsoil.l(:,1);
ml = max(data.subsoil.filter_weight);
data.subsoil.filter_weight = data.subsoil.filter_weight/ml;
%-------------------------------------------------------------------------------
%Density configuration for the bottom limit of the search space
data.subsoil.density.rho_hbot = {};
for i=1:length(data.subsoil.density.rho)
    %Rectangle definition
    rect = [data.subsoil.l(i,1) data.subsoil.l(i,2) ...
            data.subsoil.hbot_min(i) data.subsoil.htop(i)];
    %Rectangle corresponding to the highest depth division
    div = gpso2d_DivideRectangle(rect,data.subsoil.density.rho{i},...
                                 opfun.subprism_size);
    %Add to the density configuration cell
    data.subsoil.density.rho_hbot{i} = [div(:,3) div(:,5)];
end
%-------------------------------------------------------------------------------
%Filter configuration
if exist('filter_file','var')==1
    if exist(filter_file,'file')==2
        data.filt.filter_file = filter_file;
        data.filt.use_filter_file = 1;
        data.filt.use_filter = 0;
    else
        error(['The value stored in ''filter_file'' is not a data file\n',...
               'If you do not want to use filtering you must comment the ',...
               'line containing this variable']);
    end
    if use_filter>0
        for i=1:length(filter_size)
            if (rem(filter_size(i),2)==0)||(filter_size(i)==1)
                if length(filter_size)==1
                    error('''filter_size'' must be an odd>1 number');
                else
                    error('Elements in ''filter_size'' must be odd>1 numbers');
                end
            end
        end
        data.filt.use_filter = use_filter;
        data.filt.filter_size = filter_size;
    else
        data.filt.filter_size = 0;
    end
    if filter_weight_width~=0
        data.filt.filter_weight_width = filter_weight_width;
    else
        data.filt.filter_weight_width = 0;
    end
else
    data.filt.filter_file = '';
    data.filt.use_filter_file = 0;
    if use_filter>0
        error('The variable ''use_filter'' is set to >0, but there is not ',...
              'a file defined in ''filter_file''');
    end
    data.filt.filter_size = 0;
    data.filt.filter_weight_width = 0;
end
%Loading data
if data.filt.use_filter_file~=0
    %We assume the file has only one file or column
    filter_coef = load(data.filt.filter_file);
    filter_coef = filter_coef(:)';
    nd = length(filter_coef);
    if rem(nd,2)==0
        error('The file %s must contain an odd number of data',...
              data.filt.filter_file);
    end
    for i=1:length(data.filt.filter_size)
        if data.filt.filter_size(i)>nd
            if length(data.filt.filter_size)==1
                error(['The value selected in ''filter_size'' is greater ',...
                       'than the number of data in %s'],data.filt.filter_file);
            else
                error(['The value selected in position %d of ',...
                       '''filter_size'' is greater than the number of data ',...
                       'in %s'],data.filt.filter_file);
            end
        end
    end
    %Central position in the file and size from it for the filter size
    cpf = floor(nd/2)+1;
    %Extracting filter coefficients
    data.filt.filter_coef = {};
    for i=1:length(data.filt.filter_size)
        sfs = floor(data.filt.filter_size(i)/2);
        data.filt.filter_coef{i} = filter_coef(1,cpf-sfs:cpf+sfs);
    end
else
    data.filt.filter_coef = [];
end
%-------------------------------------------------------------------------------
%borehole information
if exist('boreholes_file','var')==1
    if exist(boreholes_file,'file')==2
        data.borehole.boreholes_file = boreholes_file;
        data.borehole.use_boreholes_file = 1;
    else
        error(['The value stored in ''boreholes_file'' is not a data file\n',...
               'If you do not want to use borehole information you must ',...
               'comment the line containing this variable']);
    end
else
    data.borehole.boreholes_file = '';
    data.borehole.use_boreholes_file = 0;
end
%Loading data
if data.borehole.use_boreholes_file~=0
    borehole = load(data.borehole.boreholes_file);
    if size(borehole,2)<4
        error('The file\n%s\nmust have at least 4 columns',...
              data.borehole.boreholes_file);
    end
    %Check if the boreholes are lengths or coordinates
    if size(borehole,2)==4
        %Loading data
        data.borehole.l = borehole(:,1:2);
        data.borehole.depth_min = borehole(:,3);
        data.borehole.depth_max = borehole(:,4);
        data.borehole.nb = size(data.borehole.l,1);
    else
        %Check if we have planar coordinates
        if ~has_xy
            error(['The boreholes in\n%s\nare defined by planar ',...
                   'coordinates, but the file\n%s\ndoes not contain (X,Y) ',...
                   'values'],data.borehole.boreholes_file,...
                   data.obs.observations_file);
        end
        %Length matrices
        data.borehole.l = [];
        %Slope of profile
        m = (data.obs.xy(end,2)-data.obs.xy(1,2))/...
            (data.obs.xy(end,1)-data.obs.xy(1,1));
        %Y at the origin
        y0 = data.obs.xy(1,2)-m*data.obs.xy(1,1);
        %Loop over all boreholes
        for i=1:size(borehole,1)
            %If slope is too small, the profile is parallel to Y axis
            if abs(m)<1.0e-8
                %Parameters of the second degree equation
                a = 1.0;
                b = -2.0*borehole(i,2);
                c = (data.obs.xy(1,1)-borehole(i,1))^2+borehole(i,2)^2-...
                    borehole(i,3)^2;
            else
                %Parameters of the second degree equation
                a = (1.0+m^2);
                b = 2.0*(m*y0-m*borehole(i,2)-borehole(i,1));
                c = borehole(i,1)^2+y0^2-2.0*y0*borehole(i,2)+...
                    borehole(i,2)^2-borehole(i,3)^2;
            end
            %Square root arument
            sqa = b^2-4.0*a*c;
            %Check if the value is negative
            if sqa<0.0
                %Next iteration
                continue;
            else
                %X coordinates of the intersections
                x1 = (-b+sqrt(sqa))/(2.0*a);
                x2 = (-b-sqrt(sqa))/(2.0*a);
                %Y coordinates of the intersections
                y1 = m*x1+y0;
                y2 = m*x2+y0;
                %Lengths from the profile first point
                l1 = norm([x1-data.obs.xy(1,1) y1-data.obs.xy(1,2)]);
                l2 = norm([x2-data.obs.xy(1,1) y2-data.obs.xy(1,2)]);
                %Add the limits
                data.borehole.l = [data.borehole.l;sort([l1 l2])];
            end
        end
        %Check if there are boregoles
        if isempty(data.borehole.l)
            fprintf(2,['Warning: The boreholes in file\n%s\ndo not affect ',...
                       'the profile. They will not be used\n'],...
                       data.borehole.boreholes_file);
            data.borehole.boreholes_file = '';
            data.borehole.use_boreholes_file = 0;
        else
            %Loading data
            data.borehole.depth_min = borehole(:,4);
            data.borehole.depth_max = borehole(:,5);
            data.borehole.nb = size(data.borehole.l,1);
        end
    end
end
if data.borehole.use_boreholes_file~=0
    %Boreholes segments centers
    data.borehole.lc = mean(data.borehole.l')';
    %Rectangle where the center of borehole is
    data.borehole.rectangle = NaN(data.borehole.nb,2);
    data.borehole.rectangle(:,1) = data.borehole.lc;
    %Loop through all boreholes
    for i=1:data.borehole.nb
        %Center and extreme coordinates
        lc = data.borehole.lc(i);
        ll = data.borehole.l(i,1);
        lr = data.borehole.l(i,2);
        %Loop through all prisms
        for j=1:data.subsoil.np
            %Check if the borehole's center coordinate is inside the prism
            if (lc>=data.subsoil.l(j,1))&&(lc<=data.subsoil.l(j,2))
                %Check the minimum depth
                if isnan(data.borehole.depth_min(i))
                    error('The element (%d, %d) of %s cannot be NaN',...
                          i,1,data.borehole.boreholes_file);
                else
                    data.subsoil.hbot_max(j) = data.subsoil.htop(j)-...
                                               data.borehole.depth_min(i);
                    data.subsoil.fixed_depth(j) = 1;
                    data.borehole.rectangle(i,2) = j;
                end
                %Check the maximum depth
                if ~isnan(data.borehole.depth_max(i))
                    data.subsoil.hbot_min(j) = data.subsoil.htop(j)-...
                                               data.borehole.depth_max(i);
                    data.subsoil.fixed_depth(j) = 2;
                end
            else
                %Prism width
                pw = data.subsoil.l(j,2)-data.subsoil.l(j,1);
                %Check if part of the borehole's influence is outside the prism
                if (data.subsoil.l(j,1)>=lr)||(data.subsoil.l(j,2)<=ll)
                    continue;
                end
                %Initial segment part
                if data.subsoil.l(j,1)<=ll
                    dist1 = ll;
                else
                    dist1 = data.subsoil.l(j,1);
                end
                %Final segment part
                if data.subsoil.l(j,2)>=lr
                    dist2 = lr;
                else
                    dist2 = data.subsoil.l(j,2);
                end
                %Check the affected amount of the prism width
                if (dist2-dist1)>=(pw/3.0)
                    %It is not needed to check NaN for the minimum depth here
                    data.subsoil.hbot_max(j) = data.subsoil.htop(j)-...
                                               data.borehole.depth_min(i);
                    data.subsoil.fixed_depth(j) = 1;
                    %Check the maximum depth
                    if ~isnan(data.borehole.depth_max(i))
                        data.subsoil.hbot_min(j) = data.subsoil.htop(j)-...
                                                   data.borehole.depth_max(i);
                        data.subsoil.fixed_depth(j) = 2;
                    end
                end
            end
        end
    end
end
%Assign values to the fixed_depth vector for filtering
data.subsoil.fixed_depth_f(data.subsoil.fixed_depth~=2) = 0;
data.subsoil.fixed_depth_f(data.subsoil.fixed_depth==2) = 1;
%Factor to modify the filter coefficients
data.subsoil.factor_fixed_depth = factor_fixed_depth;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Output structure as an empty variable
results = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set the search limits (must be row vectors)
model.lowlimit = data.subsoil.hbot_min';
model.upperlimit = data.subsoil.hbot_max';
if data.trend.regional_trend~=0
    model.lowlimit = [model.lowlimit ...
                      data.trend.coefficients-data.trend.sd_coefficients];
    model.upperlimit = [model.upperlimit ...
                        data.trend.coefficients+data.trend.sd_coefficients];
end
%Set initial models, if they were configured (must be row vector)
model.initial = [];
if strcmp(lower(options.inversion.seed),'given')
    %Uniformly distributed models between the limits
    model.initial = zeros(options.pso.size,length(model.lowlimit));
    for i=1:length(model.lowlimit)
        model.initial(:,i) = linspace(model.lowlimit(i),model.upperlimit(i),...
                                      options.pso.size)';
    end
    %Number of models and prisms
    nmp = size(model.initial,2);
    nsp = length(data.subsoil.hbot_max);
    %The regional trend parameters are assigned randomly in order to minimize
    %the bias in the subsoil models
    if data.trend.regional_trend~=0
        %Number of trend parameters
        ntp = nmp-nsp;
        %Set trend values
        model.initial(:,nsp+1:nmp) = repmat(data.trend.coefficients,...
                                            options.pso.size,1);
        %Perturbation of the trend parameters
        atp = repmat(data.trend.sd_coefficients,options.pso.size,1).*...
              randn(options.pso.size,ntp);
        model.initial(:,nsp+1:nmp) = model.initial(:,nsp+1:nmp)+atp;
        %Regional trend computation using the given trend coefficients
        grav_trend = data.trend.trend0*data.trend.f_to_SI;
    else
        grav_trend = 0.0;
    end
    %Check if prior model is needed
    if (uniform_distributed_initial_models~=0)&&...
       (prior_models>0)&&(opfun.prior.niter>0)
        %Generation of the common part for the subsoil model
        rect = [data.subsoil.l zeros(data.subsoil.np,1) data.subsoil.htop ...
                ones(data.subsoil.np,1)*opfun.subprism_size];
        %Cost function
        costf = zeros(options.pso.size,1);
        %Loop over all models
        for i=1:options.pso.size
            %Subsoil model
            rect(:,3) = model.initial(i,1:nsp)';
            %Gravity computation
            grav = gpso2d_GravityComputation(rect,data.subsoil.density.rho,...
                                             data.obs.lh);
            %Residuals
            residuals = data.obs.gSI-grav-grav_trend;
            %Cost function, always unweighted
            costf(i) = norm(residuals,opfun.norm_cost_function)/...
                       norm(data.obs.gSI-grav_trend,...
                            opfun.norm_cost_function)*100.0;
        end
        %Sort the misfits
        [costf,posC] = sort(costf);
        %Assign the reference models
        opfun.prior.model = model.initial(posC(1:prior_models),1:nsp);
        if data.trend.regional_trend~=0
            opfun.prior.model =[opfun.prior.model ...
                                repmat(data.trend.coefficients,prior_models,1)];
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READING THE PARTICLE CLOUDS
options.pso.cloud='yes';
if options.pso.cloud=='yes'
    %Select the cloud
    if strcmp(options.pso.esquema,'PSO')~=0
        fprintf(1,'Loading cloud_PSO.mat\n');
        load('cloud_PSO.mat');
    elseif strcmp(options.pso.esquema,'CP')~=0
        fprintf(1,'Loading cloud_CP.mat\n');
        load('cloud_CP.mat');
    elseif strcmp(options.pso.esquema,'CC')~=0
        fprintf(1,'Loading cloud_CC.mat\n');
        load('cloud_CC.mat');
    elseif strcmp(options.pso.esquema,'PP')~=0
        fprintf(1,'Loading cloud_PP.mat\n');
        load('cloud_PP.mat');
    elseif strcmp(options.pso.esquema,'RR')~=0
        fprintf(1,'Loading cloud_RR.mat\n');
        load('cloud_RR.mat');
    elseif strcmp(options.pso.esquema,'RC')~=0
        fprintf(1,'Loading cloud_RC.mat\n');
        load('cloud_RC.mat');
    elseif strcmp(options.pso.esquema,'RP')~=0
        fprintf(1,'Loading cloud_RP.mat\n');
        load('cloud_RP.mat');
    elseif strcmp(options.pso.esquema,'PR')~=0
        fprintf(1,'Loading cloud_PR.mat\n');
        load('cloud_PR.mat');
    elseif (strcmp(options.pso.esquema,'PC')~=0)||...
           (strcmp(options.pso.esquema,'RN')~=0)
        fprintf(1,'Loading cloud_PC.mat (same file for PC and RN)\n');
        load('cloud_PC.mat');
    else
        error('Unknown PSO family member');
    end
    %Loading the cloud permuting randomly the rows
    %First column is w, second al, and third ag
    prow = randperm(size(w_al_ag,1))';
    w_al_ag = w_al_ag(prow,:);
    %Charging the options structure
    if strcmp(options.pso.esquema,'PSO')~=0
        options.pso.pso.inertia=w_al_ag(:,1)';
        options.pso.pso.philocal=w_al_ag(:,2)';
        options.pso.pso.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'CP')~=0
        options.pso.cp.inertia=w_al_ag(:,1)';
        options.pso.cp.philocal=w_al_ag(:,2)';
        options.pso.cp.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'CC')~=0
        options.pso.cc.inertia=w_al_ag(:,1)';
        options.pso.cc.philocal=w_al_ag(:,2)';
        options.pso.cc.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'PP')~=0
        options.pso.pp.inertia=w_al_ag(:,1)';
        options.pso.pp.philocal=w_al_ag(:,2)';
        options.pso.pp.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'RR')~=0
        options.pso.rr.inertia=w_al_ag(:,1)';
        options.pso.rr.philocal=w_al_ag(:,2)';
        options.pso.rr.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'RC')~=0
        options.pso.rc.inertia=w_al_ag(:,1)';
        options.pso.rc.philocal=w_al_ag(:,2)';
        options.pso.rc.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'RP')~=0
        options.pso.rp.inertia=w_al_ag(:,1)';
        options.pso.rp.philocal=w_al_ag(:,2)';
        options.pso.rp.phiglobal=w_al_ag(:,3)';
    elseif strcmp(options.pso.esquema,'PR')~=0
        options.pso.pr.inertia=w_al_ag(:,1)';
        options.pso.pr.philocal=w_al_ag(:,2)';
        options.pso.pr.phiglobal=w_al_ag(:,3)';
    elseif (strcmp(options.pso.esquema,'PC')~=0)||...
           (strcmp(options.pso.esquema,'RN')~=0)
        options.pso.pc.inertia=w_al_ag(:,1)';
        options.pso.pc.philocal=w_al_ag(:,2)';
        options.pso.pc.phiglobal=w_al_ag(:,3)';
    else
        error('Unknown PSO family member');
    end
end
