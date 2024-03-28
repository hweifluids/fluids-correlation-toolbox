function [] = ...
   CorrPlot (Corr_Full_Data, CorrMax_t,t_Cmax_t,P_Sign_t,...
   Smooth_Window_s, Precision_steps, Start_Time_ms, Normalization, len)
global FREQ;

%% Plot the wavelet.

t_plot = 1 : Precision_steps : len - round(Smooth_Window_s*FREQ);

figure(2)
imagesc(Corr_Full_Data'); axis xy; hold off;
if ~exist('Start_Time_ms', 'var')
Start_Time_ms = 0; end
xticks = get(gca, 'XTick'); new_xticks = xticks*Precision_steps/FREQ*1000+Start_Time_ms;
yticks = get(gca, 'YTick'); new_yticks = yticks/FREQ*1000;
set(gca, 'XTickLabel', new_xticks); set(gca, 'YTickLabel', new_yticks);
xlabel('Time for Sliding Window (ms)'); ylabel('Time for Correlation (ms)');
title('Correlation Coefficient Distribution Wavelet over Sliding Time');

%% Plot the Wavelet (Normalized).
if Normalization == 1
Corr_Full_Data_Norm = CorrNom(Corr_Full_Data); % Conduct data normalization

figure(4)
imagesc(Corr_Full_Data_Norm'); axis xy; hold off;

xticks = get(gca, 'XTick'); new_xticks = xticks*Precision_steps/FREQ*1000+Start_Time_ms;
yticks = get(gca, 'YTick'); new_yticks = yticks/FREQ*1000;
set(gca, 'XTickLabel', new_xticks); set(gca, 'YTickLabel', new_yticks);
xlabel('Time for Sliding Window (ms)'); ylabel('Time for Correlation (ms)');
title('Correlation Coefficient Distribution (Normalized)');

end

%% Plot the CorrA_max and Time_Cmax over Time.
figure(3)
t_plot_re = 1000/FREQ*t_plot';
yyaxis left; plot(t_plot_re,CorrMax_t); hold on; ylabel('Maximum Correlation Coefficient');
yyaxis right; scatter(t_plot_re,t_Cmax_t,10,'filled'); hold on; ylabel('Delay Time Obtaining Max Correlation');
title('CorrAmax and TimeCmax over Time (Double-Windowed Correlation)');
xlabel('Time for Sliding Window (ms)');
hold off;
% Path the unsignificant area
significance_idx = find(P_Sign_t(:) == 0); 
for i = 1:length(significance_idx)
    idx = significance_idx(i);
    x = t_plot_re(idx);
    % Patch the unsignificant area
    halfsize = (max(t_plot_re)-min(t_plot_re)) / (length(t_plot_re)-1)/2;
    x_patch = [x-halfsize x+halfsize x+halfsize x-halfsize];
    yrg = ylim(gca);
    y_patch = [yrg(1) yrg(1) yrg(2) yrg(2)];
    patch(x_patch, y_patch, 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
end

end