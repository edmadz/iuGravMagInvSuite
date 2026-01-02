%*******************************************************************************
% Function: filterCoef = gpso2d_CreateFilterCoef(kind,stdev)
%           filterCoef = gpso2d_CreateFilterCoef(kind,stdev,file)
%
% Purpose:  Generate filter coefficients according to a distribution
%
% Inputs:   - kind: Kind of distribution
%                   - 'NORMAL': Normal distribution
%                   - 'TRIANG': Treiangular distribution
%           - stdev: Standard deviation of the distribution
%           - file: Name of a file for storing the results (optional)
%
% Outputs:  - filterCoef: Column vector with the filter coefficients (normalized
%                         to 1 at central element), according to the selected
%                         distribution. The width of the window covers 99.9% of
%                         the area under the distribution. If 'file' argument is
%                         present, a file containing the coefficients is created
%
% Note: This function does not perform any check about the input arguments
%
% History:  19-02-2025: Function creation
%                       José Luis García Pallero, jgpallero@gmail.com
%           03-03-2025: Change name from grav2d_ to gpso2d_
%                       José Luis García Pallero, jgpallero@gmail.com
%*******************************************************************************

function [filterCoef] = gpso2d_CreateFilterCoef(kind,stdev,file)

%Check the kind of didtribution
if strcmp(upper(kind),'NORM')
    %X coordinates
    x = round(norminv(0.999,0,stdev));
    x = [-x:x]';
    %Filter coefficients
    filterCoef = exp(-x.^2./(2.0*stdev^2));
elseif strcmp(upper(kind),'TRIANG')
    %Base of the triangle as integer number
    d = sqrt(24.0*stdev^2);
    %First half of window
    y = abs(1.0+2.0/d*[-round(d/2.0):0]);
    %Filter coefficients
    filterCoef = [y fliplr(y(1:end-1))]';
else
    error('Argument ''kind'' is not correct');
end
%Output file
if nargin>2
    idf = fopen(file,'wb');
    fprintf(idf,'%%Filter coefficients\n');
    fprintf(idf,'%.6f\n',filterCoef);
    fclose(idf);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright (c) 2025, J.L.G. Pallero, jgpallero@gmail.com,
%                    J.L. Fernández Martínez, jlfm@uniovi.es
%                    Z. Fernández Muñiz, zulima@uniovi.es
%                    Sylvain Bonvalot, sylvain.bonvalot@ird.fr
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
