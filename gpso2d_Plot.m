%PSO PLOT SCRIPT
clear('all');
%Load configurations
run('./examples/data/example-f/configuration/plot_configuration.m');
%-------------------------------------------------------------------------------
%OTHER PLOT CONFIGURATIONS
hbin_div_factor = 5; %Small values -> more bins in histograms
title_fsize = 21;
xylabel_fsize = 19;
legend_fsize = 17;
ticks_fsize = 17;
line_width = 2.0;
line_width_cd = 1.0; %Convergence and dispersion plots
line_width_r = 0.75; %Rectangles
point_size = 6;
point_size_cd = 4; %Convergence and dispersion plots
obs_size = 20;
%Symbols and colours for points
obs_symbol = '.';
obs_colour = 'r';
obsn_colour = 'g';
%Colours for the bar plot
basin_colour = 'c';
equiv_colour = 'y';
bounds_colour = 'r--';
ref_colour = 'k';
pos_legend = 'SouthEast'; %best, NorthEast, NorthWest, SouthEast, SouthWest
%Colors in ECDF and histograms for best, mean, median, mode, reference, borehole
colour_models = {'b','m','r','g','k','m--.'};
colour_ecdfh = 'c';
pos_legend_ecdf = 'NorthWest'; %best, NorthEast, NorthWest, SouthEast, SouthWest
%Colours and symbols for misfit and dispersion plots
ltp = {'b^-','rs-','m*-','gd-','co-','bs--','r*--','md--','go--','c^--',...
       'b*-.','rd-.','mo-.','g^-.','cs-.','bd:','ro:','m^:','gs:','c*:'};
%Parameter for searching equivalence region
equivalent_region_tol = 0.001; %In percentage < 100
%Equivalent region range factor to consider models outside the detected region
%A good start value is 2%. If there are few models inside the equivalence
%region, try increasing this number (if high values are used it is possible that
%the histrograms and ECDFs of some rectangles contain values outside the upper
%and lower limits of equivalence region)
range_depth_tol = 2.0; %In percentage < 100
%Units and paper size for pdf or ps figures
paper_units_pdf = 'centimeters';
paper_size_pdf = [21.0 34.0]; %height,width
%Aspect ratio for pdf or ps figures ('-bestfit' or '-fillpage')
aspect_ratio = '-fillpage';
%Modification factor of height for upper window only in model plots
factor_height_upper_window = 3.0/5.0;
%Modification factor of separation for upper and lower windows (except hists)
factor_separation_windows = 0.35;
%Modification factor of separation for upper and lower histograms windows
factor_separation_windows_hists = 0.45;
%Factor for histogram windows height resizedue to the three-line header
factor_height_hists = 0.90;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check if the struct_file variable is correct
if (exist('struct_file','var')~=1)||((ischar(struct_file)==0)&&...
   (iscell(struct_file)==0))
    error(['The variable ''struct_file'' is not defined or is not a string ',...
           'nor a cell array']);
end
%Output folders
ofp = [output_folder,filesep,'plots'];
ofpcdf = [ofp,filesep,'ecdf'];
oft = [output_folder,filesep,'text'];
ofthist = [oft,filesep,'hist'];
if exist('output_folder','var')~=1
    error('The variable ''output_folder'' is not defined');
else
    %Check if the folder exists
    if exist(output_folder,'dir')~=7
        fprintf(2,'***** The folder %s does not exist. It will be created\n',...
                output_folder);
        mkdir(output_folder);
        mkdir(oft);
        if kind_of_information~=0
            mkdir(ofthist);
            mkdir(ofp);
            if kind_of_information>1
                mkdir(ofpcdf);
            end
        end
    end
end
%Check if the subfolder 'text' exists
if exist(oft,'dir')~=7
    fprintf(2,'***** The folder %s does not exist. It will be created\n',oft);
    mkdir(oft);
end
if kind_of_information~=0
    %Check if the subfolder 'plots' exists
    if exist(ofp,'dir')~=7
        fprintf(2,'***** The folder %s does not exist. It will be created\n',...
                ofp);
        mkdir(ofp);
    end
    %Check if the subfolder 'cdf' exists
    if exist(ofthist,'dir')~=7
        fprintf(2,'***** The folder %s does not exist. It will be created\n',...
                ofthist);
        mkdir(ofthist);
    end
    %Check if the subfolder 'plots/cdf' exists
    if kind_of_information>1
        if exist(ofpcdf,'dir')~=7
            fprintf(2,['***** The folder %s does not exist. It will be ',...
                    'created\n'],ofpcdf);
            mkdir(ofpcdf);
        end
    end
end
%Convert the struct_file into a cell array if it is necessary
if ischar(struct_file)
    struct_file = {struct_file};
end
%File loading
nfiles = length(struct_file);
files = {};
for i=1:nfiles
    if exist(struct_file{i},'file')==0
        error('%s is not a file',struct_file{i});
    else
        files{i} = load(struct_file{i});
    end
end
%Reference model
if exist('reference_model','var')==1
    if exist(reference_model,'file')==2
        use_ref_model = 1;
        rmodel = load(reference_model);
        if size(rmodel,2)<2
            error(['The value stored in ''reference_model'' is not a data ',...
                   'file\nIf you do not want to use a reference model you ',...
                   'must comment the line containing this variable']);
        elseif size(rmodel,2)==2
            rmodel = rmodel(:,1:2);
        else
            if isempty(files{1}.gpso2d_results.data.obs.xy)
                error(['The reference model stored in\n%s\nare defined by ',...
                       'planar coordinates, but the profile are defined ',...
                       'only as lengths'],reference_model);
            else
                %Auxiliary matrix
                rmodel_a = rmodel(:,1:3);
                rmodel = rmodel(:,2:3);
                %Unit vector of the observations profile
                x1 = files{1}.gpso2d_results.data.obs.xy(1,1);
                y1 = files{1}.gpso2d_results.data.obs.xy(1,2);
                x2 = files{1}.gpso2d_results.data.obs.xy(end,1);
                y2 = files{1}.gpso2d_results.data.obs.xy(end,2);
                u = [x2-x1 y2-y1];
                u = u./norm(u);
                %Loop over all points
                for i=1:size(rmodel,1)
                    %Vector
                    v = [rmodel_a(i,1)-x1 rmodel_a(i,2)-y1];
                    %Projection onto de profile
                    rmodel(i,1) = v*u';
                end
            end
        end
    else
        error(['The value stored in ''reference_model'' is not a data ',...
               'file\nIf you do not want to use a reference model you must ',...
               'comment the line containing this variable']);
    end
else
    use_ref_model = 0;
    rmodel = [];
end
%Kind of equivalent region identifier
if (exist('kind_of_equiv_region','var')~=1)||(ischar(kind_of_equiv_region)==0)
    error(['The variable ''kind_of_equiv_region'' is not defined or is not ',...
           'a string']);
else
    if (strcmp(upper(kind_of_equiv_region),'BEST')==0)&&...
       (strcmp(upper(kind_of_equiv_region),'REF')==0)&&...
       (strcmp(upper(kind_of_equiv_region),'ALL')==0)
        error(['The value of ''kind_of_equiv_region'' must be ''best'', ',...
               '''ref'' or ''all''']);
    end
    if strcmp(upper(kind_of_equiv_region),'REF')&&(~use_ref_model)
        error(['The value ''ref'' for the variable ',...
               '''kind_of_equiv_region'' must be combined by a reference ',...
               'model stored in ''reference_model''']);
    end
end
%Model plot identifier
if (exist('model_plot','var')~=1)||(ischar(model_plot)==0)
    error('The variable ''model_plot'' is not defined or is not a string');
end
%Family identifier
if nfiles>1
    family_id = 'multiple';
else
    if strcmp(upper(files{1}.gpso2d_results.options.pso.esquema),'PSO')~=0
        family_id = 'GPSO';
    else
        family_id = [files{1}.gpso2d_results.options.pso.esquema,'-PSO'];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SEARCH FOR THE BEST ABSOLUTE MODEL
%best_error      -> scalar (percentage)
%best_model      -> row_vector (absolute heights)
%best_model_obs  -> row vector (observations for best model in working units)
%best_model_f_SI -> scalar (factor to convert best_model_obs into SI units)
%best_trend      -> row_vector (trend values)
%best_model_obst -> row vector (trend values for best model in working units)
%best_trend_l0   -> scalar (L0 for trend computation)
%best_trend_f_SI -> scalar (factor to convert best_model_obst into SI units)
best_error = Inf;
best_trend = [];
best_model_obst = zeros(1,size(files{1}.gpso2d_results.inv_res.obs,2));
have_trend = ~isempty(files{1}.gpso2d_results.inv_res.trend);
for i=1:nfiles
    [mm,pmm] = min(files{i}.gpso2d_results.inv_res.rel_misfit);
    if mm<best_error
        best_error = double(mm);
        best_model = double(files{i}.gpso2d_results.inv_res.model(pmm,:));
        best_model_obs = double(files{i}.gpso2d_results.inv_res.obs(pmm,:));
        best_model_f_SI = double(files{i}.gpso2d_results.inv_res.f_to_SI_obs);
        if have_trend&&(~isempty(files{i}.gpso2d_results.inv_res.trend))
            best_trend = double(files{i}.gpso2d_results.inv_res.trend(pmm,:));
            best_trend_l0 = double(files{i}.gpso2d_results.inv_res.l0_trend);
            best_trend_f_SI = ...
                          double(files{i}.gpso2d_results.inv_res.f_to_SI_trend);
            best_model_obst = ...
                       double(files{i}.gpso2d_results.inv_res.obs_trend(pmm,:));
        elseif (have_trend&&isempty(files{i}.gpso2d_results.inv_res.trend))||...
              ((~have_trend)&&(~isempty(files{i}.gpso2d_results.inv_res.trend)))
            error(['Not all files have regional trend. Files can have or\n',...
                   'not have regional trend, but all must be coherent.\n',...
                   'In this case,\n%s\nis different to the previous files'],...
                  files{i}.gpso2d_results.filename);
        end
    end
end
%Copy the absolute best values
best_error_abs = best_error;
best_model_abs = best_model;
best_model_obs_abs = best_model_obs;
if have_trend
    best_trend_abs = best_trend;
    best_model_obst_abs = best_model_obst;
end
%Number of rectangles and trend parameters
nr = length(best_model);
nt = length(best_trend);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SUBSOIL DEFINTION, OBSERVATIONS AND RELATED VARIABLES
%Subsoil definition
rect = [files{1}.gpso2d_results.data.subsoil.l zeros(nr,1) ...
        files{1}.gpso2d_results.data.subsoil.htop ...
        ones(nr,1)*files{1}.gpso2d_results.opfun.subprism_size];
%Coordinates of the center of prisms in length (row vector)
lc = files{1}.gpso2d_results.data.subsoil.lc';
%Top rectangles depths (row vector)
htop = files{1}.gpso2d_results.data.subsoil.htop';
%Working density and points
rho = files{1}.gpso2d_results.data.subsoil.density.rho;
points = files{1}.gpso2d_results.data.obs.lh;
%Norm of the cost function
ncf = files{1}.gpso2d_results.opfun.norm_cost_function;
%Original observations, in working units (row vector)
orig_obs = files{1}.gpso2d_results.data.obs.gSI'./best_model_f_SI;
%Used weights (row vector)
weights = files{1}.gpso2d_results.data.obs.weights';
if ncf==2
    weights = sqrt(weights);
end
%Observations minus best trend prediction, in working units (row vector)
o_t = double(orig_obs-best_model_obst);
%Used points in cost function computation (row vector)
pos_p = files{1}.gpso2d_results.data.obs.ps';
if ~files{1}.gpso2d_results.opfun.only_points_on_sediments
    pos_p = (pos_p==1)|(pos_p==0);
end
%Observations minus trend and vector norm
o_t_aux = o_t(pos_p).*weights(pos_p);
n_o_t_aux = norm(o_t_aux,ncf);
%Rectangles in the border region(s)
border = [];
if files{1}.gpso2d_results.data.filt.use_filter
    border_size = floor(max(files{1}.gpso2d_results.data.filt.filter_size)/2);
    for i=1:size(files{1}.gpso2d_results.data.subsoil.contiguous,1)
        row_b = files{1}.gpso2d_results.data.subsoil.contiguous(i,:);
        border = [border row_b(1):(row_b(1)+border_size-1)];
        border = [border (row_b(2)-border_size+1):row_b(2)];
    end
    border = unique(border);
    pos = (border>=0)&(border<=nr);
    border = border(pos);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
fprintf(2,'Extracting working models...');
%SEARCH FOR MODELS WITH MISFIT LOWER THAN 'equivalent_region'
%mier has number of models rows and number of rectangles columns
%tier has number of models rows and number of trend parameters columns
%mft is a column vector of length equal to rows of mier
mier = [];
tier = [];
mft = [];
pos = 0;
for i=1:nfiles
    %Swarm size
    swarm_size = files{i}.gpso2d_results.inv_res.swarm_size;
    %Check the existence of valid models
    mft_it = files{i}.gpso2d_results.inv_res.rel_misfit;
    pmft = mft_it<=equivalent_region;
    mft_it = mft_it(pmft);
    if isempty(mft_it)
        warning(['File\n%s\ndoes not contain models inside the equivalent ',...
                 'region. It is omitted\n'],files{i}.gpso2d_results.filename);
        continue;
    end
    %Check dimensions
    if (size(files{i}.gpso2d_results.inv_res.model,2)~=nr)||...
       (size(files{i}.gpso2d_results.inv_res.trend,2)~=nt)
        error(['File\n%s\nhas different number of rectangles and/or trend ',...
               'parameters than the previous one(s)'],...
              files{i}.gpso2d_results.filename);
    end
    %Intermediate matrices
    mier_aux = zeros(swarm_size,nr);
    tier_aux = [];
    if ~isempty(files{i}.gpso2d_results.inv_res.trend)
        tier_aux = zeros(swarm_size,nt);
    end
    mft_aux = zeros(swarm_size,1);
    %Row counter
    rowc = 1;
    %Loop over iterations
    for j=1:files{i}.gpso2d_results.inv_res.iterations
        %Initial position and range of positions
        pos = (j-1)*swarm_size+1;
        range_pos = pos:(pos+swarm_size-1);
        %Misfits
        mft_it = files{i}.gpso2d_results.inv_res.rel_misfit(range_pos);
        %Retain only the misfits inside the working equivalent region
        pmft = mft_it<=equivalent_region;
        %check if exist models
        if sum(pmft)>0
            %Misfits
            mft_it = mft_it(pmft);
            %Prisms and trend
            hp = files{i}.gpso2d_results.inv_res.model(range_pos,:);
            hp = hp(pmft,:);
            if ~isempty(files{i}.gpso2d_results.inv_res.trend)
                tp = files{i}.gpso2d_results.inv_res.trend(range_pos,:);
                tp = tp(pmft,:);
            else
                tp = [];
            end
            %Check the dispersion
            dispersion_f = files{i}.gpso2d_results.inv_res.dispersion_f(j)/...
                           files{i}.gpso2d_results.inv_res.dispersion_f(1)*100;
            if dispersion_f<minimum_dispersion
                %Check if there are models
                if size(hp,1)>1
                    %Retain the best model in the iteration
                    [mft_min,pos] = min(mft_it);
                    hp_min = hp(pos,:);
                    if ~isempty(files{i}.gpso2d_results.inv_res.trend)
                        tp_min = tp(pos,:);
                    end
                    %Retain the center of gravity of the swarm
                    hp = mean(hp);
                    %Compute the misfit of this model
                    rect(:,3) = hp';
                    grav = gpso2d_GravityComputation(rect,rho,points)'./...
                                                                best_model_f_SI;
                    grav = grav(pos_p).*weights(pos_p);
                    mft_it = norm(o_t_aux-grav,ncf)/n_o_t_aux;
                    %Final data
                    hp = [hp;hp_min];
                    mft_it = [mft_it;mft_min];
                    if ~isempty(files{i}.gpso2d_results.inv_res.trend)
                        tp = [mean(tp);tp_min];
                    end
                end
            end
            %Add the models to the matrices
            ndata = size(hp,1);
            range_data = rowc:(rowc+ndata-1);
            mier_aux(range_data,:) = hp; %Here 'hp' is converted to double
            if ~isempty(files{i}.gpso2d_results.inv_res.trend)
                tier_aux(range_data,:) = tp; %Also 'tp' is converted to double
            end
            mft_aux(range_data,1) = mft_it;
            rowc = rowc+ndata;
        end
    end
    %Retain only the valid data
    mier_aux = mier_aux(1:rowc-1,:);
    if ~isempty(files{i}.gpso2d_results.inv_res.trend)
        tier_aux = tier_aux(1:rowc-1,:);
    end
    mft_aux = mft_aux(1:rowc-1,1);
    %Add the models to the final matrices ('mier', 'tier' and 'mft' are double)
    mier = [mier;mier_aux];
    tier = [tier;tier_aux];
    mft = [mft;mft_aux];
end
%Check the number of models
if isempty(mier)||(size(mier,1)<2)
    error('There is only one or no models inside the equivalent region');
end
fprintf(2,'%.3f s\n',toc(t));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MISFIT OF THE REFEREMCE MODEL
if use_ref_model
    %Reference model bottom heights at the center of rectangles (row vector)
    ref_model = interp1(rmodel(:,1),rmodel(:,2),lc')';
    %Check if there is any rectangle with no model
    pos = isnan(ref_model);
    if sum(pos)
        %Compute the distance from the reference model to all the working models
        dist = ref_model(~pos)-mier(:,~pos);
        dist = dist.^2;
        dist = sqrt(sum(dist'));
        %Select the nearest model
        [dist,pos_nearest] = min(dist);
        model_nearest = mier(pos_nearest,:);
        %Put the heights of the nearest models in the void positions
        ref_model(pos) = model_nearest(pos);
    end
    %Observations generated by the reference model
    rect(:,3) = ref_model';
    grav_ref_model = gpso2d_GravityComputation(rect,rho,points)'./...
                     best_model_f_SI;
    %Computed gravities for the used points
    grav_ref_model_calc = grav_ref_model(pos_p).*weights(pos_p);
    %Cost function
    cost_ref_model = norm(o_t_aux-grav_ref_model_calc,ncf)/n_o_t_aux;
    cost_ref_model = cost_ref_model*100.0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SEARCH FOR BOUNDS ENCLOSING THE WORKING EQUIVALENT REGION
if strcmp(upper(kind_of_equiv_region),'ALL')
    %Upper and lower limits (no trend is needed)
    %Cost functions are computed later
    upper_limit = max(mier);
    lower_limit = min(mier);
else
    %Check if we are woring with the reference model
    if strcmp(upper(kind_of_equiv_region),'REF')
        %Searching reference model
        srmodel = ref_model;
    else
        %Searching reference model
        srmodel = best_model;
    end
    %Upper limit (upper_trend is actually not used)
    t = tic;
    fprintf(2,['Looking for the upper limit of the equivalence region ',...
            '(this may take some time)... ']);
    [upper_limit,upper_trend,...
     cost_upper_limit,...
     it_up] = gpso2d_FindLimits('UPPER',mier,tier,mft,srmodel,best_trend,...
                                equivalent_region,equivalent_region_tol,...
                                rect,rho,points,pos_p,weights,ncf,o_t,...
                                best_model_f_SI);
    fprintf(2,['\n   Time spent: %7.3f s, iterations: %4d, ',...
               'misfit of the upper limit: %7.3f%%\n'],...
            toc(t),it_up,cost_upper_limit);
    %Lower limit (lower_trend is actually not used)
    t = tic;
    fprintf(2,['Looking for the lower limit of the equivalence region ',...
            '(this may take some time)...']);
    [lower_limit,lower_trend,...
     cost_lower_limit,...
     it_lo] = gpso2d_FindLimits('LOWER',mier,tier,mft,srmodel,best_trend,...
                                equivalent_region,equivalent_region_tol,...
                                rect,rho,points,pos_p,weights,ncf,o_t,...
                                best_model_f_SI);
    fprintf(2,['\n   Time spent: %7.3f s, iterations: %4d, ',...
               'misfit of the lower limit: %7.3f%%\n'],...
            toc(t),it_lo,cost_lower_limit);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CENTRAL DISPERSION MODELS USING THE MODELS INSIDE THE WORKING EQUIVALENT REGION
%Outside models, considered as those with at least 10% of the rectangles outside
%Borders are considered always inside the region
pos_outside = (mier>upper_limit)&(mier<lower_limit);
pos_outside(:,border) = logical(0);
n_models = sum(pos_outside')';
pos_outside = n_models>floor(nr/10.0);
%Tolerance of equivalence region in order to consider models near to the limits
range_depth = upper_limit-lower_limit;
range_tol = range_depth*(range_depth_tol/100.0);
range_tol_aux = sort(unique(range_tol),'descend');
range_tol_aux = range_tol_aux(floor(length(range_tol_aux)/2.0));
pos = range_tol<range_tol_aux;
range_tol(pos) = range_tol_aux;
%Models TOTALLY included in the working region, considered as those totally
%included in the limits plus the tolerance, but with no more than the 10% of
%rectangles outside the strict limits (but rectangles in the border regions are
%always included)
pos_tot_inc = (mier<=(upper_limit+range_tol))&(mier>=(lower_limit-range_tol));
pos_tot_inc(:,border) = logical(1);
pos_tot_inc = pos_tot_inc(~pos_outside,:);
n_models = sum(pos_tot_inc')';
pos_tot_inc = n_models==nr;
%Export them into a file
name_file = [output_folder,filesep,'models-inside-equiv-region'];
if isempty(tier)
    models_inside = [mft(pos_tot_inc) mier(pos_tot_inc,:)];
else
    models_inside = [mft(pos_tot_inc) mier(pos_tot_inc,:) tier(pos_tot_inc,:)];
end
save(name_file,'models_inside','-v7');
%Best local model
if strcmp(upper(kind_of_equiv_region),'REF')
    var_aux = mier(pos_tot_inc,:);
    [best_error,pos] = min(mft(pos_tot_inc));
    best_model = var_aux(pos,:);
    rect(:,3) = best_model';
    best_model_obs = gpso2d_GravityComputation(rect,rho,points)'./...
                     best_model_f_SI;
    if have_trend
        var_aux = tier(pos_tot_inc,:);
        best_trend = var_aux(pos,:);
        best_model_obst = polyval(best_trend,points(:,1)');
    end
end
%Central dispersion models using the models inside the working equivalent region
%All are row vectors
if sum(pos_tot_inc)>1
    mean_model = mean(mier(pos_tot_inc,:));
    median_model = median(mier(pos_tot_inc,:));
elseif sum(pos_tot_inc)==1
    mean_model = mier(pos_tot_inc,:);
    median_model = mier(pos_tot_inc,:);
else
    error('There are no models totally inside the working equivalence region');
end
mode_model = zeros(1,nr);
if ~isempty(best_trend)
    if sum(pos_tot_inc)>1
        mean_trend = mean(tier(pos_tot_inc,:));
        median_trend = median(tier(pos_tot_inc,:));
    else
        mean_trend = tier(pos_tot_inc,:);
        median_trend = tier(pos_tot_inc,:);
    end
    mode_trend = zeros(1,nt);
end
%Subsoil models cell array and empirical cumulative distribution functions
%Change heights to depths
cmier = cell(1,nr);
ctier = cell(1,nt);
ecdf_mier = cell(1,nr);
ecdf_tier = cell(1,nt);
hist_mier = cell(1,nr);
hist_tier = cell(1,nt);
%Loop over rectangles
for i=1:nr
    %Empirical cumulative distribution function
    cmier{i} = htop(i)-mier(pos_tot_inc,i);
    [p,x] = gpso2d_Ecdf(cmier{i});
    ecdf_mier{i} = [x p];
    %Number of histogram bins equals number of meters in depth range divided by
    %the value hbin_div_factor
    nb = round((max(cmier{i})-min(cmier{i}))/hbin_div_factor);
    if nb<10
        nb = 10;
    end
    %Histogram computation and height of maximum frequency
    [fh,xh] = hist(cmier{i},nb);
    hist_mier{i} = [xh' fh'];
    [val,pos] = max(fh);
    %Store mode model in absolute heights
    mode_model(i) = htop(i)-xh(pos);
end
%Trend parameters
if ~isempty(best_trend)
    for i=1:nt
        ctier{i} = tier(pos_tot_inc,i);
        [p,x] = gpso2d_Ecdf(ctier{i});
        ecdf_tier{i} = [x p];
        nb = round((max(ctier{i})-min(ctier{i}))/hbin_div_factor);
        if nb<10
            nb = 10;
        end
        [fh,xh] = hist(ctier{i},nb);
        hist_tier{i} = [xh' fh'];
        [val,pos] = max(fh);
        %Store mode model
        mode_trend(i) = xh(pos);
    end
end
%COST FUNCTION FOR THE CENTRAL DISPERSION MODELS
%Observations generated by the different models
rect(:,3) = upper_limit';
grav_upper_limit = gpso2d_GravityComputation(rect,rho,points)'./best_model_f_SI;
rect(:,3) = lower_limit';
grav_lower_limit = gpso2d_GravityComputation(rect,rho,points)'./best_model_f_SI;
rect(:,3) = mean_model';
grav_mean_model = gpso2d_GravityComputation(rect,rho,points)'./best_model_f_SI;
rect(:,3) = median_model';
grav_median_model =gpso2d_GravityComputation(rect,rho,points)'./best_model_f_SI;
rect(:,3) = mode_model';
grav_mode_model = gpso2d_GravityComputation(rect,rho,points)'./best_model_f_SI;
%Computed gravities for the used points
grav_upper_limit_calc = grav_upper_limit(pos_p).*weights(pos_p);
grav_lower_limit_calc = grav_lower_limit(pos_p).*weights(pos_p);
grav_mean_model_calc = grav_mean_model(pos_p).*weights(pos_p);
grav_median_model_calc = grav_median_model(pos_p).*weights(pos_p);
grav_mode_model_calc = grav_mode_model(pos_p).*weights(pos_p);
%Cost functions
cost_upper_limit = norm(o_t_aux-grav_upper_limit_calc,ncf)/n_o_t_aux;
cost_lower_limit = norm(o_t_aux-grav_lower_limit_calc,ncf)/n_o_t_aux;
cost_mean_model = norm(o_t_aux-grav_mean_model_calc,ncf)/n_o_t_aux;
cost_median_model = norm(o_t_aux-grav_median_model_calc,ncf)/n_o_t_aux;
cost_mode_model = norm(o_t_aux-grav_mode_model_calc,ncf)/n_o_t_aux;
cost_upper_limit = cost_upper_limit*100.0;
cost_lower_limit = cost_lower_limit*100.0;
cost_mean_model = cost_mean_model*100.0;
cost_median_model = cost_median_model*100.0;
cost_mode_model = cost_mode_model*100.0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COORDINATES FOR PLOTTING ALL MODELS LINES
%Vector coordinates
xml = [];
yuml = [];
ylml = [];
ybml = [];
ybmla = [];
ymeanml = [];
ymedianml = [];
ymodeml = [];
yusbl = [];
ylsbl = [];
xrml = [];
yrml = [];
upper_search_limit = files{1}.gpso2d_results.model.upperlimit;
lower_search_limit = files{1}.gpso2d_results.model.lowlimit;
%Loop over all segments
for i=1:size(files{1}.gpso2d_results.data.subsoil.contiguous,1)
    %Contiguous rectangles
    contiguous = files{1}.gpso2d_results.data.subsoil.contiguous;
    %Start and end positions of each segment
    p_start = contiguous(i,1);
    p_end = contiguous(i,2);
    %Start and end X coordinates
    x_ini = lc(p_start);
    x_end = lc(p_end);
    %Positions for each rectangle
    pos = (lc>=x_ini)&(lc<=x_end);
    %Create X and heights vector coordinates for the different models
    xml = [xml lc(pos) NaN];
    yuml = [yuml upper_limit(pos) NaN];
    ylml = [ylml lower_limit(pos) NaN];
    ybml = [ybml best_model(pos) NaN];
    ybmla = [ybmla best_model_abs(pos) NaN];
    ymeanml = [ymeanml mean_model(pos) NaN];
    ymedianml = [ymedianml median_model(pos) NaN];
    ymodeml = [ymodeml mode_model(pos) NaN];
    yusbl = [yusbl upper_search_limit(pos) NaN];
    ylsbl = [ylsbl lower_search_limit(pos) NaN];
    %Create X and heights vector coordinates for the reference model
    if use_ref_model
        pos = (rmodel(:,1)>=x_ini)&(rmodel(:,1)<=x_end);
        xrml = [xrml rmodel(pos,1)' NaN];
        yrml = [yrml rmodel(pos,2)' NaN];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GENERATED MODELS
name_file = [oft,filesep,'model-subsoil.txt'];
idf = fopen(name_file,'wb');
if strcmp(upper(kind_of_equiv_region),'ALL')
    fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE WERE COMPUTED USING ALL MODELS\n',...
'%%     INSIDE THE WORKING %.3f%% EQUIVALENCE REGION. UPPER AND LOWER\n',...
'%%     LIMITS WILL BE DIFFERENT TO THE PRESCRIBED TOLERANCE AND CAN\n',...
'%%     CONTAIN MULTIPLE RELATIVE MINIMA OF THE COST FUNCTION TOPOGRAPHY\n',...
'%%*****MEAN, MEDIAN AND MODE MODELS WILL DIFFER FROM THE ONES COMPUTED\n',...
'%%     USING kind_of_equiv_region = ''best'', BUT BEST MODEL WILL BE THE ',...
'SAME\n\n\n'],equivalent_region);
elseif strcmp(upper(kind_of_equiv_region),'REF')
    fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO A LOCAL EQUIVALENCE\n',...
'%%     REGION OF %.3f%% RELATIVE ERROR COMPUTED AROUND A REFERENCE MODEL\n',...
'%%     (NOT AROUND THE GLOBAL BEST MODEL)\n',...
'%%*****BEST MODEL IS NOT GLOBAL, BUT LOCAL. MEAN, MEDIAN AND MODE MODELS\n',...
'%%     WILL ALSO DIFFER FROM THE ONES COMPUTED USING ',...
'kind_of_equiv_region = ''best''\n\n\n'],equivalent_region);
end
fprintf(idf,'%%Inversion resulting models (%s)\n\n',family_id);
fprintf(idf,'%%Model composed by upper limit...: %6.3f%% relative misfit\n',...
        cost_upper_limit);
fprintf(idf,'%%Model composed by lower limit...: %6.3f%% relative misfit\n',...
        cost_lower_limit);
fprintf(idf,'%%Best model......................: %6.3f%% relative misfit\n',...
        best_error);
fprintf(idf,'%%Mean model......................: %6.3f%% relative misfit\n',...
        cost_mean_model);
fprintf(idf,'%%Median model....................: %6.3f%% relative misfit\n',...
        cost_median_model);
fprintf(idf,'%%Mode model......................: %6.3f%% relative misfit\n',...
        cost_mode_model);
if files{1}.gpso2d_results.opfun.only_points_on_sediments
    fprintf(idf,['%%Only observation points on the sediments were involved ',...
                 'in the misfit computation\n']);
else
    fprintf(idf,['%%All observation points were involved in the misfit ',...
                 'computation\n']);
end
header = ['%INITIAL-DISTANCE    FINAL-DISTANCE    TOP-HEIGHT   ',...
          'BOTTOM-BEST   BOTTOM-MEAN BOTTOM-MEDIAN   BOTTOM-MODE   ',...
          'UPPER-LIMIT   LOWER-LIMIT    DEPTH-BEST    DEPTH-MEAN  ',...
          'DEPTH-MEDIAN    DEPTH-MODE DEPTH-UPP-LIM DEPTH-LOW-LIM'];
fmt = ['%17.10E %17.10E %13.6E %13.6E %13.6E %13.6E %13.6E %13.6E %13.6E ',...
       '%13.6E %13.6E %13.6E %13.6E %13.6E %13.6E'];
data = [rect(:,1:2) rect(:,4) best_model' mean_model' median_model' ...
        mode_model' upper_limit' lower_limit' rect(:,4)-best_model' ...
        rect(:,4)-mean_model' rect(:,4)-median_model' rect(:,4)-mode_model' ...
        rect(:,4)-upper_limit' rect(:,4)-lower_limit'];
if ~isempty(files{1}.gpso2d_results.data.subsoil.xy)
    header = [header,'      X-COORDINATE      Y-COORDINATE'];
    fmt = [fmt,' %17.10E %17.10E'];
    data = [data files{1}.gpso2d_results.data.subsoil.xy];
end
fprintf(idf,'%s\n',header);
fprintf(idf,[fmt,'\n'],data');
fclose(idf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OBSERVATIONS GENERATED BY THE DIFFERENT MODELS
is_sd = ~isempty(files{1}.gpso2d_results.data.obs.sd_gSI);
name_file = [oft,filesep,'model-observations.txt'];
idf = fopen(name_file,'wb');
if strcmp(upper(kind_of_equiv_region),'ALL')
    fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE WERE COMPUTED USING ALL MODELS\n',...
'%%     INSIDE THE WORKING %.3f%% EQUIVALENCE REGION. UPPER AND LOWER\n',...
'%%     LIMITS WILL BE DIFFERENT TO THE PRESCRIBED TOLERANCE AND CAN\n',...
'%%     CONTAIN MULTIPLE RELATIVE MINIMA OF THE COST FUNCTION TOPOGRAPHY\n',...
'%%*****MEAN, MEDIAN AND MODE MODELS ANOMALIES WILL DIFFER FROM THE ONES\n',...
'%%     COMPUTED USING kind_of_equiv_region = ''best'', BUT THE\n',...
'%%     CORRESPONDING TO THE BEST MODEL WILL BE THE SAME\n\n\n'],...
            equivalent_region);
elseif strcmp(upper(kind_of_equiv_region),'REF')
    fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO A LOCAL EQUIVALENCE\n',...
'%%     REGION OF %.3f%% RELATIVE ERROR COMPUTED AROUND A REFERENCE MODEL\n',...
'%%     (NOT AROUND THE GLOBAL BEST MODEL)\n',...
'%%*****BEST, MEAN, MEDIAN AND MODE MODELS ANOMALIES WILL DIFFER FROM THE\n',...
'%%     ONES COMPUTED USING kind_of_equiv_region = ''best''\n\n\n'],...
            equivalent_region);
end
fprintf(idf,'%%Observations generated by the models (%s)\n\n',family_id);
fprintf(idf,['%%Multiplicative factor to convert gravity into SI units, ',...
             'and standard deviations\n%%identifier (0/1->no/yes). Only ',...
             'the first and second values are used, but the\n%%other ',...
             'values are necessary to match the number of columns\n',...
             '%%       FAC-TO-SI         SD-ID\n']);
fSI_sdID = sprintf('%17.10E             %d                    0',...
                   best_model_f_SI,is_sd);
header = ['%        DISTANCE        HEIGHT ORIGINAL-OBS-ANOMALY'];
fmt = ['%17.10E %13.6E %20.13E'];
data = [points orig_obs'];
if is_sd
    fSI_sdID = [fSI_sdID,'           0'];
    header = [header,'  SD-ANOMALY'];
    fmt = [fmt,' %11.4E'];
    data = [data files{1}.gpso2d_results.data.obs.sd_gSI(:)./best_model_f_SI];
end
fSI_sdID = [fSI_sdID,'      0                  0                  0',...
                     '                  0                    0',...
                     '                  0'];
header = [header,' ON-SED   BEST-MODEL-TREND BEST-MODEL-ANOMALY ',...
                 'MEAN-MODEL-ANOMALY MEDIAN-MODEL-ANOMALY MODE-MODEL-ANOMALY'];
fmt = [fmt,' %6d %18.11E %18.11E %18.11E %20.11E %18.11E'];
data = [data files{1}.gpso2d_results.data.obs.ps best_model_obst' ...
        best_model_obs' grav_mean_model' grav_median_model' grav_mode_model'];
if ~isempty(files{1}.gpso2d_results.data.obs.xy)
    fSI_sdID = [fSI_sdID,'                 0                 0'];
    header = [header,'      X-COORDINATE      Y-COORDINATE'];
    fmt = [fmt,' %17.10E %17.10E'];
    data = [data files{1}.gpso2d_results.data.obs.xy];
end
fprintf(idf,'%s\n',fSI_sdID);
fprintf(idf,'%s\n',header);
fprintf(idf,[fmt,'\n'],data');
fclose(idf);
%Observations generated by the reference model
if use_ref_model
    name_file = [oft,filesep,'ref-model-observations.txt'];
    idf = fopen(name_file,'wb');
    fprintf(idf,'%%Observations generated by the reference model\n');
    fprintf(idf,['%%If it does not cover the entire model used in the ',...
                 'inversion, it is completed\n%%with the nearest inverted ',...
                 'model\n\n']);
    fprintf(idf,['%%Multiplicative factor to convert gravity into SI ',...
                 'units, and standard deviations\n%%identifier ',...
                 '(0/1->no/yes). Only the first and second values are ',...
                 'used, but the\n%%other values are necessary to match the ',...
                 'number of columns\n',...
                 '%%       FAC-TO-SI         SD-ID\n']);
    fSI_sdID = sprintf('%17.10E             %d                    0',...
                    best_model_f_SI,is_sd);
    header = ['%        DISTANCE        HEIGHT ORIGINAL-OBS-ANOMALY'];
    fmt = ['%17.10E %13.6E %20.13E'];
    data = [points orig_obs'];
    if is_sd
        fSI_sdID = [fSI_sdID,'           0'];
        header = [header,'  SD-ANOMALY'];
        fmt = [fmt,' %11.4E'];
        data = [data files{1}.gpso2d_results.data.obs.sd_gSI(:)./best_model_f_SI];
    end
    fSI_sdID = [fSI_sdID,'      0                  0                  0'];
    header = [header,' ON-SED   BEST-MODEL-TREND  REF-MODEL-ANOMALY'];
    fmt = [fmt,' %6d %18.11E %18.11E'];
    data = [data files{1}.gpso2d_results.data.obs.ps best_model_obst' ...
            grav_ref_model'];
    if ~isempty(files{1}.gpso2d_results.data.obs.xy)
        fSI_sdID = [fSI_sdID,'                 0                 0'];
        header = [header,'      X-COORDINATE      Y-COORDINATE'];
        fmt = [fmt,' %17.10E %17.10E'];
        data = [data files{1}.gpso2d_results.data.obs.xy];
    end
    fprintf(idf,'%s\n',fSI_sdID);
    fprintf(idf,'%s\n',header);
    fprintf(idf,[fmt,'\n'],data');
    fclose(idf);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%REGIONAL TREND TO FILE
name_file = [oft,filesep,'model-trend.txt'];
idf = fopen(name_file,'wb');
if isempty(best_trend)
    fprintf(idf,'%%There is no regional trend estimation (%s)\n',family_id);
    fprintf(idf,'%%Do not modify this file\n');
    fprintf(idf,'0\n0\n0\n0\n');
else
    if strcmp(upper(kind_of_equiv_region),'REF')
        fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO THE TREND OF THE\n',...
'%%     BEST, MEAN, MEDIAN and MODE LOCAL MODEL SELECTED UNDER THE\n',...
'%%     CONFIGURATION VALUE kind_of_equiv_region = ''ref''\n\n\n']);
    end
    nprt = length(best_trend);
    fprintf(idf,'%%Regional trend estimation (%s)\n',family_id);
    fprintf(idf,'%%The model is: trend=');
    for i=nprt:-1:2
        if i>2
            fprintf(idf,'a%d*(L-L0)^%d+',i-1,i-1);
        else
            fprintf(idf,'a1*(L-L0)+');
        end
    end
    fprintf(idf,'a0 (residuals=observations-trend)\n\n');
    fprintf(idf,'%%Multiplicative factor to convert trend to SI units\n');
    fprintf(idf,'%%(only the first value is used)\n');
    fprintf(idf,'%17.10E',best_trend_f_SI);
    for i=1:(nprt-1)
        fprintf(idf,' 0');
    end
    fprintf(idf,'\n');
    fprintf(idf,'%%Reduction center L0 for the lengths along the profile\n');
    fprintf(idf,'%%(only the first value is used)\n');
    fprintf(idf,'%17.10E',best_trend_l0);
    for i=1:(nprt-1)
        fprintf(idf,' 0');
    end
    fprintf(idf,'\n');
    fprintf(idf,'%%Regional trend parameters for the BEST model\n%%');
    for i=nprt:-1:1
        fprintf(idf,' %17s',['a',num2str(i-1)]);
    end
    fprintf(idf,'\n');
    for i=1:nprt
        fprintf(idf,' %19.12E',best_trend(i));
    end
    fprintf(idf,'\n');
    fprintf(idf,'%%No standard deviations are presented in this file\n');
    fprintf(idf,['%%You can determine their uncertainty using the ',...
                 'information contained\n%%in the *gpso2d_results.mat'' ',...
                 'file(s)\n%%']);
    for i=nprt:-1:1
        fprintf(idf,' %17s',['sd_a',num2str(i-1)]);
    end
    fprintf(idf,'\n');
    for i=1:nprt
        fprintf(idf,' %19.12E',0.0);
    end
    fprintf(idf,'\n');
    fprintf(idf,['%%Mean of the regional trend parameters for the models ',...
                 'inside the\n%%equivalence region. These values are NOT ',...
                 'the values for the mean model,\n%%which is referred to ',...
                 'the trend for the best model\n%%']);
    for i=nprt:-1:1
        fprintf(idf,' %17s',['a',num2str(i-1)]);
    end
    fprintf(idf,'\n');
    for i=1:nprt
        fprintf(idf,' %19.12E',mean_trend(i));
    end
    fprintf(idf,'\n');
    fprintf(idf,['%%Median of the regional trend parameters for the models ',...
                 'inside the\n%%equivalence region. These values are NOT ',...
                 'the values for the mean model,\n%%which is referred to ',...
                 'the trend for the best model\n%%']);
    for i=nprt:-1:1
        fprintf(idf,' %17s',['a',num2str(i-1)]);
    end
    fprintf(idf,'\n');
    for i=1:nprt
        fprintf(idf,' %19.12E',median_trend(i));
    end
    fprintf(idf,'\n');
    fprintf(idf,['%%Mode of the regional trend parameters for the models ',...
                 'inside the\n%%equivalence region. These values are NOT ',...
                 'the values for the mean model,\n%%which is referred to ',...
                 'the trend for the best model\n%%']);
    for i=nprt:-1:1
        fprintf(idf,' %17s',['a',num2str(i-1)]);
    end
    fprintf(idf,'\n');
    for i=1:nprt
        fprintf(idf,' %19.12E',mode_trend(i));
    end
    fprintf(idf,'\n');
end
fclose(idf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SEARCH BOUNDS TO FILE
sb = [xml(~isnan(xml))' yusbl(~isnan(yusbl))' ylsbl(~isnan(ylsbl))'];
name_file = [oft,filesep,'search-bounds.txt'];
idf = fopen(name_file,'wb');
fprintf(idf,'%%Employed search bounds\n\n');
fprintf(idf,'%%        DISTANCE        TOP-HEIGHT     BOTTOM-HEIGHT\n');
fprintf(idf,'%17.10E %17.10E %17.10E\n',sb');
fclose(idf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TEXT HISTOGRAMS
%Rectangles
for i=1:nr
    %Export text file
    name_file = sprintf('%s%shist-rectangle-%03d.txt',ofthist,filesep,i);
    idf = fopen(name_file,'wb');
    if strcmp(upper(kind_of_equiv_region),'ALL')
        fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO THE CONFIGURATION\n',...
'%%     VALUE kind_of_equiv_region = ''all''\n\n\n']);
    elseif strcmp(upper(kind_of_equiv_region),'REF')
        fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO THE CONFIGURATION\n',...
'%%     VALUE kind_of_equiv_region = ''ref''\n\n\n']);
    end
    fprintf(idf,'%%Histogram for rectangle %d (%s)\n',i,family_id);
    fprintf(idf,'%%Length and coordinates are referred to the center\n');
    fprintf(idf,'%%L=%.3f m, top height=%.3f m\n',lc(i),htop(i));
    if ~isempty(files{1}.gpso2d_results.data.subsoil.xy)
        fprintf(idf,'%%X=%17.10E m, Y=%17.10E m\n',...
                files{1}.gpso2d_results.data.subsoil.xy(i,1),...
                files{1}.gpso2d_results.data.subsoil.xy(i,2));
    end
    fprintf(idf,'%%%d models totally inside the %.3f%% equivalent region\n\n',...
            sum(hist_mier{i}(:,2)),equivalent_region);
    fprintf(idf,'%%      DEPTH OCCURRENCES\n');
    fprintf(idf,'%12.6E %11d\n',hist_mier{i}');
    fclose(idf);
end
%Trend parameters
if files{1}.gpso2d_results.data.trend.regional_trend
    for i=1:nt
        %Export text file
        name_file = sprintf('%s%shist-trend-a%d.txt',ofthist,filesep,nt-i);
        idf = fopen(name_file,'wb');
        if strcmp(upper(kind_of_equiv_region),'ALL')
            fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO THE CONFIGURATION\n',...
'%%     VALUE kind_of_equiv_region = ''all''\n\n\n']);
        elseif strcmp(upper(kind_of_equiv_region),'REF')
            fprintf(idf,[...
'%%*****WARNING: THE DATA IN THIS FILE CORRESPOND TO THE CONFIGURATION\n',...
'%%     VALUE kind_of_equiv_region = ''ref''\n\n\n']);
        end
        fprintf(idf,'%%Histrogram for trend parameter a%d (%s)\n',...
                nt-i,family_id);
        fprintf(idf,['%%%d models totally inside the %.3f%% equivalent ',...
                     'region\n\n'],sum(hist_tier{i}(:,2)),equivalent_region);
        fprintf(idf,'%%       VALUE OCCURRENCES\n');
        fprintf(idf,'%13.6E %11d\n',hist_tier{i}');
        fclose(idf);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set units and dimensions of the plot window
if strcmp(upper(plot_format),'PDF')~=0
    %PDF
    f = figure();
    set(f,'Paperunits',paper_units_pdf);
    set(f,'Papersize',paper_size_pdf);
    set(f,'Position',get(0,'Screensize'));
else
    %Image file
    figure('Units','Normalized','Position',[0 0 1 1]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MISFIT EVOLUTION PLOT
%Check if elements in ltp are more than the number of files to analyze
nltp = length(ltp);
if nfiles>nltp
    %Add elements to ltp repeating the initial series
    for i=nltp+1:nfiles
        ltp{i} = ltp{i-nltp};
    end
end
%Plotting misfit evolution
if kind_of_information~=0
    clf;
    hold('on');
    legend_text = {};
    max_nit = 0;
    for i=1:nfiles
        nit = files{i}.gpso2d_results.inv_res.iterations;
        if nit>max_nit
            max_nit = nit;
        end
        misfit = files{i}.gpso2d_results.inv_res.rel_misfit_best';
        [aux,file1,file2] = fileparts(files{i}.gpso2d_results.filename);
        if strcmp(upper(files{i}.gpso2d_results.options.pso.esquema),'PSO')~=0
            esquema = 'GPSO';
        else
            esquema = [files{i}.gpso2d_results.options.pso.esquema,'-PSO'];
        end
        legend_text{i} = [file1,file2,' (',esquema,')'];
        plot_handle = plot(1:nit,misfit,ltp{i});
    end
    hold('off');
    grid('on');
    box('on');
    xlim([0 max_nit+1]);
    set(gca,'FontSize',ticks_fsize); %This before any other FontSize
    title('Convergence curve(s)','FontSize',title_fsize);
    xlabel('Iterations','FontSize',xylabel_fsize);
    ylabel('Best model relative error (%)','FontSize',xylabel_fsize);
    legend(legend_text,'FontSize',legend_fsize,'Interpreter','none');
    set(plot_handle,'LineWidth',line_width_cd);
    set(plot_handle,'MarkerSize',point_size_cd);
    name_file = [ofp,filesep,'convergence.',plot_format];
    if strcmp(upper(plot_format),'PDF')~=0
        orient('Landscape');
    else
        aspect_ratio = '';
    end
    print(name_file,['-d',plot_format],aspect_ratio);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DISPERSION PLOT
%Plotting swarm dispersion
if kind_of_information~=0
    clf;
    hold('on');
    for i=1:nfiles
        nit = files{i}.gpso2d_results.inv_res.iterations;
        dispersion = files{i}.gpso2d_results.inv_res.dispersion_f./...
                     files{i}.gpso2d_results.inv_res.dispersion_f(1)*100.0;
        [aux,file1,file2] = fileparts(files{i}.gpso2d_results.filename);
        plot_handle = plot([1:nit]',dispersion,ltp{i});
    end
    hold('off');
    grid('on');
    box('on');
    xlim([0 max_nit+1]);
    set(gca,'FontSize',ticks_fsize); %This before any other FontSize
    title('Dispersion curve(s)','FontSize',title_fsize);
    xlabel('Iterations','FontSize',xylabel_fsize);
    ylabel('Filtered swarm relative dispersion (%)','FontSize',xylabel_fsize);
    %legend_text is yet created
    legend(legend_text,'FontSize',legend_fsize,'Interpreter','none');
    set(plot_handle,'LineWidth',line_width_cd);
    set(plot_handle,'MarkerSize',point_size_cd);
    yticks = get(gca,'YTick');
    yticks = [0.0 5.0 10.0 yticks(yticks>10.0)];
    set(gca,'YTick',yticks);
    name_file = [ofp,filesep,'dispersion.',plot_format];
    if strcmp(upper(plot_format),'PDF')~=0
        orient('Landscape');
    else
        aspect_ratio = '';
    end
    print(name_file,['-d',plot_format],aspect_ratio);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OVERVIEW PLOT
%Check if there is reference model
if use_ref_model
    %Heights of reference model at the centers of rectangles (row vector)
    hrm = interp1(rmodel(:,1),rmodel(:,2),lc')';
end
%Check if this plot must be generated
if kind_of_information>0
    %X limits
    x_min = min([lc points(:,1)']);
    x_max = max([lc points(:,1)']);
    mean_sep_2 = mean(abs(diff(points(:,1))))/2.0;
    x_min = x_min-mean_sep_2;
    x_max = x_max+mean_sep_2;
    %Colours for the different models
    cm = colour_models;
    %Check if there are boreholes
    use_boreholes = 0;
    if files{1}.gpso2d_results.data.borehole.use_boreholes_file
        use_boreholes = 1;
        d_bor = (files{1}.gpso2d_results.data.borehole.depth_min+...
                 files{1}.gpso2d_results.data.borehole.depth_max)./2.0;
        pos = isnan(d_bor);
        d_bor(pos) = files{1}.gpso2d_results.data.borehole.depth_min(pos);
    end
    clf;
    %Points
    hUP = plot(points(pos_p,1),points(pos_p,2),[obs_colour,obs_symbol],...
               'MarkerSize',obs_size);
    order_leg1 = 'hLeg = legend([hUP';
    order_leg2 = [',''Used points'''];
    hold('on');
    if sum(~pos_p)~=0
        hUnP = plot(points(~pos_p,1),points(~pos_p,2),...
                    [obs_symbol,obsn_colour],'MarkerSize',obs_size);
        order_leg1 = [order_leg1,',hUnP'];
        order_leg2 = [order_leg2,',''Unused points'''];
    end
    hLims = plot([xml NaN xml],[yuml NaN ylml],colour_ecdfh,...
                 'LineWidth',1.5*line_width);
    hBest = plot(xml,ybml,cm{1},'LineWidth',line_width);
    hMean = plot(xml,ymeanml,cm{2},'LineWidth',line_width);
    hMedian = plot(xml,ymedianml,cm{3},'LineWidth',line_width);
    hMode = plot(xml,ymodeml,cm{4},'LineWidth',line_width);
    order_leg1 = [order_leg1,',hLims,hBest,hMean,hMedian,hMode'];
    order_leg2 = sprintf(['%s,''Equivalence region'',',...
                          '''Best model (%.2f%% misfit)'',',...
                          '''Mean model (%.2f%% misfit)'',',...
                          '''Median model (%.2f%% misfit)'',',...
                          '''Mode model (%.2f%% misfit)'''],...
                         order_leg2,best_error,cost_mean_model,...
                         cost_median_model,cost_mode_model);
    if use_ref_model
        hRef = plot(xrml,yrml,cm{5},'LineWidth',line_width);
        order_leg1 = [order_leg1,',hRef'];
        order_leg2 = sprintf('%s,''Reference model (%.2f%% misfit)''',...
                             order_leg2,cost_ref_model);
    end
    if strcmp(upper(kind_of_equiv_region),'REF')
        hABest = plot(xml,ybmla,[cm{1},'--'],'LineWidth',line_width);
        order_leg1 = [order_leg1,',hABest'];
        order_leg2 = sprintf('%s,''Absolute best model (%.2f%% misfit)''',...
                             order_leg2,best_error_abs);
    end
    if use_boreholes
        hb = interp1(points(:,1),points(:,2),...
                     files{1}.gpso2d_results.data.borehole.lc);
        coor_xb = [];
        coor_yb = [];
        for i=1:length(files{1}.gpso2d_results.data.borehole.lc)
            coor_xb = [coor_xb files{1}.gpso2d_results.data.borehole.lc(i) ...
                       files{1}.gpso2d_results.data.borehole.lc(i) NaN];
            coor_yb = [coor_yb hb(i) hb(i)-d_bor(i) NaN];
            hBor = plot(coor_xb,coor_yb,cm{6},'LineWidth',line_width);
        end
        order_leg1 = [order_leg1,',hBor'];
        order_leg2 = [order_leg2,',''Borehole(s)'''];
    end
    if plot_search_bounds
        hSB = plot([xml NaN xml],[yusbl NaN ylsbl],bounds_colour,...
                   'LineWidth',line_width);
        order_leg1 = [order_leg1,',hSB'];
        order_leg2 = [order_leg2,',''Search bounds'''];
    end
    order_leg = [order_leg1,']',order_leg2,',''Location'',pos_legend);'];
    eval(order_leg);
    hold('off');
    grid('on');
    set(gca,'FontSize',ticks_fsize); %Before any FontSize configuration
    set(hLeg,'FontSize',legend_fsize);
    if strcmp(upper(kind_of_equiv_region),'ALL')
        tit = sprintf(['Ajusted models and %.3f%%/%.3f%% equivalence ',...
                       'region (%s)'],...
                      cost_upper_limit,cost_lower_limit,family_id);
    elseif strcmp(upper(kind_of_equiv_region),'REF')
        tit = sprintf(['Ajusted models and LOCAL %.2f%% equivalence region ',...
                       '(%s)'],equivalent_region,family_id);
    else
        tit = sprintf('Ajusted models and %.2f%% equivalence region (%s)',...
                  equivalent_region,family_id);
    end
    title(tit,'FontSize',title_fsize);
    xlabel('Length along the profile (m)','FontSize',xylabel_fsize);
    ylabel('Height (m)','FontSize',xylabel_fsize);
    xlim([x_min x_max]);
    name_file = [ofp,filesep,'overview.',plot_format];
    if strcmp(upper(plot_format),'PDF')~=0
        orient('Landscape');
    else
        aspect_ratio = '';
    end
    print(name_file,['-d',plot_format],aspect_ratio);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TREND AND RESIDUALS PLOT
%Check if this plot must be generated
if kind_of_information>0
    clf;
    %Redional trend
    if ~isempty(best_trend)
        %UPPER WINDOW
        p1 = subplot(2,1,1);
        %Original observations and trend
        hT = plot(points(:,1)',best_model_obst,cm{1},'LineWidth',line_width);
        hold('on');
        hOOU = plot(points(pos_p,1)',orig_obs(pos_p),[obs_colour,obs_symbol],...
                    'MarkerSize',obs_size);
        set(gca,'FontSize',ticks_fsize); %Before any FontSize
        if sum(~pos_p)~=0
            hOOUn = plot(points(~pos_p,1)',orig_obs(~pos_p),...
                         [obs_symbol,obsn_colour],'MarkerSize',obs_size);
        end
        hold('off');
        grid('on');
        hLeg = legend(hT,'Best trend','Location',pos_legend);
        set(hLeg,'FontSize',legend_fsize);
        ylabel('Trend','FontSize',xylabel_fsize);
        xlim([x_min x_max]);
        set(p1,'XTicklabel',[]);
        if strcmp(upper(kind_of_equiv_region),'ALL')
            tit =sprintf(['Gravity anomalies using ALL models inside ',...
                          'equivalence region (%s)\nUnits: m/s^2*%E'],...
                         family_id,1.0/best_model_f_SI);
        elseif strcmp(upper(kind_of_equiv_region),'REF')
            tit =sprintf(['Trend and gravity anomalies for LOCAL ',...
                          'equivalence region (%s)\nUnits: m/s^2*%E'],...
                         family_id,1.0/best_model_f_SI);
        else
            tit =sprintf('Trend and gravity anomalies (%s)\nUnits: m/s^2*%E',...
                         family_id,1.0/best_model_f_SI);
        end
        title(tit,'FontSize',title_fsize);
        %LOWER WINDOW
        p2 = subplot(2,1,2);
    end
    %Original residuals
    hOR = plot(points(pos_p,1),o_t(pos_p),[obs_colour,obs_symbol],...
                'MarkerSize',obs_size);
    order_leg1 = 'hLeg = legend([hOR';
    order_leg2 = [',''Used points'''];
    set(gca,'FontSize',ticks_fsize); %Before any FontSize
    hold('on');
    if sum(~pos_p)~=0
        hORUn = plot(points(~pos_p,1),o_t(~pos_p),...
                     [obs_symbol,obsn_colour],'MarkerSize',obs_size);
        order_leg1 = [order_leg1,',hORUn'];
        order_leg2 = [order_leg2,',''Unused points'''];
    end
    %Computed residuals
    hRBest = plot(points(:,1),best_model_obs,cm{1},'LineWidth',line_width);
    hRMean = plot(points(:,1),grav_mean_model,cm{2},'LineWidth',line_width);
    hRMedian = plot(points(:,1),grav_median_model,cm{3},'LineWidth',line_width);
    hRMode = plot(points(:,1),grav_mode_model,cm{4},'LineWidth',line_width);
    order_leg1 = [order_leg1,',hRBest,hRMean,hRMedian,hRMode'];
    order_leg2 = sprintf(['%s,''Best model'',''Mean model'',',...
                          '''Median model'',''Mode model'''],order_leg2);
    if use_ref_model
        hRRef = plot(points(:,1),grav_ref_model,cm{5},'LineWidth',line_width);
        order_leg1 = [order_leg1,',hRRef'];
        order_leg2 = sprintf('%s,''Reference model''',order_leg2);
    end
    if strcmp(upper(kind_of_equiv_region),'REF')
        hARBest = plot(points(:,1),best_model_obs_abs,[cm{1},'--'],...
                       'LineWidth',line_width);
        order_leg1 = [order_leg1,',hARBest'];
        order_leg2 = sprintf('%s,''Absolute best model''',order_leg2);
    end
    hold('off');
    grid('on');
    if isempty(best_trend)
        if strcmp(upper(kind_of_equiv_region),'ALL')
            tit =sprintf(['Gravity anomalies using ALL models inside ',...
                          'equivalence region (%s)\nUnits: m/s^2*%E'],...
                         family_id,1.0/best_model_f_SI);
        elseif strcmp(upper(kind_of_equiv_region),'REF')
            tit =sprintf(['Gravity anomalies for LOCAL ',...
                          'equivalence region (%s)\nUnits: m/s^2*%E'],...
                         family_id,1.0/best_model_f_SI);
        else
            tit =sprintf('Gravity anomalies (%s)\nUnits: m/s^2*%E',...
                         family_id,1.0/best_model_f_SI);
        end
        title(tit,'FontSize',title_fsize);
    end
    order_leg = [order_leg1,']',order_leg2,',''Location'',pos_legend);'];
    eval(order_leg);
    set(hLeg,'FontSize',legend_fsize);
    ylabel('Residual anomaly','FontSize',xylabel_fsize);
    xlim([x_min x_max]);
    xlabel('Length along the profile (m)','FontSize',xylabel_fsize);
    %WINDOWS ACCOMODATION
    if ~isempty(best_trend)
        %UPPER AND LOWER WINDOW SEPARATION
        pos1 = get(p1,'Position');
        pos2 = get(p2,'Position');
        sep = pos1(2)-(pos2(2)+pos2(4));
        height1 = pos1(4)+sep*(1.0-factor_separation_windows)/2.0;
        height2 = pos2(4)+sep*(1.0-factor_separation_windows)/2.0;
        height1 = height1*factor_height_hists;
        height2 = height2*factor_height_hists;
        pos1(2) = pos2(2)+height2+sep*factor_separation_windows;
        pos1(4) = height1;
        pos2(4) = height2;
        set(p1,'Position',pos1);
        set(p2,'Position',pos2);
    end
    %PRINT RESULTS
    name_file = [ofp,filesep,'anomalies.',plot_format];
    if strcmp(upper(plot_format),'PDF')~=0
        orient('Landscape');
    else
        aspect_ratio = '';
    end
    print(name_file,['-d',plot_format],aspect_ratio);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SPECIFIC MODEL PLOT
%Check if this plot must be generated
if kind_of_information>0
    %Clear figure
    clf;
    %Check for the used model
    if strcmp(upper(model_plot),'BEST')
        if strcmp(upper(kind_of_equiv_region),'REF')
            model_id = 'Best local model';
            model_h = ref_model;
        else
            model_id = 'Best model';
            model_h = best_model;
        end
        model_file = 'best-model';
        model_res = o_t-best_model_obs;
        model_misfit = best_error;
        yml = ybml;
        cml = cm{1};
    elseif strcmp(upper(model_plot),'MEAN')
        model_id = 'Mean model';
        model_file = 'mean-model';
        model_res = o_t-grav_mean_model;
        model_misfit = cost_mean_model;
        model_h = mean_model;
        yml = ymeanml;
        cml = cm{2};
    elseif strcmp(upper(model_plot),'MEDIAN')
        model_id = 'Median model';
        model_file = 'median-model';
        model_res = o_t-grav_median_model;
        model_misfit = cost_median_model;
        model_h = median_model;
        yml = ymedianml;
        cml = cm{3};
    elseif strcmp(upper(model_plot),'MODE')
        model_id = 'Mode model';
        model_file = 'mode-model';
        model_res = o_t-grav_mode_model;
        model_misfit = cost_mode_model;
        model_h = mode_model;
        yml = ymodeml;
        cml = cm{4};
    else
        error('The value of ''model_plot'' variable is not correct');
    end
    if use_ref_model
        ref_residuals = o_t-grav_ref_model;
        ref_misfit = cost_ref_model;
    end
    %UPPER WINDOW
    p1 = subplot(2,1,1);
    %Residuals
    hRes = plot(points(pos_p,1)',model_res(pos_p),[obs_colour,obs_symbol],...
                'MarkerSize',obs_size);
    hold('on')
    set(gca,'FontSize',ticks_fsize); %Before any FontSize
    if sum(~pos_p)~=0
        hResUn = plot(points(~pos_p,1)',model_res(~pos_p),...
                      [obs_symbol,obsn_colour],'MarkerSize',obs_size);
    end
    if use_ref_model
        hResRef = plot(points(:,1)',ref_residuals,...
                       [cm{5},obs_symbol],'MarkerSize',obs_size);
    end
    hold('off');
    grid('on');
    ylabel(sprintf('Residuals\nm/s^2*%.1E',1.0/best_model_f_SI),...
           'FontSize',xylabel_fsize);
    xlim([x_min x_max]);
    set(p1,'XTicklabel',[]);

    if strcmp(upper(kind_of_equiv_region),'ALL')
        tit = sprintf(['Residuals, %s (%.2f%% misfit), and %.3f%%/%.3f%% ',...
                       'equivalence region (%s)'],lower(model_id),...
                      model_misfit,cost_upper_limit,cost_lower_limit,family_id);
    elseif strcmp(upper(kind_of_equiv_region),'REF')
        tit = sprintf(['Residuals, %s (%.2f%% misfit), and LOCAL %.3f%% ',...
                       'equivalence region (%s)'],lower(model_id),...
                      model_misfit,equivalent_region,family_id);
    else
        tit = sprintf(['Residuals, %s (%.2f%% misfit), and %.3f%% ',...
                       'equivalence region (%s)'],lower(model_id),...
                      model_misfit,equivalent_region,family_id);
    end
    title(tit,'FontSize',title_fsize);
    %LOWER WINDOW
    p2 = subplot(2,1,2);
    %Rectangles drawing
    rect_a = rect;
    rect_a(:,3) = model_h';
    hRect = gpso2d_DrawRectangles(rect_a,basin_colour,line_width_r);
    hold('on');
    set(gca,'FontSize',ticks_fsize); %Before any FontSize
    %Points location
    hPL = plot(points(pos_p,1),points(pos_p,2),[obs_colour,obs_symbol],...
               'MarkerSize',obs_size);
    order_leg1 = 'hLeg = legend([hPL';
    order_leg2 = [',''Used points'''];
    if sum(~pos_p)~=0
        hPLUn = plot(points(~pos_p,1),points(~pos_p,2),...
                     [obs_symbol,obsn_colour],'MarkerSize',obs_size);
        order_leg1 = [order_leg1,',hPLUn'];
        order_leg2 = [order_leg2,',''Unused points'''];
    end
    %Equivalence region
    rect_a(:,3) = lower_limit';
    rect_a(:,4) = upper_limit';
    hEquiv = gpso2d_DrawRectangles(rect_a,equiv_colour,line_width_r);
    order_leg1 = [order_leg1,',hEquiv(1)'];
    order_leg2 = [order_leg2,',''Equivalence region'''];
    %Working model
    hMod = plot(xml,yml,cml,'LineWidth',line_width);
    order_leg1 = [order_leg1,',hMod'];
    order_leg2 = [order_leg2,',''',model_id,''''];
    %Reference model
    if use_ref_model
        hRef = plot(xrml,yrml,cm{5},'LineWidth',line_width);
        order_leg1 = [order_leg1,',hRef'];
        order_leg2 = sprintf('%s,''Reference model (%.2f%% misfit)''',...
                             order_leg2,cost_ref_model);
    end
    if strcmp(upper(kind_of_equiv_region),'REF')&&...
       strcmp(upper(model_plot),'BEST')
        hABest = plot(xml,ybmla,[cm{1},'--'],'LineWidth',line_width);
        order_leg1 = [order_leg1,',hABest'];
        order_leg2 = sprintf('%s,''Absolute best model (%.2f%% misfit)''',...
                             order_leg2,best_error_abs);
    end
    %Boreholes
    if use_boreholes
        hb = interp1(points(:,1),points(:,2),...
                     files{1}.gpso2d_results.data.borehole.lc);
        coor_xb = [];
        coor_yb = [];
        for i=1:length(files{1}.gpso2d_results.data.borehole.lc)
            coor_xb = [coor_xb files{1}.gpso2d_results.data.borehole.lc(i) ...
                       files{1}.gpso2d_results.data.borehole.lc(i) NaN];
            coor_yb = [coor_yb hb(i) hb(i)-d_bor(i) NaN];
            hBor = plot(coor_xb,coor_yb,cm{6},'LineWidth',1.5*line_width);
        end
        order_leg1 = [order_leg1,',hBor'];
        order_leg2 = [order_leg2,',''Borehole(s)'''];
    end
    %Search bounds
    if plot_search_bounds
        hSB = plot([xml NaN xml],[yusbl NaN ylsbl],bounds_colour,...
                   'LineWidth',line_width);
        order_leg1 = [order_leg1,',hSB'];
        order_leg2 = [order_leg2,',''Search bounds'''];
    end
    hold('off');
    grid('on');
    order_leg = [order_leg1,']',order_leg2,',''Location'',pos_legend);'];
    eval(order_leg);
    set(hLeg,'FontSize',legend_fsize);
    xlabel('Length along the profile (m)','FontSize',xylabel_fsize);
    ylabel('Height (m)','FontSize',xylabel_fsize);
    xlim([x_min x_max]);
    %UPPER AND LOWER WINDOW SIZES
    pos1 = get(p1,'Position');
    pos2 = get(p2,'Position');
    sep = pos1(2)-(pos2(2)+pos2(4));
    height1 = pos1(4)*factor_height_upper_window;
    height2 = pos2(4)+pos1(4)*(1.0-factor_height_upper_window)+...
                      sep*(1.0-factor_separation_windows);
    pos1(2) = pos2(2)+height2+sep*factor_separation_windows;
    pos1(4) = height1;
    pos2(4) = height2;
    set(p1,'Position',pos1);
    set(p2,'Position',pos2);
    %PRINT PLOT
    name_file = [ofp,filesep,model_file,'.',plot_format];
    if strcmp(upper(plot_format),'PDF')~=0
        orient('Landscape');
    else
        aspect_ratio = '';
    end
    print(name_file,['-d',plot_format],aspect_ratio);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HISTOGRAM PLOTS
%Check if these plots must be generated
if kind_of_information>1
    %Check if depth must be computed from the observed points on the surface
    if kind_of_information>2
        %Surface heights at the center of rectangles (row vector)
        hs = interp1(points(:,1),points(:,2),lc')';
        %For NaN values, use the htop values
        pos = isnan(hs);
        hs(pos) = htop(pos);
        %Depths of the rectangles upper side
        dht = hs-htop;
    else
        dht = zeros(1,nr);
    end
    %Depths of the different models
    d_best = dht+htop-best_model;
    d_mean = dht+htop-mean_model;
    d_median = dht+htop-median_model;
    d_mode = dht+htop-mode_model;
    d_best_a = dht+htop-best_model_abs;
    %Check if there is reference model
    if use_ref_model
        %Depths of reference model (NaNs in 'hrm' will be NaNs in 'd_rm')
        d_rm = dht+htop-hrm;
    end
    %Clear figure
    clf;
    %Rectangles
    for i=1:nr
        %Coordinates for the segments of the different models
        sx = [d_best(i) d_best(i) d_mean(i) d_mean(i) ...
              d_median(i) d_median(i) d_mode(i) d_mode(i) ...
              d_best_a(i) d_best_a(i)];
        sy = [0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0];
        %Empirical CDF plot
        p1 = subplot(2,1,1);
        dx_ecdf = (ecdf_mier{i}(2,1)-ecdf_mier{i}(1,1))/2.0;
        hStairs = stairs(dht(i)+ecdf_mier{i}(:,1),ecdf_mier{i}(:,2),...
                         colour_ecdfh);
        x_min = min(dht(i)+ecdf_mier{i}(:,1)-dx_ecdf);
        x_max = max(dht(i)+ecdf_mier{i}(:,1)+dx_ecdf);
        hold('on');
        if exist('OCTAVE_VERSION')
            hDepth = plot(sx(1:2),sy(1:2),cm{1},'LineWidth',line_width,...
                          sx(3:4),sy(3:4),cm{2},'LineWidth',line_width,...
                          sx(5:6),sy(5:6),cm{3},'LineWidth',line_width,...
                          sx(7:8),sy(7:8),cm{4},'LineWidth',line_width);
        else
            hDepth = plot(sx(1:2),sy(1:2),cm{1},sx(3:4),sy(3:4),cm{2},...
                          sx(5:6),sy(5:6),cm{3},sx(7:8),sy(7:8),cm{4},...
                          'LineWidth',line_width);
        end
        order_leg1 = 'hLeg = legend([hDepth(1),hDepth(2),hDepth(3),hDepth(4)';
        order_leg2 = [',''Best model'',''Mean model'',''Median model'',',...
                      '''Mode model'''];
        x_min = min([x_min sx(1:8)]);
        x_max = max([x_max sx(1:8)]);
        if use_ref_model&&(~isnan(d_rm(i)))
            sxrm = [d_rm(i) d_rm(i)];
            syrm = [0.0 1.0];
            hDrm = plot(sxrm,syrm,cm{5},'LineWidth',line_width);
            order_leg1 = [order_leg1,',hDrm'];
            order_leg2 = [order_leg2,',''Reference model'''];
            x_min = min([x_min sxrm]);
            x_max = max([x_max sxrm]);
        end
        if strcmp(upper(kind_of_equiv_region),'REF')
            hADepth = plot(sx(9:10),sy(9:10),[cm{1},'--'],...
                           'LineWidth',line_width);
            order_leg1 = [order_leg1,',hADepth'];
            order_leg2 = [order_leg2,',''Absolute best model'''];
            x_min = min([x_min sx(9:10)]);
            x_max = max([x_max sx(9:10)]);
        end
        if use_boreholes
            pos = files{1}.gpso2d_results.data.borehole.rectangle(:,2)==i;
            if sum(pos)
                sxb = [d_bor(pos) d_bor(pos)];
                syb = [0.0 1.0];
                hBor = plot(sxb,syb,cm{6},'LineWidth',line_width);
                order_leg1 = [order_leg1,',hBor'];
                order_leg2 = [order_leg2,',''Borehole'''];
                x_min = min([x_min sxb]);
                x_max = max([x_max sxb]);
            end
        end
        %Make x_min and x_max monotonic, if neccessary
        if x_min>x_max
            aux = x_min;
            x_min = x_max;
            x_max = aux;
        elseif x_min==x_max
            x_min = x_min-x_min/2.0;
            x_max = x_max+x_max/2.0;
        end
        order_leg = [order_leg1,']',...
                     order_leg2,',''Location'',pos_legend_ecdf);'];
        eval(order_leg);
        hold('off');
        grid('on');
        set(gca,'FontSize',ticks_fsize); %Before any FontSize configuration
        set(hStairs,'LineWidth',line_width);
        set(hLeg,'FontSize',legend_fsize);
        if strcmp(upper(kind_of_equiv_region),'REF')
            tit = sprintf(['Empirical CDF and histogram, (%d models ',...
                           'totally inside in tol<=%.3f%%/%.3f%%)\n',...
                           'Rectangle %d, L=%.3f m, top height=%.3f m'],...
                          sum(hist_mier{i}(:,2)),cost_upper_limit,...
                          cost_lower_limit,i,lc(i),htop(i));
        elseif strcmp(upper(kind_of_equiv_region),'REF')
            tit = sprintf(['Empirical CDF and histogram, (%d models ',...
                           'totally inside in LOCAL tol<=%.3f%%)\n',...
                           'Rectangle %d, L=%.3f m, top height=%.3f m'],...
                          sum(hist_mier{i}(:,2)),equivalent_region,i,lc(i),...
                          htop(i));
        else
            tit = sprintf(['Empirical CDF and histogram, (%d models ',...
                           'totally inside in tol<=%.3f%%)\nRectangle %d, ',...
                           'L=%.3f m, top height=%.3f m'],...
                          sum(hist_mier{i}(:,2)),equivalent_region,i,lc(i),...
                          htop(i));
        end
        if ~isempty(files{1}.gpso2d_results.data.subsoil.xy)
            tit = sprintf('%s\nX=%.3f m, Y=%.3f m',tit,...
                          files{1}.gpso2d_results.data.subsoil.xy(i,1),...
                          files{1}.gpso2d_results.data.subsoil.xy(i,2));
        end
        tit = sprintf('%s (%s)',tit,family_id);
        title(tit,'FontSize',title_fsize);
        ylabel('Probability','FontSize',xylabel_fsize);
        xlim([x_min x_max]);
        %Histogram plot
        p2 = subplot(2,1,2);
        hBar = bar(dht(i)+hist_mier{i}(:,1),hist_mier{i}(:,2),'hist');
        hold('on');
        ymax = max(get(gca,'YLim'));
        if exist('OCTAVE_VERSION')
            plot(sx(1:2),sy(1:2)*ymax,cm{1},'LineWidth',line_width,...
                 sx(3:4),sy(3:4)*ymax,cm{2},'LineWidth',line_width,...
                 sx(5:6),sy(5:6)*ymax,cm{3},'LineWidth',line_width,...
                 sx(7:8),sy(7:8)*ymax,cm{4},'LineWidth',line_width);
        else
            plot(sx(1:2),sy(1:2)*ymax,cm{1},sx(3:4),sy(3:4)*ymax,cm{2},...
                 sx(5:6),sy(5:6)*ymax,cm{3},sx(7:8),sy(7:8)*ymax,cm{4},...
                 'LineWidth',line_width);
        end
        if use_ref_model&&(~isnan(d_rm(i)))
            plot(sxrm,syrm*ymax,cm{5},'LineWidth',line_width);
        end
        if strcmp(upper(kind_of_equiv_region),'REF')
            plot(sx(9:10),sy(9:10),[cm{1},'--'],'LineWidth',line_width);
        end
        if use_boreholes
            pos = files{1}.gpso2d_results.data.borehole.rectangle(:,2)==i;
            if sum(pos)
                hBor = plot(sxb,syb*ymax,cm{6},'LineWidth',line_width);
            end
        end
        hold('off');
        grid('on');
        set(hBar,'FaceColor',colour_ecdfh);
        set(gca,'FontSize',ticks_fsize); %Before any FontSize configuration
        xlabel('Rectangle depth (m)','FontSize',xylabel_fsize);
        ylabel('Number of occurrences','FontSize',xylabel_fsize);
        xlim([x_min x_max]);
        %UPPER AND LOWER WINDOW SEPARATION
        pos1 = get(p1,'Position');
        pos2 = get(p2,'Position');
        sep = pos1(2)-(pos2(2)+pos2(4));
        height1 = pos1(4)+sep*(1.0-factor_separation_windows_hists)/2.0;
        height2 = pos2(4)+sep*(1.0-factor_separation_windows_hists)/2.0;
        height1 = height1*factor_height_hists;
        height2 = height2*factor_height_hists;
        pos1(2) = pos2(2)+height2+sep*factor_separation_windows_hists;
        pos1(4) = height1;
        pos2(4) = height2;
        set(p1,'Position',pos1);
        set(p2,'Position',pos2);
        %PRINT RESULTS
        name_file = sprintf('%s%secdf-rectangle-%03d.%s',...
                            ofpcdf,filesep,i,plot_format);
        if strcmp(upper(plot_format),'PDF')~=0
            orient('Landscape');
        else
            aspect_ratio = '';
        end
        print(name_file,['-d',plot_format],aspect_ratio);
    end
    %Check if there are trend parameters
    if files{1}.gpso2d_results.data.trend.regional_trend
        %Loop over all trend parameters
        for i=1:nt
            %X label
            x_label = sprintf('Parameter value (m/s^2*%E',1.0/best_model_f_SI);
            if (nt-i)==0
                x_label = [x_label,')'];
            elseif (nt-i)==1
                x_label = [x_label,'/m)'];
            else
                x_label = [x_label,'/m^',num2str(nt-1),')'];
            end
            %Coordinates for the segments of the different models
            sx = [best_trend(i) best_trend(i) mean_trend(i) mean_trend(i) ...
                  median_trend(i) median_trend(i) mode_trend(i) mode_trend(i)];
            sy = [0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0];
            %Empirical CDF plot
            subplot(2,1,1);
            dx_ecdf = (ecdf_tier{i}(2,1)-ecdf_tier{i}(1,1))/2.0;
            hStairs = stairs(ecdf_tier{i}(:,1),ecdf_tier{i}(:,2),colour_ecdfh);
            x_min = min(ecdf_tier{i}(:,1)-dx_ecdf);
            x_max = max(ecdf_tier{i}(:,1)+dx_ecdf);
            hold('on');
            hTrend = plot(sx(1:2),sy(1:2),cm{1},sx(3:4),sy(3:4),cm{2},...
                          sx(5:6),sy(5:6),cm{3},sx(7:8),sy(7:8),cm{4},...
                          'LineWidth',line_width);
            x_min = min([x_min sx(1:8)]);
            x_max = max([x_max sx(1:8)]);
            hLeg = legend(hTrend,'Best value','Mean value','Median value',...
                          'Mode value','Location',pos_legend_ecdf);
            hold('off');
            grid('on');
            set(gca,'FontSize',ticks_fsize); %Before any FontSize configuration
            set(hStairs,'LineWidth',line_width);
            set(hLeg,'FontSize',legend_fsize);
            if strcmp(upper(kind_of_equiv_region),'REF')
                tit = sprintf(['Empirical CDF and histogram, (%d models ',...
                               'totally inside in tol<=%.3f%%/%.3f%%)\n',...
                               'Trend parameter a%d (%s)'],...
                              sum(hist_tier{i}(:,2)),cost_upper_limit,...
                              cost_lower_limit,nt-i,family_id);
            elseif strcmp(upper(kind_of_equiv_region),'REF')
                tit = sprintf(['Empirical CDF and histogram, (%d models ',...
                               'totally inside in LOCAL tol<=%.3f%%)\n',...
                               'Trend parameter a%d (%s)'],...
                              sum(hist_tier{i}(:,2)),equivalent_region,nt-i,...
                              family_id);
            else
                tit = sprintf(['Empirical CDF and histogram, (%d models ',...
                               'totally inside in tol<=%.3f%%)\nTrend ',...
                               'parameter a%d (%s)'],sum(hist_tier{i}(:,2)),...
                               equivalent_region,nt-i,family_id);
            end
            title(tit,'FontSize',title_fsize);
            ylabel('Probability','FontSize',xylabel_fsize);
            xlim([x_min x_max]);
            %Histogram plot
            subplot(2,1,2);
            hBar = bar(hist_tier{i}(:,1),hist_tier{i}(:,2),'hist');
            hold('on');
            ymax = max(get(gca,'YLim'));
            plot(sx(1:2),sy(1:2)*ymax,cm{1},sx(3:4),sy(3:4)*ymax,cm{2},...
                 sx(5:6),sy(5:6)*ymax,cm{3},sx(7:8),sy(7:8)*ymax,cm{4},...
                 'LineWidth',line_width);
            hold('off');
            grid('on');
            set(hBar,'FaceColor',colour_ecdfh);
            set(gca,'FontSize',ticks_fsize); %Before any FontSize configuration
            xlabel(x_label,'FontSize',xylabel_fsize);
            ylabel('Number of occurrences','FontSize',xylabel_fsize);
            xlim([x_min x_max]);
            %Print results
            name_file = sprintf('%s%secdf-trend-a%d.%s',...
                                ofpcdf,filesep,nt-i,plot_format);
            if strcmp(upper(plot_format),'PDF')~=0
                orient('Landscape');
            else
                aspect_ratio = '';
            end
            print(name_file,['-d',plot_format],aspect_ratio);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SUMMARY FILE
%Data in the first file
if files{1}.gpso2d_results.opfun.only_points_on_sediments~=0
    ps = files{1}.gpso2d_results.data.obs.ps;
    working_points1 = files{1}.gpso2d_results.data.obs.lh(ps,:);
    working_points_g1 = files{1}.gpso2d_results.data.obs.gSI(ps);
else
    working_points1 = files{1}.gpso2d_results.data.obs.lh;
    working_points_g1 = files{1}.gpso2d_results.data.obs.gSI;
end
subsoil1 = [files{1}.gpso2d_results.data.subsoil.l ...
            files{1}.gpso2d_results.data.subsoil.htop];
density1 = load(files{1}.gpso2d_results.data.density.density_file);
if files{1}.gpso2d_results.data.density.use_h_density_file~=0
    hdensity1 = load(files{1}.gpso2d_results.data.density.h_density_file);
end
if files{1}.gpso2d_results.data.borehole.use_boreholes_file~=0
    borehole1 = load(files{1}.gpso2d_results.data.borehole.boreholes_file);
end
%Summary
name_file = [output_folder,filesep,'summary.txt'];
idf = fopen(name_file,'wb');
fprintf(idf,'Files involved in the analysis:\n');
for i=1:nfiles
    fprintf(idf,'%s\n',files{i}.gpso2d_results.filename);
end
fprintf(idf,'\n');
for i=1:nfiles
    fprintf(idf,'* %s\n',files{i}.gpso2d_results.filename);
    %PSO member, swarm size, and iterations
    fprintf(idf,'  PSO family member:.......................... %s\n',...
            files{i}.gpso2d_results.options.pso.esquema);
    fprintf(idf,'  Delta t range:.............................. [%.2f %.2f]\n',...
            files{i}.gpso2d_results.opfun.deltatmin,...
            files{i}.gpso2d_results.opfun.deltatmax);
    fprintf(idf,'  Swarm size:................................. %d\n',...
            files{i}.gpso2d_results.options.pso.size);
    fprintf(idf,'  Number of iterations:....................... %d\n',...
            files{i}.gpso2d_results.options.pso.maxiter);
    %Norm
    fprintf(idf,'  Norm:....................................... L%d',...
            files{i}.gpso2d_results.opfun.norm_cost_function);
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.opfun.norm_cost_function~=...
           files{1}.gpso2d_results.opfun.norm_cost_function
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Weights
    fprintf(idf,'  Weights in the cost function computation:... ');
    if files{i}.gpso2d_results.data.obs.use_weights~=0
        fprintf(idf,'YES');
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.data.obs.use_weights~=...
           files{1}.gpso2d_results.data.obs.use_weights
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Used observations
    fprintf(idf,'  Used observations:.......................... ');
    if files{i}.gpso2d_results.opfun.only_points_on_sediments==0
        fprintf(idf,'ALL');
    else
        fprintf(idf,'ONLY POINTS ON SEDIMENTS');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.opfun.only_points_on_sediments~=...
           files{1}.gpso2d_results.opfun.only_points_on_sediments
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Regional trend
    fprintf(idf,'  Regional trend:............................. ');
    if files{i}.gpso2d_results.data.trend.use_trend_file~=0
        if files{i}.gpso2d_results.data.trend.regional_trend~=0
            fprintf(idf,'INVERTED');
        else
            fprintf(idf,'IMPOSED');
        end
        fprintf(idf,', GRADE %d',size(tier,2)-1);
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.data.trend.use_trend_file~=...
           files{1}.gpso2d_results.data.trend.use_trend_file
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Filtering
    fprintf(idf,'  Filtering:.................................. ');
    if files{i}.gpso2d_results.data.filt.use_filter~=0
        fprintf(idf,'YES (%d PASS(ES))',...
                files{i}.gpso2d_results.data.filt.use_filter);
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.data.filt.use_filter~=...
           files{1}.gpso2d_results.data.filt.use_filter
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Filter window width
    fprintf(idf,'  Filter window width(s):..................... [');
    nfw = length(files{i}.gpso2d_results.data.filt.filter_size);
    for j=1:nfw
        fprintf(idf,'%d',files{i}.gpso2d_results.data.filt.filter_size(j));
        if j~=nfw
            fprintf(idf,' ');
        end
        if (i~=1)&&...
           ((nfw~=length(files{1}.gpso2d_results.data.filt.filter_size))||...
            (files{i}.gpso2d_results.data.filt.filter_size(j)~=...
             files{1}.gpso2d_results.data.filt.filter_size(j)))
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        end
    end
    fprintf(idf,']\n');
    %Filter weight
    fprintf(idf,'  Filtering weighting using prisms width:..... ');
    if files{i}.gpso2d_results.data.filt.filter_weight_width~=0
        fprintf(idf,'YES');
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.data.filt.filter_weight_width~=...
           files{1}.gpso2d_results.data.filt.filter_weight_width
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Filtering in the first iteration
    fprintf(idf,'  Filtering in the first iteration:........... ');
    if files{i}.gpso2d_results.extra.filt_first_it_o~=0
        fprintf(idf,'YES');
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.extra.filt_first_it_o~=...
           files{1}.gpso2d_results.extra.filt_first_it_o
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Subprisms
    fprintf(idf,'  Subprism size (if applicable):.............. ');
    if files{i}.gpso2d_results.opfun.subprism_size==0.0
        fprintf(idf,'NO SUBPRISMS');
    else
        fprintf(idf,'%.2f',files{i}.gpso2d_results.opfun.subprism_size);
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.opfun.subprism_size~=...
           files{1}.gpso2d_results.opfun.subprism_size
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Horizontal density definition
    fprintf(idf,'  Horizontal density definition:.............. ');
    if files{i}.gpso2d_results.data.density.use_h_density_file~=0
        fprintf(idf,'YES');
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.data.density.use_h_density_file~=...
           files{1}.gpso2d_results.data.density.use_h_density_file
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Boreholes
    fprintf(idf,'  Using boreholes as absolute constraints:.... ');
    if files{i}.gpso2d_results.data.borehole.use_boreholes_file~=0
        fprintf(idf,'YES');
    else
        fprintf(idf,'NO');
    end
    if i==1
        fprintf(idf,'\n');
    elseif files{i}.gpso2d_results.data.borehole.use_boreholes_file~=0~=...
           files{1}.gpso2d_results.data.borehole.use_boreholes_file~=0
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
    else
        fprintf(idf,'\n');
    end
    %Observations file
    fprintf(idf,'  Observations file:.......................... %s',...
            files{i}.gpso2d_results.data.obs.observations_file);
    if i==1
        fprintf(idf,'\n');
    else
        if strcmp(files{i}.gpso2d_results.data.obs.observations_file,...
                  files{1}.gpso2d_results.data.obs.observations_file)==0
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        end
        if files{i}.gpso2d_results.opfun.only_points_on_sediments~=0
            ps = files{i}.gpso2d_results.data.obs.ps;
            working_pointsi = files{i}.gpso2d_results.data.obs.lh(ps,:);
            working_points_gi = files{i}.gpso2d_results.data.obs.gSI(ps);
        else
            working_pointsi = files{i}.gpso2d_results.data.obs.lh;
            working_points_gi = files{i}.gpso2d_results.data.obs.gSI;
        end
        if (sum(sum(working_pointsi~=working_points1))~=0)||...
           (sum(sum(working_points_gi~=working_points_g1))~=0)
            fprintf(idf,[' *****WARNING: THE POINTS USED ARE NOT THE SAME ',...
                         'AS THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        else
            fprintf(idf,'\n');
        end
    end
    %Subsoil file
    fprintf(idf,'  Subsoil file:............................... %s',...
            files{i}.gpso2d_results.data.subsoil.subsoil_file);
    if i==1
        fprintf(idf,'\n');
    else
        if strcmp(files{i}.gpso2d_results.data.subsoil.subsoil_file,...
                  files{1}.gpso2d_results.data.subsoil.subsoil_file)==0
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        end
        subsoili = [files{i}.gpso2d_results.data.subsoil.l ...
                    files{i}.gpso2d_results.data.subsoil.htop];
        if sum(sum(subsoili~=subsoil1))~=0
            fprintf(idf,[' *****WARNING: THE SUBSOIL DEFINITION USED IS ',...
                         'NOT THE SAME AS THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        else
            fprintf(idf,'\n');
        end
    end
    %Density file
    fprintf(idf,'  Density definition file:.................... %s',...
            files{i}.gpso2d_results.data.density.density_file);
    if i==1
        fprintf(idf,'\n');
    else
        if strcmp(files{i}.gpso2d_results.data.density.density_file,...
                  files{1}.gpso2d_results.data.density.density_file)==0
            fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE SAME AS ',...
                         'THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        end
        densityi = load(files{i}.gpso2d_results.data.density.density_file);
        if sum(sum(densityi~=density1))~=0
            fprintf(idf,[' *****WARNING: THE DENSITY DEFINITION USED IS ',...
                         'NOT THE SAME AS THE CORRESPONDING IN %s\n'],...
                    files{1}.gpso2d_results.filename);
        else
            fprintf(idf,'\n');
        end
    end
    %Horizontal density file
    if (files{i}.gpso2d_results.data.density.use_h_density_file~=0)&&...
       (files{1}.gpso2d_results.data.density.use_h_density_file~=0)
        fprintf(idf,'  Horizontal density definition file:......... %s',...
                files{i}.gpso2d_results.data.density.h_density_file);
        if i==1
            fprintf(idf,'\n');
        else
            if strcmp(files{i}.gpso2d_results.data.density.h_density_file,...
                      files{1}.gpso2d_results.data.density.h_density_file)==0
                fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE ',...
                             'SAME AS THE CORRESPONDING IN %s\n'],...
                        files{1}.gpso2d_results.filename);
            end
          hdensityi = load(files{i}.gpso2d_results.data.density.h_density_file);
            if sum(sum(hdensityi~=hdensity1))~=0
                fprintf(idf,[' *****WARNING: THE HORIZONTAL DENSITY ',...
                             'DEFINITION USED  IS NOT THE SAME AS THE ',...
                             'CORRESPONDING IN %s\n'],...
                        files{1}.gpso2d_results.filename);
            else
                fprintf(idf,'\n');
            end
        end
    end
    %Filter file
    if (files{i}.gpso2d_results.data.filt.use_filter~=0)&&...
       (files{1}.gpso2d_results.data.filt.use_filter~=0)
        fprintf(idf,'  Filter file:................................ %s',...
                files{i}.gpso2d_results.data.filt.filter_file);
        if i==1
            fprintf(idf,'\n');
        else
            if strcmp(files{i}.gpso2d_results.data.filt.filter_file,...
                      files{1}.gpso2d_results.data.filt.filter_file)==0
                fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE ',...
                             'SAME AS THE CORRESPONDING IN %s\n'],...
                        files{1}.gpso2d_results.filename);
            end
            if length(files{i}.gpso2d_results.data.filt.filter_coef)~=...
               length(files{1}.gpso2d_results.data.filt.filter_coef)
                fprintf(idf,[' *****WARNING: THE FILTER DEFINITION USED IS ',...
                             'NOT THE SAME AS THE CORRESPONDING IN %s\n'],...
                        files{1}.gpso2d_results.filename);
            else
                exist_error = 0;
                for j=1:length(files{i}.gpso2d_results.data.filt.filter_coef)
                    if sum(files{i}.gpso2d_results.data.filt.filter_coef{j}~=...
                           files{1}.gpso2d_results.data.filt.filter_coef{j})~=0
                        fprintf(idf,[' *****WARNING: THE FILTER DEFINITION ',...
                                     'USED IS NOT THE SAME AS THE ',...
                                     'CORRESPONDING IN %s\n'],...
                                files{1}.gpso2d_results.filename);
                        exist_error = 1;
                        break;
                    end
                end
                if ~exist_error
                    fprintf(idf,'\n');
                end
            end
        end
    end
    %Boreholes file
    if (files{i}.gpso2d_results.data.borehole.use_boreholes_file~=0)&&...
       (files{1}.gpso2d_results.data.borehole.use_boreholes_file~=0)
        fprintf(idf,'  Boreholes file:............................. %s',...
                files{i}.gpso2d_results.data.borehole.boreholes_file);
        if i==1
            fprintf(idf,'\n');
        else
            if strcmp(files{i}.gpso2d_results.data.borehole.boreholes_file,...
                      files{1}.gpso2d_results.data.borehole.boreholes_file)==0
                fprintf(idf,[' *****WARNING: THIS PARAMETER IS NOT THE ',...
                             'SAME AS THE CORRESPONDING IN %s\n'],...
                        files{1}.gpso2d_results.filename);
            end
         boreholei = load(files{i}.gpso2d_results.data.borehole.boreholes_file);
            if isequaln(boreholei,borehole1)==0
                fprintf(idf,[' *****WARNING: THE BOREHOLES USED ARE NOT ',...
                             'THE SAME AS THE CORRESPONDING IN %s\n'],...
                        files{1}.gpso2d_results.filename);
            else
                fprintf(idf,'\n');
            end
        end
    end
end
fclose(idf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are met:
%
%- Redistributions of source code must retain the above copyright notice, this
%  list of conditions and the following disclaimer.
%- Redistributions in binary form must reproduce the above copyright notice,
%  this list of conditions and the following disclaimer in the documentation
%  and/or other materials provided with the distribution.
%- Neither the name of the copyright holders nor the names of its contributors
%  may be used to endorse or promote products derived from this software without
%  specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED.