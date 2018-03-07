X = SpeReader('OD1 7 2-3-2017.spe');
ODfinal = double(read(X))./1000;



xx=[1:1:size(ODfinal,2)];%fitting dependent variable
yy=[1:1:size(ODfinal,1)];

Ix = round(sum(xx.*sum(ODfinal,1))./sum(sum(ODfinal,1)));
Iy = round(sum(yy.'.*sum(ODfinal,2))./sum(sum(ODfinal,2)));

maxOD = max(max(ODfinal));

[X,Y] = meshgrid(xx,yy);
XData = zeros(size(X,1),size(Y,2),2);
XData(:,:,1) = X;
XData(:,:,2) = Y;

ODcutoff = 8;
xi = [0 maxOD Ix 20 Iy 20 0];
lb = [-1 0 0 0 0 0 -pi/4];
ub = [1 ODcutoff inf inf inf inf pi/4];

options = optimoptions('lsqcurvefit','display','off');
[fitresult,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunctionRot,xi,XData,ODfinal,lb,ub,options);

%% Plotting
imagesc(xx,yy,real(ODfinal))
     
colorbar
colormap jet
xlabel('x (pixels)');
ylabel('y (pixels)');
hold on;
Z = D2GaussFunctionRot(fitresult,XData);

contour(xx,yy,Z,'k','LineWidth',1.25)