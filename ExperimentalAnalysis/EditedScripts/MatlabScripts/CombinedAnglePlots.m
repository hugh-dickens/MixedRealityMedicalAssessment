clc; close all;
clear all;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
     
    ID = 9;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_ID_';
    ID_folder =  [ID_folder ID '\'];
    mat_data = ['Data_' ID];

    load([ID_folder mat_data])
end

pol_missing_data = [];
%% Plot holo and polhemus data for slow trials section
%slow trials
for i=1:30
% i=1;
       figure(i)
% %     slow if statements
   
        holo_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_HoloData'];
        pol_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_POLGroundTruth'];
        
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
        
        
        [c,lags] = xcorr(sgf,yy_holo_spline);
        
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
        
        % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         % ADD THIS LINE FOR ALL TRIALS.
%         x_pol = x_pol(1:length(sgf));
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; slow trial \n', i)
%         end
        
        else
            fprintf('Not enough Hololens data for trial %i; slow trial \n',i)
            pol_missing_data = [pol_missing_data i];
            
        end
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',i)
    end
        
end

%% medium
for i=1:30
% i=1;
       figure(i+30)
% %     slow if statements
   
        holo_dynamic = ['ID_',num2str(ID),'_medium_', num2str(i), '_HoloData'];
        pol_dynamic = ['ID_',num2str(ID),'_medium_', num2str(i), '_POLGroundTruth'];
        
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
        title('Slow trial')
        legend('Holo Data','Holo Spline','Polh Data')
        
        hold off
        
%         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         % ADD THIS LINE FOR ALL TRIALS.
%         x_pol = x_pol(1:length(sgf));
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; medium trial \n', i)
%         end
        
        else
            fprintf('Not enough Hololens data for trial %i; medium trial \n',i)
            pol_missing_data = [pol_missing_data i];
        end
    else
        fprintf('No polhemus data for trial %i\n; medium trial \n',i)
    end
        
end

%% fast
for i=1:30
% i=1;
       figure(i+60)
% %     slow if statements
   
        holo_dynamic = ['ID_',num2str(ID),'_fast_', num2str(i), '_HoloData'];
        pol_dynamic = ['ID_',num2str(ID),'_fast_', num2str(i), '_POLGroundTruth'];
        
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
        title('Slow trial')
        legend('Holo Data','Holo Spline','Polh Data')
        
        hold off
        
%         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         % ADD THIS LINE FOR ALL TRIALS.
%         x_pol = x_pol(1:length(sgf));
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial \n', i)
%         end
        
        else
            fprintf('Not enough Hololens data for trial %i; fast trial \n',i)
            pol_missing_data = [pol_missing_data i];
        end
    else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
    end
        
end
% %%
% for i=1:16  
% 
%     figure(i+20)
%     
%     % slow TRIAL 2
%     holo_dynamic = ['ID_2_slow_trial2_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_slow_trial2_', num2str(i), '_POLGroundTruth'];
% 
%     if isfield(experiment_data,pol_dynamic) == 1
%          
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Slow trial 2')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, y_pol);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
%         
%         else
%             fprintf('Not enough Hololens data for trial %i, slow trial 2 \n',i)
%         end
%         
%     else
%         fprintf('No polhemus data for trial %i, slow trial 2 \n',i)
%     end
%     
% end
% 
% for i=1:11 
% 
%     figure(i+36)
%     % slow TRIAL 2
%     holo_dynamic = ['ID_2_slow_trial2v2_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_slow_trial2v2_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Slow trial 2 v2')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, y_pol);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, slow trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, slow trial 2 \n',i)
%     end
% 
%     
% end
% 
% %% Medium trials section
% % 
% for i=2:20
%     
%     figure(i+47)
%     holo_dynamic = ['ID_2_medium_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_medium_', num2str(i), '_POLGroundTruth'];
% 
%     % need to check if the field exists, if it does then do this otherwise
%     % dont
%     if isfield(experiment_data,pol_dynamic) == 1
%      
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%            
%             more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%             rowsToDelete = y_holo < 0 | y_holo > 180;
%             y_holo(rowsToDelete) = [];
%             x_holo(rowsToDelete) = [];
%             y_holo(more_rowsToDelete) = [];
%             x_holo(more_rowsToDelete) = [];
%             steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%             xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%             yy_holo = spline(x_holo,y_holo,xx_holo);
%             subplot(2,1,1);
%             plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%             hold on
% 
%             % % plot holo data with points and a spline overlaid
%             x_pol = seconds(Pol_data.Timestamp);
%             y_pol = Pol_data.Angle;
%             
%             order = 3;
%             framelen = 93;
% 
%             y_pol_sgf = sgolayfilt(y_pol,order,framelen);
%             y_pol_sgf_full = y_pol_sgf;
%             
%             rowsToDelete = y_pol_sgf < 0 | y_pol_sgf > 180;
%             more_rowsToDelete = x_pol > (x_pol(1)+1000);
%             y_pol_sgf(more_rowsToDelete) = [];
%             x_pol(more_rowsToDelete) = [];
%             y_pol_sgf(rowsToDelete) = [];
%             x_pol(rowsToDelete) = [];
%             
% 
% 
%             plot(x_pol, y_pol_sgf);
% 
%             xlabel('Time')
%             ylabel('Angle')
%             title('Medium trial')
%             legend('Holo Data','Holo Spline', 'Polh Data')
% 
%             hold off
%             
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
%         
%         else
%             fprintf('Not enough Hololens data for trial %i, medium trial \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, medium trial \n',i)
%     end
% 
% end
% %%
% for i=1:3
%     
%     figure(i+67)
%     % medium TRIAL 2
%     holo_dynamic = ['ID_2_medium_trial2v1_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_medium_trial2v1_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Medium trial 2 v1')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
%             
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, medium trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, medium trial 2 \n',i)
%     end
% 
% end
% 
% 
% for i=1:5
% 
%     figure(i+70)
%     % medium TRIAL 2
%     holo_dynamic = ['ID_2_medium_trial2v2_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_medium_trial2v2_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Medium trial 2 v2')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%                 
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, medium trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, medium trial 2 \n',i)
%     end
% 
% end
% 
% 
% for i=1:15
% 
%     figure(i+75)
%     % slow TRIAL 2
%     holo_dynamic = ['ID_2_medium_trial2v3_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_medium_trial2v3_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Medium trial 2 v3')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%         
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, sgf);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, medium trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, medium trial 2 \n',i)
%     end
% 
% end
% 
% %% Fast trials section
% % 
% for i=1:24
%     
%     figure(i+90)
%     holo_dynamic = ['ID_2_fast_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_fast_', num2str(i), '_POLGroundTruth'];
% 
%     % need to check if the field exists, if it does then do this otherwise
%     % dont
%     if isfield(experiment_data,pol_dynamic) == 1
%      
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%            
%             more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%             rowsToDelete = y_holo < 0 | y_holo > 180;
%             y_holo(rowsToDelete) = [];
%             x_holo(rowsToDelete) = [];
%             y_holo(more_rowsToDelete) = [];
%             x_holo(more_rowsToDelete) = [];
%             steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%             xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%             yy_holo = spline(x_holo,y_holo,xx_holo);
%             subplot(2,1,1);
%             plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%             hold on
% 
%             % % plot holo data with points and a spline overlaid
%             x_pol = seconds(Pol_data.Timestamp);
%             y_pol = Pol_data.Angle;
%             rowsToDelete = y_pol < 0 | y_pol > 180;
%             more_rowsToDelete = x_pol > (x_pol(1)+1000);
%             y_pol(more_rowsToDelete) = [];
%             x_pol(more_rowsToDelete) = [];
%             y_pol(rowsToDelete) = [];
%             x_pol(rowsToDelete) = [];
%             order = 3;
%             framelen = 101;
% 
%             sgf = sgolayfilt(y_pol,order,framelen);
% 
%             plot(x_pol, sgf);
% 
%             xlabel('Time')
%             ylabel('Angle')
%             title('Fast trial')
%             legend('Holo Data','Holo Spline', 'Polh Data')
% 
%             hold off
%             
%             
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, y_pol);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
%         
%         else
%         
%             fprintf('Not enough Hololens data for trial %i, fast trial \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, fast trial \n',i)
%     end
% 
% end
% 
% 
% for i=1:14
% 
%     figure(i+114)
%     % fast TRIAL 2
%     holo_dynamic = ['ID_2_fast_trial2v1_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_fast_trial2v1_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Fast trial 2 v1')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%         
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, y_pol);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, fast trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, fast trial 2 \n',i)
%     end
% 
%     end
% 
% 
% for i=1:2
% 
%     figure(i+128)
%     % fast TRIAL 2
%     holo_dynamic = ['ID_2_fast_trial2v2_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_fast_trial2v2_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Fast trial 2 v2')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%                 %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, y_pol);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, fast trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, fast trial 2 \n',i)
%     end
% 
%     end
% 
% 
% for i=1:10
% 
%     figure(i+130)
%     % slow TRIAL 2
%     holo_dynamic = ['ID_2_fast_trial2v3_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_fast_trial2v3_', num2str(i), '_POLGroundTruth'];
%     
%     if isfield(experiment_data,pol_dynamic) == 1
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         % % plot holo data with points and a spline overlaid
%         x_holo = seconds(Holo_data.Timestamp);
%         y_holo = Holo_data.Angle;
%         if length(y_holo) > 1
%         more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%         rowsToDelete = y_holo < 0 | y_holo > 180;
%         y_holo(rowsToDelete) = [];
%         x_holo(rowsToDelete) = [];
%         y_holo(more_rowsToDelete) = [];
%         x_holo(more_rowsToDelete) = [];
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         yy_holo = spline(x_holo,y_holo,xx_holo);
%         subplot(2,1,1);
%         plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%         hold on
% 
%         % % plot holo data with points and a spline overlaid
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = [];
%         order = 3;
%         framelen = 101;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         plot(x_pol, sgf);
% 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Fast trial 2 v3')
%         legend('Holo Data','Holo Spline', 'Polh Data')
% 
%         hold off
%         
%         %         % error bar part:
%         
%         Holo_data = experiment_data.(holo_dynamic);
%         Pol_data = experiment_data.(pol_dynamic);
% 
%         holo_millisecond = round(Holo_data.Milliseconds,2,'significant');
%         holo_millisecond(holo_millisecond == 1000000) = 990000;
%         y_holo = Holo_data.Angle;
%         
%         holo_second = seconds(round(Holo_data.Timestamp, 'seconds'));
%         Polh_second = seconds(round(Pol_data.Timestamp, 'seconds'));
%         
%         b1 = num2str(holo_second);
%         b2 = num2str(holo_millisecond);
%         % Concatenate the two strings element wise
%         c1 = strcat(b1, b2);
%         % turn spaces into 0s
%         str = regexprep(cellstr(c1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_holo = str2double(str);
%         
% 
%         holo_data_final = cat(2,x_holo, y_holo);
% 
%         polh_millisecond = round(Pol_data.Milliseconds,2,'significant');
%         polh_millisecond(polh_millisecond == 1000000) = 990000;
%         y_pol = Pol_data.Angle;
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         a1 = num2str(Polh_second);
%         a2 = num2str(polh_millisecond);
%         % Concatenate the two strings element wise
%         d1 = strcat(a1, a2);
%         % turn spaces into 0s
%         str1 = regexprep(cellstr(d1), ' ', '0');
%         % Convert the result back to a numeric matrix
%         x_pol = str2double(str1);
% 
%         pol_data_final = cat(2, x_pol, y_pol);
% 
%         [~, rowsA, rowsB] = intersect(holo_data_final(:, 1), pol_data_final(:, 1));
%         rowsA = sort(rowsA);
%         rowsB = sort(rowsB);
%         comparing_angles = [holo_data_final(rowsA, 2) pol_data_final(rowsB, 2)];
% 
%         comparing_diff = comparing_angles(:,1) - comparing_angles(:,2);        
%         if length(comparing_diff)>1
%             rmse = sqrt(mean((comparing_angles(:,1)-comparing_angles(:,2)).^2));
%             subplot(2,1,2)
%             bar(comparing_diff)
%             title('Total rmse is',rmse)
%             ylabel('Difference in angle data (holo - polh)')
%         else 
%             fprintf('No comparing diff data for trial %i; fast trial 2 \n', i)
%         end
% 
%         else
%             fprintf('Not enough Hololens data for trial %i, fast trial 2 \n',i)
%         end
%     else
%         fprintf('No polhemus data for trial %i, fast trial 2 \n',i)
%     end
% 
% end
% 
% 
% 
