% Run all paper figures in one script

%% Plot example of markings in the GUI.

% This requires manual interaction in the GUI before printing the figure,
% and resizing of the eps file in e.g. inkscape

% pf_eeglabmarkings; 


%% Run all other figures in the paper.

pf_eigenvalues;         % t = few seconds
pf_movement_artifact;   % t = few seconds
pf_blink_muscle_artifact; % t = few seconds
pf_muscle_only_artifact; % t = few seconds
pf_rank;                % t = about 20 min (10 min per artifact type)
pf_hybriddata;          % t = about 10 min
pf_timelags;            % t = about 10 min
pf_methodtables;        % t = about 25 min


%% Generate strings to paste in LaTeX tables for results of different methods

% Takes a while to run because of ICA computations

% pf_methodtables;      % t = about 25 min

