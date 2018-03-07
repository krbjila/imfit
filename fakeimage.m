N = 400;
x = [0:N - 1]-N/2;
y = x;

[X,Y] = meshgrid(x,y);


cloud = exp(-((X-30).^2 + (Y+100).^2)/2/20.^2);
noise = 0.5.*randn(N);

x0 = 50; y0 = -25;
fringe = 0.5.*sin(sqrt((X-x0).^2 + (Y-y0).^2));
image = noise+ cloud+fringe;


imageft = fftshift(fft2(image));

filter = hanning(N)*hanning(N)'; filter = filter.^15;

imagefilt = ifft2(fftshift(imageft.*filter));



figure(1); 
subplot(2,2,1); imagesc(y,x,image); colormap(jet); title('Raw Image');
subplot(2,2,2); imagesc(y,x,abs(imageft)); colormap(jet); title('Image FT');
subplot(2,2,3); imagesc(y,x,filter); colormap(jet); title('Filter');
subplot(2,2,4); imagesc(y,x,real(imagefilt)); colormap(jet); title('Filtered Image');