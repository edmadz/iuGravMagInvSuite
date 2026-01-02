%*******************************************************************************
% Function: dataf = gpso2d_AverageFilter(n,data,cont,fcoef,fixd,fixw,weight)
%           dataf = gpso2d_AverageFilter(n,data,cont,fcoef,fixd,fixw,weight,fwc)
%
% Purpose:  Applies a weighted average filter to a data vector
%
% Inputs:   - n: Number of times the filter is applied
%           - data: Vector containing the data to filter
%           - cont: Two-column matrix with the definition of the contiguous data
%                   in the vector 'data':
%                   - Col. 1: Position (referred to 'data') of the first point
%                             for the contiguous set
%                   - Col. 2: Position (referred to 'data') of the last point
%                             for the contiguous set
%           - fcoef: Cell array containing in each position a vector of odd
%                    length with the filter window coefficients. The filtering
%                    process will be applied for each window. The filtering will
%                    be repeated 'n' times, being each time the application of
%                    a filtering for each window defined in 'fcoef'
%           - fixd: Vector of the same length as 'data' containing identifiers
%                   of fixed data. Two possible values:
%                   - 0: The data is not fixed
%                   - 1: The data is fixed, so the filter coefficient
%                        corresponding to the data will be multiplied by 'fixw'
%           - fixw: Weight factor to apply to the filter coefficient
%                   corresponding to the fixed data. Three possible values:
%                   - 0: No special filter is applied to the fixed data
%                   - 1: Previous filtering is applied in the surroundings
%                        (filter window size) of the fixed point prior to the
%                        general filter is applied 'n' times
%                   - Greater than 1:  Previous filtering is applied in the
%                        surroundings (filter window size) of the fixed point
%                        prior to the general filter is applied 'n' times with
%                        the value of 'fixw'
%           - weight: Identifier for weight application:
%                     - 0: No weight application
%                     - Other than 0: Weight application
%           - fwc: Vector of the same length as 'data' containing the weight of
%                  each one. This argument is not mandatory if weight=0
%
% Outputs:  - dataf: Vector containing the filtered data
%
% Note: This function does not perform any check about the input arguments
%
%*******************************************************************************

function [dataf] = gpso2d_AverageFilter(n,data,cont,fcoef,fixd,fixw,weight,fwc)

%Convert data vector to row
data = data(:)';
nd = length(data);
%Number of filter windows
nfw = length(fcoef);
%Convert all vectors to row
for i=1:nfw
    fcoef{i} = fcoef{i}(:)';
end
fixd = fixd(:)';
if weight~=0
    fwc = fwc(:)';
else
    fwc = ones(1,nd);
end
%Output vector
dataf = data;
%Number of coefficientes of the first window
nc = length(fcoef{1});
%Check if the window is 1 length or there is only one data
if (n==0)||(nd<=1)||(nc<=1)
    return;
end
%Half window
hw = floor(nc/2);
%Possible fixed data
pos_fixd = fixd~=0;
%Assign to fixd the fixw value to fixed positions and value 1 to the others
fixd(:) = 1.0;
if fixw~=0.0
    fixd(pos_fixd) = fixw;
end
%Number of subsegments
ns = size(cont,1);
%Loop over subsegments
for i=1:ns
    %Subsegment positions
    pos_s = cont(i,1):cont(i,2);
    nps = length(pos_s);
    %Data corresponding to the subsegment
    data_s = data(pos_s);
    fixd_s = fixd(pos_s);
    pos_fixd_s = pos_fixd(pos_s);
    fwc_s = fwc(pos_s);
    %Check if fixed data exist and prior filtering is needed
    %This previous filtering is applied only with the first window
    if (fixw>0)&&(sum(pos_fixd_s)>=1)
        %Apply filtering
        ffix = gpso2d_AverageFilterAux(data_s,fcoef{1},fwc_s,fixd_s);
        %Loop over the fixed data
        for j=1:nps
            %If the data is not fixed, next point
            if pos_fixd_s(j)==0
                continue;
            end
            %Loop over half window
            for k=(j-hw):(j+hw)
                %Assign de filtered data
                if (k>=1)&&(k<=nps)
                    if pos_fixd_s(k)==0
                        data_s(k) = ffix(k);
                    end
                end
            end
        end
    end
    %Apply the filter over the data
    for j=1:n
        %Loop through all windows
        for k=1:nfw
            data_s_f = gpso2d_AverageFilterAux(data_s,fcoef{k},fwc_s,fixd_s);
            %Recover the fixed data
            data_s_f(pos_fixd_s) = data_s(pos_fixd_s);
            %Update the data to filter
            data_s = data_s_f;
        end
    end
    %Assign the result to the output vector
    dataf(pos_s) = data_s;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dfilt] = gpso2d_AverageFilterAux(data,fcoef,fweight1,fweight2)

%Output vector
dfilt = data;
%Number of data
nd = length(data);
%Half window
hw = floor(length(fcoef)/2);
%If the filter window is of length 0, the filtered data is the original data
if (nd==1)||(hw==0)
    return;
end
%Check if weights are provided
if nargin<3
    fweight1 = ones(1,nd);
end
if nargin<4
    fweight2 = ones(1,nd);
end
%Zero padding
data = [zeros(1,hw) data zeros(1,hw)];
fweight1 = [zeros(1,hw) fweight1 zeros(1,hw)];
fweight2 = [zeros(1,hw) fweight2 zeros(1,hw)];
%Loop over elements
for i=(hw+1):(hw+nd)
    %Positions in the original vector
    pos = (i-hw):(i+hw);
    %Coefficients
    coef = fcoef.*fweight1(pos).*fweight2(pos);
    %Filtering
    dfilt(i-hw) = sum(coef.*data(pos))/sum(coef);
end

