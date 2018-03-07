function F = DoubleGaussFunction(x,xdata)
%% x = [Offset, Amp1, wx1, wy1, Amp2, wx2, wy2,x0,y0]

F =x(1)+x(2)*exp(-((xdata(:,:,1)-x(8)).^2./(2*x(3)^2) + (xdata(:,:,2)-x(9)).^2./(2*x(4)^2) ))...
    +x(5)*exp(-((xdata(:,:,1)-x(8)).^2./(2*x(6)^2) + (xdata(:,:,2)-x(9)).^2./(2*x(7)^2) ));
