function [CorrMax_t, t_Cmax_t, Corr_Full_Data] = ...
   CorrMB (X1_t, X2_t, Search_Window_s, Smooth_Window_s, ...
   Precision_steps, Start_Time_ms, Confidence_P1, Normalization, Compare_Fig)
%% This is a function regarding Correlation Analysis Method B.
% Namely, Windowed method.
% Author: Huanxia WEI @ NUS     Version: 2024/03/20, R2022a
global FREQ 

%% Calculate the Correlation Sequence by Iterately Using Method A
% Value setting for debug purpose only. Make it always comments until debug.
%Search_Window = 10/1000; Smooth_Window = 50/1000; Precision = 10;
% End of debug zone

len_x1=length(X1_t); len_x2=length(X2_t); % Detect the length of signal.
if len_x1 ~= len_x2
    error('The two signals for Method B have different length!'); end
len = len_x1;
clear len_x1 len_x2
if ~exist('Start_Time_ms', 'var')
Start_Time_ms = 0; end
if Compare_Fig == 1
    Tem_Pic = 2; 
else 
    Tem_Pic = 1; 
end
t_plot = 1 : Precision_steps : len - round(Smooth_Window_s*FREQ);
% Initial the returning matrix
sizezeros = length(t_plot);
CorrMax_t = zeros(sizezeros,1); t_Cmax_t = zeros(sizezeros,1);
Touch_t = zeros(sizezeros,1); P_Sign_t = zeros(sizezeros,1);
Corr_Full_Data = zeros(sizezeros,round(Search_Window_s*FREQ));

for i = 1 : Precision_steps : len - Smooth_Window_s*FREQ
    j = round((i-1)/Precision_steps)+1;
    X1_t_win = X1_t (i:i+round(Smooth_Window_s*FREQ));
    X2_t_win = X2_t (i:i+round(Smooth_Window_s*FREQ));
    win_start = i / FREQ;    
    fprintf('Current Window Starts at %.4f ms.\n',win_start*1000);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MAIN CALCULATION BY CALLING CORRELATION METHOD A %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [CorrA_t, CorrA_max, t_Cmax, P_Sign, Touch] =  ...       
    CorrMA (X1_t_win, X2_t_win, Search_Window_s, Confidence_P1, 1, 0.3, Tem_Pic, i);
    CorrMax_t(j) = CorrA_max;   t_Cmax_t(j) = t_Cmax;
    Touch_t(j) = Touch;         P_Sign_t(j) = P_Sign;
    Corr_Full_Data(j,:) = CorrA_t(:,1)';

    if Compare_Fig == 1 % Combine the correlation and original experimental photo
    img_L = imread("temp\temp.png");
    pic_right_name = sprintf('exp_pics/%d.jpg', i); img_R = imread(pic_right_name);  
    height_L = size(img_L, 1); height_R = size(img_R, 1);
    if height_L ~= height_R
        img_R_resized = imresize(img_R, [height_L, NaN]);
    else
        img_R_resized = img_R;
    end
    img_combined = [img_L, img_R_resized];
    
    text_str = ['Time = ', num2str(i/FREQ*1000),' ms'];
    position = [3380, 10];
    font_size = 80;
    text_color = [200, 200, 200]; 
    img_with_watermark = insertText(img_combined, position, text_str, ...
        'FontSize', font_size, 'TextColor', text_color, 'BoxOpacity', 0);
    figure(5);    imshow(img_with_watermark);
    end     % Add timecode to the picture
end

%% Plots
CorrPlot (Corr_Full_Data, CorrMax_t,t_Cmax_t,P_Sign_t,...
   Smooth_Window_s, Precision_steps, Start_Time_ms, Normalization, len);

end