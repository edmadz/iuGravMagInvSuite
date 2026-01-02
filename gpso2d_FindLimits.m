%*******************************************************************************
% Purpose:  Auxiliary function to find limits of equivalence region
%
% Inputs:   - uplo: Identifier of upper or lower model ('UPPER'/'LOWER')
%           - mier: 'mier'
%           - tier: 'tier'
%           - mft_mier: column vector with relative misfit of each row in 'mier'
%           - bm: 'best_model' or, in general, a reference model
%           - bt: 'best_trend'
%           - er: 'equivalent_region'
%           - ed: 'equivalent_region_tol'
%           - rect: 'rect'
%           - rho: files{1}.gpso2d_results.data.subsoil.density.rho
%           - pts: files{1}.gpso2d_results.data.obs.lh
%           - pu: 'pos_p'
%           - w: 'weights'
%           - ncf: 'ncf'
%           - o_t: 'o_t' (in working units)
%           - f_SI: 'best_model_f_SI'
%
% Outputs:  - ull: Found model (row vector)
%           - ullt: Found trend model (row vector)
%           - mft: Cost function of the found limit
%           - it: Number of iterations employed in the computations
%
% History:  07-07-2018: Function creation
%                       José Luis García Pallero, jgpallero@gmail.com
%           14-10-2018: Code optimization
%                       José Luis García Pallero, jgpallero@gmail.com
%           02-03-2025: Code to individual function for GNU Octave
%                       José Luis García Pallero, jgpallero@gmail.com
%           03-03-2025: Change name from grav2d_ to gpso2d_
%                       José Luis García Pallero, jgpallero@gmail.com
%*******************************************************************************

function [ull,ullt,mft,it] = gpso2d_FindLimits(uplo,mier,tier,mft_mier,bm,bt,...
                                               er,ed,rect,rho,pts,pu,w,ncf,...
                                               o_t,f_SI)

    %Relative misfit delta for crude search
    delta_er = 1.0;
    %Maximum number of models to use in crude search
    nmm = 10;
    %Probability increment and division factor for first search based on ECDF
    pinc = 0.01; %En tanto por 1
    pd = 1.25;
    pinc_tol = 1.0e-8;
    %Maximum correction factor for second search based in maximum difference
    mcf = 10.0;
    mcf_tol = 1.0e-6;
    %Number of iterations for print message
    ipm = 100;
    %Check for kind of limit to search
    if strcmp(upper(uplo),'UPPER')
        %Upper limit
        uplo = 0;
    else
        %Lower limit
        uplo = 1;
    end
    %Check if there is regional trend
    is_trend = 0;
    if ~isempty(tier)
        is_trend = 1;
        nt = size(tier,2);
        ullt = bt;
    else
        ullt = [];
    end
    %Auxiliary variables
    nr = size(mier,2);
    ull = bm;
    o_t = o_t(pu).*w(pu);
    n_o_t = norm(o_t,ncf);
    it = 0;
    %Cost function computation of the reference model
    rect(:,3) = bm';
    grav = gpso2d_GravityComputation(rect,rho,pts)'./f_SI;
    grav = grav(pu).*w(pu);
    mft = norm(o_t-grav,ncf)/n_o_t*100.0;
    if mft>er
        error(['There are no models below the working equivalent region ',...
               '(%.2f%%)\nIf we are sampling around a reference model, ',...
               'this model cost function\n-or the cost function of the ',...
               'generated model nearest to it- (%.2f%%)\nis greater than ',...
               'the working equivalent region'],er,mft);
    end
    %Models with misfit near the working tolerance
    pos_inside = (mft_mier>=(er-delta_er))&(mft_mier<=(er+delta_er));
    %Check if we are looking for upper or lower bound
    if uplo==0
        %Models totally above
        pos_valid = mier>=bm;
    else
        %Models totally below
        pos_valid = mier<=bm;
    end
    %Number of rectangles above or below
    n_pos_valid = sum(pos_valid')';
    %Looking for models for computing the first candidate
    for i=1.0:-0.05:0.0
        %Models almost totally above or below
        pos_ab = n_pos_valid>=ceil(i*nr);
        %Models near the working tolerance totally above or below
        pos = pos_inside&pos_ab;
        %Check if there is any model
        n = sum(pos);
        if n>=nmm
            %Extract the working models
            mier_work = mier(pos,:);
            if is_trend
                tier_work = tier(pos,:);
            end
            %Check if the models are not all above or below
            if i~=1.0
                %Assign the value of the best model in the rectangles outside
                pos_valid_w = pos_valid(pos,:);
                for j=1:size(pos_valid_w,1)
                    mier_work(j,~pos_valid_w(j,:)) = bm(~pos_valid_w(j,:));
                end
            end
            %Compute the euclidean distance to the reference model
            dist = bm-mier_work;
            dist = dist.^2;
            dist = sqrt(sum(dist'));
            %Sort distances
            [dist,pos] = sort(dist,'ascend');
            %Candidate model
            ull = mean(mier_work(pos(1:nmm),:));
            if is_trend
                ullt = mean(tier_work(pos(1:nmm),:));
            end
            %Loop termination
            break;
        end
    end
    %Cost function computation of the candidate model
    rect(:,3) = ull';
    grav = gpso2d_GravityComputation(rect,rho,pts)'./f_SI;
    grav = grav(pu).*w(pu);
    mft = norm(o_t-grav,ncf)/n_o_t*100.0;
    %ECDF of all data
    pref_m = zeros(1,nr);
    ecdf_m = cell(1,nr);
    for i=1:nr
        %ECDF
        [p,x] = gpso2d_Ecdf(mier(:,i));
        %Suppression of the first data as it is repeated
        ecdf_m{i} = [x(2:end) p(2:end)];
        %Probability of the candidate bound
        if length(ecdf_m{i}(:,1))>1
            pref_m(i) = interp1(ecdf_m{i}(:,1),ecdf_m{i}(:,2),ull(i),...
                                'linear','extrap');
        end
        if pref_m(i)>1.0
            pref_m(i) = 1.0;
        elseif pref_m(i)<0.0
            pref_m(i) = 0.0;
        end
    end
    if is_trend
        pref_t = zeros(1,nt);
        ecdf_t = cell(1,nt);
        for i=1:nt
            %ECDF
            [p,x] = gpso2d_Ecdf(tier(:,i));
            %Suppression of the first data as it is repeated
            ecdf_t{i} = [x(2:end) p(2:end)];
            %Probability of the reference model
            if length(ecdf_t{i}(:,1))>1
                pref_t(i) = interp1(ecdf_t{i}(:,1),ecdf_t{i}(:,2),ullt(i),...
                                    'linear','extrap');
            end
            if pref_t(i)>1.0
                pref_t(i) = 1.0;
            elseif pref_t(i)<0.0
                pref_t(i) = 0.0;
            end
        end
    else
        pref_t = [];
        ecdf_t = {};
    end
    %Current probabilities and misfit
    c_pref_m = pref_m;
    c_pref_t = pref_t;
    %Probability increment
    pinc_aux = pinc;
    %Infinite loop
    while 1
        %Iteration counter update
        it = it+1;
        %Probability value depending on upper or lower
        if uplo==0
            %New probability
            if mft<=er
                %If misfit is inside limit, it must be go up
                c_pref_m = c_pref_m+pinc_aux;
                if is_trend
                    c_pref_t = c_pref_t+pinc_aux;
                end
            else
                %If misfit is outside limit, it must be go down
                c_pref_m = c_pref_m-pinc_aux;
                if is_trend
                    c_pref_t = c_pref_t-pinc_aux;
                end
            end
        else
            %New probability
            if mft<=er
                %If misfit is inside must, it be go down
                c_pref_m = c_pref_m-pinc_aux;
                if is_trend
                    c_pref_t = c_pref_t-pinc_aux;
                end
            else
                %If misfit is outside must, it be go up
                c_pref_m = c_pref_m+pinc_aux;
                if is_trend
                    c_pref_t = c_pref_t+pinc_aux;
                end
            end
        end
        %Update probability increment
        pinc_aux = pinc_aux/pd;
        if pinc_aux<pinc_tol
            pinc_aux = pinc;
        end
        %Check extreme values
        pos = c_pref_m>1.0;
        c_pref_m(pos) = 1.0;
        pos = c_pref_m<0.0;
        c_pref_m(pos) = 0.0;
        if is_trend
            pos = c_pref_t>1.0;
            c_pref_t(pos) = 1.0;
            pos = c_pref_t<0.0;
            c_pref_t(pos) = 0.0;
        end
        %Update limit values
        for i=1:nr
            %Computed value
            val_calc = interp1(ecdf_m{i}(:,2),ecdf_m{i}(:,1),c_pref_m(i),...
                               'linear','extrap');
            %Computed value must be compatible with reference model
            if uplo==0
                if val_calc<bm(i)
                    ull(i) = bm(i);
                    c_pref_m(i) = pref_m(i);
                else
                    ull(i) = val_calc;
                end
            else
                if val_calc>bm(i)
                    ull(i) = bm(i);
                    c_pref_m(i) = pref_m(i);
                else
                    ull(i) = val_calc;
                end
            end
        end
        %Regional trend
        if is_trend
            for i=1:nt
                %Computed value
                if length(ecdf_t{i}(:,1))>1
                    val_calc = interp1(ecdf_t{i}(:,2),ecdf_t{i}(:,1),...
                                       c_pref_t(i),'linear','extrap');
                else
                    val_calc = c_pref_t(i);
                end
                %Computed value must be compatible with reference model
                if uplo==0
                    if val_calc<bt(i)
                        ullt(i) = bt(i);
                        c_pref_t(i) = pref_t(i);
                    else
                        ullt(i) = val_calc;
                    end
                else
                    if val_calc>bt(i)
                        ullt(i) = bt(i);
                        c_pref_t(i) = pref_t(i);
                    else
                        ullt(i) = val_calc;
                    end
                end
            end
        end
        %Model misfit
        rect(:,3) = ull';
        grav = gpso2d_GravityComputation(rect,rho,pts)'./f_SI;
        %Retain only the needed points and apply weights
        grav = grav(pu).*w(pu);
        %Cost function
        mft = norm(o_t-grav,ncf)/n_o_t*100.0;
        if floor(it/ipm)==(it/ipm)
            fprintf(2,'\n   Iteration: %4d, misfit: %7.3f%%... ',it,mft);
        end
        %Check if tolerance is reached for the search based on ECDF
        if abs(mft-er)<=ed
            %Original limits
            ull_orig = ull;
            %Maximum and minimun values for all models
            max_val = max(mier);
            min_val = min(mier);
            %Check for models totally over or below the limit
            if uplo==0
                %Find all models totally below the limit
                pos = mier<=ull;
                n_models = sum(pos')';
                pos = n_models==nr;
                %Set the limit to the maximum value
                for i=1:nr
                    %Find the maximum value
                    val = max(mier(pos,i));
                    %It must be compatible with reference model
                    if val<=bm(i)
                        ull(i) = bm(i);
                    else
                        ull(i) = val;
                    end
                end
            else
                %Find all models totally over the limit
                pos = mier>=ull;
                n_models = sum(pos')';
                pos = n_models==nr;
                %Set the limit to the minimum value
                for i=1:nr
                    %Find the minimum value
                    val = min(mier(pos,i));
                    %It must be compatible with reference model
                    if val>=bm(i)
                        ull(i) = bm(i);
                    else
                        ull(i) = val;
                    end
                end
            end
            %Maximum correction
            mc = max(abs(ull_orig-ull))/mcf;
            mc_aux = mc;
            %Infinite loop for search based on correction
            while 1
                %Gravity attraction for the current model
                rect(:,3) = ull';
                grav = gpso2d_GravityComputation(rect,rho,pts)'./f_SI;
                %Retain only the needed points and apply weights
                grav = grav(pu).*w(pu);
                %Cost function
                mft = norm(o_t-grav,ncf)/n_o_t*100.0;
                %Creck for termination
                if abs(mft-er)<=ed
                    break;
                end
                %Check kind of limit
                if uplo==0
                    %Check the misfit
                    if mft<=er
                        %Limit going up
                        ull = ull+mc_aux;
                    else
                        %Limit going down
                        ull = ull-mc_aux;
                    end
                    %It must be compatible with reference model and max limits
                    pos = ull>max_val;
                    ull(pos) = max_val(pos);
                    pos = ull<bm;
                    ull(pos) = bm(pos);
                else
                    %Check the misfit
                    if mft<=er
                        %Limit going down
                        ull = ull-mc_aux;
                    else
                        %Limit going up
                        ull = ull+mc_aux;
                    end
                    %It must be compatible with reference model and max limits
                    pos = ull<min_val;
                    ull(pos) = min_val(pos);
                    pos = ull>bm;
                    ull(pos) = bm(pos);
                end
                %Update the correction
                mc_aux = mc_aux/pd;
                if mc_aux<mcf_tol
                    mc_aux = mc;
                end
                %Iteration counter
                it = it+1;
                if floor(it/ipm)==(it/ipm)
                    fprintf(2,'\n   Iteration: %4d, misfit: %7.3f%%... ',it,mft);
                end
            end
            %Creck for termination
            if abs(mft-er)<=ed
                break;
            end
        end
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
