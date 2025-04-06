function histogram_(data,binsLimits,ylb,xlb)

gca;

nBins=length(binsLimits)/2;

for i=1:nBins
    indexMin = i+((i-1)*1);
    indexMax = indexMin+1;
    
    binMin = binsLimits(indexMin);
    binMax = binsLimits(indexMax);
    
    barWidth = binMax-binMin;
    
    data_=data;
    data_(data<binMin)=[];
    data_(data_>binMax)=[];
    barHeight(i) = length(data_);
    
    hold on
    rectangle('position',[binMin,0,barWidth,barHeight(i)],...
        'FaceColor',[.7 .7 .7],'EdgeColor','k',...
        'LineWidth',0.5)
    hold off
end

grid on
xlabel(xlb)
ylabel(ylb)
set(gca,'FontSize',20)
set(gca,'Box','on')
ylim([0,max(barHeight)*1.1])

end