clc; close all;
clear all;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
    calibration_flag = 0;
    ID = 14;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\UnprocessedData';
    ID_folder =  [ID_folder '\'];
    mat_data = ['Data_' ID];

    load([ID_folder mat_data])
end

%% first recordings

pol_missing_data = [];
names = fieldnames( experiment_data );
subStrSlow = '_slow';
slow_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow ) ) ) ) );
subStrMedium = '_medium';
medium_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium ) ) ) ) );
subStrFast = '_fast';
fast_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast ) ) ) ) );

% %% second recordings

pol_missing_data_v2 = [];
% names = fieldnames( experiment_data );
subStrSlow_v2 = '_slowv2';
slow_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow_v2 ) ) ) ) );
subStrMedium_v2 = '_mediumv2';
medium_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium_v2 ) ) ) ) );
subStrFast_v2 = '_fastv2';
fast_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast_v2 ) ) ) ) );

% 
% %% third recordings
% 
pol_missing_data_v3 = [];
% names = fieldnames( experiment_data );
subStrSlow_v3 = '_slowv3';
slow_filteredStruct_v3 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow_v3 ) ) ) ) );
subStrMedium_v3 = '_mediumv3';
medium_filteredStruct_v3 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium_v3 ) ) ) ) );
subStrFast_v3 = '_fastv3';
fast_filteredStruct_v3 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast_v3 ) ) ) ) );
% these need to be changed depending on participant


%% Calibration sequence to associate myo electrodes with muscles.

    names = fieldnames( experiment_data );
    subStr = 'ID_14_test_EMG_data';
    Calibration_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStr ) ) ) ) );
    EMG_data = ['ID_14_test_EMG_data_calib']; 
    EMG_calibration_data = experiment_data.(EMG_data);
    
    % plot the moving mean for the cut data. this removes the data with
    % bands below a certain amount, the goal being to take away parts when
    % myo shouldnt have been recording. This should give a total time of
    % ~20seconds
     figure(1)
     moving_RMS_EMG = sqrt(movmean(EMG_calibration_data{1:end,1:8}.^2,10));
     indices_a = find(moving_RMS_EMG(1:end,1) < 4);
     moving_RMS_EMG(indices_a, :) = [];
     EMG_calibration_data(indices_a, :) = [];
     
     indices_b = find(moving_RMS_EMG(1:end,3) < 4);
     moving_RMS_EMG(indices_b, :) = [];
     EMG_calibration_data(indices_b, :) = [];
          
     indices_c = find(moving_RMS_EMG(1:end,6) < 4);
     moving_RMS_EMG(indices_c, :) = [];
     EMG_calibration_data(indices_c, :) = [];
     
     plot(moving_RMS_EMG)
     legend
    
    % split the timestamp
    EMG_calibration_data_split = datevec(EMG_calibration_data.Timestamp);
    % find the seconds part
    EMG_calibration_data_seconds = seconds(EMG_calibration_data_split(:,6));
    %extract the minutes part
    EMG_calibration_data_minutes = minutes(EMG_calibration_data_split(:,5));
    % remove minutes and seconds index 1 to get normalised
    EMG_calibration_data_normalised_min = EMG_calibration_data_minutes - EMG_calibration_data_minutes(1);
    EMG_calibration_data_normalised_sec = EMG_calibration_data_seconds - EMG_calibration_data_seconds(1);
    % find overall time in seconds
    EMG_calib_total = seconds(EMG_calibration_data_normalised_min + EMG_calibration_data_normalised_sec);
    % find dt the difference in time (note some of these are 0)
    dt = diff(EMG_calib_total);
    % last timestamp in the emg file
    END_TIME = EMG_calib_total(end)
    % total time of emg file with cutting
    TOTAL_TIME = 0.005*length(EMG_calib_total)
    
    % turn seconds into a table
    Arr_emg_data = array2table(EMG_calib_total);
    % add the seconds and calibration emg data to a single table
    for i = 1:8
        Arr_emg_data = [Arr_emg_data EMG_calibration_data(:,i)];        
    end
    
    %%%% Plot the moving average of the whole calibration sequence.
%     for i = 1:8
%          figure(1)
%          
%          plot(sqrt(movmean(EMG_calibration_data{1:end,i}.^2,10)))
%          hold on
% %          hold on
% %          plot(flex_EMG_total)
% %          hold on
% %          plot(extend_EMG_total)
% %          hold on
% %          plot(cocontract_EMG_total)
% %          hold off
%      end
%      hold off
%      legend

     
     %% snip the data up according to the 10s relax,5s flex, 5s extend, and 5s cocontract
     % this has been done using ratios. Need to check the plots to make
     % sure this works for the specific participant. Generally, 2 or 3=
     % flex and 6-7 extend
        relax_EMG = Arr_emg_data(1: round(0.33 * length(EMG_calib_total)), :)  ;
        % flex data
        flex_EMG = Arr_emg_data(round(0.33 * length(EMG_calib_total)) + 1 : round(0.53 * length(EMG_calib_total)), :)  ;
        % extend data
        extend_EMG = Arr_emg_data(round(0.53 * length(EMG_calib_total)) + 1 : round(0.73 * length(EMG_calib_total)), :)  ;
        % cocontract data
        cocontract_EMG = Arr_emg_data(round(0.73 * length(EMG_calib_total)) + 1 : end, :)  ;
        
     relax_EMG_total = zeros(8,1);
     flex_EMG_total = zeros(8,1);
     extend_EMG_total = zeros(8,1);
     cocontract_EMG_total = zeros(8,1);
     
     %%% check the values on right. If they're very close then inspect more
     %%% closely
     for i= 2:9
%          relax_EMG_total(i-1) = sum(abs(relax_EMG{1:end,i}),1);
         relax_EMG_total(i-1) = sum(sqrt(movmean(relax_EMG{1:end,i}.^2,10)));
%          flex_EMG_total(i-1) =  sum(abs(flex_EMG{1:end,i}),1);
         flex_EMG_total(i-1) = sum(sqrt(movmean(flex_EMG{1:end,i}.^2,10)));
%          extend_EMG_total(i-1) = sum(abs(extend_EMG{1:end,i}),1);
         extend_EMG_total(i-1) = sum(sqrt(movmean(extend_EMG{1:end,i}.^2,10)));
%          cocontract_EMG_total(i-1) = sum(abs(cocontract_EMG{1:end,i}),1);
         cocontract_EMG_total(i-1) = sum(sqrt(movmean(cocontract_EMG{1:end,i}.^2,10)));
         
     end
     
     
%      top_three_relax = maxk(relax_EMG_total,3);
%      bands_EMG_relax = [];
     
%      top_three_flex = maxk(flex_EMG_total,3);
     top_flex = maxk(flex_EMG_total,1);
     bands_EMG_flex = [];
     
%      top_three_extend = maxk(extend_EMG_total,3);
     top_extend = maxk(extend_EMG_total,1);
     bands_EMG_extend = [];
     
     top_three_cocontract = maxk(cocontract_EMG_total,3);
     bands_EMG_cocontract = [];
     
%         bands_EMG_relax = [bands_EMG_relax find(top_three_relax(i) == relax_EMG_total)];
      for i = 1
        bands_EMG_flex = [bands_EMG_flex find(top_flex(i) == flex_EMG_total)];
        bands_EMG_extend = [bands_EMG_extend find(top_extend(i) == extend_EMG_total)];
      end
        
    top_three_cocontract = sort(top_three_cocontract,'descend');
        
    for i = 1:3
        bands_EMG_cocontract = [bands_EMG_cocontract find(top_three_cocontract(i) == cocontract_EMG_total)];
        
    end
     


%% Plot spectral analysis of EMG data
% % % time_seconds = EMG_calib_total;
% % % EMG_data = Arr_emg_data(:,2:9); 
% % % fs = 200;
% % % dt_mean = (seconds(mean(seconds(dt))));
% % % % %% This is the plot for the calibration EMG data
% % % % for i= bands_EMG_flex
% % % % 
% % % % % for i=1:8
% % % % x = table2array(EMG_data(:,i));
% % % % 
% % % % %%%% SHOULD I highpass FILTER BEFORE PERFORMING SPECTRAL ANALYSIS?
% % % % x = (highpass(diff(x)./dt_mean, 5, 1/dt_mean));
% % % %         
% % % % y = fft(x);
% % % % 
% % % % n = length(x);          % number of samples
% % % % f = (0:n-1)*(fs/n);     % frequency range
% % % % power = abs(y).^2/n;    % power of the DFT
% % % % 
% % % % 
% % % % plot(f(1:floor(n/2)),power(1:floor(n/2)))
% % % % xlabel('Frequency (Hz)','FontSize',20)
% % % % ylabel('Power (W/Hz)','FontSize',20)
% % % % % xlim([5 100])
% % % % 
% % % % hold on
% % % % end
% % % % 
% % % % % legend('EMG 4', 'EMG 5', 'EMG 6')
% % % % legend('Flexor EMG band','FontSize',20);
% % % % title('Calibration sequence')
% % % % hold off

%% Find time of 'catch' and then plot spectral analysis for EMG of stretch reflex

% SLOW
namesslow = fieldnames( slow_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct_slow = rmfield( slow_filteredStruct, namesslow(find(cellfun(@isempty, strfind( namesslow, subStrPol)))));
Polh_Fields_slow = fieldnames(Pol_filteredStruct_slow);
fs = 200;

namesmedium = fieldnames( medium_filteredStruct );
Pol_filteredStruct_medium = rmfield( medium_filteredStruct, namesmedium(find(cellfun(@isempty, strfind( namesmedium, subStrPol)))));
Polh_Fields_medium = fieldnames(Pol_filteredStruct_medium);

namesfast = fieldnames( fast_filteredStruct );
Pol_filteredStruct_fast = rmfield( fast_filteredStruct, namesfast(find(cellfun(@isempty, strfind( namesfast, subStrPol)))));
Polh_Fields_fast = fieldnames(Pol_filteredStruct_fast);

%%
dt_mean = (seconds(mean(seconds(dt))));
for trialnum = 1: length(Polh_Fields_slow)
% for trialnum = 4
 pol_dynamic = [string(Polh_Fields_slow(trialnum))]; 
 EMG_data_used = ['ID_',num2str(ID),'_test_EMG_data_slow']; 
 
    % find catch part of trial. For more details see
    % AngularVelocity_vs_Error_spline.m
    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        EMG_data = experiment_data.(EMG_data_used);
        x_pol = (Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t_pol = (Pol_data{:,1});
        dt_pol = seconds(diff(t_pol));
        v = (lowpass(diff(y_pol)./dt_pol, 5, 1/mean(dt_pol)));
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        length_v_half = round(3*length(v)/10);
        length_v_end_part = round(length(v) * 0.8);
        
        max_v = max(v(length_v_half:length_v_end_part));
        max_v_ind = find(v==max_v);
        
        if max_v > 200
            end_ind = max_v_ind + 50;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 150 & max_v <= 200
            end_ind = max_v_ind + 100;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 100 & max_v <= 150
            end_ind = max_v_ind+ 150;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 60 & max_v <= 100
            end_ind = max_v_ind + 275;
            start_ind = max_v_ind - 50;
            
        else
            end_ind = max_v_ind + 400;
            start_ind = max_v_ind - 75;
        end
        velocities_slow(trialnum) = mean(abs(v(start_ind:end_ind)));
        % this finds the EMG catch phase using the timestamps of the catch
        % period from the polh data
        timestamp_start = datetime('2021-08-24')+ (x_pol(start_ind));
        timestamp_start.Format = 'hh:mm:ss';
        timestamp_end = datetime('2021-08-24')+ (x_pol(end_ind));
        timestamp_end.Format = 'hh:mm:ss';
        EMG_date_timestamp = EMG_data.Timestamp ;
        EMG_date_timestamp.Format = 'hh:mm:ss';
        EMG_indexes = (EMG_date_timestamp >= timestamp_start ) & (EMG_date_timestamp <= timestamp_end) ;
        EMG_catch = EMG_data(EMG_indexes,:);

        % now perform FFT
        x_flex = table2array(EMG_catch(:,bands_EMG_flex));
        length(x_flex);

        figure(2)
        x_high_flex = highpass(x_flex,5,fs);
        x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
        x_flex = lowpass(x_band_flex,99,fs) ;
        

        movRMS_flex = sqrt(movmean(x_flex.^2,10));
        x_flex = 0:0.005:(length(movRMS_flex) - 1) * 0.005;
        subplot(2,1,1)
        plot(x_flex, movRMS_flex)
        Int_slow_flex(trialnum) = trapz(x_flex, movRMS_flex)/ x_flex(end);
        xlabel('Time after catch (s)')
        ylabel('RMS Voltage (mV)')
        title('Top is flexor, bottom is extensor')
        hold on
        
        x_extend= table2array(EMG_catch(:,bands_EMG_extend));
        length(x_extend);

        subplot(2,1,2)
        x_slow_extend = highpass(x_extend,5,fs);
        x_band_extend = bandstop(x_slow_extend,[49.9 50.1],fs);
        x_extend = lowpass(x_band_extend,99,fs) ;
        

        movRMS_extend = sqrt(movmean(x_extend.^2,10));
        x_extend = 0:0.005:(length(movRMS_extend) - 1) * 0.005;
        plot(x_extend, movRMS_extend)
        Int_slow_extend(trialnum) = trapz(x_extend, movRMS_extend)/ x_extend(end);
        xlabel('Time after catch (s)')
        ylabel('RMS Voltage (mV)')
        hold on
              
    end
end
title('Slow', ['Flex:' num2str(mean(Int_slow_flex)) '  ' num2str(std(Int_slow_flex)) ' ;  '...
    num2str(mean(Int_slow_extend)) ' ' num2str(std(Int_slow_extend))])
hold off


%% medium 
for trialnum = 1: length(Polh_Fields_medium)
% for trialnum = 4
 pol_dynamic = [string(Polh_Fields_medium(trialnum))]; 
 EMG_data_used = ['ID_',num2str(ID),'_test_EMG_data_medium']; 

    % find catch part of trial. For more details see
    % AngularVelocity_vs_Error_spline.m
    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        EMG_data = experiment_data.(EMG_data_used);
        x_pol = (Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t_pol = (Pol_data{:,1});
        dt_pol = seconds(diff(t_pol));
        v = (lowpass(diff(y_pol)./dt_pol, 5, 1/mean(dt_pol)));
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        length_v_half = round(3*length(v)/10);
        length_v_end_part = round(length(v) * 0.8);
        
        max_v = max(v(length_v_half:length_v_end_part));
        max_v_ind = find(v==max_v);
        
        if max_v > 200
            end_ind = max_v_ind + 50;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 150 & max_v <= 200
            end_ind = max_v_ind + 100;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 100 & max_v <= 150
            end_ind = max_v_ind+ 150;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 60 & max_v <= 100
            end_ind = max_v_ind + 275;
            start_ind = max_v_ind - 50;
            
        else
            end_ind = max_v_ind + 400;
            start_ind = max_v_ind - 75;
        end
        if end_ind < length(v)
            velocities_medium(trialnum) = mean(abs(v(start_ind:end_ind)));
        else
            velocities_medium(trialnum) = mean(abs(v(start_ind:end)));
        end
        % this finds the EMG catch phase using the timestamps of the catch
        % period from the polh data
        if end_ind < length(v)
        
            timestamp_start = datetime('2021-08-24')+ (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = datetime('2021-08-24')+ (x_pol(end_ind));
            timestamp_end.Format = 'hh:mm:ss';
        else
            timestamp_start = datetime('2021-08-24')+ (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = datetime('2021-08-24')+ (x_pol(end));
            timestamp_end.Format = 'hh:mm:ss';
        end
            EMG_date_timestamp = EMG_data.Timestamp ;
            EMG_date_timestamp.Format = 'hh:mm:ss';
            EMG_indexes = (EMG_date_timestamp >= timestamp_start ) & (EMG_date_timestamp <= timestamp_end) ;
            EMG_catch = EMG_data(EMG_indexes,:);
        
        x_flex = table2array(EMG_catch(:,i));
        length(x_flex);

        figure(3)
        x_high_flex = highpass(x_flex,5,fs);
        x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
        x_flex = lowpass(x_band_flex,99,fs) ;
        

        movRMS_flex = sqrt(movmean(x_flex.^2,10));
        x_flex = 0:0.005:(length(movRMS_flex) - 1) * 0.005;
        % remove values above 0.75s
        ind_del = x_flex > 0.75;
        x_flex(ind_del) = [];
        movRMS_flex(ind_del) = [];
        subplot(2,1,1)
        plot(x_flex, movRMS_flex)
        Int_medium_flex(trialnum) = trapz(x_flex, movRMS_flex)/ x_flex(end);
        title('Top is flexor, bottom is extensor')
        hold on
        
        x_extend= table2array(EMG_catch(:,bands_EMG_extend));

        subplot(2,1,2)
        x_medium_extend = highpass(x_extend,5,fs);
        x_band_extend = bandstop(x_medium_extend,[49.9 50.1],fs);
        x_extend = lowpass(x_band_extend,99,fs) ;
        

        movRMS_extend = sqrt(movmean(x_extend.^2,10));
        x_extend = 0:0.005:(length(movRMS_extend) - 1) * 0.005;
        ind_del = x_extend > 0.75;
        x_extend(ind_del) = [];
        movRMS_extend(ind_del) = [];
        plot(x_extend, movRMS_extend)
        Int_medium_extend(trialnum) = trapz(x_extend, movRMS_extend)/ x_extend(end);
        xlabel('Time after catch (s)')
        ylabel('RMS Voltage (mV)')
        hold on
              
    end
end
title('Medium', ['Flex:' num2str(mean(Int_medium_flex)) '  ' num2str(std(Int_medium_flex)) ' ;  '...
    num2str(mean(Int_medium_extend)) ' ' num2str(std(Int_medium_extend))])
hold off
%% fast
for trialnum = 1: length(Polh_Fields_fast)
i = bands_EMG_flex;
dt_mean = (seconds(mean(seconds(dt))));

 pol_dynamic = [string(Polh_Fields_fast(trialnum))]; 
 EMG_data_used = ['ID_',num2str(ID),'_test_EMG_data_fast']; 

    % find catch part of trial. For more details see
    % AngularVelocity_vs_Error_spline.m
    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        EMG_data = experiment_data.(EMG_data_used);
        x_pol = (Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t_pol = (Pol_data{:,1});
        dt_pol = seconds(diff(t_pol));
        
        v = (lowpass(diff(y_pol)./dt_pol, 5, 1/mean(dt_pol)));
        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        length_v_half = round(3*length(v)/10);
        length_v_end_part = round(length(v) * 0.8);
        
        max_v = max(v(length_v_half:length_v_end_part));
        max_v_ind = find(v==max_v);
        
        
        if max_v > 200
            end_ind = max_v_ind + 50;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 150 & max_v <= 200
            end_ind = max_v_ind + 100;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 100 & max_v <= 150
            end_ind = max_v_ind+ 150;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 60 & max_v <= 100
            end_ind = max_v_ind + 275;
            start_ind = max_v_ind - 50;
            
        else
            end_ind = max_v_ind + 400;
            start_ind = max_v_ind - 75;
        end
        
        if end_ind < length(v)
            velocities_fast(trialnum) = mean(abs(v(start_ind:end_ind)));
        else
            velocities_fast(trialnum) = mean(abs(v(start_ind:end)));
        end
        
        if end_ind < length(v)
        
            timestamp_start = datetime('2021-08-24')+ (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = datetime('2021-08-24')+ (x_pol(end_ind));
            timestamp_end.Format = 'hh:mm:ss';
        else
            timestamp_start = datetime('2021-08-24')+ (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = datetime('2021-08-24')+ (x_pol(end));
            timestamp_end.Format = 'hh:mm:ss';
        end
            EMG_date_timestamp = EMG_data.Timestamp ;
            EMG_date_timestamp.Format = 'hh:mm:ss';
            EMG_indexes = (EMG_date_timestamp >= timestamp_start ) & (EMG_date_timestamp <= timestamp_end) ;
            EMG_catch = EMG_data(EMG_indexes,:);

        x_flex = table2array(EMG_catch(:,i));
        length(x_flex);

        figure(4)
        x_high_flex = highpass(x_flex,5,fs);
        x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
        x_flex = lowpass(x_band_flex,99,fs) ;
        
        %%%time based analysis
%         x_abs = abs(x);
        movRMS_flex = sqrt(movmean(x_flex.^2,10));
        x_flex = 0:0.005:(length(movRMS_flex) - 1) * 0.005;
        ind_del = x_flex > 0.45;
        x_flex(ind_del) = [];
        movRMS_flex(ind_del) = [];
        subplot(2,1,1)
        plot(x_flex, movRMS_flex)
        Int_fast_flex(trialnum) = trapz(x_flex, movRMS_flex)/ x_flex(end);
        title('Top is flexor, bottom is extensor')
        hold on
        
        x_extend = table2array(EMG_catch(:,bands_EMG_extend));

        subplot(2,1,2)
        x_high_extend = highpass(x_extend,5,fs);
        x_band_extend = bandstop(x_high_extend,[49.9 50.1],fs);
        x_extend = lowpass(x_band_extend,99,fs) ;
        

        movRMS_extend = sqrt(movmean(x_extend.^2,10));
        x_extend = 0:0.005:(length(movRMS_extend) - 1) * 0.005;
        ind_del = x_extend > 0.45;
        x_extend(ind_del) = [];
        movRMS_extend(ind_del) = [];
        plot(x_extend, movRMS_extend)
        Int_fast_extend(trialnum) = trapz(x_extend, movRMS_extend) / x_extend(end);
        xlabel('Time after catch (s)')
        ylabel('RMS Voltage (mV)')
        hold on
              
    end
end

title('Fast', ['Flex:' num2str(mean(Int_fast_flex)) '  ' num2str(std(Int_fast_flex)) ' ;  '...
    num2str(mean(Int_fast_extend)) ' ' num2str(std(Int_fast_extend))])
hold off







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%