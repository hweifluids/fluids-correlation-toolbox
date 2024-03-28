function [CorrA_t, CorrA_max, t_Cmax, P_Sign, Touch] = ...
   CorrMA (X1_t, X2_t, Phase_Diff_Max_s, Confidence_P, Figure_on, Fixed_axis_yrange, Save_Pic, Timecode)
%% This is a function regarding Correlation Analysis Method A.
% Namely, Un-windowed method.
% Author: Huanxia WEI @ NUS     Version: 2024/03/20, R2022a
%% Use the global variable FREQ for testing frequency
%global FREQ 
FREQ = 80000;
% Value setting for debug purpose only. Make it always comments until debug.
% T1=50/1000; t_start = 150/1000;
% pha_diff = 1234; printf('WARNING! DEBUG MODE ENABLED!');
% End of debug zone

len_x1=length(X1_t); len_x2=length(X2_t); % Detect the length of signal.
if len_x1 ~= len_x2
    error('The two signals for Method A have different length!'); 
end
len = len_x1;
clear len_x1 len_x2

%% Calculate the CorrA_t Results
% Generate a time sequency for calculations.
T=(len-1)/FREQ; 
t_seq= 0:1/FREQ:T-Phase_Diff_Max_s; % Generate a time sequency for calculations.
% Window the signal X1
X1_winA = X1_t(1:round((T-Phase_Diff_Max_s)*FREQ)); 

% Calculation CorrA_t
CorrA_t = zeros (round(Phase_Diff_Max_s*FREQ),2); % Initial CorrA_t
for pha_diff = 0:1:Phase_Diff_Max_s*FREQ-1
    X2_winA = X2_t(1+pha_diff:round((T-Phase_Diff_Max_s)*FREQ+pha_diff));
    [corr_t,p_val]= corr(X1_winA,X2_winA);
    CorrA_t(pha_diff+1,:) = [corr_t,p_val];
end

%% Return the Maximium Correlated Time-Point and Significance
CorrA_max = max(CorrA_t(round(Phase_Diff_Max_s*FREQ/50):round(Phase_Diff_Max_s*FREQ),1));
index = find(CorrA_t(:,1) == CorrA_max);
t_Cmax = index*1000/FREQ;
CorrA_max = CorrA_t(index,1);
%t_Cmax = index*1000/FREQ + t_start;
fprintf("The maximium correlation coefficient is %.4f.\nThe corresponding time is at %.4f ms.\n",CorrA_max,t_Cmax);
Thd_P = 1-Confidence_P;
if CorrA_t(index,2) < Thd_P
    P_Sign = 1;
else 
    P_Sign = 0;
end
if index == length(CorrA_t(:,1))
    Touch = 1; fprintf("Warning: Time Touch Occurs!\n");
else
    Touch = 0; fprintf("\n");
end

%% Plot the Pearson Factor over Time with Significance
if Figure_on == 1
    %t_seq_plot = (t_seq(1:round(T1*FREQ))*1000 + t_start)';
    t_seq_plot = (t_seq(1:round(Phase_Diff_Max_s*FREQ))*1000)';
    %plot(t_seq_plot,CorrA_t(:,1));
    %plot(t_seq_plot,CorrA_t(:,2));
    figure(1); clf;
    plot(t_seq_plot, CorrA_t(:,1), 'b-'); % Plot Pearson Factors
    hold on; 
    
% Fix the axis range due to input parameter
    xlim([0,round(Phase_Diff_Max_s*1000)]);
    if ~exist('Fixed_axis_yrange', 'var')
    Fixed_axis_yrange = 0;
    end
    if Fixed_axis_yrange ~= 0
        ylim([-Fixed_axis_yrange,Fixed_axis_yrange]); 
    end

% Highlight the unsignificant area
    % Detect the x-position with P-Value > Thd_P, namely unsignificant.
    significance_idx = find(CorrA_t(:,2) > Thd_P); 
    
    for i = 1:length(significance_idx)
        idx = significance_idx(i);
        x = t_seq_plot(idx);
        % Patch the unsignificant area
        x_patch = [x-500/FREQ x+500/FREQ x+500/FREQ x-500/FREQ];
        yrg = ylim(gca);
        y_patch = [yrg(1) yrg(1) yrg(2) yrg(2)];
        patch(x_patch, y_patch, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end
    hold on;
    
% Draw the peak lines
    % Time position line
    xrg = xlim(gca); yrg = ylim(gca);
    hold on; plot([t_Cmax t_Cmax],yrg,'Color',"#77AC30",'LineWidth',2);
    hold on; plot(xrg,[CorrA_max CorrA_max],'Color',"#77AC30",'LineWidth',2);
    
% Create the labels and titles
    hold off;
    xlabel('Time (ms)');
    ylabel('Pearson Factor');
    title('Correlation vs Time with Significance (Un-Windowed Method)');
    grid on;
    
%% Save or Temp the Figure    
    if Save_Pic == 2 % Temp and Save
        print('-dpng', '-r300', 'temp/temp.png');
        pic_name = sprintf('output/%d.png', Timecode);
        print('-dpng', '-r300', pic_name);
    end 
    if Save_Pic == 1 % Only Save
        pic_name = sprintf('output/%d.png', Timecode);
        print('-dpng', '-r300', pic_name);
    end 
end
end