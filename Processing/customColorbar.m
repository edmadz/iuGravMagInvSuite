function customColorbar(n,decimal,fontSize,angle,fontSizeTitle,fontWeightTitle,title_,position)

if(decimal<0)
    decimal = 0;
end

if(position=='E')
    cb=colorbar('eastoutside');
elseif(position=='S')
    cb=colorbar('southoutside');
end

t=get(cb,'Limits');
l=linspace(t(1),t(2),n);
%l=linspace(0.0,0.225,n);
%l=linspace(0,1000,n);
l=round(l,decimal);

while(~(length(unique(l))==length(l) && all(diff(l)>=0)))
    l=linspace(t(1),t(2),n);
    decimal=decimal+1;
    l=round(l,decimal);
end

set(cb,'Limits',[min(l) max(l)])
set(cb,'Ticks',l)
set(cb,'TickLabels',l)
set(cb,'FontSize',fontSize)
title(cb,title_,'FontSize',fontSizeTitle,'FontWeight',fontWeightTitle)

end