function[lo_env,up_env,lo_env2,up_env2]=ExtractDopplerFromECHO(A) 
% A function to extract the Doppler velocity from ECHO images.
% The input image is in gray scale with EKG shown in a green color.
% The input image is a 3D array with the first two dimensions
% being the number of pixles in the vertical and horzontal axes,
% respectively. The image array contains the RGB components of the image, 
% where the numbers in the RGB data repreent the amplitude of the Red, 
% Green, and Blue compoents, respectively.
%
%
%  Exmaple call: 
%       ExtractDopplerFromECHO(ImageFile);
%
% Amirtaha Taebi
% Department of Biomedical Engineering
% University of California Davis
% Summer 2019

 %% Parameters
 
 Gray_threshold1= 30;   % Amplitude threshold
                         % You can reduce thresholds to find hard to find green
                         % pixels.
 
 GrayStart=  80;         % Starting pixel of the Doppler in the image
 GrayEnd  =1767;         % End pixel of the Doppler in the image

                          
VerticalPixelDoppler_start=575;
VerticalPixelDoppler_end  =1030;
YellowLine = 790;
Doppler_Flip = VerticalPixelDoppler_end-VerticalPixelDoppler_start;
SearchWindow = 100;    % search window to find maximum

DopplerEnvThreshold = 0.30; % Threshold to find doppler envelope
DopplerEnvThreshold2 = 0.05;


%% Main function
Original_image = A;
Original_image_Doppler = Original_image(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:);

% removing the white dots from the lower part of the ECHO image
for i1 = 0:31
    for i2 = round(i1*53.225)+75:round(i1*53.225)+75+8
        for i3 = 1013:1032
            A(i3,i2,:) = 0;
        end
    end
end

% smoothing the doppler image
% smoothed_image(:,:,1) = smooth2a(double(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,1)),3,3)/255;
% smoothed_image(:,:,2) = smooth2a(double(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,2)),3,3)/255;
% smoothed_image(:,:,3) = smooth2a(double(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,3)),3,3)/255;

% Plot original image and find image dimentions in pixels
figure(201); image(Original_image);

Size1=size(A,1);
Size2=size(A,2);

GrayFoundArray=zeros(Size1,Size2);
avg_intensity = zeros(Size1,Size2);
A_double_format = double(A);

smoothed_image(:,:,1) = smooth2a(A_double_format(:,:,1),3,3)/255;
smoothed_image(:,:,2) = smooth2a(A_double_format(:,:,2),3,3)/255;
smoothed_image(:,:,3) = smooth2a(A_double_format(:,:,3),3,3)/255;

figure(202)
image(A_double_format)

for i1=VerticalPixelDoppler_start:VerticalPixelDoppler_end
    for i2=1:Size2
       avg_intensity(i1,i2) = (A_double_format(i1,i2,1)+A_double_format(i1,i2,2)+A_double_format(i1,i2,3))/3;
       if (avg_intensity(i1,i2) > Gray_threshold1)
           GrayFoundArray (i1,i2)= avg_intensity(i1,i2); % bright gray
%        if (A(i1,i2,2) >  Gray_threshold1  &&  ( A(i1,i2,2) == A(i1,i2,1)) &&(A(i1,i2,1) == A(i1,i2,3))) 
%            GrayFoundArray (i1,i2)= avg_intensity(i1,i2);
       end
       
     end
end

% remove parts of the image that would not contain Doppler.
GreenFoundArray1=GrayFoundArray(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:);

figure(203);  image(GrayFoundArray)
    
avg_intensity2 = avg_intensity;

% upper and lower of the Doppler, criteria 1
for i2 = GrayStart:GrayEnd
    for i1 = 1:Size1
        if avg_intensity(i1,i2) < DopplerEnvThreshold * max(avg_intensity(VerticalPixelDoppler_start:VerticalPixelDoppler_end,i2))
            avg_intensity(i1,i2) = 0;
        end
    end
    k = find(avg_intensity(VerticalPixelDoppler_start:VerticalPixelDoppler_end,i2)>0);
    up_env(i2) = min(k);
    lo_env(i2) = max(k);
end

up_env = Doppler_Flip - up_env;
up_env = up_env(GrayStart:GrayEnd);

lo_env = Doppler_Flip - lo_env;
lo_env = lo_env(GrayStart:GrayEnd);

% upper and lower of the Doppler, criteria 2
for i2 = GrayStart:GrayEnd
    [M1,I1] = max(avg_intensity2(YellowLine-SearchWindow:YellowLine,i2));
    [M2,I2] = max(avg_intensity2(YellowLine:YellowLine+SearchWindow,i2));
    
    k2 = find(avg_intensity2(VerticalPixelDoppler_start:I1+YellowLine-SearchWindow,i2) < DopplerEnvThreshold2 * M1);
    if isempty(k2)
        k2 = 1;
    end
    up_env2(i2) = max(k2);
    
    k3 = find(avg_intensity2(I2+YellowLine:VerticalPixelDoppler_end,i2) < DopplerEnvThreshold2 * M2);
    if isempty(k3)
        k3 = VerticalPixelDoppler_end - VerticalPixelDoppler_start;
    else
        k3 = k3 + YellowLine + I2 - VerticalPixelDoppler_start;
    end
    lo_env2(i2) = min(k3);
end

up_env2 = Doppler_Flip - up_env2;
up_env2 = up_env2(GrayStart:GrayEnd);

lo_env2 = Doppler_Flip - lo_env2;
lo_env2 = lo_env2(GrayStart:GrayEnd);

figure(204)
subplot(3,1,1); image(GreenFoundArray1); title('Envelopes criteria 1')
subplot(3,1,2); plot(up_env); ylabel('U Enev [Pixel]')
subplot(3,1,3); plot(lo_env); xlabel('Time [Pixel]'); ylabel('L Enev [Pixel]')

figure(205)
subplot(3,1,1); image(GreenFoundArray1); title('Envelopes criteria 2')
subplot(3,1,2); plot(up_env2); ylabel('U Enev [Pixel]')
subplot(3,1,3); plot(lo_env2); xlabel('Time [Pixel]'); ylabel('L Enev [Pixel]')

time_pixel = 450;
fig206 = figure(206);
% plot(VerticalPixelDoppler_start:VerticalPixelDoppler_end,A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,time_pixel,1),'r');hold on;...
%     plot(VerticalPixelDoppler_start:VerticalPixelDoppler_end,A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,time_pixel,2),'g');hold on;...
%     plot(VerticalPixelDoppler_start:VerticalPixelDoppler_end,A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,time_pixel,3),'b');hold on;
plot(VerticalPixelDoppler_start:VerticalPixelDoppler_end,GreenFoundArray1(:,time_pixel),'k'); hold off
title(['@ Time = ' num2str(time_pixel) ' Pixel'])
xlabel('Y (Vertical Pixel)')
ylabel('Intensity')
% legend('R','G','B','avg')
axis([VerticalPixelDoppler_start VerticalPixelDoppler_end 0 256])

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig206,'thresholding_method','-djpeg','-r300')


% % plotting the Doppler envelopes on the ECHO image
% figure(201)
% hold on; plot(GrayStart:GrayEnd,VerticalPixelDoppler_end-1-up_env);
% hold on; plot(GrayStart:GrayEnd,VerticalPixelDoppler_end-1-lo_env);hold off

figure(207)
subplot(3,1,1); image(Original_image_Doppler)
subplot(3,1,2); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('without white dots')
subplot(3,1,3); image(smoothed_image(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('smoothed')

figure(208)
image(A)

figure(209)
subplot(3,1,1); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('Criteria #1')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env);hold off
subplot(3,1,2); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('Criteria #2')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env2);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env2);hold off
subplot(3,1,3); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('Criteria 1 (red) vs 2 (blue)'); xlabel('Time [Pixel]'); ylabel('Amp [Pixel]')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env,'r');
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env,'r');
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env2,'b');
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env2,'b');hold off

figure(210)
subplot(2,1,1); plot(up_env); hold on; plot(up_env2); hold off; legend('criteria 1', 'criteria 2'); 
ylabel('U envelope [Pixel]'); title(['Threshold: criteria 1 = ' num2str(100*DopplerEnvThreshold) '%, criteria 2 = ' num2str(100*DopplerEnvThreshold2) '%']);
subplot(2,1,2); plot(lo_env); hold on; plot(lo_env2); hold off; legend('criteria 1', 'criteria 2'); ylabel('L envelope [Pixel]')


%% smoothed ECHO image
GrayFoundArray_s=zeros(Size1,Size2);
avg_intensity_s = zeros(Size1,Size2);

for i1=VerticalPixelDoppler_start:VerticalPixelDoppler_end
    for i2=1:Size2
       avg_intensity_s(i1,i2) = (smoothed_image(i1,i2,1)+smoothed_image(i1,i2,2)+smoothed_image(i1,i2,3))/3;
       if (avg_intensity_s(i1,i2) > Gray_threshold1)
           GrayFoundArray_s (i1,i2)= avg_intensity_s(i1,i2); % bright gray
       end
       
     end
end

avg_intensity2_s = avg_intensity_s;

% upper and lower of the Doppler, criteria 1
for i2 = GrayStart:GrayEnd
    for i1 = 1:Size1
        if avg_intensity_s(i1,i2) < DopplerEnvThreshold * max(avg_intensity_s(VerticalPixelDoppler_start:VerticalPixelDoppler_end,i2))
            avg_intensity_s(i1,i2) = 0;
        end
    end
    k_s = find(avg_intensity_s(VerticalPixelDoppler_start:VerticalPixelDoppler_end,i2)>0);
    up_env_s(i2) = min(k_s);
    lo_env_s(i2) = max(k_s);
end

up_env_s = Doppler_Flip - up_env_s;
up_env_s = up_env_s(GrayStart:GrayEnd);

lo_env_s = Doppler_Flip - lo_env_s;
lo_env_s = lo_env_s(GrayStart:GrayEnd);

% upper and lower of the Doppler, criteria 2
for i2 = GrayStart:GrayEnd
    [M1_s,I1_s] = max(avg_intensity2_s(YellowLine-SearchWindow:YellowLine,i2));
    [M2_s,I2_s] = max(avg_intensity2_s(YellowLine:YellowLine+SearchWindow,i2));
    
    k2_s = find(avg_intensity2_s(VerticalPixelDoppler_start:I1_s+YellowLine-SearchWindow,i2) < DopplerEnvThreshold2 * M1_s);
    if isempty(k2_s)
        k2_s = 1;
    end
    up_env2_s(i2) = max(k2_s);
    
    k3_s = find(avg_intensity2_s(I2_s+YellowLine:VerticalPixelDoppler_end,i2) < DopplerEnvThreshold2 * M2_s);
    if isempty(k3_s)
        k3_s = VerticalPixelDoppler_end - VerticalPixelDoppler_start;
    else
        k3_s = k3_s + YellowLine + I2_s - VerticalPixelDoppler_start;
    end
    lo_env2_s(i2) = min(k3_s);
end

up_env2_s = Doppler_Flip - up_env2_s;
up_env2_s = up_env2_s(GrayStart:GrayEnd);

lo_env2_s = Doppler_Flip - lo_env2_s;
lo_env2_s = lo_env2_s(GrayStart:GrayEnd);


figure(211)
subplot(3,1,1); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('Smoothed - Criteria #1')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env_s);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env_s);hold off
subplot(3,1,2); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('Smoothed - Criteria #2')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env2_s);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env2_s);hold off
subplot(3,1,3); image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); title('Smoothed - Criteria 1 (red) vs 2 (blue)'); xlabel('Time [Pixel]'); ylabel('Amp [Pixel]')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env_s,'r');
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env_s,'r');
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env2_s,'b');
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env2_s,'b');hold off

figure(212)
subplot(2,1,1); plot(up_env_s); hold on; plot(up_env2_s); hold off; legend('criteria 1', 'criteria 2'); 
ylabel('U envelope [Pixel]'); title(['Threshold: Smoothed criteria 1 = ' num2str(100*DopplerEnvThreshold) '%, Smoothed criteria 2 = ' num2str(100*DopplerEnvThreshold2) '%']);
subplot(2,1,2); plot(lo_env_s); hold on; plot(lo_env2_s); hold off; legend('criteria 1', 'criteria 2'); ylabel('L envelope [Pixel]')


fig213 = figure(213);
plot(1:length(lo_env), lo_env, 'r', 1:length(up_env), up_env, 'r')
hold on
plot(1:length(lo_env2), lo_env2, 'b', 1:length(up_env2), up_env2, 'b')
% legend('Criteria 1','Criteria 1','Criteria 2')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 4])
print(fig213,'envelopes','-djpeg','-r300')

fig214 = figure(214);
image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); %title('Smoothed - Criteria 1 (red) vs 2 (blue)'); xlabel('Time [Pixel]'); ylabel('Velocity [Pixel]')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env,'r','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env,'r','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env2,'b','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env2,'b','LineWidth',1.5);hold off
xticks([]); yticks([]);
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
% print(fig214,'envelopes2','-djpeg','-r300')


fig215 = figure(215);
plot(1:length(lo_env_s), lo_env_s, 'r', 1:length(up_env_s), up_env_s, 'r')
hold on
plot(1:length(lo_env2_s), lo_env2_s, 'b', 1:length(up_env2_s), up_env2_s, 'b')
% legend('Criteria 1','Criteria 1','Criteria 2')
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 4])
% print(fig215,'envelopes3','-djpeg','-r300')

fig216 = figure(216);
image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); %title('Smoothed - Criteria 1 (red) vs 2 (blue)'); xlabel('Time [Pixel]'); ylabel('Velocity [Pixel]')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env_s,'r','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env_s,'r','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - up_env2_s,'b','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - lo_env2_s,'b','LineWidth',1.5);hold off
xticks([]); yticks([]);
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
% print(fig216,'envelopes4','-djpeg','-r300')


%% Histogram
%Split into RGB Channels
Red = A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,1);
Green = A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,2);
Blue = A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,3);
%Get histValues for each channel
[yRed, x] = imhist(Red);
[yGreen, x] = imhist(Green);
[yBlue, x] = imhist(Blue);
%Plot them together in one plot
figure(217)
plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');
axis([0 256 0 6000])


HIST_IN(:,1) = imhist(Red,256); %RED
HIST_IN(:,2) = imhist(Green,256); %GREEN
HIST_IN(:,3) = imhist(Blue,256); %BLUE

fig218 = figure(218);
bar(HIST_IN(:,1),'r');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig218,'hist4','-djpeg','-r300')

fig219 = figure(219);
bar(HIST_IN(:,2),'g');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig219,'hist5','-djpeg','-r300')

fig220 = figure(220);
bar(HIST_IN(:,3),'b');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig220,'hist6','-djpeg','-r300')

fig221 = figure(221);
bar(HIST_IN(:,1),'r');
axis([120 190 0 5000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 1.5 3])
print(fig221,'hist7','-djpeg','-r300')

fig222 = figure(222);
bar(HIST_IN(:,2),'g');
axis([120 190 0 5000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 1.5 3])
print(fig222,'hist8','-djpeg','-r300')

fig223 = figure(223);
bar(HIST_IN(:,3),'b');
axis([120 190 0 5000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 1.5 3])
print(fig223,'hist9','-djpeg','-r300')



HIST_IN(:,1) = imhist(A(:,:,1),256); %RED
HIST_IN(:,2) = imhist(A(:,:,2),256); %GREEN
HIST_IN(:,3) = imhist(A(:,:,3),256); %BLUE

fig225 = figure(225);
bar(HIST_IN(:,1),'r');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig225,'hist1','-djpeg','-r300')

fig226 = figure(226);
bar(HIST_IN(:,2),'g');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig226,'hist2','-djpeg','-r300')

fig227 = figure(227);
bar(HIST_IN(:,3),'b');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig227,'hist3','-djpeg','-r300')



fig228 = figure(228);
HIST_avg = histogram(avg_intensity2(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:),256); 
% bar(HIST_avg,'k');
axis([0 256 0 6000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig228,'hist10','-djpeg','-r300')


%% Bland-Altman
fig241 = figure(241);
scatter((lo_env+lo_env2)/2,lo_env-lo_env2,'.k')
set(gca,'box','on')
xlabel('(Method 1 + Method 2) / 2 [Pixels]');
ylabel('Method 1 - Method 2 [Pixels]');
bias_lo_env = mean(lo_env-lo_env2)
LOV_lo_env = 1.96*std(lo_env-lo_env2)
up_limit = (bias_lo_env + LOV_lo_env);
lo_limit = (bias_lo_env - LOV_lo_env);
hold on
plot([0 200], [bias_lo_env bias_lo_env], 'r', [0 200], [up_limit up_limit], '--b', [0 200], [lo_limit lo_limit], '--b')
hold off
axis([0 200 -150 150]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig241,'BA1','-djpeg','-r300')

fig242 = figure(242);
scatter((up_env+up_env2)/2,up_env-up_env2,'.k')
set(gca,'box','on')
xlabel('(Method 1 + Method 2) / 2 [Pixels]');
ylabel('Method 1 - Method 2 [Pixels]');
bias_up_env = mean(up_env-up_env2)
LOV_up_env = 1.96*std(up_env-up_env2)
up_limit = (bias_up_env + LOV_up_env);
lo_limit = (bias_up_env - LOV_up_env);
hold on
plot([250 450], [bias_up_env bias_up_env], 'r', [250 450], [up_limit up_limit], '--b', [250 450], [lo_limit lo_limit], '--b')
hold off
axis([250 450 -150 150]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig242,'BA2','-djpeg','-r300')


fig243 = figure(243);
scatter((lo_env_s+lo_env2_s)/2,lo_env_s-lo_env2_s,'.k')
set(gca,'box','on')
xlabel('(Method 1 + Method 2) / 2 [Pixels]');
ylabel('Method 1 - Method 2 [Pixels]');
bias_lo_env_s = mean(lo_env_s-lo_env2_s)
LOV_lo_env_s = 1.96*std(lo_env_s-lo_env2_s)
up_limit = (bias_lo_env_s + LOV_lo_env_s);
lo_limit = (bias_lo_env_s - LOV_lo_env_s);
hold on
plot([0 200], [bias_lo_env_s bias_lo_env_s], 'r', [0 200], [up_limit up_limit], '--b', [0 200], [lo_limit lo_limit], '--b')
hold off
axis([0 200 -150 150]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig243,'BA3','-djpeg','-r300')

fig244 = figure(244);
scatter((up_env_s+up_env2_s)/2,up_env_s-up_env2_s,'.k')
set(gca,'box','on')
xlabel('(Method 1 + Method 2) / 2 [Pixels]');
ylabel('Method 1 - Method 2 [Pixels]');
bias_up_env_s = mean(up_env_s-up_env2_s)
LOV_up_env_s = 1.96*std(up_env_s-up_env2_s)
up_limit = (bias_up_env_s + LOV_up_env_s);
lo_limit = (bias_up_env_s - LOV_up_env_s);
hold on
plot([250 450], [bias_up_env_s bias_up_env_s], 'r', [250 450], [up_limit up_limit], '--b', [250 450], [lo_limit lo_limit], '--b')
hold off
axis([250 450 -150 150]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3])
print(fig244,'BA4','-djpeg','-r300')

%% Hybrid Peak Velocity Profile
hybrid_lo = (lo_env_s + lo_env2_s)/2;
hybrid_up = (up_env_s + up_env2_s) / 2;
fig251 = figure(251);
plot(1:length(hybrid_lo), hybrid_lo, 'k', 1:length(hybrid_up), hybrid_up, 'k')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 4])
print(fig251,'hybrid1','-djpeg','-r300')

fig252 = figure(252);
image(A(VerticalPixelDoppler_start:VerticalPixelDoppler_end,:,:)); %title('Smoothed - Criteria 1 (red) vs 2 (blue)'); xlabel('Time [Pixel]'); ylabel('Velocity [Pixel]')
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - hybrid_up,'w','LineWidth',1.5);
hold on; plot(GrayStart:GrayEnd,Doppler_Flip - hybrid_lo,'w','LineWidth',1.5);hold off
xticks([]); yticks([]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
print(fig252,'hybrid2','-djpeg','-r300')

%% Analysis of sudden changes in the peak velocity profile using FFT
L = length(lo_env);
Fs_env = 532;
f = Fs_env*(0:(L/2))/L;

Y_lo_env = fft(lo_env);
P2_lo_env = abs(Y_lo_env/L);
P1_lo_env = P2_lo_env(1:L/2+1);
P1_lo_env(2:end-1) = 2*P1_lo_env(2:end-1);

Y_lo_env_s = fft(lo_env_s);
P2_lo_env_s = abs(Y_lo_env_s/L);
P1_lo_env_s = P2_lo_env_s(1:L/2+1);
P1_lo_env_s(2:end-1) = 2*P1_lo_env_s(2:end-1);

fig261 = figure(261);
plot(f,P1_lo_env,'k',f,P1_lo_env_s,'r')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
axis([-inf inf -inf inf])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 2])
print(fig261,'fft','-djpeg','-r300')
axis([.05 inf 0 2])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 1])
print(fig261,'fft_zoom','-djpeg','-r300')


Y_up_env = fft(up_env);
P2_up_env = abs(Y_up_env/L);
P1_up_env = P2_up_env(1:L/2+1);
P1_up_env(2:end-1) = 2*P1_up_env(2:end-1);

Y_up_env_s = fft(up_env_s);
P2_up_env_s = abs(Y_up_env_s/L);
P1_up_env_s = P2_up_env_s(1:L/2+1);
P1_up_env_s(2:end-1) = 2*P1_up_env_s(2:end-1);

fig262 = figure(262);
plot(f,P1_up_env,'k',f,P1_up_env_s,'r')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
axis([-inf inf -inf inf])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 2])
print(fig262,'fft2','-djpeg','-r300')
axis([.05 inf 0 2])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 1])
print(fig262,'fft2_zoom','-djpeg','-r300')


Y_lo_env2 = fft(lo_env2);
P2_lo_env2 = abs(Y_lo_env2/L);
P1_lo_env2 = P2_lo_env2(1:L/2+1);
P1_lo_env2(2:end-1) = 2*P1_lo_env2(2:end-1);

Y_lo_env2_s = fft(lo_env2_s);
P2_lo_env2_s = abs(Y_lo_env2_s/L);
P1_lo_env2_s = P2_lo_env2_s(1:L/2+1);
P1_lo_env2_s(2:end-1) = 2*P1_lo_env2_s(2:end-1);

fig263 = figure(263);
plot(f,P1_lo_env2,'k',f,P1_lo_env2_s,'r')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
axis([-inf inf -inf inf])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 2])
print(fig263,'fft3','-djpeg','-r300')
axis([.05 inf 0 2])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 1])
print(fig263,'fft3_zoom','-djpeg','-r300')


Y_up_env2 = fft(up_env2);
P2_up_env2 = abs(Y_up_env2/L);
P1_up_env2 = P2_up_env2(1:L/2+1);
P1_up_env2(2:end-1) = 2*P1_up_env2(2:end-1);

Y_up_env2_s = fft(up_env2_s);
P2_up_env2_s = abs(Y_up_env2_s/L);
P1_up_env2_s = P2_up_env2_s(1:L/2+1);
P1_up_env2_s(2:end-1) = 2*P1_up_env2_s(2:end-1);

fig264 = figure(264);
plot(f,P1_up_env2,'k',f,P1_up_env2_s,'r')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
axis([-inf inf -inf inf])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 2])
print(fig264,'fft4','-djpeg','-r300')
axis([.05 inf 0 2])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 2 1])
print(fig264,'fft4_zoom','-djpeg','-r300')

%%
smoothed_image(:,:,1) = smooth2a(double(A(:,:,1)),3,3)/255;
BW1 = edge(smoothed_image(575:1030,:,1),'Canny',.05,'vertical');
BW2 = edge(smoothed_image(575:1030,:,1),'Prewitt',.05,'vertical');
fig271 = figure(271);
imshow(BW1)
fig272 = figure(272);
imshow(BW2)
BW1 = edge(smoothed_image(575:1030,:,1),'Canny',.3,'vertical');
BW2 = edge(smoothed_image(575:1030,:,1),'Prewitt',.3,'vertical');
fig273 = figure(273);
imshow(BW1)
fig274 = figure(274);
imshow(BW2)

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
print(fig271,'canny1','-djpeg','-r300')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
print(fig272,'prewitt1','-djpeg','-r300')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
print(fig273,'canny2','-djpeg','-r300')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 2])
print(fig274,'prewitt2','-djpeg','-r300')
end