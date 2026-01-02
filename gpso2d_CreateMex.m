%This script creates the mex files written in C
%Compiling using OpenMP: 0/1 -> no/yes
omp = 1;
%Compiler options
woptions = '-Wall';
% woptions = '-Wall -Wextra';
optoptions = '-O3';
optoptionspc = '/O2';
ompoptions = '-fopenmp';
ompoptionspc = '/openmp';
%Check if I want OpenMP
if omp
    %Check if we are in GNU Octave or Matlab
    if exist('OCTAVE_VERSION')
        %Compiler options
        options = [' ',woptions,' ',optoptions,' ',ompoptions,' '];
    else
        %Check between MS Windows and no MS Windows
        if ispc~=0
            %Compiler options
            options = [' COMPFLAGS="$COMPFLAGS ',...
                       optoptionspc,' ',ompoptionspc,'" '];
        else
            %Compiler options
            options = [' CFLAGS="$CFLAGS ',...
                       woptions,' ',optoptions,' ',ompoptions,...
                       '" LDFLAGS="$LDFLAGS ',ompoptions,'"'];
        end
    end
else
    %Check if we are in GNU Octave or Matlab
    if exist('OCTAVE_VERSION')
        %Compiler options
        options = [' ',woptions,' ',optoptions,' '];
    else
        %Check between MS Windows and no MS Windows
        if ispc~=0
            %Compiler options
            options = [' COMPFLAGS="$COMPFLAGS ',optoptionspc,'" '];
        else
            %Compiler options
            options = [' CFLAGS="$CFLAGS ',woptions,' ',optoptions,'"'];
        end
    end
end
%Compilation of gpso2d_GravityRectangle.c
order = sprintf('mex %s gpso2d_GravityRectangle.c',options);
eval(order);
%Compilation of gpso2d_GravityModels.c
order = sprintf('mex %s gpso2d_GravityModels.c',options);
eval(order);
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
