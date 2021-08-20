clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
    for ID = 10:12
%     ID = 11;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_MATLAB\VelocityErrorData\';
    mat_data = ['VelErrorData' ID];
    load([ID_folder mat_data])
    end
end

mergeVelErrors = cell2struct([struct2cell(VelErrorData11);struct2cell(VelErrorData12)],[fieldnames(VelErrorData11);fieldnames(VelErrorData12)]);
figure(1)
x = [];
y = [];
fields = fieldnames(mergeVelErrors);
for i = 1:numel(fields)
temp = table2cell(mergeVelErrors.(fields{i}));

vel = temp(:,2);
rmse = temp(:,3);
vel = vel(all(cell2mat(vel) ~= 0,2),:);
rmse = rmse(all(cell2mat(rmse) ~= 0,2),:);
x = [x; vel];
y = [y; rmse];

plot([vel{:}], [rmse{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

hold on

% 

title('Velocity against error between hololens and polhemus recordings for all participants')
xlabel('Velocity')
ylabel('RMSE error')


end

x = cell2mat(x);
y = cell2mat(y);
mdl = fitlm(x,y)

plot(mdl)

legend('Slow 10', 'Medium 10', 'Fast 10', 'Slow 11', 'Medium 11', 'Fast 11','Slow 12', 'Medium 12', 'Fast 12')

title('Velocity against error between hololens and polhemus recordings for participant', ID)
xlabel('Velocity')
ylabel('RMSE error')

hold off




