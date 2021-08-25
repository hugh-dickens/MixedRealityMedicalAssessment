clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.
IDs = [1,4,5,6,7,8,9,10,11,12,13, 14, 15, 16, 17];
chk = exist('Nodes','var');
if ~chk
    for ID = IDs
%     ID = 11;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_MATLAB\VelocityErrorData\';
    mat_data = ['VelErrorData' ID];
    load([ID_folder mat_data])
    end
end
% mergeVelErrors = cell2struct([struct2cell(VelErrorData11), fieldname(VelErrorData11));
mergeVelErrors = cell2struct([struct2cell(VelErrorData1);struct2cell(VelErrorData4);...
    struct2cell(VelErrorData5);struct2cell(VelErrorData6);...
    struct2cell(VelErrorData7);struct2cell(VelErrorData8);...
    struct2cell(VelErrorData9);struct2cell(VelErrorData10);...
    struct2cell(VelErrorData11);...
    struct2cell(VelErrorData12);struct2cell(VelErrorData13);...
    struct2cell(VelErrorData14); struct2cell(VelErrorData15);...
    struct2cell(VelErrorData16); struct2cell(VelErrorData17)],...
[fieldnames(VelErrorData1);fieldnames(VelErrorData4);...
    fieldnames(VelErrorData5);fieldnames(VelErrorData6);...
    fieldnames(VelErrorData7);fieldnames(VelErrorData8);fieldnames(VelErrorData9);...
    fieldnames(VelErrorData10);...
    fieldnames(VelErrorData11);fieldnames(VelErrorData12);fieldnames(VelErrorData13);...
    fieldnames(VelErrorData14);fieldnames(VelErrorData15);...
    fieldnames(VelErrorData16);fieldnames(VelErrorData17)]);


x = [];
y = [];
fields = fieldnames(mergeVelErrors);
mergevel = [];
mergeRMSE = [];

% fields = fieldnames(VelErrorData11);
% counter_bool = true;
counter = 0;
for i = 1:numel(fields)
counter_bool = true;
temp = table2cell(mergeVelErrors.(fields{i}));
% temp = table2cell(VelErrorData11.(fields{i}));

vel = temp(:,2);
rmse = temp(:,3);

if counter == 0 & counter_bool == true
   
    mergevel = [mergevel; vel];
    mergeRMSE = [mergeRMSE; rmse];
    
    counter = 1;
    counter_bool = false;

end
    
if counter == 1 & counter_bool == true
    mergevel = [mergevel; vel];
    mergeRMSE = [mergeRMSE; rmse];
    counter = 2;
    counter_bool = false;

end
if counter == 2 & counter_bool == true
    figure(i/3)
    mergevel = [mergevel; vel];
    mergeRMSE = [mergeRMSE; rmse];
    counter = 0;
    counter_bool = false;
    mergevel = mergevel(~cellfun('isempty',mergevel));
    mergeRMSE = mergeRMSE(~cellfun('isempty',mergeRMSE));
    mergevel = mergevel(all(cell2mat(mergevel) ~= 0,2),:);
    mergeRMSE = mergeRMSE(all(cell2mat(mergeRMSE) ~= 0,2),:);
   
    
    x = mergevel;
    y = mergeRMSE;
%     x = [x; vel];
%     y = [y; rmse];

    plot([mergevel{:}], [mergeRMSE{:}], 'o')
    xlabel('Velocity (rad/s)')
    ylabel('RMSE error')

    hold on
    x = cell2mat(x);
    y = cell2mat(y);
    mdl = fitlm(x,y);

    plot(mdl)
    ave_v = mean(x);
    ave_rmse = mean(y);
    title(["Velocity against error between hololens and polhemus: ", "Ave. RMSE = " num2str(ave_rmse) "Ave Vel = " num2str(ave_v)])
    xlabel('Velocity (rad/s)')
    ylabel('RMSE error')

    hold off
    saveas(gcf,['ID' num2str(i/3 + 2) '.png'])
    mergevel = [];
    mergeRMSE = [];
    x = [];
    y = [];
 
end

end

