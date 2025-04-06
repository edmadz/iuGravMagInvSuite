function binsLimits = binsGeneration(binMin,binWidth,n)

binsLimits = [];

for i=1:n
    if(i==1)
        binsLimits=[binMin,binMin+binWidth];
    else
        binsLimits=[binsLimits,binsLimits(end),binsLimits(end)+binWidth];
    end
end

end