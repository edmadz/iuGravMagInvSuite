function colors = cmy2rgb(input)

if(min(size(input))==4)
    if(max(input(:))>1)
        input = input./255;
        R=(1-input(:,2)).*(1-input(:,1));
        G=(1-input(:,3)).*(1-input(:,1));
        B=(1-input(:,4)).*(1-input(:,1));
    else
        R=(1-input(:,2)).*(1-input(:,1));
        G=(1-input(:,3)).*(1-input(:,1));
        B=(1-input(:,4)).*(1-input(:,1));
    end
elseif(min(size(input))==3)
    R=(1-input(:,1));
    G=(1-input(:,2));
    B=(1-input(:,3));
end

colors=cat(2,R,G,B);