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

%% Calibration sequence to associate myo electrodes with muscles.
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
EMG_name = ['ID_2_fast_', num2str(4), '_EMG'];
EMG_data = experiment_data.(EMG_name);
fs = 150;

figure(1)
for i= bands_EMG_flex

x = table2array(EMG_data(:,i));
y = fft(x);

n = length(x);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(y).^2/n;    % power of the DFT


plot(f(118:floor(n/2)),power(118:floor(n/2)))
xlabel('Frequency')
ylabel('Power')

hold on
end

legend('EMG 4', 'EMG 5', 'EMG 6')
hold off

%% Find time of 'catch' and then plot spectral analysis for EMG of stretch reflex

for i = 1:20
holo_dynamic = ['ID_2_slow_', num2str(i), '_HoloData'];
emg_dynamic = ['ID_2_slow_', num2str(i), '_EMG'];
        
if isfield(experiment_data,pol_dynamic) == 1
    Holo_data = experiment_data.(holo_dynamic);
    EMG_data = experiment_data.(emg_dynamic);
    % % plot holo data with points and a spline overlaid
    x_holo = (Holo_data.Timestamp);
    y_holo = Holo_data.Angle;
    if length(y_holo) > 1
    more_rowsToDelete =  x_holo > (x_holo(1)+1000);
    rowsToDelete = y_holo < 0 | y_holo > 180;
    y_holo(rowsToDelete) = [];
    x_holo(rowsToDelete) = [];
    y_holo(more_rowsToDelete) = [];
    x_holo(more_rowsToDelete) = [];
        
    angle_index = find(y_holo > 120);
%     timestamp_catch = x_holo(angle_index(2));
    
    holo_millisecond = round(Holo_data.Milliseconds(angle_index(2)),2,'significant');
    holo_millisecond(holo_millisecond == 1000000) = 990000;
    EMG_millisecond = round(EMG_data.Milliseconds,2,'significant');
    EMG_millisecond(EMG_millisecond == 1000000) = 990000;
    
    holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
    EMG_second = seconds(round(EMG_data.Timestamp, 'seconds'));

    b1 = num2str(holo_second);
    b2 = num2str(holo_millisecond);
    % Concatenate the two strings element wise
    c1 = strcat(b1, b2);
    % turn spaces into 0s
    str = regexprep(cellstr(c1), ' ', '0');
    % Convert the result back to a numeric matrix
    x_holo = str2double(str);
    
    b1EMG = num2str(EMG_second);
    b2EMG = num2str(EMG_millisecond);
    % Concatenate the two strings element wise
    c1EMG = strcat(b1EMG, b2EMG);
    % turn spaces into 0s
    strEMG = regexprep(cellstr(c1EMG), ' ', '0');
    % Convert the result back to a numeric matrix
    x_EMG = str2double(strEMG);
    
    EMG_data_final = cat(2,x_EMG, y_holo);
    
    else
        fprintf('No Holo data for trial %i\n; slow trial \n',i)
    end
    
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',i)
    end

end
