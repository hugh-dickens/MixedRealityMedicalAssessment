clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
    
    ID = 17;
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

calibration_term_slow = 2;
lag_term_slow = 0.17;
%% slow
close all;
namesSlow = fieldnames( slow_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrPol)))));

Polh_Fields = fieldnames(Pol_filteredStruct);
subStrHolo = '_HoloData';
Holo_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct);


vels_cell_slow_ID_17 = cell(0, 3);

integer = 0;
for trialnum = 1:length(Polh_Fields)
% for trialnum = 20
%    pol_dynamic = [string(Polh_Fields(trialnum ))] ;
%     
%     if trialnum < length(Holo_Fields)
%         
%     holo_dynamic = [string(Holo_Fields(trialnum))];
%     newStr = erase(pol_dynamic,'_POLGroundTruth');
%     newSubstr = erase(holo_dynamic, '_HoloData');

    pol_dynamic = [string(Polh_Fields(trialnum - integer ))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1;
        
    elseif newStr == newSubstr

        if isfield(experiment_data,pol_dynamic) == 1
            Pol_data = experiment_data.(pol_dynamic);
            Holo_data = experiment_data.(holo_dynamic);
            
try
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp) - lag_term_slow;
        y_holo = Holo_data.Angle + calibration_term_slow;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        pol_millis(more_rowsToDelete) = [];
        pol_millis(rowsToDelete) = [];
        
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        v = zeros(length(pol_millis),1) ;
        for i = 1:length(pol_millis)-1
            v(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
        end
        
        length_v_half = round(3*length(v)/7);
        
        max_angle = find(sgf==max(sgf(length_v_half:end)));
        min_angle = find(sgf==min(sgf(length_v_half:end)));
%         start_ind = max_inst_vel - 100;
%         end_ind = max_inst_vel + 200;
        start_ind = min_angle;
        end_ind = max_angle;
        
%         if start_ind + 600 < end_ind
%             end_ind = start_ind + 600;
%         end
        
        pol_dataframe = [x_pol sgf];
        holo_data_comp = [x_holo y_holo];
        
        if end_ind < length(v)
            avg_vel = mean(v(start_ind:end_ind));
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            
            
        elseif end_ind >= length(v)
            avg_vel = mean(v(start_ind:end));
            pol_comp = pol_dataframe(end-600:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
        
        index_holo = holo_data_comp(:,1)>pol_comp(1,1);
        holo_filtered_temp = holo_data_comp(index_holo,1:2);
        index_temp_holo = holo_filtered_temp(:,1)<pol_comp(end,1);
        holo_filtered = holo_filtered_temp(index_temp_holo ,1:2);
        
        holo_comp_length = length(holo_filtered);
        pol_comp_length_non_spline = length(pol_comp(:,1));
        bins = floor(pol_comp_length_non_spline/holo_comp_length);
        i = 0;
        pol_binned_data =[];
        
        for n = 1:holo_comp_length
            i= i + 1;
            if i == 1
                pol_binned_data(i) = mean(pol_comp(1:(n)*bins,2));
            else
                pol_binned_data(i) = mean(pol_comp(bins*(n-1):(n)*bins,2));
            end
        end
        

        comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        if length(comparing_diff)>0
            rmse = sqrt((sum(comparing_diff).^2)/(length(comparing_diff)));
            
            if (rmse < 39 & avg_vel < 50) | (rmse < 50 & avg_vel > 50 & avg_vel < 80)
%             if rmse < 10000
            vels_cell_slow_ID_17{end+1, 1}  = pol_dynamic;
            vels_cell_slow_ID_17{end, 2} = avg_vel;
            vels_cell_slow_ID_17{end, 3} = rmse;
            
            figure(trialnum)
            subplot(2,1,1)
            plot(holo_filtered(:,1), holo_filtered(:,2) )
            hold on
            plot(pol_comp(:,1), pol_comp(:,2))
            title(rmse, avg_vel)
            hold off 

            subplot(2,1,2)
            plot(holo_data_comp(:,1), holo_data_comp(:,2) )
            hold on
            plot(pol_dataframe(:,1), pol_dataframe(:,2))
            title(rmse, avg_vel)
            hold off 
            
            elseif rmse > 100
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
            end
        else 
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
        end
        
%         vels_cell_slow_ID_1{trialnum, 1}  = pol_dynamic;
%         vels_cell_slow_ID_1{trialnum,2} = avg_vel;
%         vels_cell_slow_ID_1{trialnum,3} = rmse;
        
% %         figure(trialnum)
% %         plot(holo_filtered(:,1), holo_filtered(:,2) )
% %         hold on
% %         plot(pol_comp(:,1), pol_comp(:,2))
% %         hold off 
        
%         figure(trialnum)
%         plot(holo_data_comp(:,1), holo_data_comp(:,2) )
%         hold on
%         plot(pol_dataframe(:,1), pol_dataframe(:,2))
%         hold off 
        
catch me
end
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',trialnum)
        end
    end
    end
end
%% just plot
close all;
figure(1)
avg_vel_tot_slow = vels_cell_slow_ID_17(:,2);
rmse_tot_slow = vels_cell_slow_ID_17(:,3);
% avg_vel_tot_slow = avg_vel_tot_slow(all(cell2mat(avg_vel_tot_slow) ~= 0,2),:);
% rmse_tot_slow = rmse_tot_slow(all(cell2mat(rmse_tot_slow) ~= 0,2),:);

% avg_vel_tot_slow = avg_vel_tot_slow(all(cell2mat(avg_vel_tot_slow) ~= 0,2),:);
% rmse_tot_slow = rmse_tot_slow(all(cell2mat(rmse_tot_slow) ~= 0,2),:);
% 



plot([avg_vel_tot_slow{:}], [rmse_tot_slow{:}], 'o')


xlabel('Velocity (rad/s)')
ylabel('RMSE error')
% 
%% medium
namesMedium = fieldnames( medium_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct_medium = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct_medium);
subStrHolo = '_HoloData';
Holo_filteredStruct_medium = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct_medium);
lag_term_medium = 0.17;
calibration_term_medium = 2;


%% edit ID number here !!
close all;
vels_cell_medium_ID_17 = cell(0, 3);
integer = 0;
for trialnum = 1:length(Polh_Fields)
    
% % for trialnum = 2
%     pol_dynamic = [string(Polh_Fields(trialnum))]; 
%     
%     if trialnum < length(Holo_Fields)
%         
%     holo_dynamic = [string(Holo_Fields(trialnum))];
%     newStr = erase(pol_dynamic,'_POLGroundTruth');
%     newSubstr = erase(holo_dynamic, '_HoloData');
    pol_dynamic = [string(Polh_Fields(trialnum + integer))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1;
        
    elseif newStr == newSubstr
   
        if isfield(experiment_data,pol_dynamic) == 1
            Pol_data = experiment_data.(pol_dynamic);
            Holo_data = experiment_data.(holo_dynamic);
            
try
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp) - lag_term_medium;
        y_holo = Holo_data.Angle + calibration_term_medium;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        pol_millis(more_rowsToDelete) = [];
        pol_millis(rowsToDelete) = [];
        
        
        
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        v = zeros(length(pol_millis),1) ;
        for i = 1:length(pol_millis)-1
            v(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
        end
        
        length_v_half = round(3*length(v)/8);
        
        max_angle = find(sgf==max(sgf(length_v_half:end)));
        min_angle = find(sgf==min(sgf(length_v_half:end)));
        if trialnum == 1 | 29
            max_angle = min_angle + 300;
        end
            
%         start_ind = max_inst_vel - 100;
%         end_ind = max_inst_vel + 200;
        start_ind = min_angle;
        end_ind = max_angle;
        
%         if start_ind + 500 < end_ind
%             end_ind = start_ind + 500;
%         end
        
        pol_dataframe = [x_pol sgf];
        holo_data_comp = [x_holo y_holo];
        
        if end_ind < length(v)
            avg_vel = mean(v(start_ind:end_ind));
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            
            
        elseif end_ind >= length(v)
            avg_vel = mean(v(start_ind:end));
            pol_comp = pol_dataframe(start_ind:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
            
        
        index_holo = holo_data_comp(:,1)> (pol_comp(1,1) - 0.01);
        holo_filtered_temp = holo_data_comp(index_holo,1:2);
        index_temp_holo = holo_filtered_temp(:,1)< (pol_comp(end,1) + 0.01);
        holo_filtered = holo_filtered_temp(index_temp_holo,1:2);
        
        holo_comp_length = length(holo_filtered);
        pol_comp_length_non_spline = length(pol_comp(:,1));
        bins = floor(pol_comp_length_non_spline/holo_comp_length);
        i = 0;
        pol_binned_data =[];
        
        for n = 1:holo_comp_length
            i= i + 1;
            if i == 1
                pol_binned_data(i) = mean(pol_comp(1:(n)*bins,2));
            else
                pol_binned_data(i) = mean(pol_comp(bins*(n-1):(n)*bins,2));
            end
        end
        

        comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        if length(comparing_diff)>0
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));
            if (rmse < 50 & avg_vel < 60) | (rmse < 70 & avg_vel> 70)
%             if rmse < 10000    
            vels_cell_medium_ID_17{end+1, 1}  = pol_dynamic;
            vels_cell_medium_ID_17{end, 2} = avg_vel;
            vels_cell_medium_ID_17{end, 3} = rmse;
        figure(trialnum)
        subplot(2,1,1)
        plot(holo_filtered(:,1), holo_filtered(:,2) )
        hold on
        plot(pol_comp(:,1), pol_comp(:,2))
        title(rmse, avg_vel)
        hold off 

        subplot(2,1,2)
        plot(holo_data_comp(:,1), holo_data_comp(:,2) )
        hold on
        plot(pol_dataframe(:,1), pol_dataframe(:,2))
        title(rmse, avg_vel)
        hold off 
        
%             elseif rmse > 120
%                 pol_dynamic = 0;
%                 avg_vel = 0;
%                 rmse = 0;
%             end
            else
            
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
            end
        end
       
%         
%         vels_cell_medium_ID_1{trialnum, 1}  = pol_dynamic;
%         vels_cell_medium_ID_1{trialnum,2} = avg_vel;
%         vels_cell_medium_ID_1{trialnum,3} = rmse;
        
%         figure(trialnum)
%         plot(holo_filtered(:,1), holo_filtered(:,2) )
%         hold on
%         plot(pol_comp(:,1), pol_comp(:,2))
%         hold off 
%         
%         figure(trialnum)
%         plot(holo_data_comp(:,1), holo_data_comp(:,2) )
%         hold on
%         plot(pol_dataframe(:,1), pol_dataframe(:,2))
%         hold off 
%        
catch me
end
    else
        fprintf('No polhemus data for trial %i\n; medium trial \n',i)
        end
    end
    end


end

%% just plot
close all;
figure(1)
avg_vel_tot_medium = vels_cell_medium_ID_17(:,2);
rmse_tot_medium = vels_cell_medium_ID_17(:,3);
% avg_vel_tot_medium = avg_vel_tot_medium(all(cell2mat(avg_vel_tot_medium) ~= 0,2),:);
% rmse_tot_medium = rmse_tot_medium(all(cell2mat(rmse_tot_medium) ~= 0,2),:);
% 
% avg_vel_tot_medium = avg_vel_tot_medium(all(cell2mat(avg_vel_tot_medium) ~= 0,2),:);
% rmse_tot_medium = rmse_tot_medium(all(cell2mat(rmse_tot_medium) ~= 0,2),:);

plot([avg_vel_tot_medium{:}], [rmse_tot_medium{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

%% fast
namesFast = fieldnames( fast_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);
subStrHolo = '_HoloData';
Holo_filteredStruct_fast = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct_fast);
lag_term_fast = 0.15;
calibration_term_fast = 2;
%% edit ID number here !! and everywhere
close all;
vels_cell_fast_ID_17 = cell(0, 11);
integer = 0;
for trialnum = 1:length(Polh_Fields)
%     for trialnum = 28
       

    pol_dynamic = [string(Polh_Fields(trialnum - integer))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1;
        
    elseif newStr == newSubstr

    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        Holo_data = experiment_data.(holo_dynamic);

    

        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp) - lag_term_fast;
        seconds_diff = diff(seconds(Holo_data.Timestamp));
        holo_freq = 1/(sum(seconds_diff)/ length(seconds_diff));
     
        y_holo = Holo_data.Angle + calibration_term_fast;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        pol_millis(more_rowsToDelete) = [];
        pol_millis(rowsToDelete) = [];
        
        %%% added for presentation 
       
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        v = zeros(length(pol_millis),1) ;
        for i = 1:length(pol_millis)-1
            v(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
        end
        
        length_v_half = round(3*length(v)/9);
        length_v_end_part = round(length(v) * 0.8);
        
        max_angle = find(v==max(v(length_v_half:end)))+ 50;
        min_angle = max_angle - 150;

        start_ind = min_angle;
        end_ind = max_angle;

        pol_dataframe = [x_pol sgf];
        holo_data_comp = [x_holo y_holo];
        
        if end_ind < length(v)
            avg_vel = mean(v(start_ind:end_ind));
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            
            
        elseif end_ind >= length(v)
            avg_vel = mean(v(start_ind:end-500));
            pol_comp = pol_dataframe(start_ind:end-500, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
        
%         x_holo = holo_filtered(:,1);
%         y_holo = holo_filtered(:,2);

% create spline!!
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        

        % removing duplicate data from y_holo
        [~, indexA, ~] = unique(y_holo);
        A = sort(indexA);
        y_holo_spline_temp = y_holo(A);
        x_holo_spline_temp = x_holo(A);
        % removing duplicate data from x_holo_spline
        [~, indexA, ~] = unique(x_holo_spline_temp);
        A = sort(indexA);
        y_holo_spline = y_holo_spline_temp(A);
        x_holo_spline = x_holo_spline_temp(A);
        
        steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
        xx_holo_spline_post = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
        if length(y_holo_spline) > 1
            
            yy_holo_spline_post = spline(x_holo_spline,y_holo_spline,xx_holo_spline_post);
        
        % cut the spline data so that it perfectly matches pol_comp    
        index_holo_spline_temp = xx_holo_spline_post(:)>( pol_comp(1,1));
        spline_filtered_temp_x = xx_holo_spline_post((index_holo_spline_temp));
        spline_filtered_temp_y = yy_holo_spline_post((index_holo_spline_temp));
        index_holo_spline = spline_filtered_temp_x(:)<( pol_comp(end,1));
        xx_holo_spline_post = spline_filtered_temp_x((index_holo_spline));
        yy_holo_spline_post = spline_filtered_temp_y((index_holo_spline));
        
        
           
        % cut holo data 'around' the polh determined catch phase
        index_holo = holo_data_comp(:,1)>( pol_comp(1,1));
        holo_filtered_temp = holo_data_comp((index_holo),1:2);
        diff_holo = diff(holo_filtered_temp(:,2));
        max_diff = (max(diff_holo));
        idx_diff = find(max_diff == diff_holo);
        holo_filtered = holo_filtered_temp((1:idx_diff+1),1:2);
        
        % now need to make sure the timing is the same so cut polh data
        % around holo
        pol_index = pol_comp(:,1) > holo_filtered(1,1);
        pol_filtered_temp = pol_comp((pol_index),1:2);
        idx_pol_end = pol_filtered_temp(:,1) < holo_filtered(end,1);
        pol_comp_non_spline = pol_filtered_temp((idx_pol_end),1:2);
        
        % bin the data
        holo_comp_length = length(holo_filtered);
        pol_comp_length_non_spline = length(pol_comp_non_spline(:,1));
        bins = floor(pol_comp_length_non_spline/holo_comp_length);
        i = 0;
        pol_binned_data =[];
        
        for n = 1:holo_comp_length
            i= i + 1;
            if i == 1
                pol_binned_data(i) = mean(pol_comp_non_spline(1:(n)*bins,2));
            else
                pol_binned_data(i) = mean(pol_comp_non_spline(bins*(n-1):(n)*bins,2));
            end
        end
        
        % calculate the onset time during catch phase when holo misses tags
        holo_diffs = diff(holo_filtered(:,2));
        time_diffs = diff(holo_filtered(:,1));
        result = max( holo_diffs (holo_diffs >= 0) );
        onset_time = time_diffs(find(result == holo_diffs));
        
        comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        
        if length(comparing_diff) > 0
             
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));

            vels_cell_fast_ID_17{end+1, 1}  = pol_dynamic;
            vels_cell_fast_ID_17{end, 2} = avg_vel;
            vels_cell_fast_ID_17{end, 3} = rmse;
            vels_cell_fast_ID_17{end, 5} = pol_binned_data(:);
            vels_cell_fast_ID_17{end, 6} = holo_filtered(:,2);
            
           
            
            figure(trialnum)
            subplot(2,1,1)
            plot(holo_filtered(:,1), holo_filtered(:,2), 'x' )
            hold on
            plot(pol_comp_non_spline(:,1), pol_comp_non_spline(:,2))
            title(['rmse with raw data: ' num2str(rmse)],['avg vel: ' num2str(avg_vel)])
            hold off 
            
            
            %spline rmse work: .....>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            spline_comp_length = length(yy_holo_spline_post);
            pol_comp_length_non_spline = length(pol_comp(:,1));
            bins = floor(spline_comp_length/pol_comp_length_non_spline);
            i = 0;
            spline_binned_data =[];

            for n = 1:pol_comp_length_non_spline
                i= i + 1;
                if i == 1
                    spline_binned_data(i) = mean(yy_holo_spline_post(1:(n)*bins));
                else
                    spline_binned_data(i) = mean(yy_holo_spline_post(bins*(n-1):(n)*bins));
                end
            end


            comparing_diff_spline = abs(spline_binned_data(:) - pol_comp(:,2));

            rmse_spline = sqrt((sum(comparing_diff_spline).^2)/length(comparing_diff_spline));
            avg_vel_whole_trial = mean(v);
            
            vels_cell_fast_ID_17{end, 4} = rmse_spline;
            vels_cell_fast_ID_17{end, 7} = pol_comp(:,2);
            vels_cell_fast_ID_17{end, 8} = spline_binned_data(:);
            vels_cell_fast_ID_17{end, 9 } = onset_time;
            vels_cell_fast_ID_17{end, 10} = avg_vel_whole_trial;
            vels_cell_fast_ID_17{end, 11} = holo_freq;
            

            subplot(2,1,2)
            plot(xx_holo_spline_post, yy_holo_spline_post);
            hold on
            plot(pol_comp(:,1), pol_comp(:,2))
            title(['rmse with spline: ' num2str(rmse_spline)],['avg vel: ' num2str(avg_vel)])
            hold off 
            
        end
        end
        
    
            else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
            end
    end
    
    end
end


%% just plot
close all;
figure(1)
avg_vel_tot_fast = vels_cell_fast_ID_17(:,2);
rmse_tot_fast = vels_cell_fast_ID_17(:,3);

plot([avg_vel_tot_fast{:}], [rmse_tot_fast{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

%% plot all
close all;
figure(1)
x = [[avg_vel_tot_slow{:}] [avg_vel_tot_medium{:}] [avg_vel_tot_fast{:}]]';
y = [[rmse_tot_slow{:}] [rmse_tot_medium{:}] [rmse_tot_fast{:}]]';

mdl = fitlm(x,y)

plot([avg_vel_tot_slow{:}], [rmse_tot_slow{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

hold on

plot([avg_vel_tot_medium{:}], [rmse_tot_medium{:}], 'o')

hold on

plot([avg_vel_tot_fast{:}], [rmse_tot_fast{:}], 'o')

hold on

plot(mdl)

legend('Slow', 'Medium', 'Fast')

title('Velocity against error between hololens and polhemus recordings for participant', ID)
xlabel('Velocity')
ylabel('RMSE error')

hold off


%%
slow_ID_17 = 'VelSlow_ID_17';
medium_ID_17 = 'VelMedium_ID_17';
fast_ID_17 = 'VelFast_ID_17';
VelErrorData17.(slow_ID_17) = cell2table(vels_cell_slow_ID_17);
VelErrorData17.(medium_ID_17) = cell2table(vels_cell_medium_ID_17) ;
VelErrorData17.(fast_ID_17) = cell2table(vels_cell_fast_ID_17);
save('VelErrorData17', 'VelErrorData17')

