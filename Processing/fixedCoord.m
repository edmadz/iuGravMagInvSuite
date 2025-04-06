function fixedCoord(nx,xAngle,ny,yAngle)

yt=get(gca,'YTick');
yt=linspace(min(yt),max(yt),ny);
set(gca,'YTick',yt)
set(gca,'YTickLabel',sprintf('%.0f\n',yt))
set(gca,'YTickLabelRotation',xAngle)

xt=get(gca,'XTick');
xt=linspace(min(xt),max(xt),nx);
set(gca,'XTick',xt)
set(gca,'XTickLabel',sprintf('%.0f\n',xt))
set(gca,'XTickLabelRotation',yAngle)

end