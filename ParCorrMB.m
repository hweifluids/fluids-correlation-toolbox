function [CorrMax_t, t_Cmax_t, Corr_Full_Data] = ...
   ParCorrMB (X1_t, X2_t, Search_Window_s, Smooth_Window_s, ...
   Precision_steps, Start_Time_ms, Confidence_P1, Normalization)

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

%% Prepare the parallel computing
steps = size (1 : Precision_steps : len - round(Smooth_Window_s*FREQ));
steps2nd = steps(2);
steps1= size(1:1+round(Smooth_Window_s*FREQ));
    X1_t_win = zeros(steps2nd, steps1(2));
    X2_t_win = zeros(steps2nd, steps1(2));
    
    %i = 1 : Precision_steps : len - Smooth_Window_s*FREQ
for i = 1 : steps2nd
    %a = X1_t (i:i+round(Smooth_Window_s*FREQ));
    X1_t_win(i,:) = X1_t (i:i+round(Smooth_Window_s*FREQ));
    X2_t_win(i,:) = X2_t (i:i+round(Smooth_Window_s*FREQ));
end

%% PARFOR
parfor i = 1 : steps2nd
    %j = round((i-1)/Precision_steps)+1;
    real_i = (i-1)*Precision_steps + 1;
    win_start = real_i / 80000;    
    fprintf('Current Window Starts at %.4f ms.\nNotice: Parallel Mode Enabled! \n',win_start*1000);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MAIN CALCULATION BY CALLING CORRELATION METHOD A %
    % WARNING: PARALLEL VERSION ! ADMIN PERM NEEDED !  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [CorrA_t, CorrA_max, t_Cmax, P_Sign, Touch] =  ...       
    CorrMA (X1_t_win(i,:)', X2_t_win(i,:)', Search_Window_s, Confidence_P1, 1, 0.3, 0, i);
%     OUTPUT CONTROL
    tempxlsx = sprintf('temp/parallel_temp_%d.xlsx', real_i);
    writematrix(CorrA_max, tempxlsx, 'Range', 'A1');
    writematrix(t_Cmax, tempxlsx, 'Range', 'A2');
    writematrix(Touch, tempxlsx, 'Range', 'A3');
    writematrix(P_Sign, tempxlsx, 'Range', 'A4');
    writematrix(CorrA_t(:,1)', tempxlsx, 'Range', 'A5');
    fprintf('Temp Recording for Parallel: Step %d.\n',real_i);
end

%% PARPOST: Parallel Data Post-Processing.
[CorrMax_t, t_Cmax_t, Touch_t, P_Sign_t, Corr_Full_Data] = ...
    ParPost(Precision_steps, len, Smooth_Window_s, Search_Window_s, FREQ);

%% Plots
CorrPlot (Corr_Full_Data, CorrMax_t,t_Cmax_t,P_Sign_t,...
   Smooth_Window_s, Precision_steps, Start_Time_ms, Normalization, len);

end