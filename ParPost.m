function [CorrMax_t, t_Cmax_t, Touch_t, P_Sign_t, Corr_Full_Data] = ...
    ParPost(Precision_steps, len, Smooth_Window_s, Search_Window_s, FREQ)

steps = size (1 : Precision_steps : len - round(Smooth_Window_s*FREQ));
steps2nd = steps(2);

sizezeros = length(1 : Precision_steps:len - Smooth_Window_s*FREQ);
CorrMax_t = zeros(sizezeros,1); 
t_Cmax_t = zeros(sizezeros,1);
Touch_t = zeros(sizezeros,1); 
P_Sign_t = zeros(sizezeros,1);
Corr_Full_Data = zeros(sizezeros,round(Search_Window_s*FREQ));
finalstep = (steps2nd-1)*Precision_steps + 1;

%parfor j = 1 : round(Precision_steps) : finalstep
parfor j = 1 : steps2nd
%     OUTPUT CONTROL
%     CorrMax_t(j) = CorrA_max;   
%     t_Cmax_t(j) = t_Cmax;
%     Touch_t(j) = Touch;         
%     P_Sign_t(j) = P_Sign;
%     Corr_Full_Data(j,:) = CorrA_t(:,1)';
    tempxlsx_read = sprintf('temp/parallel_temp_%d.xlsx\n', (j-1)*Precision_steps + 1);
    fprintf('Reading the Temp File for Parallel Post: ');
    fprintf(tempxlsx_read);
    matdata = readmatrix(tempxlsx_read);
    CorrMax_t(j,1) = matdata(1,1);   
    t_Cmax_t(j,1) = matdata(2,1);
    Touch_t(j,1) = matdata(3,1);         
    P_Sign_t(j,1) = matdata(4,1);
    Corr_Full_Data(j,:) = matdata(5,:);
end
end