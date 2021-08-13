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

% Calibration sequence to associate myo electrodes with muscles.
if calibration_flag == 0 %% at the moment this isnt set to 1 anywhere on purpose
    names = fieldnames( experiment_data );
    subStr = '_EMGCalibration';
    Calibration_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStr ) ) ) ) );
    EMG_calibration_name = ['ID_2_medium_4_EMGCalibration']; 
    EMG_calibration_data = experiment_data.(EMG_calibration_name);
    
    EMG_calibration_data_split = datevec(EMG_calibration_data.Timestamp);
    EMG_calibration_data_seconds = EMG_calibration_data_split(:,6);
    final_EMG_calib_seconds = EMG_calibration_data_seconds - EMG_calibration_data_seconds(1);
    
    Arr_emg_data = array2table(final_EMG_calib_seconds);
    
    for i = 1:8
        Arr_emg_data = [Arr_emg_data EMG_calibration_data(:,i)];        
    end
    % relax data
    indices_relax = find(final_EMG_calib_seconds<10);
    relax_EMG = Arr_emg_data(indices_relax, :)  ;
    % flex data
    indices_flex = find(final_EMG_calib_seconds > 10 & final_EMG_calib_seconds<15);
    flex_EMG = Arr_emg_data(indices_flex,:)  ;
    % extend data
    indices_extend = find(final_EMG_calib_seconds > 16 & final_EMG_calib_seconds<21);
    extend_EMG = Arr_emg_data(indices_extend,:) ;
    % cocontract data
    indices_cocontract = find(final_EMG_calib_seconds > 22);
    cocontract_EMG = Arr_emg_data(indices_cocontract,:);
     relax_EMG_total = zeros(8,1);
     flex_EMG_total = zeros(8,1);
     extend_EMG_total = zeros(8,1);
     cocontract_EMG_total = zeros(8,1);
     for i = 2:9
         relax_EMG_total(i-1) = sum(abs(relax_EMG{1:end,i}),1);
         flex_EMG_total(i-1) =  sum(abs(flex_EMG{1:end,i}),1);
         extend_EMG_total(i-1) = sum(abs(extend_EMG{1:end,i}),1);
         cocontract_EMG_total(i-1) = sum(abs(cocontract_EMG{1:end,i}),1);
     end
     
     top_three_relax = maxk(relax_EMG_total,3);
     bands_EMG_relax = [];
     
     top_three_flex = maxk(flex_EMG_total,3);
     bands_EMG_flex = [];
     
     top_three_extend = maxk(extend_EMG_total,3);
     bands_EMG_extend = [];
     
     top_three_cocontract = maxk(cocontract_EMG_total,3);
     bands_EMG_cocontract = [];
     for i = 1:3
        bands_EMG_relax = [bands_EMG_relax find(top_three_relax(i) == relax_EMG_total)];
        bands_EMG_flex = [bands_EMG_flex find(top_three_flex(i) == flex_EMG_total)];
        bands_EMG_extend = [bands_EMG_extend find(top_three_extend(i) == extend_EMG_total)];
        bands_EMG_cocontract = [bands_EMG_cocontract find(top_three_cocontract(i) == cocontract_EMG_total)];
     end
     
end

%% Plot spectral analysis of EMG data
EMG_name = ['ID_2_slow_', num2str(1), '_EMG'];
EMG_data = experiment_data.(EMG_name);
fs = 1000;


for i= bands_EMG_extend
figure(i)
x = table2array(EMG_data(:,i));
y = fft(x);

n = length(x);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(y).^2/n;    % power of the DFT


plot(f(118:floor(n/2)),power(118:floor(n/2)))
xlabel('Frequency')
ylabel('Power')

% hold on
end

% legend('EMG 1', 'EMG 2', 'EMG 3', 'EMG 4', 'EMG 5', 'EMG 6', 'EMG 7', 'EMG 8')
% hold off



