%*******************************************************************************
% Function: gpso2d_Ecdf(data);
%           f = gpso2d_Ecdf(data);
%           [f,x] = gpso2d_Ecdf(data);
%
% Purpose:  Compute the empirical cumulative distribution function
%
% Inputs:   - data: Vector (row or column) containing the data. It can contain
%                   NaN data, which will be eliminated
%
% Outputs:  - Two possible behaviors:
%             - No output data: The empirical cumulative density function will
%                               be plotted
%             - With 1 or two output data:
%               - f: Column vector (even if the argument 'data' is a row vector)
%                    containing the values of the empirical cumulative
%                    distibution function evaluated at the corresponding value
%                    of x
%               - x: Column vector (even if the argument 'data' is a row vector)
%                    containing the values where the empirical cumulative is
%                    evaluated
%
% Note: This function does not perform any check about the input arguments
%
% History:  09-11-2018: Function creation
%                       José Luis García Pallero, jgpallero@gmail.com
%           24-06-2023: Use Matlab's own function if it is possible
%                       José Luis García Pallero, jgpallero@gmail.com
%           01-03-2025: Works (slow) although Statistics package not present
%                       José Luis García Pallero, jgpallero@gmail.com
%           03-03-2025: Change name from grav2d_ to gpso2d_
%                       José Luis García Pallero, jgpallero@gmail.com
%*******************************************************************************

function [f,x] = gpso2d_Ecdf(data)

%Try if the function ecdf() exists
try
    %ecdf() function exists for sure in Matlab (Statistics package)
    if nargout==0
        ecdf(data);
    else
        [f,x] = ecdf(data);
    end
catch
    %Retain the data different to NaN, sort them and transform to column vector
    data = data(~isnan(data));
    data = sort(data);
    data = data(:);
    %Output values
    x = unique(data);
    f = x*0.0;
    %Number of data, original and output
    n = length(data);
    nx = length(x);
    %Loop through unique data
    for i=1:nx
        %Number of data less or equal to current data relative to the total
        f(i) = sum(data<=x(i))/n;
    end
    %Add 0.0 as first value of f and repeat the first value of x
    f(2:nx+1) = f;
    f(1) = 0.0;
    x(2:nx+1) = x;
    x(1) = x(2);
    %Plot data, if it is needed
    if nargout==0
        stairs(x,f);
        xlabel('x');
        ylabel('F(x)');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright (c) 2018-2025, J.L.G. Pallero, jgpallero@gmail.com,
%                         J.L. Fernández Martínez, jlfm@uniovi.es
%                         Z. Fernández Muñiz, zulima@uniovi.es
%                         Sylvain Bonvalot, sylvain.bonvalot@ird.fr
%
%All rights reserved.
%
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
%DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT,
%INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
%OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
%ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
