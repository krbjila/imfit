function [FitResults, Slices]=fit_OD(OD,Frame,fitfunction,handles)

 %%% Prep some parameters for fitting
    [M,I] = max(OD(:));
    [Iy, Ix] = ind2sub(size(OD),I);
    
    decimate = 1; %Decimate the window so that only every nth point is taken
    OD = OD(1:decimate:end,1:decimate:end);

    XSize = size(OD,1);
    YSize = size(OD,2);
    
    %Crop image and axes
    x = Frame(1):Frame(2);%Frame(1):Frame(2);
    y = Frame(3):Frame(4);%Frame(3):Frame(4);

    %Get data ready for fitting
    [X,Y] = meshgrid(x,y);
    AllData = zeros(size(X,1),size(Y,2),2);
    AllData(:,:,1) = X;
    AllData(:,:,2) = Y;
    
    OD = OD.';
    
    switch fitfunction 
        case 1 %Single gaussian 
            %%%Fitting
            x0 = [0,M, Iy, 20, Ix, 20, 0]; %Initial guess for parameters [offset, Amp,xo,wx,yo,wy,fi]
            % define lower and upper bounds [Amp,xo,wx,yo,wy,fi]
            lb = [-10,0,min(x),0,min(y),0,-pi/4];
            ub = [10,20,max(x),200,max(y),200,pi/4];
            options = optimoptions(@lsqcurvefit,'Algorithm','trust-region-reflective',...
                'Display','off');
            [FitResults,~,~,~] = lsqcurvefit(@D2GaussFunctionRot,double(x0),AllData,double(OD),lb,ub,options);
            disp(['Angle is ' num2str(FitResults(7)/3.1415*180)]);
            
%             axes(handles.AxSlice1);            
%             imagesc(D2GaussFunctionRot(FitResults,AllData));
            
            
            InterpolationMethod = 'nearest';
            m = -tan(FitResults(7));% Point slope formula
            b = (-m*FitResults(3) + FitResults(5));
            xvh = 1:XSize*4;
            yvh = xvh*m + b;
            
            hPoints = interp2(X,Y,OD,xvh,yvh,InterpolationMethod);
            xposh = (xvh-FitResults(3))/cos(FitResults(7))+FitResults(3);% correct for the longer diagonal if fi~=0
            xdatafit = linspace(Frame(1),Frame(2),300);
            hdatafit = FitResults(2)*exp(-(xdatafit-FitResults(3)).^2/(2*FitResults(4)^2))+FitResults(1);
            
            % generate points along vertical axis
            mrot = -m;
            brot = (mrot*FitResults(5) - FitResults(3));
            yvv = 1:YSize*4;
            xvv = yvv.*mrot-brot;
            
            vPoints = interp2(X,Y,OD,xvv,yvv,InterpolationMethod);
            xposv = (yvv-FitResults(5))/cos(FitResults(7))+FitResults(5);% correct for the longer diagonal if fi~=0
            
            ydatafit = linspace(Frame(3),Frame(4),300);
            vdatafit = FitResults(2)*exp(-(ydatafit-FitResults(5)).^2/(2*FitResults(6)^2))+FitResults(1);
            
            Slices = {xposh; hPoints; xposv; vPoints; xdatafit; hdatafit; ydatafit; vdatafit};
            
        case 2 %Double gaussian 
        %x = [Offset, Amp1, wx1, wy1, Amp2, wx2, wy2,x0,y0]
        x0 = [0,M,5,5,M/2,20,20,Ix,Iy]; 
        lb = [-1,0,0,0,0,0,0,min(x),min(y)];
        ub = [1,10,min(x),min(x),10,max(y),max(y),max(x),max(y)];
        options = optimoptions(@lsqcurvefit,'Algorithm','trust-region-reflective',...
                'Display','off');
        [FitResults,~,~,~] = lsqcurvefit(@DoubleGaussFunction,double(x0),AllData,double(OD),lb,ub,options);
    
        xind = find(x==round(FitResults(8)));
        yind = find(y==round(FitResults(9)));    
                
        DatSlice1 = OD(yind,:);      
        DatSlice2 = OD(:,xind);
            
        FitSurf = DoubleGaussFunction(FitResults,AllData);
        FitSlice1 = FitSurf(yind,:);
        FitSlice2 = FitSurf(:,xind);
        
        Slices = {x,DatSlice1,y,DatSlice2,x,FitSlice1,y,FitSlice2};
        
    end
    