function [color_] = convertColorRange(color)

R = color(1); R_ = R/255;
G = color(2); G_ = G/255;
B = color(3); B_ = B/255;

color_ = cat(2,R_,G_,B_);

end