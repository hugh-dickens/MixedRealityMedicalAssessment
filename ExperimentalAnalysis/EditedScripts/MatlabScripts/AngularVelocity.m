clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
     
    ID = 10;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_MATLAB\UnprocessedData';
    ID_folder =  [ID_folder '\'];
    mat_data = ['Data_' ID];


    load([ID_folder mat_data])
end

%% Plot holo and polhemus data for slow trials section
%slow trials
for i=1:20

        figure(i)
% %     slow if statements
   
        holo_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_HoloData'];
        pol_dynamic = ['ID_',num2str(ID),'_slow_', num2str(i), '_POLGroundTruth'];
        
        if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 300;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
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
            v(i) = (sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
        end
        
        plot(x_pol, v);
% % 
        
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(v);
        
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Slow trial', avg_vel)
%         legend('Holo Data')
        legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i; slow trial \n',i)
        end
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',i)
    end
        
end

for i=1:20

        figure(i+20)
% %     slow if statements
   
        holo_dynamic = ['ID_',num2str(ID),'_medium_', num2str(i), '_HoloData'];
        pol_dynamic = ['ID_',num2str(ID),'_medium_', num2str(i), '_POLGroundTruth'];
        
        if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 300;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
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
            v(i) = (sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
        end
        
        plot(x_pol, v);
% % 
        
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Slow trial', avg_vel)
%         legend('Holo Data')
        legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i; medium trial \n',i)
        end
    else
        fprintf('No polhemus data for trial %i\n; medium trial \n',i)
    end
        
end

for i=1:20

        figure(i+40)
% %     slow if statements
   
        holo_dynamic = ['ID_',num2str(ID),'_fast_', num2str(i), '_HoloData'];
        pol_dynamic = ['ID_',num2str(ID),'_fast_', num2str(i), '_POLGroundTruth'];
        
        if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 300;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
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
            v(i) = (sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
        end
        
        plot(x_pol, v);
% % 
        
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Slow trial', avg_vel)
%         legend('Holo Data')
        legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i; fast trial \n',i)
        end
    else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
    end
        
end

%% temporary section
for i=1:16  

    figure(i+20)
    
    % slow TRIAL 2
    holo_dynamic = ['ID_2_slow_trial2_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_slow_trial2_', num2str(i), '_POLGroundTruth'];

    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 300;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Slow trial 2', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, slow trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, slow trial 2 \n',i)
    end
        
end

for i=1:11 

    figure(i+36)
    % slow TRIAL 2
    holo_dynamic = ['ID_2_slow_trial2v2_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_slow_trial2v2_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 300;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Slow trial 2', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, slow trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, slow trial 2 \n',i)
    end
        
end

%% Medium trials section
% 
for i=2:20
    
    figure(i+47)
    holo_dynamic = ['ID_2_medium_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_medium_', num2str(i), '_POLGroundTruth'];

    % need to check if the field exists, if it does then do this otherwise
    % dont
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 400;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
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
            v(i) = (sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000;
        end
        
        plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Medium trial', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, medium trial \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, medium trial \n',i)
    end
        
end
%%
for i=1:3
    
    figure(i+67)
    % medium TRIAL 2
    holo_dynamic = ['ID_2_medium_trial2v1_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_medium_trial2v1_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 400;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Medium trial', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, medium trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, medium trial 2 \n',i)
    end
        
end


for i=1:5

    figure(i+70)
    % medium TRIAL 2
    holo_dynamic = ['ID_2_medium_trial2v2_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_medium_trial2v2_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 400;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Medium trial 2', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, medium trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, medium trial 2 \n',i)
    end
        
end


for i=1:15

    figure(i+75)
    % slow TRIAL 2
    holo_dynamic = ['ID_2_medium_trial2v3_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_medium_trial2v3_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 400;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Medium trial 2', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, medium trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, medium trial 2 \n',i)
    end
        
end

%% Fast trials section
% 
for i=1:24
    
    figure(i+90)
    holo_dynamic = ['ID_2_fast_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_fast_', num2str(i), '_POLGroundTruth'];

    % need to check if the field exists, if it does then do this otherwise
    % dont
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 500;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Fast trial', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
        
            fprintf('Not enough Hololens data for trial %i, fast trial \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, fast trial \n',i)
    end
        
end


for i=1:14

    figure(i+114)
    % fast TRIAL 2
    holo_dynamic = ['ID_2_fast_trial2v1_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_fast_trial2v1_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 500;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Fast trial 2', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, fast trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, fast trial 2 \n',i)
    end
        
end


for i=1:2

    figure(i+128)
    % fast TRIAL 2
    holo_dynamic = ['ID_2_fast_trial2v2_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_fast_trial2v2_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 500;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Fast trial 2', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
        else
            fprintf('Not enough Hololens data for trial %i, fast trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, fast trial 2 \n',i)
    end
        
end


for i=1:10

    figure(i+130)
    % slow TRIAL 2
    holo_dynamic = ['ID_2_fast_trial2v3_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_fast_trial2v3_', num2str(i), '_POLGroundTruth'];
    
    if isfield(experiment_data,pol_dynamic) == 1
        Holo_data = experiment_data.(holo_dynamic);
        Pol_data = experiment_data.(pol_dynamic);


        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        y_holo_angular = Holo_data.AngularVelocity;
        if length(y_holo_angular) > 1
            
        more_rowsToDelete =  x_holo > (x_holo(1)+1000);
        rowsToDelete = y_holo_angular < 0 | y_holo_angular > 500;
        y_holo_angular(rowsToDelete) = [];
        x_holo(rowsToDelete) = [];
        y_holo_angular(more_rowsToDelete) = [];
        x_holo(more_rowsToDelete) = [];
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
        yy_holo_angular = spline(x_holo,y_holo_angular,xx_holo);
%         subplot(2,1,1);
        plot(x_holo,y_holo_angular,'o',xx_holo,yy_holo_angular);
%         
        hold on
% 
 % % plot holo data with points and a spline overlaid
 %%% polh data currently too noisy
%         x_pol = seconds(Pol_data.Timestamp);
%         y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
%         
%         rowsToDelete = y_pol < 0 | y_pol > 180;
%         more_rowsToDelete = x_pol > (x_pol(1)+1000);
%         y_pol(more_rowsToDelete) = [];
%         x_pol(more_rowsToDelete) = [];
%         y_pol(rowsToDelete) = [];
%         x_pol(rowsToDelete) = []; 
%         pol_millis(more_rowsToDelete) = [];
%         pol_millis(rowsToDelete) = [];
%         
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v(i) = (y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 100000;
%         end
%         
%         plot(x_pol, v);
% % 
%%%%%% Need to change this to just around the point of catch !!
        avg_vel = mean(y_holo_angular);
        xlabel('Time')
        ylabel('Angular Velocity')
        title('Fast trial 2 v3', avg_vel)
        legend('Holo Data')
%         legend('Holo Data', 'Polh Data')
        
        hold off
              
else
            fprintf('Not enough Hololens data for trial %i, fast trial 2 \n',i)
        end
    else
        fprintf('No polhemus data for trial %i, fast trial 2 \n',i)
    end
        
end




