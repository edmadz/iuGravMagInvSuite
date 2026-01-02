%PSO INVERSION SCRIPT
clear('all');
%Load configurations
run('./examples/data/example-f/configuration/inversion_configuration.m');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%THE USER SHOULD NOT MODIFY THE CODE FROM THIS POINT ON%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check deltats definition
if ismatrix(deltats)
    %Dimensions of deltats
    [dtr,dtc] = size(deltats);
    %Check for errors
    if (dtr<1)||(dtc~=2)
        error('The variable ''deltats'' must be a two-column matrix');
    end
else
    error('The variable ''deltats'' must be a matrix');
end
%Check repeat definition
if isscalar(repeat)
    repeat = round(repeat);
    if repeat<1
        error('The variable ''repeat'' must greater or equal than 1');
    end
else
    error('The variable ''repeat'' must be a scalar');
end
%The pso_family_members variable must be a cell array
if iscell(pso_family_members)
    %Loop over all PSO family members
    for i=1:length(pso_family_members)
        %Extract the family member name
        pso_family_member = pso_family_members{i};
        %Prefix for the output file
        prefix_output = sprintf('%s%s_',output_prefix,pso_family_member);
        %Loop over detats values
        for j=1:dtr
            %Deltat values
            deltat = deltats(j,:);
            %Loop over repetitions
            for k=1:repeat
                %Output folder
                folder_output = sprintf('%s/%s/%.2f-%.2f-%d/',...
                                        output_folder,pso_family_member,...
                                        deltat(1),deltat(2),k);
                %Print information on screen
                fprintf(1,['\n\nPSO family member: %s, ',...
                           'deltat=[%.2f %.2f], repetition=%d\n\n'],...
                        pso_family_member,deltat(1),deltat(2),k);
                %Generate basic structures
                gpso2d_BasicStructures;
                %PSO computation
                gpso2d_PSO;
            end
        end
    end
else
    error('The variable ''pso_family_members'' must be a cell array');
end
