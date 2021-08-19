clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
     
    ID = 10;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_MATLAB';
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

%% second recordings

pol_missing_data_v2 = [];
names = fieldnames( experiment_data );
subStrSlow_v2 = '_slowv2';
slow_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow_v2 ) ) ) ) );
subStrMedium_v2 = '_mediumv2';
medium_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium_v2 ) ) ) ) );
subStrFast_v2 = '_fastv2';
fast_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast_v2 ) ) ) ) );


%% slow

namesSlow = fieldnames( slow_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);


vels_cell_slow = cell(length(Polh_Fields), 2);
for trialnum = 1:length(Polh_Fields)
    
    pol_dynamic = [string(Polh_Fields(trialnum))] ;
% for i=1:30
% i=1;
%        figure(trialnum)
% %     slow if statements
%    
%         holo_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_HoloData'];
%         pol_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_POLGroundTruth'];
%         
        if isfield(experiment_data,pol_dynamic) == 1
            Pol_data = experiment_data.(pol_dynamic);
            
            % % plot holo data with points and a spline overlaid
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = [];
        % filter the polh data before plotting....
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
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
        
        avg_vel = mean(v);
        vels_cell_slow{trialnum, 1}  = pol_dynamic;
        vels_cell_slow{trialnum,2} = avg_vel;
       
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',i)
        end
        
end

%% medium
namesMedium = fieldnames( medium_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);

vels_cell_medium = cell(length(Polh_Fields), 2);
for trialnum = 1:length(Polh_Fields)
    
    pol_dynamic = [string(Polh_Fields(trialnum))] ;
% for i=1:30
% i=1;
%        figure(trialnum)
% %     slow if statements
%    
%         holo_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_HoloData'];
%         pol_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_POLGroundTruth'];
%         
        if isfield(experiment_data,pol_dynamic) == 1
            Pol_data = experiment_data.(pol_dynamic);
            
            % % plot holo data with points and a spline overlaid
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = [];
        % filter the polh data before plotting....
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
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
        
        avg_vel = mean(v);
        vels_cell_medium{trialnum, 1}  = pol_dynamic;
        vels_cell_medium{trialnum,2} = avg_vel;
       
    else
        fprintf('No polhemus data for trial %i\n; medium trial \n',i)
        end
        
end

%% fast
namesFast = fieldnames( fast_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);

vels_cell_fast = cell(length(Polh_Fields), 2);
for trialnum = 1:length(Polh_Fields)
    
    pol_dynamic = [string(Polh_Fields(trialnum))] ;
% for i=1:30
% i=1;
%        figure(trialnum)
% %     slow if statements
%    
%         holo_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_HoloData'];
%         pol_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_POLGroundTruth'];
%         
        if isfield(experiment_data,pol_dynamic) == 1
            Pol_data = experiment_data.(pol_dynamic);
            
            % % plot holo data with points and a spline overlaid
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = [];
        % filter the polh data before plotting....
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
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
        
        avg_vel = mean(v);
        vels_cell_fast{trialnum, 1}  = pol_dynamic;
        vels_cell_fast{trialnum,2} = avg_vel;
       
    else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
        end
        
end