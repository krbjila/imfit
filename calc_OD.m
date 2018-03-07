function [ODact, FrameReg] = calc_OD(data,species,bin,tprobe,Region,filter, filterpower)
filter = filter{1};
filterpower = str2double(filterpower); 
%%%Calculates the OD for either K or Rb taking into account saturation effects

ODSat = 4;
x1 = Region(1);
x0 = Region(2);
crop1 = Region(3);
crop0 = Region(4);
CCDCenter = 404; %404 for two-frame, 560 for three-frame
CCDVSize = size(data,1);

% Separate Light, Shadow, and Dark frames
if species == 'K'
    shadow=data(:,1:CCDCenter/bin,1,1);
    light=data(:,1:CCDCenter/bin,1,2);
    dark=data(:,1:CCDCenter/bin,1,3);
    
    ISat=bin^2*290*tprobe; %counts/px, see book 49, pp. 65

    
elseif species == 'Rb'
    shadow=data(:,(CCDCenter+bin)/bin:end,1,1);
    light=data(:,(CCDCenter+bin)/bin:end,1,2);
    dark=data(:,(CCDCenter+bin)/bin:end,1,3);    
    
    ISat=bin^2*260*tprobe; %counts/px, see book 49, pp. 100
end

%%% Fourier Filtering

switch filter
    case 'None'
        disp(filter);
        disp(filterpower);
    case 'Hann Window'
        hannx = hanning(size(shadow,1));
        hanny = hanning(size(shadow,2));
        window = fftshift((hannx*hanny').^filterpower);

        shadow = ifft2(window.*fft2(double(shadow)));
        light = ifft2(window.*fft2(double(light)));
        dark = ifft2(window.*fft2(double(dark)));
    case 'Hamming Window'
        hammx = hamming(size(shadow,1));
        hammy = hamming(size(shadow,2));
        window = fftshift((hammx*hammy').^filterpower);

        shadow = ifft2(window.*fft2(double(shadow)));
        light = ifft2(window.*fft2(double(light)));
        dark = ifft2(window.*fft2(double(dark)));
    case 'Blackman Window'
        blackx = blackman(size(shadow,1));
        blacky = blackman(size(shadow,2));
        window = fftshift((blackx*blacky').^filterpower);

        shadow = ifft2(window.*fft2(double(shadow)));
        light = ifft2(window.*fft2(double(light)));
        dark = ifft2(window.*fft2(double(dark)));        
end

%%%Conditions for cropping
r1 = x0 - floor(crop0/2);
r2 = x0 + floor(crop0/2)-1;
r3 = x1 - floor(crop1/2);
r4 = x1 + floor(crop1/2)-1;

if r1<1
    r1 = 1;
end

if r2 > CCDCenter/bin
    r2 = CCDCenter/bin;
end

if r3<1
    r3 = 1;
end

if r4 > CCDVSize
    r4 = CCDVSize;
end

% Filtering



%Crop window to cropsize
shadowcrop=shadow(r3:r4,r1:r2);
lightcrop=light(r3:r4,r1:r2);
darkcrop=dark(r3:r4,r1:r2);

FrameReg = [r3 r4 r1 r2];

% Calculate OD
OD = (log(double(lightcrop-darkcrop)./double(shadowcrop-darkcrop)));
ODmod = log((1-exp(-ODSat))./(exp(-1*OD)-exp(-ODSat)));
ODact = ODmod + (1-exp(-1*ODmod)).*double(lightcrop)/ISat;

ODact = real(ODact);
ODact(isnan(ODact)) = 0;
ODact(isinf(ODact)) = 0;