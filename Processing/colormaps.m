function cmaps = colormaps(M,colorpattern,distribution)

minM = min(M);
maxM = max(M);
Msort = sort(M);
M_=M; M_(isnan(M))=[];
numberSamples = length(M_); %consider only non-NaN values

%% ACCESS THE COLORMAP

tblFolder=loadTBL(strcat(colorpattern,'.tbl'));
colors = findcolormap(tblFolder);

intervals = length(colors)-1;

%% SET THE COLOR DISTRIBUTION TYPE
if(strcmp(distribution,'linear'))
    percent_ = 100/intervals;
    percent = percent_*ones(size(colors));
    colorPattern = createCmap(colors,percent,numberSamples);
elseif(strcmp(distribution,'equalized'))
    bins = zeros(1,intervals);
    samplesPerBin = ceil(numberSamples/length(bins));
    % ENCONTRA OS INTERVALOS EM QUE OS BINS TERï¿½O A MESMA QUANTIDADE DE AMOSTRAS
    for m=1:numberSamples
        for n=2:length(bins)
            if(m == (n-1)*samplesPerBin)
                bins(n) = Msort(m);
                break
            end
        end
    end
    binranges = [minM,bins(2:end),maxM];
    %dispï¿½e os intervalos dos bins em forma de porcentagem
    for x_=1:intervals
        percent(x_) = (100*(binranges(x_+1)-binranges(x_)))/(maxM-minM);
    end
    colorPattern = createCmap(colors,percent,numberSamples);
elseif(strcmp(distribution,'normalized'))
    bins_ = zeros(1,length(colors));
    %calcula a funï¿½ï¿½o distribuiï¿½ï¿½o acumulada para pontos especï¿½ficos
    mu = 0;
    sigma = 1;
    x = linspace(-3,3,numberSamples);
    pd = makedist('Normal',mu,sigma);
    y = cdf(pd,x);
    y_ = y.*numberSamples;
%     figure
%     plot(x,y_)
    
    %Encontra os intervalos dos bins seguindo uma distribuiï¿½ï¿½o gaussiana
    for m=1:numberSamples
        %x_ = sum(M < Msort(m));
        for n=1:length(bins_)
            if(m == y_(n))
                bins_(n) = Msort(m);
            end
        end
    end
    binranges = [minM,bins_(2:end-1),maxM];
    %dispõe os intervalos dos bins em forma de porcentagem
    for x_=1:intervals
        percent(x_) = (100*(binranges(x_+1)-binranges(x_)))/(maxM-minM);
    end
    colorPattern = createCmap(colors,percent,255);
end

cmaps=colorPattern;