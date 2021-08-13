clc; close all;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
    calibration_flag = 0;
    ID = 2;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_ID_';
    ID_folder =  [ID_folder ID '\'];
    mat_data = ['Data_' ID];

    load([ID_folder mat_data])
end

if calibration_flag == 0 %% at the moment this isnt set to 1 anywhere on purpose
    names = fieldnames( experiment_data );
    subStr = '_EMGCalibration';
    Calibration_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStr ) ) ) ) );
    EMG_calibration_name = ['ID_2_medium_4_EMGCalibration']; 
    EMG_calibration_data = experiment_data.(EMG_calibration_name);
    
    EMG_calibration_data_split = datevec(EMG_calibration_data.Timestamp);
    EMG_calibration_data_seconds = EMG_calibration_data_split(:,6);
    final_EMG_calib_seconds = EMG_calibration_data_seconds - EMG_calibration_data_seconds(1);
    indices = find(abs(final_EMG_calib_seconds)<2);
    final_EMG_calib_seconds(indices) = [];

end

%% Plot spectral analysis of EMG data
EMG_name = ['ID_2_slow_', num2str(1), '_EMG'];
EMG_data = experiment_data.(EMG_name);
fs = 100;


for i=1:8
figure(i)
x = table2array(EMG_data(:,i));
y = fft(x);

n = length(x);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(y).^2/n;    % power of the DFT

plot(f(1:floor(n/2)),power(1:floor(n/2)))
xlabel('Frequency')
ylabel('Power')

% hold on
end

% legend('EMG 1', 'EMG 2', 'EMG 3', 'EMG 4', 'EMG 5', 'EMG 6', 'EMG 7', 'EMG 8')
% hold off



