%%%%%%%%%%%% File used for statistical analysis of temporal EMG data

%% LOAD
clc; clear all; close all;
IDs = [6,7,8,9,10,11,12,13, 14, 15, 16, 17];
chk = exist('Nodes','var');
power = zeros(102,6);
if ~chk
for ID = IDs
    ID = num2str(ID);
    folderload = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Frequency';
    fileload = ['\Frequency_EMG_ID_' ID];
    load([folderload fileload]);
    fn = fieldnames(EMG_Frequency);
    %%% could do something to filter the velocites first and then calc mean
    %%% IEMG and smoothness...
    ID = str2num(ID);
    for speed = 0:2
    temp_power_flex = (EMG_Frequency.(fn{1+2*speed}));
    temp_power_extend = (EMG_Frequency.(fn{2+2*speed}));
    temp_freq = (EMG_Frequency.(fn{13+speed}));
    
    for trials = 1: length(temp_freq(:,1))
        freq_no_zeros = (nonzeros(temp_freq(trials,:)));
        power_no_zeros_flex = (nonzeros(temp_power_flex(trials,2:end)));
        power_no_zeros_extend = (nonzeros(temp_power_extend(trials,2:end)));
        % bin the spectral data into 1Hz categories
        [B,idx] = histc(freq_no_zeros,0:1:100);
        idx_filt= idx(idx<=100);
        temp_flex = accumarray(idx_filt(:),power_no_zeros_flex(idx<=100),[],@mean);
        temp_extend = accumarray(idx_filt(:),power_no_zeros_extend(idx<=100),[],@mean);
        binned_power_flex(1:length(temp_flex),trials) = temp_flex;
        binned_power_extend(1:length(temp_extend),trials) = temp_extend;
    end
    power(:, speed+1) = power(:,speed+1) + [0; (mean(binned_power_flex, 2)); 0];
    power(:, speed+4) = power(:,speed+4) + [0; (mean(binned_power_extend, 2)); 0];
    end
end

    power(:,:) = power(:,:) / length(IDs);
    %%% plotted mean spectral analysis for 1Hz binned data over all IDs
    freqs = 0:1:100;
%     power = [0; (mean(binned_power, 2)); 0];
    freqs(end+1) = 100;

%     if speed == 0
    figure(1)
    subplot(2,1,1)
    h1 = patch(freqs,power(:,1),'r');
    
    hold on
%     elseif speed == 1
    h2 = patch(freqs,power(:,2),'y');
    hold on
%     else speed == 2
    h3 = patch(freqs,power(:,3),'b');
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    set(h1,'facealpha',0.5)
    set(h2,'facealpha',0.5)
    set(h3,'facealpha',0.5)
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Spectral Power (W/Hz)')
    title('Flexor')
    ylim([0 15000])
    hold off
    
%     figure(2)
    subplot(2,1,2)
    h1 = patch(freqs,power(:,4),'r');
    hold on
%     elseif speed == 1
    h2 = patch(freqs,power(:,5),'y');
    hold on
%     else speed == 2
    h3 = patch(freqs,power(:,6),'b');
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    set(h1,'facealpha',0.5)
    set(h2,'facealpha',0.5)
    set(h3,'facealpha',0.5)
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Spectral Power (W/Hz)')
    title('Extensor')
    hold off
   
%%%%>>>>>>>>>>>>> DO STUFF
end

%% Running integral - cant find the source i used before?? Normalised

figure(2)
    subplot(2,1,1)
    Q_slow_flex = cumtrapz(power(2:101,1));
    norm_slow_flex = Q_slow_flex/ Q_slow_flex(end);
    below = max(norm_slow_flex(norm_slow_flex < 0.5));
    below_ind = find(below == norm_slow_flex);
    above = min(norm_slow_flex(norm_slow_flex > 0.5));
    above_ind = find(above == norm_slow_flex);
    interp_freq_slow_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_slow_flex)
    
    hold on
    Q_med_flex = cumtrapz(power(2:101,2));
    norm_med_flex = Q_med_flex/ Q_med_flex(end);
    below = max(norm_med_flex(norm_med_flex < 0.5));
    below_ind = find(below == norm_med_flex);
    above = min(norm_med_flex(norm_med_flex > 0.5));
    above_ind = find(above == norm_med_flex);
    interp_freq_med_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_med_flex)
    hold on
%     else speed == 2
    Q_fast_flex = cumtrapz(power(2:101,3));
    
    norm_fast_flex = Q_fast_flex/ Q_fast_flex(end);
    below = max(norm_fast_flex(norm_fast_flex < 0.5));
    below_ind = find(below == norm_fast_flex);
    above = min(norm_fast_flex(norm_fast_flex > 0.5));
    above_ind = find(above == norm_fast_flex);
    interp_freq_fast_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_fast_flex)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Normalised Power')
    title('Flexor')
    hold off
    
    subplot(2,1,2)
    Q_slow_extensor = cumtrapz(power(2:101,4));
    norm_slow_extensor = Q_slow_extensor/ Q_slow_extensor(end);
    below = max(norm_slow_extensor(norm_slow_extensor < 0.5));
    below_ind = find(below == norm_slow_extensor);
    above = min(norm_slow_extensor(norm_slow_extensor > 0.5));
    above_ind = find(above == norm_slow_extensor);
    interp_freq_slow_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_slow_extensor)
    
    hold on
    Q_med_extensor = cumtrapz(power(2:101,5));
    norm_med_extensor = Q_med_extensor/ Q_med_extensor(end);
    below = max(norm_med_extensor(norm_med_extensor < 0.5));
    below_ind = find(below == norm_med_extensor);
    above = min(norm_med_extensor(norm_med_extensor > 0.5));
    above_ind = find(above == norm_med_extensor);
    interp_freq_med_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_med_extensor)
    hold on
%     else speed == 2
    Q_fast_extensor = cumtrapz(power(2:101,6));
    
    norm_fast_extensor = Q_fast_extensor/ Q_fast_extensor(end);
    below = max(norm_fast_extensor(norm_fast_extensor < 0.5));
    below_ind = find(below == norm_fast_extensor);
    above = min(norm_fast_extensor(norm_fast_extensor > 0.5));
    above_ind = find(above == norm_fast_extensor);
    interp_freq_fast_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_fast_extensor)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Normalised Power')
    title('Extensor')
    hold off
    
%% Running integral - cant find the source i used before?? 

figure(3)
    subplot(2,1,1)
    Q_slow_flex = cumtrapz(power(2:101,1));
    mean_power_flex_slow = mean(power(2:101,1))
    max_power_flex_slow = max(power(2:101,1))
    plot(Q_slow_flex )
    
    hold on
    Q_med_flex = cumtrapz(power(2:101,2));
    mean_power_flex_med = mean(power(2:101,2))
    max_power_flex_med = max(power(2:101,2))
    plot(Q_med_flex)
    hold on
%     else speed == 2
    Q_fast_flex = cumtrapz(power(2:101,3));
    mean_power_flex_fast = mean(power(2:101,3))
    max_power_flex_fast = max(power(2:101,3))
    plot(Q_fast_flex)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Power (W)')
    title('Flexor')
    hold off
    
    subplot(2,1,2)
    Q_slow_extensor = cumtrapz(power(2:101,4));
    mean_power_extensor_slow = mean(power(2:101,4))
    max_power_extensor_slow = max(power(2:101,4))
    plot(Q_slow_extensor)
    
    hold on
    Q_med_extensor = cumtrapz(power(2:101,5));
    mean_power_extensor_med = mean(power(2:101,5))
    max_power_extensor_med = max(power(2:101,5))
    plot(Q_med_extensor)
    hold on
%     else speed == 2
    Q_fast_extensor = cumtrapz(power(2:101,6));
    mean_power_extensor_fast = mean(power(2:101,6))
    max_power_extensor_fast = max(power(2:101,6))
    plot(Q_fast_extensor)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Power (W)')
    title('Extensor')
    hold off
% % %% plot raw smoothness 
% % 
% % slow_flex = plot(abs(mean_smoothness(:,1)))
% % hold on
% % slow_extend = plot(abs(mean_smoothness(:,2)))
% % hold on
% % 
% % medium_flex = plot(abs(mean_smoothness(:,3)))
% % hold on
% % medium_extend = plot(abs(mean_smoothness(:,4)))
% % hold on
% % 
% % fast_flex = plot(abs(mean_smoothness(:,5)))
% % hold on
% % fast_extend = plot(abs(mean_smoothness(:,6)))
% % hold on
% % 
% % calib_flex = plot(Calib_Temporal.smoothness_flex_calib)
% % hold on
% % calib_extend = plot(Calib_Temporal.smoothness_extend_calib)
% % hold on
% % 
% % xlabel('ID')
% % ylabel('Mean smoothness / variance')
% % legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
% %          'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
% %      
% % % % %% Try normalising in time 
% % % % norm_slow_flex = abs(mean_smoothness(:,1))./ 1.8;
% % % % norm_medium_flex = abs(mean_smoothness(:,3)) ./ 0.75;
% % % % norm_fast_flex = abs(mean_smoothness(:,5)) ./ 0.45;
% % % % 
% % % % norm_slow_extend = abs(mean_smoothness(:,2))./ 1.8;
% % % % norm_medium_extend = abs(mean_smoothness(:,4)) ./ 0.75;
% % % % norm_fast_extend = abs(mean_smoothness(:,6)) ./ 0.45;
% % % % 
% % % % norm_calib_flex = Calib_Temporal.smoothness_flex_calib ./ Calib_Temporal.time_calib;
% % % % norm_calib_extend = Calib_Temporal.smoothness_extend_calib ./ Calib_Temporal.time_calib;
% % % % 
% % % % slow_flex = plot(norm_slow_flex)
% % % % hold on
% % % % slow_extend = plot(norm_slow_extend)
% % % % hold on
% % % % 
% % % % medium_flex = plot(norm_medium_flex)
% % % % hold on
% % % % medium_extend = plot(norm_medium_extend)
% % % % hold on
% % % % 
% % % % fast_flex = plot(norm_fast_flex)
% % % % hold on
% % fast_extend = plot(norm_fast_extend)
% % hold on
% % 
% % calib_flex = plot(norm_calib_flex)
% % hold on
% % calib_extend = plot(norm_calib_extend)
% % hold on
% % 
% % xlabel('ID')
% % ylabel('Mean smoothness / variance')
% % legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
% %          'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
% % title('Normalised')
% %      
% % %% Flex raw
% % 
% % Anova_flex_smoothness = [mean_smoothness(:,1) mean_smoothness(:,3) mean_smoothness(:,5) ];
% % [p,tbl,stats] = anova1(Anova_flex_smoothness)
% % 
% % %% Extend raw
% % Anova_extend_smoothness = [mean_smoothness(:,2) mean_smoothness(:,4) mean_smoothness(:,6)];
% % [p,tbl,stats] = anova1(Anova_extend_smoothness)
% % multcompare(stats)
% % %% All raw
% % Anova_all_smoothness = [mean_smoothness(:,1) mean_smoothness(:,2) mean_smoothness(:,3) mean_smoothness(:,4) mean_smoothness(:,5) mean_smoothness(:,6)];
% % [p,tbl,stats] = anova1(Anova_all_smoothness)
% % multcompare(stats)
% % %% Flex normalised
% % Anova_flex_smoothness_norm = [norm_slow_flex norm_medium_flex norm_fast_flex ];
% % [p,tbl,stats] = anova1(Anova_flex_smoothness_norm)
% % 
% % %% Extend normalised
% % Anova_extend_smoothness_norm = [norm_slow_extend norm_medium_extend norm_fast_extend ];
% % [p,tbl,stats] = anova1(Anova_extend_smoothness_norm)
% % 
% % %% All normalised
% % Anova_all_smoothness_norm = [norm_slow_flex norm_medium_flex norm_fast_flex  ...
% %     norm_slow_extend norm_medium_extend norm_fast_extend  ];
% % [p,tbl,stats] = anova1(Anova_all_smoothness_norm)
