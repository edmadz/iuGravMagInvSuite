function [posX,posY,Width,Height]=centralizeWindow(Width_,Height_)

%Size of the screen
screensize = get(0,'Screensize');
Width = screensize(3);
Height = screensize(4);

posX = (Width/2)-(Width_/2);
posY = (Height/2)-(Height_/2);
Width=Width_;
Height=Height_;

end