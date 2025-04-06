function [circx,circy] = generateCircle(n,radius,showPlot)
angle = linspace(-180,180,n);
circx = radius*cosd(angle);
circy = radius*sind(angle);
if(showPlot==1)
    plot(circx,circy)
    axis equal
end
end