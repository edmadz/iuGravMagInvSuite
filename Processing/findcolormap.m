function colormap = findcolormap(path)

ch = [];

data = importdata(path);
if (isstruct(data))
    dado = data.data;
    [~,n]=size(dado);
    if(n==4) % cmyk
        ch=cmy2rgb(dado);
    elseif(n==3) %rgb
        for x=1:n
            ch = cat(2,ch,dado(:,x));
        end
    end
else
    dado = data;
    [~,n]=size(dado);
    if(n==4) % cmyk
        ch=cmy2rgb(dado);
    elseif(n==3) %rgb
        for x=1:n
            ch = cat(2,ch,dado(:,x));
        end
    end
end

if(max(ch(:))>1)
    ch = ch./255;
end

colormap = ch;