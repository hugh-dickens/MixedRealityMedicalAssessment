clear all; clc; close;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.
ID = 2;
ID = num2str(ID);
ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\PythonScriptsForExperiment\EditedScripts\Data_ID_';
ID_folder =  [ID_folder ID '\'];
mat_data = ['Data_' ID];

load([ID_folder mat_data])
