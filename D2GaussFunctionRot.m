function F = D2GaussFunctionRot(x,xdata)
%% x = [Offset, Amp, x0, wx, y0, wy, fi]

xdatarot(:,:,1)= xdata(:,:,1)*cos(x(7)) - xdata(:,:,2)*sin(x(7));
xdatarot(:,:,2)= xdata(:,:,1)*sin(x(7)) + xdata(:,:,2)*cos(x(7));
x0rot = x(3)*cos(x(7)) - x(5)*sin(x(7));
y0rot = x(3)*sin(x(7)) + x(5)*cos(x(7));

F =x(1)+x(2)*exp(   -((xdatarot(:,:,1)-x0rot).^2./(2*x(4)^2) + (xdatarot(:,:,2)-y0rot).^2./(2*x(6)^2) ));

F;