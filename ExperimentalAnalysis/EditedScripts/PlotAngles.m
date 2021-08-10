clear all; clc; close;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.
ID = 2;
ID = num2str(ID);
ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_ID_';
ID_folder =  [ID_folder ID '\'];
mat_data = ['Data_' ID];

load([ID_folder mat_data])

% %% Plot holo and polhemus data for slow trials
% %slow trials
% for i=1:20
% 
%     figure(i)
% % %     slow if statements
%     if (i~=6)
%     if (i~=9)
%     if (i~=16)
%         
%     holo_dynamic = ['ID_2_slow_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_slow_', num2str(i), '_POLGroundTruth'];
%     
%     Holo_data = experiment_data.(holo_dynamic);
%     Pol_data = experiment_data.(pol_dynamic);
% 
%     % % plot holo data with points and a spline overlaid
%     x_holo = seconds(Holo_data.Timestamp);
%     y_holo = Holo_data.Angle;
%     more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%     rowsToDelete = y_holo < 0 | y_holo > 180;
%     y_holo(rowsToDelete) = [];
%     x_holo(rowsToDelete) = [];
%     y_holo(more_rowsToDelete) = [];
%     x_holo(more_rowsToDelete) = [];
%     steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%     xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%     yy_holo = spline(x_holo,y_holo,xx_holo);
%     plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%     hold on
% 
%     % % plot holo data with points and a spline overlaid
%     x_pol = seconds(Pol_data.Timestamp);
%     y_pol = Pol_data.Angle;
%     rowsToDelete = y_pol < 0 | y_pol > 180;
%     more_rowsToDelete = x_pol > (x_pol(1)+1000);
%     y_pol(more_rowsToDelete) = [];
%     x_pol(more_rowsToDelete) = [];
%     y_pol(rowsToDelete) = [];
%     x_pol(rowsToDelete) = [];
%     plot(x_pol, y_pol);
%     
%     xlabel('Time')
%     ylabel('Angle')
%     legend('Holo Data','Holo Spline', 'Polh Data')
% 
%     hold off
%     
%     end
%     end
%     end
% 
% end
% 
% for i=1:16  
% 
%     figure(i+20)
%     
%     % slow TRIAL 2
%     holo_dynamic = ['ID_2_slow_trial2_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_slow_trial2_', num2str(i), '_POLGroundTruth'];
% 
%     Holo_data = experiment_data.(holo_dynamic);
%     Pol_data = experiment_data.(pol_dynamic);
% 
%     % % plot holo data with points and a spline overlaid
%     x_holo = seconds(Holo_data.Timestamp);
%     y_holo = Holo_data.Angle;
%     more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%     rowsToDelete = y_holo < 0 | y_holo > 180;
%     y_holo(rowsToDelete) = [];
%     x_holo(rowsToDelete) = [];
%     y_holo(more_rowsToDelete) = [];
%     x_holo(more_rowsToDelete) = [];
%     steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%     xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%     yy_holo = spline(x_holo,y_holo,xx_holo);
%     plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%     hold on
% 
%     % % plot holo data with points and a spline overlaid
%     x_pol = seconds(Pol_data.Timestamp);
%     y_pol = Pol_data.Angle;
%     rowsToDelete = y_pol < 0 | y_pol > 180;
%     more_rowsToDelete = x_pol > (x_pol(1)+1000);
%     y_pol(more_rowsToDelete) = [];
%     x_pol(more_rowsToDelete) = [];
%     y_pol(rowsToDelete) = [];
%     x_pol(rowsToDelete) = [];
%     plot(x_pol, y_pol);
%     
%     xlabel('Time')
%     ylabel('Angle')
%     legend('Holo Data','Holo Spline', 'Polh Data')
% 
%     hold off
% 
% end
% 
% for i=1:11 
% 
%     figure(i+36)
%     
%     if (i~=7)
%     % slow TRIAL 2
%     holo_dynamic = ['ID_2_slow_trial2v2_', num2str(i), '_HoloData'];
%     pol_dynamic = ['ID_2_slow_trial2v2_', num2str(i), '_POLGroundTruth'];
% 
%     Holo_data = experiment_data.(holo_dynamic);
%     Pol_data = experiment_data.(pol_dynamic);
% 
%     % % plot holo data with points and a spline overlaid
%     x_holo = seconds(Holo_data.Timestamp);
%     y_holo = Holo_data.Angle;
%     more_rowsToDelete =  x_holo > (x_holo(1)+1000);
%     rowsToDelete = y_holo < 0 | y_holo > 180;
%     y_holo(rowsToDelete) = [];
%     x_holo(rowsToDelete) = [];
%     y_holo(more_rowsToDelete) = [];
%     x_holo(more_rowsToDelete) = [];
%     steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%     xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%     yy_holo = spline(x_holo,y_holo,xx_holo);
%     plot(x_holo,y_holo,'o',xx_holo,yy_holo);
%     hold on
% 
%     % % plot holo data with points and a spline overlaid
%     x_pol = seconds(Pol_data.Timestamp);
%     y_pol = Pol_data.Angle;
%     rowsToDelete = y_pol < 0 | y_pol > 180;
%     more_rowsToDelete = x_pol > (x_pol(1)+1000);
%     y_pol(more_rowsToDelete) = [];
%     x_pol(more_rowsToDelete) = [];
%     y_pol(rowsToDelete) = [];
%     x_pol(rowsToDelete) = [];
%     plot(x_pol, y_pol);
%     
%     xlabel('Time')
%     ylabel('Angle')
%     legend('Holo Data','Holo Spline', 'Polh Data')
% 
%     hold off
%     
%     end
% 
% end

%% Medium trials

for i=1:20

    figure(i)
% %     slow if statements
%     if (i~=6)
%     if (i~=9)
%     if (i~=16)
    print(i)
    holo_dynamic = ['ID_2_medium_', num2str(i), '_HoloData'];
    pol_dynamic = ['ID_2_medium_', num2str(i), '_POLGroundTruth'];
    
    Holo_data = experiment_data.(holo_dynamic);
    Pol_data = experiment_data.(pol_dynamic);

    % % plot holo data with points and a spline overlaid
    x_holo = seconds(Holo_data.Timestamp);
    y_holo = Holo_data.Angle;
    more_rowsToDelete =  x_holo > (x_holo(1)+1000);
    rowsToDelete = y_holo < 0 | y_holo > 180;
    y_holo(rowsToDelete) = [];
    x_holo(rowsToDelete) = [];
    y_holo(more_rowsToDelete) = [];
    x_holo(more_rowsToDelete) = [];
    steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
    xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
    yy_holo = spline(x_holo,y_holo,xx_holo);
    plot(x_holo,y_holo,'o',xx_holo,yy_holo);
    hold on

    % % plot holo data with points and a spline overlaid
    x_pol = seconds(Pol_data.Timestamp);
    y_pol = Pol_data.Angle;
    rowsToDelete = y_pol < 0 | y_pol > 180;
    more_rowsToDelete = x_pol > (x_pol(1)+1000);
    y_pol(more_rowsToDelete) = [];
    x_pol(more_rowsToDelete) = [];
    y_pol(rowsToDelete) = [];
    x_pol(rowsToDelete) = [];
    plot(x_pol, y_pol);
    
    xlabel('Time')
    ylabel('Angle')
    legend('Holo Data','Holo Spline', 'Polh Data')

    hold off
    
    
%     end
%     end
%     end

end
