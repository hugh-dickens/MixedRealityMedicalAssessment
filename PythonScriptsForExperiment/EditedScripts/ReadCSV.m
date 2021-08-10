clear all;

% Add in a for loop that searches through fast medium and slow trials.
ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\PythonScriptsForExperiment\EditedScripts\Data_ID_2\';
myfiles = dir(ID_folder);
filenames={myfiles(:).name}';
for i = 1:numel(filenames)
    folder_in = strcat(ID_folder,filenames(i));
% folder_in='C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\PythonScriptsForExperiment\EditedScripts\Data_ID_2\fast';                               % directory of interest

    d=dir(fullfile(folder_in{1},'*.csv*'));                        % return the .csv files in the given folder
    var_name = [];
%     filenames{i} = struct();
    for i=1:numel(d)

      % stores all experiment data in a structure with the name of the table as
      % the experimental condition, trial, ID, data type.
      file_name = d(i).name;
      var_name = string([file_name(1:end-4)]);
      var_name = strcat('ID_', var_name);
      data = readtable(fullfile(folder_in{1},d(i).name)); 
      experiment_data.(var_name) = data;
      % do whatever w/ the i-th file here before going on to the next...
    end    
end