clc; close all;
clear all;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
     
    ID = 13;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_MATLAB\UnprocessedData';
    ID_folder =  [ID_folder '\'];
    mat_data = ['Data_' ID];

    load([ID_folder mat_data])
end

pol_missing_data = [];
names = fieldnames( experiment_data );
subStrSlow = '_slow';
slow_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow ) ) ) ) );
subStrMedium = '_medium';
medium_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium ) ) ) ) );
subStrFast = '_fast';
fast_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast ) ) ) ) );

%% Plot holo and polhemus data for slow trials section
%slow trials
namesSlow = fieldnames( slow_filteredStruct );
subStrHolo = '_HoloData';
Holo_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct);
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);
for trialnum = 1:length(Holo_Fields)
    
    holo_dynamic = [string(Holo_Fields(trialnum))];
    try
    pol_dynamic = [string(Polh_Fields(trialnum))] ;
% for i=1:30
% i=1;
       figure(trialnum)
% %     slow if statements
%    
%         holo_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_HoloData'];
%         pol_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_POLGroundTruth'];
%         
        if isfield(experiment_data,pol_dynamic) == 1 
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);

        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo = Holo_data.Angle;
        if length(y_holo) > 1
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo < 0 | y_holo > 180;
        y_holo(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        
%         try     
%             yy_holo = spline(x_holo,y_holo,xx_holo);
%             subplot(2,1,1);
%             plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%             hold on
%         catch ME
            % removing duplicate data
            [~, indexA, ~] = unique(y_holo);
            A = sort(indexA);
            y_holo_spline = y_holo(A);
            x_holo_spline = x_holo(A);
            steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
            xx_holo_spline = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
            if length(y_holo_spline) > 1
                yy_holo_spline = spline(x_holo_spline,y_holo_spline,xx_holo_spline);

%         end

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
        
        
%         [c,lags] = xcorr(sgf,yy_holo_spline);
        
        lag = 0.2;
        
        
%         subplot(2,1,1);
        plot(x_holo_spline - lag,y_holo_spline,'o',xx_holo_spline -lag,yy_holo_spline);
        hold on
        
        plot(x_pol, sgf);
% 
        xlabel('Time')
        ylabel('Angle')
        title('Slow trial')
        legend('Holo Data','Holo Spline','Polh Data')
        
        hold off
       
        
            else
                fprintf('Repeat data from holo %i; slow trial', trialnum)
            end
        else
            fprintf('Not enough Hololens data for trial %i; slow trial \n',trialnum)
            pol_missing_data = [pol_missing_data i];
            
        end
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',trialnum)
        end
    catch me
        
        fprintf('no polh data for trial %i\n; slow \n', trialnum)
    end
end

%% medium
namesMedium = fieldnames( medium_filteredStruct );
subStrHolo = '_HoloData';
Holo_filteredStruct = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct);
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);

for trialnum = 1:length(Holo_Fields)
    
    holo_dynamic = [string(Holo_Fields(trialnum ))];
    try
    pol_dynamic = [string(Polh_Fields(trialnum))] ;
% for i=1:30
% i=1;
       figure(trialnum + 40)
% %     slow if statements
   
        if isfield(experiment_data,pol_dynamic) == 1 & isfield(experiment_data,holo_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);

        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo = Holo_data.Angle;
        if length(y_holo) > 1
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo < 0 | y_holo > 180;
        y_holo(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         try     
%             yy_holo = spline(x_holo,y_holo,xx_holo);
%             subplot(2,1,1);
%             plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%             hold on
%         catch ME
            [~, indexA, ~] = unique(y_holo);
            A = sort(indexA);
            y_holo_spline = y_holo(A);
            x_holo_spline = x_holo(A);
            steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
            xx_holo_spline = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
            if length(y_holo_spline) > 1
            yy_holo_spline = spline(x_holo_spline,y_holo_spline,xx_holo_spline);
            
%         end

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
        
        lag = 0.2;
        
        
%         subplot(2,1,1);
        plot(x_holo_spline - lag,y_holo_spline,'o',xx_holo_spline - lag,yy_holo_spline);
        hold on
        
        plot(x_pol, sgf);
% 
        xlabel('Time')
        ylabel('Angle')
        title('Medium trial')
        legend('Holo Data','Holo Spline','Polh Data')
        
        hold off
        

            else
                fprintf('Repeat data from holo %i; slow trial', trialnum)
            end
        
        else
            fprintf('Not enough Hololens data for trial %i; medium trial \n',trialnum)
            pol_missing_data = [pol_missing_data trialnum];
        end
    else
        fprintf('No polhemus data for trial %i\n; medium trial \n',trialnum)
    end
    catch me
        fprintf('no polh data for trial %i\n; medium \n', trialnum)
    end
end

%% fast
namesFast = fieldnames( fast_filteredStruct );
subStrHolo = '_HoloData';
Holo_filteredStruct = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct);
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);

for trialnum = 1:length(Holo_Fields)
    
    holo_dynamic = [string(Holo_Fields(trialnum ))];
    try
    pol_dynamic = [string(Polh_Fields(trialnum))] ;
% for i=1:30
% i=1;
       figure(trialnum+80)
        
        if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);

        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo = Holo_data.Angle;
        if length(y_holo) > 1
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo < 0 | y_holo > 180;
        y_holo(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         try     
%             yy_holo = spline(x_holo,y_holo,xx_holo);
%             subplot(2,1,1);
%             plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%             hold on
%         catch ME
            [~, indexA, ~] = unique(y_holo);
            A = sort(indexA);
            y_holo_spline = y_holo(A);
            x_holo_spline = x_holo(A);
            steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
            xx_holo_spline = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
            yy_holo_spline = spline(x_holo_spline,y_holo_spline,xx_holo_spline);
            
%         end

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
        
        lag = 0.2;
        
        
%         subplot(2,1,1);
        plot(x_holo_spline - lag,y_holo_spline,'o',xx_holo_spline -lag,yy_holo_spline);
        hold on
        
        plot(x_pol, sgf);
% 
        xlabel('Time')
        ylabel('Angle')
        title('Fast trial')
        legend('Holo Data','Holo Spline','Polh Data')
        
        hold off
        
        
        else
            fprintf('Not enough Hololens data for trial %i; fast trial \n',i)
            pol_missing_data = [pol_missing_data i];
        end
    else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
        end
        
    catch me
        fprintf('no polh data for trial %i\n; fast \n', trialnum)
    end
end
