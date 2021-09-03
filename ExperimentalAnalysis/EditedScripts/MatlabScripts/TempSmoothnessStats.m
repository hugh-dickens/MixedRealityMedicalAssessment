%%%%%%%%%%%% File used for statistical analysis of temporal EMG data

%% LOAD
clc; clear all; close all;
IDs = [6,7,8,9,10,11,12,13, 14, 15, 16, 17];
chk = exist('Nodes','var');
if ~chk
for ID = IDs
    ID = num2str(ID);
    folderload = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Temporal';
    fileload = ['\Temporal_EMG_ID_' ID];
    load([folderload fileload]);
    fn = fieldnames(EMG_Temporal);
    %%% could do something to filter the velocites first and then calc mean
    %%% IEMG and smoothness...
    ID = str2num(ID);
    for i = 1:6
        mean_IEMG(ID-5, i) = mean(EMG_Temporal.(fn{i}));
    end
    
    for i = 7:12
        mean_smoothness(ID-5, i - 6) = mean(EMG_Temporal.(fn{i}));
    end

   
%%%%>>>>>>>>>>>>> DO STUFF
end
end
calibLoad = ['\Temporal_EMG_Calib'];
load([folderload calibLoad]);

%% plot raw smoothness 

slow_flex = plot(abs(mean_smoothness(:,1)))
hold on
slow_extend = plot(abs(mean_smoothness(:,2)))
hold on

medium_flex = plot(abs(mean_smoothness(:,3)))
hold on
medium_extend = plot(abs(mean_smoothness(:,4)))
hold on

fast_flex = plot(abs(mean_smoothness(:,5)))
hold on
fast_extend = plot(abs(mean_smoothness(:,6)))
hold on

calib_flex = plot(Calib_Temporal.smoothness_flex_calib)
hold on
calib_extend = plot(Calib_Temporal.smoothness_extend_calib)
hold on

xlabel('ID')
ylabel('Mean smoothness / variance')
legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
         'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
     
%% Try normalising in time 
norm_slow_flex = abs(mean_smoothness(:,1))./ 1.8;
norm_medium_flex = abs(mean_smoothness(:,3)) ./ 0.75;
norm_fast_flex = abs(mean_smoothness(:,5)) ./ 0.45;

norm_slow_extend = abs(mean_smoothness(:,2))./ 1.8;
norm_medium_extend = abs(mean_smoothness(:,4)) ./ 0.75;
norm_fast_extend = abs(mean_smoothness(:,6)) ./ 0.45;

norm_calib_flex = Calib_Temporal.smoothness_flex_calib ./ Calib_Temporal.time_calib;
norm_calib_extend = Calib_Temporal.smoothness_extend_calib ./ Calib_Temporal.time_calib;

slow_flex = plot(norm_slow_flex)
hold on
slow_extend = plot(norm_slow_extend)
hold on

medium_flex = plot(norm_medium_flex)
hold on
medium_extend = plot(norm_medium_extend)
hold on

fast_flex = plot(norm_fast_flex)
hold on
fast_extend = plot(norm_fast_extend)
hold on

calib_flex = plot(norm_calib_flex)
hold on
calib_extend = plot(norm_calib_extend)
hold on

xlabel('ID')
ylabel('Mean smoothness / variance')
legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
         'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
title('Normalised')
     
%% Flex raw

Anova_flex_smoothness = [mean_smoothness(:,1) mean_smoothness(:,3) mean_smoothness(:,5) ];
[p,tbl,stats] = anova1(Anova_flex_smoothness)

%% Extend raw
Anova_extend_smoothness = [mean_smoothness(:,2) mean_smoothness(:,4) mean_smoothness(:,6)];
[p,tbl,stats] = anova1(Anova_extend_smoothness)
multcompare(stats)
%% All raw
Anova_all_smoothness = [mean_smoothness(:,1) mean_smoothness(:,2) mean_smoothness(:,3) mean_smoothness(:,4) mean_smoothness(:,5) mean_smoothness(:,6)];
[p,tbl,stats] = anova1(Anova_all_smoothness)
multcompare(stats)
%% Flex normalised
Anova_flex_smoothness_norm = [norm_slow_flex norm_medium_flex norm_fast_flex ];
[p,tbl,stats] = anova1(Anova_flex_smoothness_norm)

%% Extend normalised
Anova_extend_smoothness_norm = [norm_slow_extend norm_medium_extend norm_fast_extend ];
[p,tbl,stats] = anova1(Anova_extend_smoothness_norm)

%% All normalised
Anova_all_smoothness_norm = [norm_slow_flex norm_medium_flex norm_fast_flex  ...
    norm_slow_extend norm_medium_extend norm_fast_extend  ];
[p,tbl,stats] = anova1(Anova_all_smoothness_norm)
