%% SLIDE AND SEARCH: DOUBLE_WINDOWED CORRELATION ANALYSIS PROGRAM FOR TWO ENGINEERING SIGNALS
% Author: Huanxia WEI @ NUS     Version: 2024/03/21, R2022a

%% Define the inputs and parameters
filename = 'corr_data.xlsx'; 

%% Method Switcher
Method = 2; % 1 for Method A and 2 for Method B
Re_Read_Data = 1; % Set to 1 to reload the data from local table

%% Read the data table
if Re_Read_Data == 1 % BD FH JL
X1_t = readmatrix(filename, 'Range', 'J3:J1048576', 'OutputType', 'double');
X1_t = X1_t(1:find(~isnan(X1_t), 1, 'last'));
X2_t = readmatrix(filename, 'Range', 'L3:L1048576', 'OutputType', 'double');
X2_t = X2_t(1:find(~isnan(X2_t), 1, 'last'));
t_seq_total = readmatrix(filename, 'Range', 'A3:A1048576', 'OutputType', 'double');
t_seq_total = t_seq_total(1:find(~isnan(t_seq_total), 1, 'last'));
t_start=t_seq_total(1);
global FREQ
FREQ = 1 / (t_seq_total(2) - t_seq_total(1))*1000;
fprintf('The sampling frequency is %d Hz.\n',round(FREQ));
end

%% Method A: Un-Windowed Method
if Method == 1
T1 = 20 / 1000; % Set to phase_diffence_max_in_millisecond / 1000
Confidence_P = 0.95; % Set to the confidence target you want.
[A_CorrA_t, A_CorrA_max, A_t_Cmax, A_P_Sign, A_Touch] = ...
    CorrMA (X1_t, X2_t, T1, Confidence_P, 1, 0, 1, 0);
end

%% Method B: Double-Windowed Method
if Method == 2
Search_Window = 10/1000; % Small Window for Searching: in millisecond / 1000, or in second
Smooth_Window = 50/1000; % Sliding Window for Smoothing: in millisecond / 1000, or in second
Precision = 1; % Slinding Interval, in Number of Timesteps for each sliding process
Confidence_P1 = 0.95; % Set to the confidence target you want.
Start_Time = 150; % Start time in millisecond

par_enabler = 1;

if par_enabler == 1
% With Parallel Computing
delete(gcp('nocreate')); numCore = feature('numcores'); parpool(numCore - 2);
[B_CorrMax_t, B_t_Cmax_t, B_Corr_Full_Data] = ...
   ParCorrMB (X1_t, X2_t, Search_Window, Smooth_Window, Precision,Start_Time,Confidence_P1,1);
end
if par_enabler == 0
% Without Parallel Computing
 [B_CorrMax_t, B_t_Cmax_t, B_Corr_Full_Data] = ...
     CorrMB (X1_t, X2_t, Search_Window, Smooth_Window, ...
     Precision, Start_Time, Confidence_P1, 1, 0);
end
end

%% Output the data in the works
save('output/data/Corr_Full_Data.mat',"B_Corr_Full_Data");
save('output/data/CorrMax_t.mat',"B_CorrMax_t");
%save('output/data/P_Sign_t.mat',"P_Sign_t");
save('output/data/t_Cmax_t.mat',"B_t_Cmax_t");

%% Note for Figures
% Figure(1) = Instantaneous Correlation Distribution % Disabled by default
% Figure(2) = Correlation Coefficient Distribution Wavelet over Sliding Time
% Figure(3) = CorrA_max and Time_Cmax over Time (Double-Windowed Correlation)
% Figure(4) = Correlation Coefficient Distribution Wavelet over Sliding Time (Normalized)
% Figure(5) = Figure(1) with Image for Comparing Purpose % Disabled by default